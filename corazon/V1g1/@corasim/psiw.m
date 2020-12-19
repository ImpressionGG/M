function oo = psiw(o,psi,W,D)                     
%
% PSIW    Psi-W representation of a rational function
%
%            oo = psiw(o)              % transform to psi-w form
%            oo = psiw(o,psi,W,D)      % psi-w form of a transfer function
%            oo = psiw(o,psi,W)        % psi-w form, D = 0
%
%         Create a psi-w representation of a rational function
%
%                   p(s)
%            G)s) = ---- = w1/psi1(s) + w2/psi2(s) + ... + wm/psim(s) + D
%                   q(s)
%         with
%
%            psi_i(s) := s^2 + a1(i)*s + a0(i)
%
%         to get nx1 vectors M,a1 and a0 fo a state space representation
%            .
%            x1 = x2
%            .
%            x2 = -diag(a0)*x1 - diag(a1)*x2 + u
%
%            y  = diag(W)*x1 + D*u
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, SIMU, PSION
%
   if (nargin == 1 && nargout <= 1)
      oo = Transform(o);
   elseif (nargin == 3)
      oo = PsiW(o,psi,W,0);
   elseif (nargin == 4)
      oo = PsiW(o,psi,W,D);
   else
      error('1, 3 or 4 input args expected');
   end
end

%==========================================================================
% Transform To Modal Representation
%==========================================================================

function oo = Transform(o)             % Transform to Modal Form       
   oo = modal(o);                      % cast to modal system
   [a0,a1,B,C,D] = data(oo,'a0,a1,B,C,D');
   
   m = length(a0);                     % number of modes
   if (size(B,2) ~= 1 || size(C,1) ~= 1)
      error('implementation restriction for MIMO systems');
   end
   if (norm(B(1:m))/norm(B(2*m:end)) > eps)
      error('implementation restriction for general B matrices');
   end
   if (norm(C(2*m:end))/norm(C(1:m)) > eps)
      error('implementation restriction for general C matrices');
   end
   
   psi = [1+0*a1 a1 a0];
   W = B(2*m:end)' .* C(1:m);
   
   oo = inherit(corasim('psiw'),o);
   oo = data(oo,'psi,W,D',psi,W,D);
end

%==========================================================================
% Create Psi-W System
%==========================================================================

function oo = PsiW(o,psi,W,D)          % Create Psi-W Representation   
   [m,n] = size(psi);
   if (n ~= 3)
      error('psi must have exactly 3 columns');
   end
   if (size(W,1 ~= 1))
      error('W must be a row vector');
   end
   if (length(W) ~= m)
      error('sizes of psi and W do not match');
   end
   if (length(D) ~= 1)
      error('D must be a scalar');
   end
   
   oo = inherit(corasim('psiw'),o);
   oo = data(oo,'psi,W,D', psi,W,D);
end

