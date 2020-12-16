function phi = psion(o,psi,omega)     % Modal frequency response
%
% PSION Get modal frequency response for modal coefficient matrix 
%       psi = [1 a1(1) a0(1); 1 a1(2) a0(2); ... ; 1 a1(n) a0(n)]
%       and given circular frequency vector omega
%
%          phi = psion(o,psi,omega)   % modal frequency response
%
%          phi(jw) := [1/psi1(jw), 1/psi2(jw), ..., 1/psin(jw)]'
%           
%       Example:
%
%          L0(jw0) = G31(jw0)/G33(jw0)
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
%       See also: CORASIM
%
   jw = 1i*omega(:).';                 % imaginary circular frequency

   m = size(psi,1);                    % number of modes   
   n = length(jw);
   
   for (i=1:m)
      phi(i,1:n) = 1 ./ polyval(psi(i,:),jw);
   end
end
