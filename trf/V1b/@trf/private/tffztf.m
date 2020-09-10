function Hz = tffztf(Gs,Ts)
%
% TFFZTF  z-transformation. Hz = tffztf(Gs,Ta)  calculates the
%	  z-transform Hz  corresponding  to the  continuous
%	  system transfer function Gs and a given sampling
%	  period Ts.
%	     If a discrete system q-transfer function Gq is
%	  given, the call Hz = tffztf(Gq) calculates  the cor-
%         responding  z-transform  performing	the variable
%	  substitution
%
%			       z - 1
%		   q = Omega0 ------- ,   Omega0 = 2/Ts
%			       z + 1
%
%	  See TFFNEW, TFFQTF.
%
   Gs = tffcan(Gs);
   [class,kind] = ddmagic(Gs);

   if ( kind == 1 )			      % s-domain

      if ( nargin < 2 ) error('Sampling Time (arg2) missing'); end

      n1 = max(size(Gs)) - 1;		      % degree + 1
      num = Gs(1,2:n1+1);  den = Gs(2,2:n1+1);

      [A,B,C,D] = tf2ss(num,den);
      [Phi,H] = c2d(A,B,Ts);
      [num,den] = ss2tf(Phi,H,C,D,1);

   elseif ( kind == 3 )		      % z-domain

      Gq = Gs;
      if ( nargin < 2 ) Ts = Gq(2,1); end
      Om0 = 2/Ts;

      n2 = max(size(Gq));  n1 = n2-1;		     % degree + 1

      q1 = zeros(n1,n1);  q2 = zeros(n1,n1);
      q1(1,n1) = 1;  q2(1,n1) = 1;
      for (i = 1:n1-1)
	 q1(i+1,:) = conv(q1(i,2:n1), [Om0, -Om0]);
	 q2(i+1,:) = conv(q2(i,2:n1), [  1,    1]);
      end

      q = q2;
      for (i = 1:n1)
	 q(i,:) = conv(q1(i,n2-i:n1),q2(n2-i,i:n1));
      end

      num = zeros(1,n1);  den = num;
      for (i = 1:n1)
	 num = num + Gq(1,n2+1-i) * q(i,:);
	 den = den + Gq(2,n2+1-i) * q(i,:);
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

   Hz = tffnew(num,den,'z',Ts);

% eof
