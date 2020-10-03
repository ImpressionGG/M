function [a0,a1,M,N,omega,zeta] = modal(o,num,den,varargin)                     
%
% MODAL   Modal representation of a rational function
%
%            oo = modal(o)             % transform to modal form
%            [a0,a1,B,C,D] = modal(o)  % Get modal matrices
%
%            oo = modal(o,a0,a1,B,C,D) % create modal system
%
%            [a0,a1,M,N] = modal(o,num,den)
%
%            [a0,a1,M,N,omega,zeta] = modal(o,num,den)
%
%         Alternatively a corasim state space system can be generated
%
%            oo = modal(o,num,den)
%            [A,B,C,D] = data(oo,'A,B,C,D')
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
   if (nargin == 1 && nargout <= 1)
      oo = Transform(o);
      a0 = oo;                         % rename out arg
      return                           % and bye!
   elseif (nargin == 6 && nargout <= 1)
      a0 = num;  a1 = den;             % rename input args
      B = varargin{1};                 % rename input arg
      C = varargin{2};                 % rename input arg
      D = varargin{3};                 % rename input arg
      oo = Create(o,a0,a1,B,C,D);
      a0 = oo;                         % rename out arg
      return                           % and bye!
   elseif (nargin == 3)
      oo = Modal(o,num,den);
   else
      error('1 or 3 input args expected');
   end
 
   [a0,a1,M,N,omega,zeta] = var(oo,'a0,a1,M,N,omega,zeta');
    
   if (nargout <= 1)
      n = length(a0);
      A21 = -diag(a0);  A22 = -diag(a1);  
      A = [zeros(n),eye(n); A21 A22];
      B = [0*N; M];  C = [M', N'];  D = 0;
      
      oo = system(oo,A,B,C,D);
      a0 = oo;                         % output arg1
   end
end

%==========================================================================
% Transform To Modal Representation
%==========================================================================

function oo = Transform(o)             % Transform to Modal Form       
   oo = system(o);                     % cast to state space system
   [A,B,C,D] = system(oo);
   
   n = floor(length(A)/2);
   m = size(B,2);
   l = size(C,1);
   
   if (2*n ~= length(A))
      error('modal transformation is based on even system dimension\n ');
   end
   
      % diagonalize the system (we assume that all eigenvalues are
      % distinct and the transformation matrix is well conditioned
      
   [Tc,Q] = eig(A);
   Ad = Tc\A*Tc;  
   Bd = Tc\B;  
   Cd = C*Tc;  
   Dd = D;
   
   err = norm(Ad-Q);                   % just check numeric quality
   if abs(err) > 1e-10
      fprintf('*** warning: bad conditioned modal transformation (Q)\n');
   end
   
      % check whether eigenvales are in proper order
      
   k1 = 1:2:2*n-1;                     % indexing kind#1 eigenvalues
   k2 = 2:2:2*n;                       % indexing kind#2 eigenvalues

   s = diag(Q);                        % all eigenvalues
   s1 = s(1:2:2*n-1);                  % unique eigenvalues
   s2 = s(2:2:2*n);                    % conjugate complex eigenvalues
   
      % check eigenvalue consistency
      
   if (any(real(s1)~=real(s2)))
      error('mismatch: real parts of eigenvalues');
   end
   if (any(imag(s1)~=-imag(s2)))
      error('mismatch: imaginary parts of eigenvalues');
   end
   
      % very good - all eigenvalues are consistent
      % transform now to real coefficient matrices

   Z = zeros(2*n);
   Tr = Z; invTr = Z;                  % trafo matrix to real block form
   Ts = Z; invTs = Z;                  % trafo matrix to canonic form
   Tp = Z;                             % permutation matrix (unitary)
   
   Tk = [1 sqrt(-1); 1 -sqrt(-1)];  invTk = inv(Tk);
   AA = Z; BB = [];  CC = [];  DD = D;
   for (k=1:n)
      idx = 2*k-1:2*k;
      Tr(idx,idx) = Tk;
      invTr(idx,idx) = invTk;
      
         % get block matrices (block index k)
         
      Qk = diag(s(idx));               % diagonal block (complex)
      Ak = Tk\Qk*Tk;                   % dynamic matrix block
      Bk = Tk\Bd(idx,:);               % input matrix block
      Ck = Cd(:,idx)*Tk;               % output matrix block
      
      err = norm(imag(Ak)) + norm(imag(Bk)) + norm(imag(Ck));
      if (err > 1e-10)
         fprintf('*** warning: bad conditioned modal blocks\n');
      end
      
         % make it truely real
         
      Ak = real(Ak);  Bk = real(Bk);  Ck = real(Ck);
      
         % transform to controller normal form
         % transform to controllable canonic form
      
      bk = Bk(:,1);                    % first trial      
      Q = [bk Ak*bk];
      t = ([0 1]/Q)';
      Tq = [t'; t'*Ak];

         % if trafo Tc is singular then set bk = [1,1,...,1]' and
         % try another time ...
         
      if abs(det(Tq)) < 1e-10
         bk = [1;1];                   % let bk be a fictive input matrix
         Q = [bk Ak*bk];
         t = ([0 1]/Q)';
         Tq = [t'; t'*Ak];
      end

         % now we should have the canonical form [Ac,Bc,Cc,Dc]
         
      Aq = Tq*Ak/Tq;  Bq = Tq*Bk;  Cq = Ck/Tq; 
      
         % build-up a0 and a1 vector
         
      a0(k) = -Aq(2,1);  a1(k) = -Aq(2,2);
      AA(n+k,k) = a0(k);  AA(n+k,n+k) = a1(k);  AA(k,n+k) = 1;
      BB(k,1:m) = Bq(1,:);
      BB(n+k,1:m) = Bq(2,:);
      CC(:,k) = Cq(:,1);
      CC(:,n+k) = Cq(:,2);
      
         % build total transformation matrix for final check
         
      Ts(idx,idx) = inv(Tq);           % trafo to canonical form
      invTs(idx,idx) = Tq;
      
      Tp(k,2*k-1) = 1;                 % final permutation trafo
      Tp(n+k,2*k) = 1;
   end
   
   Ar = Tr\Ad*Tr;  Br = Tr\Bd;  Cr = Cd*Tr;  Dr = Dd;
   
      % check numeric quality
      
   if (norm(imag(Ar)) > 1e-10)
      fprintf('*** warning: bad conditioned modal transformation (A)\n');
   end
   if (norm(imag(Br)) > 1e-10)
      fprintf('*** warning: bad conditioned modal transformation (B)\n');
   end
   if (norm(imag(Cr)) > 1e-10)
      fprintf('*** warning: bad conditioned modal transformation (C)\n');
   end
      
      % take real parts (to have clean matrices)
      
   Ar = real(Ar);  Br = real(Br);  Cr = real(Cr);  Dr = real(Dr);
   oo = system(corasim,Ar,Br,Cr,Dr);   % for debug
   
      % transform to canonical form
      
   As = invTs*Ar*Ts; Bs = invTs*Br;  Cs = Cr*Ts;  Ds = Dr;
   
      % modal matrix through permutation
      
   Am = Tp\As*Tp;  Bm = Tp\Bs;  Cm = Cs*Tp;  Dm = Ds;
   
      % build total transformation and check
      
   Tt = Tc*Tr*Ts*Tp;
   At = Tt\A*Tt;  Bt = Tt\B;  Ct = C*Tt;  Dt = D;

      % final checks
      
   errA = norm(Am-At);  errB = norm(Bm-Bt);  
   errC = norm(Cm-Ct);  errD = norm(Dm-Dt);
   
   if (errA+errB+errC+errD > 1e-10)
      fprintf('*** warning: modal transformation ill conditioned\n');
   end
   
      % build final system and provide trafo matrices as variables
      %    Tt: total trafo
      %    Tc: trafo from original system to (complex) diagonal system
      %    Tr: trafo from (complex) diagonal system to real block system
      %    Ts: trafo from real block system to canonical system
      %    Tp: trafo for final permutation
      
   oo = modal(oo,a0,a1,Bm,Cm,Dm);
   oo = var(oo,'Tt,Tc,Tr,Ts,Tp,a0,a1,B,C,D',Tt,Tc,Tr,Ts,Tp,a0,a1,Bm,Cm,Dm);
end

%==========================================================================
% Create Modal System
%==========================================================================

function oo = Create(o,a0,a1,B,C,D)
   a0 = a0(:);  a1 = a1(:);
   
   if any(size(a0)~=size(a1)) || min(size(a0)) ~= 1
      error('a0 (arg2) and a1 (arg3) must be vectors of same length');
   end
   
   n = length(a0);
   [nB,m] = size(B);
   [l,nC] = size(C);
   [mD,nD] = size(D);
   
   if (nB ~= 2*n)
      error('bad size of B (arg4)');
   end
   if (nC ~= 2*n)
      error('bad size of C (arg5)');
   end
   if (mD ~= l) || (nD ~= m)
      error('bad size of D (arg6)');
   end
   
      % so far everything looks good now ...
      
   I = eye(n);
   A = [0*I, I; -diag(a0) -diag(a1)];
   
   oo = inherit(corasim('modal'),o);
   oo = data(oo,'a0,a1,B,C,D', a0,a1,B,C,D);
   
   i1 = 1:n;  i2 = n+1;2*n;
   A11 = A(i1,i1);  A12 = A(i1,i2);
   A21 = A(i2,i1);  A22 = A(i2,i2);
   B1 = B(i1,:);  B2 = B(i2,:);
   C1 = C(:,i1);  C2 = C(:,i2);
   
   oo = var(oo,'a0,a1,A,B,C,D,A11,A12,A21,A22,B1,B2,C1,C2,D',...
                a0,a1,A,B,C,D,A11,A12,A21,A22,B1,B2,C1,C2,D);
end

%==========================================================================
% Modal Representation
%==========================================================================

function oo = Modal(o,num,den)         % Modal Representation          
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
            qi = Mul(o,qi,Psi(j,:));
         end
      end
      
         % now we have reduced qi(s) = q(s) / psi_i(s) 
         
      r = roots(psi);                  % roots of characteristic factor
      s(i,1) = r(1);                   % first root (of 2)
      qi = Mul(o,qi,[1 -s(i)']);
      
      ps = Eval(o,num,s(i));
      qs = Eval(o,qi, s(i));
      c(i,1) = ps ./ qs;
      cs(i,1) = c(i) * s(i)';
   end
   
   M = sqrt(-2*real(cs));
   N = 2*real(c)./M;
   
      % reconstruct p(s) and q(s)
      
   p = 0;  q = 1;
   for (i=1:length(c))
      psi = Mul(o,[1 -s(i)],[1 -s(i)']);
      q = Mul(o,q,psi);
      
      qi = 1;
      for (j=1:n)
         if (j ~= i)
            psi = Psi(j,:);
            qi = Mul(o,qi,psi);
         end
      end
      
      pi = -2*real(c(i)) + 2*real(c(i)*s(i))';
      p = Add(o,p,Mul(o,qi,pi));
   end
   
   err = norm(q-den) / norm(q);
   if (err > 1e3*eps)
      fprintf('*** warning: numerical issues @ denominator calc (3)\n');
   end
   
   err = norm(p-num) / norm(p);
   if (err > 1e3*eps)
      fprintf('*** warning: numerical issues @ numerator calc (4)\n');
   end
   
   oo = var(o,'a0,a1,M,N,omega,zeta,Psi',a0,a1,M,N,omega,zeta,Psi);
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


