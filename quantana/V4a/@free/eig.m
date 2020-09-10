function psi = eig(obj,k,z,t)
%
% EIG    Get momentum eigenfunctions of free particle (returned as matrix)
%
%           fpo = harmonic(2,-10:0.1:10);  % free particle object
%
%        Get momentum eigen function to given set of wave numbers k
%
%           psi = eig(fpo,k);    % get momentum eigen function acc. to k
%
%        Get a range of eigen functions. Result is returned by a matrix 
%        for the eigen functions
%
%           PSI = eig(fpo,1:6);  % get momentum eigen functions
%
%        Specify also z-space and optionally evaluate at t
%
%           PSI = eig(fpo,1:6,-10:0.1:10);  % get momentum eigen functions
%           PSI = eig(fpo,1:6,z,t);         % get momentum eigen functions
%
%        See also: FREE, ZSPACE
%
   if (nargin == 4)
      if (length(t) ~= 1)
         error('t (arg4) must be a scalar!');
      end
   end

      % retrieve working data

   dat = data(obj);  hbar = dat.hbar;  m = dat.m;
   sigma = dat.sigma;  iu = sqrt(-1);

   if (nargin < 3)
      z = dat.zspace(:);
   end

      % take care about idx (arg2)
      
   if (nargin < 2)
      k = 1;
   end
   k = k(:);
   
      % calculate eigen vectors

   if (nargin < 4)   % no t argument provided
      psi = conj(exp(i*k*z')');
   else
      om = hbar*k.*k/(2*m);
      t = t*ones(size(z));
      psi = exp(i*k*z' - i*om*t')';
   end      
   return

% eof