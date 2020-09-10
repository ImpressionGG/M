function Gq = tffqtf(Gs,Ts)
%
% tffqtf  Q-transformation.
%
%            Gq = tffqtf(Gs,Ts)
%            Gq = tffqtf(Gz)
%
%         Gq = tffqtf(Gs,Ts)  calculates the q-transform Gq
%         corresponding  to the  continuous system transfer 
%         function Gs and a given sampling period Ts.
%	     If a discrete  system transfer  function Hz is
%	  given, the call Gq = tffqtf(Gz) calculates  the cor-
%	  responding  q-transform  performing	the variable
%	  substitution
%
%			Omega0 + q
%		   z = ------------ ,  Omega0 = 2/Ts
%			Omega0 - q
%
%	  See TFFNEW, TFFZTF.
%
   Gs = tffcan(Gs);
   [class,kind] = ddmagic(Gs);

   if ( kind == 1 )			      % s-domain
      Gs = tffztf(Gs,Ts);        	      % now z-domain
      kind = 2;
   end

   if ( kind == 2 )			      % z-domain
      H = Gs;
      if ( nargin < 2 ) Ts = H(2,1); end
      Om0 = 2/Ts;

      n2 = max(size(H));  n1 = n2-1;		    % degree + 1

      z1 = zeros(n1,n1);  z2 = zeros(n1,n1);
      z1(1,n1) = 1;  z2(1,n1) = 1;
      for (i = 1:n1-1)
	 z1(i+1,:) = conv(z1(i,2:n1), [ 1, Om0]);
	 z2(i+1,:) = conv(z2(i,2:n1), [-1, Om0]);
      end

      z = z2;
      for (i = 1:n1)
	 z(i,:) = conv(z1(i,n2-i:n1),z2(n2-i,i:n1));
      end

      num = zeros(1,n1);  den = num;
      for (i = 1:n1)
	 num = num + H(1,n2+1-i) * z(i,:);
	 den = den + H(2,n2+1-i) * z(i,:);
      end

   else
      error('Bad transfer function kind');
   end

%
% normalize
%
   idx = min( find(abs(den) > eps) );
   if ( max(size(idx)) > 0 )
      num = num / den(idx);  den = den / den(idx);
   end

   Gq = tffnew(num,den,'q',Ts);

% eof
