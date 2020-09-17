function [a0,a1,M,N,omega,zeta] = modal(o,num,den)
%
% MODAL   Modal representation of a rational function
%
%            [a0,a1,M,N] = modal(o,num,den)
%
%            [a0,a1,M,N,omega,zeta] = modal(o,num,den)
%
%         Alternatively a corasim state space system can be generated
%
%            oo = modal(o,num,den)
%            [A,B,C,D] = 
%
%         Find modal representation of a rational function
%
%                     p(s)
%            G)s) = --------- = (s*N' + M') * diag{psi_i(s)^-1} * M
%                     q(s)
%
%                    n           rho_i(s)
%            G(s) = Sum {M(i) * ----------}  with rho_i(s) := N(i)*s + M(i)
%                   i=1          psi_i(s)
%
%                    n   M(i)^2        n         M(i)^2
%                 = Sum ---------  =  Sum ----------------------
%                   i=1  psi_i(s)     i=1  s^2 + a1(i)*s + a0(i)
%         with
%
%            psi_i(s) := s^2 + a1(i)*s + a0(i)
%
%         to get nx1 vectors M,a1 and a0 fo a state space representation
%
%            .
%            x1 = x2
%            .
%            x2 = -diag(a0)*x1 - diag(a1)*x2 + M*u
%
%            y  = M'*x1 + N'*x2 + D*u
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, SIMU
%
   if (nargin == 3)
      [a0,a1,M,N,omega,zeta] = Modal(o,num,den);
   else
      error('1 or 3 input args expected');
   end
   
   if (nargout <= 1)
      n = length(a0);
      A21 = -diag(a0);  A22 = -diag(a1);  
      A = [zeros(n),eye(n); A21 A22];
      B = [0*N; M];  C = [M', N'];  D = 0;
      
      oo = system(o,A,B,C,D);
      oo = var(oo,'a0,a1,M,N,omega,zeta',a0,a1,M,N,omega,zeta);
      a0 = oo;                         % output arg1
   end
end

%==========================================================================
% Modal Decomposition
%==========================================================================

function [a0,a1,M,N,omega,zeta] = Modal(o,num,den)
   num = Trim(o,num);                  % remove leading numerator zeros
   den = Trim(o,den);                  % remove leading denominator zeros
   
   if length(num) >= length(den)
      error('num/den must be strictly proper (deg(num) < deg(den)');
   end
   
      % make a root check: all poles must be either zero or have to be
      % complex (with non zero imaginary parts)
      
   r = roots(den);
   n = floor(length(r)/2);
   
   if (2*n ~= length(r))
      error('even number of poles required');
   end
   
   if any(r~=0 & imag(r)==0)
      error('cannot deal with nonzero real poles');
   end
   
      % ok so far - we can start now our actual job!
      % start with calculation of a0,a1 (omega,zeta) ...
      
   for (i=1:n)                         % for all complex pole pairs
      ri = r(2*i-1);
      rj = r(2*i);
      
         % identify psi(s) polynomial
         
      psi = conv([1 -ri],[1 -ri']);
      Psi(i,1:3) = psi;               % assemble Psi matrix

      if any(imag(psi) ~= 0)
         error('cannot identify complex conjugate pole pairs');
      end
      
      a1(i,1) = psi(2);  a0(i,1) = psi(3);
      omega = sqrt(a0);  zeta = a1./omega/2; 
   end
   
      % now calculate coefficients of M vector
      
   for (i=1:n)
      psi = Psi(i,:);                  % characteristic factor
      
         % build qi(s) = q(s) / psi_i(s)
         % i.e.: qi(s) = psi_1(s) * ... * psi_n(s)  (i ~= j)
         
      qi = 1;
      for (j=1:n)
         if (j ~= i)
            qi = conv(qi,Psi(j,:));
         end
      end
      
         % now we have reduced qi(s) = q(s) / psi_i(s) 
         
      ri = roots(psi);                 % roots of characteristic factor
      ps = [Eval(o,num,ri(1)) Eval(o,num,ri(2))];
      qs = [Eval(o,qi ,ri(1)) Eval(o,qi ,ri(2))];
      c = ps ./ qs;
      
         % ci is a 2-row containing conjugate complex residual coefficients
         % next step is to calculate the residual factor
         
      ci = conv([1 -c(1)],[1 -c(2)]);
      if any(imag(ci)~=0)
         fprintf('*** warning: numerical issues (2)\n');
      end
      
         % calculate M and N vectors 
         
      c1 = ci(2);  c0 = ci(3);
      if (c0 == 0)
         M(i,1) = 0;  N(i,1) = 0;
      else
         M(i,1) = sqrt(c0);  N(i,1) = c1/M(i); 
      end
   end
end

%==========================================================================
% Polynomial Division
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
function z = Add(o,x,y)                % Add Polynomials               
   nx = length(x);  ny = length(y);  n = max(nx,ny);
   z = [zeros(1,n-nx) x] + [zeros(1,n-ny) y];
end
function z = Mul(o,x,y)                % Multiply Polynomials          
   z = conv(x,y);
end
function [q,r] = Div(o,x,y)            % Divide Polynomials            
   x = Trim(o,x);                      % remove trailing zeros
   y = Trim(o,y);                      % remove trailing zeros
   
      % if degree y is greater than degree of x then division result is
      % zero and remainder equals x (and we are done)
      
   if (length(y) > length(x))
      q = 0;                           % divison result equals zero
      r = x;                           % return dividend as the remainder
      return                           % and we are done - bye!
   end
   
      % otherwise the hard job begins ...
      
   q = [];  r = 0;
   l = length(x) - length(y);          % degree difference (must be >= 0)
   assert(l >= 0);
   
   r = x;                              % initial remainder
   for (j=l:-1:0)
      q(end+1) = r(1)/y(1);
      p = [q(end)*y zeros(1,j)];       % p = q(end)*y << j
      
      r = r - p;
      r = r(2:end);
   end
   
      % final check: x = q*y + r, or r-x + q*y = 0
    
   ok = Add(o,Add(o,r,-x),Mul(o,q,y));
   if norm(ok) > 1e5*eps
      fprintf('*** warning: bad conditioned poly division (1)\n');
   end
end
function x = Eval(o,p,s)               % Eval Polynomial p(s)          
   p = Trim(o,p);                      % trim polynomial
   n = length(p)-1;                    % polynomial order
   powers = n:-1:0;                    % powers of s
   s = s.^powers;                      % raise s to the powers
   x = s*p(:);                         % p(n)*s^n + ... + p(0)*s^0
end


