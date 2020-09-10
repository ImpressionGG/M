function [phi,T] = dft(obj,psi)
%
% DFT       Discrete Fourier transformation
%
%              phi = dft(quantana,psi)
%
%           Formula
%
%              phi(k) = sum{j=0:N-1}( psi(j)*exp(-2*pi/N*i*k*j) )
%              where N = length(psi)
%
%           See also: QUANTANA, IDFT
%
   N = size(psi,1);
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
   T = exp(-2*pi/N * i*JK);          % transformation matrix
   
      % calculate now the Fourier transform
      
   phi = T*psi;
   
   %
   % An alternative way of calculation
   %
   % phi = psi;
   % jT = -2*pi/N*i*idx;
   % for (k=0:N-1)
   %   tT = exp(jT*k);
   %   phi(k+1) = tT*psi; 
   % end
   %
   
   return
   
%eof   