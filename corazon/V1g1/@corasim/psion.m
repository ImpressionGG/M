function phi = psion(o,psi,omega)     % Modal frequency response
%
% PSION Get modal frequency response for modal coefficient matrix 
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
%       quency response matrix Gjw (l x n matrix) with n = length(omega) 
%       
%          Gjw = psion(o,psi,omega,W)   % TRF (TRM) frequency response
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
%
%       See also: CORASIM, FQR
%
   omega = omega*opt(o,{'oscale',1});  % scale omega
   jw = 1i*omega(:).';                 % imaginary circular frequency

   m = size(psi,1);                    % number of modes   
   n = length(jw);
   
   for (i=1:m)
      phi(i,1:n) = 1 ./ polyval(psi(i,:),jw);
   end
end
