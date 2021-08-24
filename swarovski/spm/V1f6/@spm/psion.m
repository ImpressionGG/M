function [oo,Idx] = psion(o,varargin)  % psion representation
%
% PSION Get either psion representation of a transfer system in modal
%       form or calculate frequency response for psion representation.
%
%          oo = system(o,cdx);              % get contact relevant system
%          [PsiW,Idx] = psion(o,oo);        % get psion representation
%          [PsiW,Idx] = psion(o,A,B,C);     % get psion representation
%          [psiW,Idx] = psion(o,A,B,C,T0);  % get unnormalized psion repr.
%
%          Gjw = psion(o,PsiW,omega)        % calculate FQR
%          [Gjw,Phi] = psion(o,PsiW,omega)  % return internal Phi matrix
%
%       Output arg PsiW is the psion matrix, while Idx (an indexing matrix)
%       is for looking up weight vectors wij, i.e. wij = PsiW(:,Idx(i,j)).
%
%       Upercase PsiW means time normalized psion representation which
%       requires normalized omega (Om = T0*om) for FQR calculation (see
%       example 1).
%
%       Lowercase psiW means unnormalized psion representation which
%       requires unnormalized omega (om) for FQR calculation (see example
%       2).
%
%       Given a modal, time normalized system by T0
%
%          x´= v
%          v´= A21*x + A22*v + B2*u    % A21 = -diag(a0), A22 = -diag(a1)
%          y = C1*x
%
%       and the definition of weight vector wij
%
%          wij = C1(i,:)'.*B2(:,j)
%
%       the time normalized psion representation is defined by the 
%       nx(3+l*m) matrix
%
%          PsiW := [one,a1,a0, w11:wl1, w12:wl2,...,w1m:wlm]
%
%       while the unnormalized psion representation is defined by the 
%       nx(3+l*m) matrix
%
%          psiW := [one*T0*T0,a1*T0,a0, w11:wl1, w12:wl2,...,w1m:wlm]
%
%       Example 1:
%
%          oo = system(o,cdx)
%          [A,B_1,B_3,C_3,T0] = var(oo,'A,B_1,B_3,C_3,T0')
%          PsiW31 = psion(o,A,B_1,C_3) % to calculate G31(jw)
%          PsiW33 = psion(o,A,B_3,C_3) % to calculate G33(jw)
%
%          G31jw = psion(o,PsiW31,om*T0)
%          G33jw = psion(o,PsiW33,om*T0)
%
%       Example 2:
%
%          oo = system(o,cdx)
%          [A,B_1,B_3,C_3,T0] = var(oo,'A,B_1,B_3,C_3,T0')
%          psiW31 = psion(o,A,B_1,C_3,T0)       % to calculate G31(jw)
%          psiW33 = psion(o,A,B_3,C_3,T0)       % to calculate G33(jw)
%
%          G31jw = psion(o,psiW31,om)  % no multiplication of om with T0
%          G33jw = psion(o,psiW33,om)  % no multiplication of om with T0
%
%       Remark:
%          
%       Copyright(c): Bluenetics 2021
%
%       See also: SPM, SYSTEM, LAMBDA
%
   function Comment
%
%       modal frequency response for modal coefficient matrix 
%       psi = [1 a1(1) a0(1); 1 a1(2) a0(2); ... ; 1 a1(n) a0(n)]
%       and given circular frequency vector omega (note that any
%       provided omega vector will be scaled).
%
%       1) Modal Frequency Response
%
%          phi = psion(o,psi,omega)   % modal frequency response
%
%          phi(jw) := [1/psi1(jw), 1/psi2(jw), ..., 1/psin(jw)]'
%           
%       2) Transfer Function Frequency Response
%
%       Alternatively a frequency response of a transfer function can be
%       calculated to a give representation [psi,W], where psi (an m x 3
%       matrix )contains the modal parameters (psi = [one a1 a0]) and W
%       is an lxm matrix containing the modal weights. The result is a fre-
%       quency response matrix Gjw (l x n matrix) with n = length(omega).
%       Optionally also calculate dB value as second output arg
%       
%          [Gjw,dB] = psion(o,psi,omega,W) % TRF (TRM) frequency response
%
%       Important remark: any omega (arg3) is multiplied by omega scaling 
%       factor (option 'oscale'), which is by default 1.
%
%       Examples: consider the calculation of the frequency response of 
%       L0(jw) 
%
%          L0(jw0) = G31(jw0)/G33(jw0)
%
%       given the representations
%
%          G31(s): [psi,w31T], G33(s): [psi,w33T]
%
%       with psii(s) := s^2 + a1(i)*s + a0(i)*s
%
%          G31(s) = w31(1)/psi1(s) + w31(2)/psi2(s) + ... + w31(n)*psin(s)
%          G33(s) = w33(1)/psi1(s) + w33(2)/psi2(s) + ... + w33(n)*psin(s)
%
%       let
%
%           phi(jw) := [1/psi1(jw), 1/psi2(jw), ..., 1/psin(jw)]'
%
%       then
%
%                      w31' * phi(jw0)
%          L0(jw0) = -------------------
%                      w33' * phi(jw0)
%
%
%       Example 1: explicite use of phi vector
%          om = logspace(2,7);                   % 10^2 ... 10^7
%          [psi,W] = cook(o,'psi,W');
%          phi = psion(o,psi,om) 
%          Gjw = (W{3,1}*phi) ./ (W{3,3}*phi)    % final division
%
%       Example 2: without using phi, providing a weight row vector
%          om = logspace(2,7);                   % 10^2 ... 10^7
%          [psi,W] = cook(o,'psi,W');
%          G31jw = psion(o,psi,om,W{3,1}) 
%          G33jw = psion(o,psi,om,W{3,3}) 
%          Gjw = G31jw ./ G33jw                  % final division
%
%       Example 3: without using pi, providing a 2xm weight matrix
%          om = logspace(2,7);                   % 10^2 ... 10^7
%          [psi,W] = cook(o,'psi,W');
%          Gjw = psion(o,psi,om,[W{3,1};W{3,3}]) % 2 x n matrix
%          Gjw = Gjw(1,:) ./ Gjw(2,:)            % final division
%
%       Example 4: using scaled modal parameters
%          om = logspace(2,7);                   % 10^2 ... 10^7
%          [psi,W] = cook(o,'psi,W');
%
%          oscale = 1e-3;                        % scale omega by 1/1000
%          Psi = [psi(:,1) psi(:,2)*oscale psi(:,3)*oscale^2]  % scale!
%          o = opt(o,'oscale',oscale)            % psion() needs !!!
%
%          G31jw = psion(o,Psi,om,W{3,1})        % use scaled modal param's        
%
%       Options:
%          oscale:           omega scaling factor (default 1)
%          digits:           variable precision digit number (default: 0)
%
%       See also: CORASIM, FQR
%
   end

   if (nargin == 2)
      oo = varargin{1};
      [oo,Idx] = Psion(o);             % calculate Psion representation
   elseif (nargin == 3)
      PsiW = varargin{1};  omega = varargin{2};
      [oo,Idx] = Fqr(o,PsiW,omega);
   elseif (nargin == 4)
      A = varargin{1};  B = varargin{2};   C = varargin{3};
      o = data(o,'A,B,C,D',A,B,C,0*C*B);
      [oo,Idx] = Psion(o,1);           % calculate Psion representation
   elseif (nargin == 5)
      A = varargin{1};  B = varargin{2};   
      C = varargin{3};  T0 = varargin{4}; 
      o = data(o,'A,B,C,D,T0',A,B,C,0*C*B,T0);
      [oo,Idx] = Psion(o,T0);          % calculate Psion representation
   end
end

%==========================================================================
% Calculate Psion Representation
%==========================================================================

function [PsiW,Idx] = Psion(o,T0)
   [a0,a1,B2,C1] = Modal(o);           % get modal form parameters
   
%  Psi = [1+0*a0,a1*T0,a0*T0*T0];
   Psi = [(1+0*a0)*T0*T0,a1*T0,a0];
   
   n = length(a0);  m = size(B2,2);  l = size(C1,1);
   W = zeros(n,l*m);  Idx = zeros(l,m);
   
   k = 1;
   for (j=1:m)
      for(i=1:l)
         wij = C1(i,:)'.*B2(:,j);
         W(:,k) = wij;
         Idx(i,j) = 3+k;               % index to identify W-column
         k = k+1;
      end
   end
   
   PsiW = [Psi,W];
end

%==========================================================================
% Frequency Response
%==========================================================================

function [Gjw,Phi] = Fqr(o,PsiW,omega)
   jw = 1i*omega(:).';                 % imaginary circular frequency

   Psi = PsiW(:,1:3);
   W = PsiW(:,4:end);
   
   m = size(Psi,1);                    % number of modes   
   n = length(jw);

      % use variable precision arithmetics if option digits > 0
      
   digits = opt(o,{'digits',0});
   if (digits > 0)
      psi = vpa(psi,digits);
      jw = vpa(jw,digits);
   end
   
      % calculate psion response:
      % phi(jw) = 1 / (jw*jw + a1*jw + a0)
      
%  Phi = 1 ./ (ones(m,1)*(jw.*jw) + Psi(:,2)*jw + Psi(:,3)*ones(1,n));
   Phi = 1 ./ (Psi(:,1)*(jw.*jw) + Psi(:,2)*jw + Psi(:,3)*ones(1,n));
   
   Gjw = W'*Phi;
end

%==========================================================================
% Stuff
%==========================================================================
  
function Stuff(o)      
   omega = omega*opt(o,{'oscale',1});  % scale omega
   jw = 1i*omega(:).';                 % imaginary circular frequency

   m = size(psi,1);                    % number of modes   
   n = length(jw);

      % use variable precision arithmetics if option digits > 0
      
   digits = opt(o,{'digits',0});
   if (digits > 0)
      psi = vpa(psi,digits);
      jw = vpa(jw,digits);
   end
   
      % calculate psion response:
      % phi(jw) = 1 / (jw*jw + a1*jw + a0)
      
%  phi = 1 ./ (ones(m,1)*(jw.*jw) + psi(:,2)*jw + psi(:,3)*ones(1,n));
   phi = 1 ./ (psi(:,1)*(jw.*jw) + psi(:,2)*jw + psi(:,3)*ones(1,n));
   
      % for 3 input args we are done by returning phi
      
   if (nargin == 3)
      oo = double(phi);                % return phi
      return
   end
   
      % for 4 input args we have to continue calculation of the TRF
      % frequency response
      
   if (nargin == 4)
      Gjw = W*phi;
      if (nargout >= 2)
         dB = 20*log10(abs(Gjw));      % optionally return magnitude in dB
         if (digits > 0)
            dB = double(dB);
         end
      end
      oo = double(Gjw);
      return
   end
   
      % running beyond this point is a bug
      
   assert(0);
end

%==========================================================================
% Helper
%==========================================================================

function [a0,a1,B2,C1] = Modal(o)
   [A,B,C,D] = data(o,'A,B,C,D');
   n = length(A)/2;
   
   if (n ~= round(n))
      error('even dynamic matrix dimension expected');
   end
   
   i1 = 1:n;  i2 = n+i1;
   A11 = A(i1,i1);  A12 = A(i1,i2);  A21 = A(i2,i1);  A22 = A(i2,i2);
   B1 = B(i1,:);  B2 = B(i2,:);  C1 = C(:,i1);  C2 = C(:,i2);  I = eye(n);  
   
   if ~isequal(A11,0*I) || ~isequal(A12,I)
      error('no modal form');
   end
   
   a0 = -diag(A21);  a1 = -diag(A22);

   if ~isequal(A21,-diag(a0)) || ~isequal(A22,-diag(a1))
      error('no modal form');
   end
   
   if ~isequal(B1,0*B1) || ~isequal(C2,0*C2)
      error('no modal form');
   end
   
   if ~isequal(D,0*D)
      error('no modal form');
   end
end

