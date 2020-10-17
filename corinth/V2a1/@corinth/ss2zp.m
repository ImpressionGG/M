function [Z,p,K] = ss2zp(o,A,B,C,D,iu) % State Space to Zero/Pole      
%
%   SS2ZP	Variable precision state-space to zero-pole conversion.
%
%	            [z,p,k] = SS2ZP(o,A,B,C,D,iu)  factored transfer function
%
%           calculates the transfer function in factored form
%
%			                   -1           (s-z1)(s-z2)...(s-zn)
%		         G(s) = C(sI-A) B + D =  k ---------------------
%			                                (s-p1)(s-p2)...(s-pn)
%	         of the system:
%		         .
%		         x = Ax + Bu
%		         y = Cx + Du
%
%	         from the iu'th input.  Vector p contains the pole locations of 
%           the denominator of the transfer function.  The numerator zeros
%           are returned in the columns of matrix z with as many columns as
%           there are outputs y. The gains for each numerator transfer 
%           function are returned in column vector k.
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CORASIM, TRF, SYSTEM, ZP2TF
%
   o.argcheck(5,5,nargin);
   o.abcdcheck(A,B,C,D);
   
   if (nargin < 6)
      iu = 1:size(B,2);
   end

   
      % remove relevant input
      
   B = B(:,iu);
   D = D(:,iu);

      % conversion of state space to zero/pole/K representation
      
   A = vpa(A);  B = vpa(B);  C = vpa(C);  D = vpa(D);
   [Z,P,K] = Diag(o,A,B,C,D);           % diagonalizing based conversion
end

%==========================================================================
% Diagonalizing Based Conversion to Zero/Pole Representation
%==========================================================================

function [Z,P,K] = Diag(o,A,B,C,D)     % Diagonalizing Based Conversion
%
% DIAG    Diagonalizing based conversion of a state space representation
%         to zero/pole/K representation.
%
%            [Z,P,K] = Diag(o,A,B,C,D)
%
%         Original system:
%
%            x`= A*x + B*u    | inv(T)*
%            y = C*x + D*u
%
%         Transform: x = T*z => z' = T\x,  S := T\A*T
%
%            z`= T\x`= T\A*(T*z) + T\B*u
%            y = C*(T*z) + D*u
%
%         Diagonal system:
%
%            z`= (T\A*T)*z + (T\B)*u  =  S*z  + Bs*u   => Bs := T\B
%            y = (C*T)  *z +   D  *u  =  Cs*z + D*u    => Cs := C*T 
%
%         i/j-th transfer function
%
%            wij = C(i,:)*B(:,j).'     % i/j-th weight vector
%            Gij(s) = wij(1)/(s-p(i)) + ... + wij(n)/(s-p(n)) + D(i,j)
%
%         For full C-matrix:
%
%            Wj = C*B(:,j).'           % j-th weight matrix
%            Gj(s) = Wj(1)/(s-p(i)) + ... + Wj(n)/(s-p(n)) + D(:,j)
%

      % do poles first, they're easy
      
   [T,S] = eig(A);                     % S = T\A*T
   P = diag(S);                        % poles
   
   Bs = T\B;                           % transformed input matrix
   Cs = C*T;                           % transformed output matrix
   
      % get numerator polynomial
      
   n = length(P);                      % system order  
   num = zeros(1,n);                   % init numerator

      % calculate weight matrix
j=1;      
   Bj = ones(n,1)*Bs(:,j).';
   Wj = Cs .* Bj;
   
   for (i=1:n)
      numi = 1;                        % init i-th numerator
      for (k=1:n)
         if (i == k)
            continue;                  % don't multiply this factor
         end
         psik = [1 -P(k)];             % psik(s) = (s - pole(k))
         numi = conv(o,numi,psik);     % product over almost all psii(s) 
      end
      
      numi = Wj(i)*numi;
      
            % add-up numerator
            
      ni = length(numi);
      num = num + [zeros(1,n-ni), numi];
   end
   
      % add D-part
      
   num = [0 num] + D(:,j)*Poly(o,P);
end

%==========================================================================
% Markov Parameter Based Conversion to Zero/Pole Representation
%==========================================================================
   
function [Z,p,K] = Markov(o,A,B,C,D,iu)% Markov Parameter Based        

      % do poles first, they're easy
      
   p = eig(A);

      % now try zeros, they're harder
      
   [no,ns] = size(C);
   Z = zeros(ns,no) + inf;		         % set whole Z matrix to infinities
   
      % loop through outputs, finding zeros
      
   for i=1:no
      S1 = [A B;C(i,:) D(i,:)];
      S2 = diag([ones(1,ns) 0]);
      Zv = eig(S1,S2);
      
         % now put NS valid zeros into Z. There will always be at least one
         % NaN or infinity
         
%     zv = zv((zv ~= nan)&(zv ~= inf));
      Zv = Zv((~isnan(Zv)) & (~isinf(Zv)));
      if length(Zv) ~= 0
         Z(1:length(Zv),i) = Zv;
      end
   end

      % now finish up by finding gains using Markov parameters
      
   K = d;  CAn = C;
   while any(K==0)	                  % do until all k's are finished
      markov = CAn*B;
      i = find(K==0);
      K(i) = markov(i);
      CAn = CAn*A;
   end
end

%==========================================================================
% Helper
%==========================================================================

function c = Poly(o,x)                 % Convert Roots to Polynomial   
%
% POLY  Convert roots to polynomial.
%       POLY(A), when A is an N by N matrix, is a row vector with
%       N+1 elements which are the coefficients of the
%       characteristic polynomial, det(lambda*eye(size(A)) - A).
%
%       POLY(V), when V is a vector, is a vector whose elements are
%       the coefficients of the polynomial whose roots are the
%       elements of V. For vectors, ROOTS and POLY are inverse
%       functions of each other, up to ordering, scaling, and
%       roundoff error.
%
%       Examples:
%
%          roots(poly(1:20)) generates Wilkinson's famous example.
%
%       Class support for inputs A,V: double, single, sym
%
%       See also ROOTS, CONV, RESIDUE, POLYVAL.
%
   [m,n] = size(x);
   if m == n                           % square matrix?
      e = eig(x);                      % Characteristic polynomial
   elseif (m==1) || (n==1)
      e = x;
   else
      error(message('MATLAB:poly:InputSize'))
   end

      % Strip out infinities
      
   e = e(isfinite(e));

      % Expand recursion formula
      
   n = length(e);
   c = [1 zeros(1,n,class(x))];
   for j=1:n
       c(2:(j+1)) = c(2:(j+1)) - e(j).*c(1:j);
   end

      % The result should be real if the roots are complex conjugates.
      
   if isequal(sort(e(imag(e)>0)),sort(conj(e(imag(e)<0))))
       c = real(c);
   end
end

