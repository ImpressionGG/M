function [num,den] = ss2tf(o,A,B,C,D,iu) % State Space to Transfer Fct.
%
%   SS2TF	Variable precision state-space to rational transfer function
%           conversion.
%
%	            [num,den] = SS2ZP(o,A,B,C,D,iu)
%
%           calculates the transfer function in factored form
%
%			                   -1            bm*s^m + ... + b1*s + b0 
%		         G(s) = C(sI-A) B + D =  k --------------------------
%			                                   s^n + ... + a1*s + a0
%	         of the system:
%		         .
%		         x = Ax + Bu
%		         y = Cx + Du
%
%	         from the iu'th input.  Vector den contains the coefficients of
%           the denominator in descending powers of s.  The numerator 
%           coefficients are returned in matrix num with as many rows as
%           there are outputs 
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CORASIM, TRF, SYSTEM, SS2ZP
%
   o.argcheck(5,6,nargin);
   o.abcdcheck(A,B,C,D);

   n = length(A);                    % system order
   ni = size(B,2);                   % number of inputs
   no = size(C,1);                   % number of outputs
   
   if (nargin < 6 && ni > 1)
      error('arg6 missing since number of inputs > 1');
   elseif (nargin < 6)
      iu = 1;
   end
   
      % convert to VPA matrices
      
   A = vpa(A);  B = vpa(B);  C = vpa(C);  D = vpa(D); 
   B = B(:,iu);
   D = D(:,iu);
      
   den = polynom(o,A);
      
   num = vpa(ones(no, n+1));
   
   for i=1:no
      num(i,:) = polynom(o,A-B*C(i,:)) + (D(i) - 1) * den;
   end
end

