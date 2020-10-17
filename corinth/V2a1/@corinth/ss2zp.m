function [Z,P,K] = ss2zp(o,A,B,C,D,iu) % State Space to Zero/Pole      
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
   
      % convert to VPA matrices and select relevant input
      
   A = vpa(A);  B = vpa(B);  C = vpa(C);  D = vpa(D); 
   B = B(:,iu);
   D = D(:,iu);

      % do poles and denominator first, they're easy
      
   P = eig(A);
   den = Trim(o,polynom(o,A));
   
      % now try zeros, they're harder
      
   Z = vpa(zeros(n,no) + inf);		  % set whole Z matrix to infinities
   
      % loop through outputs, finding zeros
      
   for i=1:no
      Mi = A - B*C(i,:);
      numi = polynom(o,Mi) + (D(i) - 1) * den;
      numi = Trim(o,numi);
      
      zi = roots(numi);      
      Z(1:length(zi),i) = zi.';
      
      K(1,i) = numi(1)/den(1);
   end
end

%==========================================================================
% Helper
%==========================================================================

function y = Trim(o,x)                 % Trim Mantissa                 
%
% TRIM    Trim mantissa: remove leading mantissa zeros
%
   idx = find(x~=0);
   if isempty(idx)
      y = 0;
   else
      y = x(idx(1):end);
   end
end

