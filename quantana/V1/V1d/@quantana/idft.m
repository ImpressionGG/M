function [psi,T] = idft(obj,phi)
%
% IDFT      Inverse Discrete Fourier transformation
%
%              psi = idft(quantana,phi)
%
%           Formula
%
%              psi(j) = 1/N * sum{k=0:N-1}( phi(k)*exp(+2*pi/N*i*k*j) )
%              where N = length(psi)
%
%           See also: QUANTANA, DFT
%
   N = size(phi,1);
   idx = 0:N-1;          % basis index line
   
      % We calculate the transformation matrix
      % We could do like that:
      %
      %    E = [];
      %    for (j=0:N-1)
      %       E(j+1,1:N) = idx*j;
      %    end
      %    T = exp(-i*2*pi/N).^E;
      %
      % but we can do much simpler
      
   JK = idx'*idx;
   T = exp(-2*pi/N * i*JK);        % transformation matrix
   
   %[ans,T0] = dft(quantana,phi);
   
   invT = T'/N;
   
   psi = invT*phi;
   
   return
   
%eof   