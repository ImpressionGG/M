function [k,om] = kspace(obj)
%
% KSPACE    Return k-space of free particle object. This is the space
%           which is the domain for the discrete Fourier transform of a
%           wave function. Optionally also according omega values are 
%           retrieved.
%
%              fpo = gauss(free,1,-2)         % define free particle object
%              [k,om] = kspace(fpo)           % return k coordinates
%
%           See also: FREE, ZSPACE, WAVE
%
   dat = data(obj);
   z = dat.zspace(:);  hbar = dat.hbar;  m = dat.m;
      
         % we calculate the indices for the wave numbers k
         % high indices need to be treated as negative !!!
         
   N = length(z);
   M = ceil(N/2) + 1;  % k index M:N needs to be moved into the negative
   idx = 0:N-1;
   idx(M:N) = idx(M:N) - N;    % indices are shuffeled
         
      % look now, how we calculate omega. The case k=1 matches
      % to a wave length lambda = 2*pi/(z(N)-z(1))
     
   lambda = z(N) - z(1);      % natural wave length
   k = idx' * 2*pi/lambda;
   om = hbar*k.*k/(2*m);      % om = E/hbar = (hbar*k)^2/(2*m*hbar)   

   return

% eof