function oo = can(o,eps)               % Cancel Common Factors         
%
% CAN   Cancel transfer function, occasionally convert state space system
%       to num/den 
%
%          oo = can(o)                 % cancel object
%          oo = can(o,eps)             % cancel @ specific cancel epsilon
%
%       Options ('tff' type only):
%
%          eps:              cancellation epsilon (default: 1e-7)
%
%       See also: CORASIM, TRIM, FORM
%
   if (nargin >= 2)
      o = opt(o,'eps',eps);
   end
   
   oo = CanTrf(o);
end

%==========================================================================
% Cancel Trf
%==========================================================================

function oo = CanTrf(o)                % Cancel Transfer Function          
   oo = o;                             % just in case
   caneps = opt(o,{'eps',1e-7});
   
      % calculate numerator and denominator roots
      
   [rnum,rden] = Roots(o,1);
   dirty = 0;		     % init dirty state

   degnum = length(rnum);
   degden = length(rden);
   
   if ( degden == 0  ||  degnum == 0 ) 
      oo = trim(o);
      return; 
   end

      % calculate relative distance matrix D: 
      %
      %    D := [D(i,j)] = [dr(i,j)/r(i,j)]
      %
      % with
      %
      %    dr(i,j) = abs(zero(j)-pole(i))
      %    r(i,j)  = abs(zero(j)+pole(i))

   D = [];
   for (i = 1:degden)
      r = abs((rnum + rden(i))/2);     % mean absolute value
      dr = abs(rnum - rden(i));        % absolute value of distance
      idx = find(r > eps);
      if ~isempty(idx)
         dr(idx) = dr(idx) ./ r(idx);
      end
      D = [D, dr];	 % distance matrix
   end

      % prepare cancellation

   idx_den = 1:degden;  idx_num = 1:degnum;

   for (j = 1:length(rden))
      
      delta = abs(D(:,j));
      found = find( delta < caneps );  
      
      for ( k = 1:length(found) )
	      i = found(k);
         
	      if ( idx_num(i) ~= 0  &  idx_den(j) ~= 0 )
            Cancel(o);                    % cancel pole/zero
            break;
	      end
      end
   end

      % if some cancellation happened then we have a dirty state
      % which has to be handeled ...
      
   if ( dirty ~= 0 )
      HandleDirty(o);
   end
   
      % normalize to denominator coefficien
      
   cn = den(1);
   if (cn ~= 0 && cn ~= 1)
      num = num/cn;                    % normalize numerator
      den = den/cn;                    % normalize denominator
   end
   
         % poke num/den back to transfer function

   oo = poke(o,num,den);
   oo = trim(oo);
   
   function [rnum,rden] = Roots(o,mode)% Get Transfer Function Roots   
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
   function HandleDirty(o)             % Handle Dirty Status           
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
   function Cancel(o)                  % Cancel Pole/Zero              
      dirty = 1;
      idx_num(i) = 0;
      idx_den(j) = 0;

      if (control(o,{'verbose',1}) > 0)
         re = real(rnum(i));  im = imag(rnum(i));
         fprintf('cancel: %g',re);

         if ( abs(im) > eps )
            if ( im > 0)
               fprintf(' + i %g',im);
            else
               fprintf(' - i %g',-im);
            end
         end

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
      end
   end
end
