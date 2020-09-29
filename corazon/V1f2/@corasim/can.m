function oo = can(o,x,y)               % Cancel Common Factors         
%
% CAN   Cancel transfer function, occasionally convert state space system
%       to num/den 
%
%          oo = can(o)                 % cancel object
%
%       Options ('tff' type only):
%
%          eps:              cancellation epsilon (default: 1e-7)
%
%       See also: CORASIM, TRIM, FORM
%
   oo = CanTrf(o);
end

%==========================================================================
% Cancel Trf
%==========================================================================

function oo = CanTrf(o)                % Cancel Transfer Function          
   oo = o;                             % just in case
   caneps = opt(o,{'eps',1e-3});
   
      % calculate numerator and denominator roots
      
   [rnum,rden] = Roots(o,1);
   dirty = 0;		     % dirty bit

   degnum = length(rnum);
   degden = length(rden);
   
   if ( degden == 0  ||  degnum == 0 ) 
      oo = o;
      return; 
   end

      % calculate distance matrix

   D = [];
   for (i = 1:degden)
      avg = abs((rnum + rden(i))/2);
      dT = abs(rnum - rden(i));
      idx = find(avg > eps);
      if ~isempty(idx)
         dT(idx) = dT(idx) ./ avg(idx);
      end
      D = [D, dT];	 % distance matrix
   end

      % prepare cancellation

   idx_den = 1:degden;  idx_num = 1:degnum;

   for (j = 1:length(rden))
      
      delta = abs(D(:,j));
      found = find( delta < caneps );  
      
      for ( k = 1:length(found) )
	      i = found(k);
         
	      if ( idx_num(i) ~= 0  &  idx_den(j) ~= 0 )
	         dirty = 1;
	         re = real(rnum(i));  im = imag(rnum(i));
	         fprintf('cancel: %g',re);
	         if ( abs(im) > eps )
	            if ( im > 0)
		            fprintf(' + i %g',im);
               else
		            fprintf(' - i %g',-im);
               end
            end
            
            % re = real(r_num(i));  im = imag(r_num(i));
	         re = real(rden(j));  im = imag(rden(j));
	         fprintf(' <--> %g',re);
	         if ( abs(im) > eps )
	            if ( im > 0)
		            fprintf(' + i %g',im);
               else
		            fprintf(' - i %g',-im);
               end
            end
	         fprintf(' (delta: %g)\n',delta(i));
	         idx_num(i) = 0;
            idx_den(j) = 0;
            break;
	      end
      end
   end

   if ( dirty ~= 0 )
      idx_num(find(idx_num == 0)) = [];
      idx_den(find(idx_den == 0)) = [];

         % K factor

      if ( all(num == 0)  &  all( den == 0 ) )
	      K = NaN;
      elseif ( all(num == 0) )
	      K = 0;
      elseif ( all(den == 0) )
	      K = inf;
      else
	      if ( degnum <= degden )
	         [ans1,ans2,K] = tf2zp(num,den);   % get gain K
         else
	         [ans1,ans2,K] = tf2zp(den,num);   % get gain K
	          K = 1/K;
         end
      end

         % new numerator and denominator

      [num,den] = zp2tf(rnum(idx_num),rden(idx_den),K);

      if ( length(num) == 0 ) num = 1; end	   % V1.0a
      if ( length(den) == 0 ) den = 1; end	   % V1.0a

         % new K factor (K1)

      if ( all(num == 0)  &  all( den == 0 ) )
	      K1 = NaN;
      elseif ( all(num == 0) )
	      K1 = 0;
      elseif ( all(den == 0) )
	      K1 = inf;
      else
	      if ( degnum <= degden )
	         [ans1,ans2,K1] = tf2zp(num,den);   % get gain K
         else
	         [ans1,ans2,K1] = tf2zp(den,num);   % get gain K
	         K1 = 1/K1;
	      end
      end
      
      num = K/K1*num;
   end
   
      % normalize to denominator coefficien
      
   cn = den(1);
   if (cn ~= 0 && cn ~= 1)
      num = num/cn;                    % normalize numerator
      den = den/cn;                    % normalize denominator
   end
   
         % poke num/den back to transfer function

   oo = poke(o,num,den);
   
   function [rnum,rden] = Roots(o,mode) % Get Roots of Transfer Function
      [num,den] = peek(o);
      
         % numerator roots
         
      if (all(num == 0)) 
         rnum = []; 
      else
         rnum = roots(num);
      end

         % denominator roots
      
      if ( mode == 1 )
         [ans,idx1] = sort(abs(rnum));
      else
         [ans,idx1] = sort(real(rnum));
      end
      rnum = rnum(idx1);               % re-order numerator roots

      %num = num(m-deg_num-1:m-1);

         % denominator roots

      if (all(den == 0))
         rden = []; 
      else
         rden = roots(den);
      end
      
         % sort denominator roots
         
      if ( mode == 1 ) 
         [~,idx2] = sort(abs(rden));
      else
         [~,idx2] = sort(real(rden));
      end
      rden = rden(idx2);               % re-order denominator roots
   end
end
