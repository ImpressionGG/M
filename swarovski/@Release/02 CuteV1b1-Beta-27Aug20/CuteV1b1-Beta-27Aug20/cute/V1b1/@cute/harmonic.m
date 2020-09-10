function [yf,yr,p,omegas] = harmonic(o,t,y,n)
%
% HARMONIC  Find least square fit for harmonic signal. Input time vector
%           t and data y and optionally fitting order n. return fitted
%           data yf, residuum yr, parameter vector p and circular freq's
%
%              [yf,yr,p,omegas] = harmonic(o,t,y,n)    % harmonic fit
%              [yf,yr,p,omegas] = harmonic(o,t,y)      % n = 1
%
%           The fitted function has the form:
%
%              yf = a0 * ones(size(t)) +
%                 + a1 * cos(omega1*t) + b1 * sin(omega1*t) +
%                 :          ...       :         ...        :
%                 + an * cos(omegan*t) + bn * sin(omegan*t) +
%
%              yr = y - yf    % residuum
%              omegas = [omega1,...,omegan]
%
%           Algorithm for n = 1
%
%              f(t) = a0*ones(size(t)) + a1*cos(omega1*t) + b1*sin(omega1*t)
%
%           To solve it define:
%
%              p = [a0,a1,b1]'        % parameter vector (to be found)
%
%              H := [ones(size(t(:))); cos(omega1*t(:)); sin(omega1*t(:))]
%
%              p = inv(H'*H)*H'*y(:)  % solution
%
%           See also: CUTE, FFT, CLUSTER
%
   if (nargin < 4)
      n = 1;
   else
      n = max(0,n);                    % make it a number >= 0
   end  
   
      % perform fast Fourier transform
      
   [f,Y] = fft(o,t,y);
   
      % first frequency is zero (constant term)
      
   t = t(:);                           % convert t to a column
   H = ones(size(t));                  % initial column of H
   Y(1) = 0;                           % set amplitude zero
   omegas = [0];                       % first frequency is at zero
   
   for (i=1:n)
      idx = find(Y==max(Y));  fdx = idx(1);

      om = 2*pi*f(fdx);
      omegas(1,end+1) = om;
      Y(fdx) = 0;                      % this frequency's magnitude := zero
   
      H = [H, cos(om*t), sin(om*t)];
   end
   
      % solve p = inv(H'*H)*H'*y(:)    % same as p = H\y(:)
      
   p = H\y(:);
   
   yf = p'*H';                         % fitted curve data
   yr = y - yf;                        % residuum
end
