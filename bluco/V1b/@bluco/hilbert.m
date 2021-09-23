function y = hilbert(o,x)              % Hilbert Transform
%
% HILBERT   Compute Hilbert transform
%
%              y = hilbert(o,x)
%
%           See also: BLUCO
%
   f = fft(x);
   fi = 1i*f;                          % complex multiplication by i
   
      % indices of positive and negative frequencies
      
   n = length(x);
   pos = 2:floor(n/2) + mod(n,2);      % indices of positive frequencies 
   neg = ceil(n/2) + 1 + ~mod(n,2):n;  % indices of negative frequencies
   
   f(pos) = f(pos) - 1i*fi(pos);
   f(neg) = f(neg) + 1i*fi(neg);
   
      % take inverse FFT
      
   y = ifft(f);
end
