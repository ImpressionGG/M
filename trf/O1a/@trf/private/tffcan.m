function Gc = tffcan(G,c_epsi)
%
% tffcan  CANCEL transfer function
%
%            Gc = tffcan(G)
%            Gc = tffcan(G,c_epsi)
%
%	  The second argument is the 'cancel epsilon' and is by default
%	  the value of the global variable tfCanEpsi. 
%
%         If the second argument is NaN, e.g. Gc = CAN(G,NaN), only lea-
%         ding zeros are removed.
%
%         See also: TFFNEW, TFFTRIM
%

   global tfCanEpsi

   if ( length(tfCanEpsi) == 0 ) tfCanEpsi = 1e-7; end

   if ( nargin < 2 )
      c_epsi = tfCanEpsi;
   end


   while(G(1,2) == 0 & G(2,2) == 0)
      [ans,n2] = size(G);
      G = [G(:,1) G(:,3:n2)];
   end

   if ( isnan(c_epsi) ) Gc = G; return; end

   dirty = 0;		     % dirty bit
   m = length(G);

   if (m > 1  &  G(1) < 0) G(1) = -G(1);  G(2,:) = -G(2,:); end
   num = G(1,2:m);  den = G(2,2:m);

   if (all(num == 0)) r_num = []; else r_num = roots(num); end
   if ( G(1) == 2 ) [ans,idx1] = sort(abs(r_num));
      else [ans,idx1] = sort(real(r_num));  end
   r_num = r_num(idx1);  deg_num = length(r_num);
   num = num(m-deg_num-1:m-1);

   if (all(den == 0)) r_den = []; else r_den = roots(den); end
   if ( G(1) == 2 ) [ans,idx2] = sort(abs(r_den));
      else  [ans,idx2] = sort(real(r_den));  end
   r_den = r_den(idx2);  deg_den = length(r_den);
   den = den(m-deg_den-1:m-1);

   Gc = tffnew(num,den);
   Gc(:,1) = G(:,1);

   if ( deg_den == 0  |  deg_num == 0 ) return; end

      % calculate distance matrix


   D = [];
   for (i = 1:deg_den)
      D = [D, abs(r_num - r_den(i))];	 % distance matrix
   end

      % prepare cancellation

   idx_den = 1:deg_den;  idx_num = 1:deg_num;

   for (j = 1:deg_den)
      found = find( abs(D(:,j)) < c_epsi );
      for ( k = 1:length(found) )
	 i = found(k);
	 if ( idx_num(i) ~= 0  &  idx_den(j) ~= 0 )
	    dirty = 1;
	    re = real(r_num(i));  im = imag(r_num(i));
	    fprintf('cancel: %g',re);
	    if ( abs(im) > eps )
	       if ( im > 0)
		  fprintf(' + i %g',im);
	       else
		  fprintf(' - i %g',-im);
	       end
	    end
	    % re = real(r_num(i));  im = imag(r_num(i));
	    re = real(r_den(j));  im = imag(r_den(j));
	    fprintf(' <--> %g',re);
	    if ( abs(im) > eps )
	       if ( im > 0)
		  fprintf(' + i %g',im);
	       else
		  fprintf(' - i %g',-im);
	       end
	    end
	    fprintf('\n');
	    idx_num(i) = 0;  idx_den(j) = 0;  break;
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
	 if ( deg_num <= deg_den )
	    [ans1,ans2,K] = tf2zp(num,den);   % get gain K
	 else
	    [ans1,ans2,K] = tf2zp(den,num);   % get gain K
	    K = 1/K;
	 end
      end

% new numerator and denominator

      [num,den] = zp2tf(r_num(idx_num),r_den(idx_den),K);

      if ( length(num) == 0 ) num = 1; end	   % V1.0a
      if ( length(den) == 0 ) den = 1; end	   % V1.0a

% new K factor (K1)			  % V1.0a

      if ( all(num == 0)  &  all( den == 0 ) )
	 K1 = NaN;
      elseif ( all(num == 0) )
	 K1 = 0;
      elseif ( all(den == 0) )
	 K1 = inf;
      else
	 if ( deg_num <= deg_den )
	    [ans1,ans2,K1] = tf2zp(num,den);   % get gain K
	 else
	    [ans1,ans2,K1] = tf2zp(den,num);   % get gain K
	    K1 = 1/K1;
	 end
      end

% construct new transfer function

      Gc = tffmul(K/K1,tffnew(num,den));		% V1.0a
      Gc(:,1) = G(:,1);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Rev   Date        Who   Comment
%  ---   ---------   ---   --------------------------------------------
%    0   19-Nov-93   hux   Version 2.0
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
