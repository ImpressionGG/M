function [psi,ev] = eig(obj,idx,t)
%
% EIG    Get eigenfunctions of a quon (returned in a matrix)
%
%           qob = quon(envi(quantana,kind));  % quon object
%
%        Get n-th eigen function & eigenvalue
%
%           [psi,ev] = eig(qob,n);    % get n-th eigen function & e.v.
%
%        Get a range of eigen functions & according eigenvalues. Result
%        id returned by a matrix for the eigen functions, and a vector 
%        for the eigen values
%
%           [PSI,EV] = eig(qob,0:6);  % get eigen functions % e.v.
%
%        Specify also z-space and optionally evaluate at t
%
%           [PSI,EV] = eig(qob,0:6,-10:0.1:10);  % get e.f. & e.v.
%           [PSI,EV] = eig(qob,0:6,z,t);         % get e.f(t) % e.v.
%
%        As a special feature eig can return a pseudo function according
%        to a real valued (non integer) index.
%
%          [psi,ev] = eig(qob,2.45,z,t);    % pseudo eigen function
%
%           =>  lambda = 0.45;  floor(2.45) = 2;  ceil(2.45) = 3;
%               [psi0,ev0] = eig(qob,2.0,z,1);  % eigen function, index = 2
%               [psi1,ev1] = eig(qob,3.0,z,1);  % eigen function, index = 3
%               psi = pisi0 + lambda*(psi1-psi0);
%               ev  = ev0 + lambda*(ev1-ev0);
%
%        See also: QUON, WAVE
%
   profiler('quon_eig',1);
   dat = data(obj);             % retrieve working data
   kind = dat.kind;             % quon kind
   hbar = dat.hbar;             % reduced Planck constant 
   iu = sqrt(-1);               % imaginary unit
   
      % see if psi-functions have been already calculated

   Psi = dat.Psi;               % get pre calculated psi table
   energy = dat.energy;         % energy values
   [m,n] = size(Psi);

      % take care about all args
      
   if (nargin < 2)            % take care about idx (arg2)
      idx = 1:n;
      if (length(idx)==1)
         idx = 0:25;
      end
   end
   
   if (any(idx < 0))
      error('arg2 must be >= 0!');
   end

   if (nargin < 3)           % take care about t (arg4)
      t = 0;
   else
      if (length(t) ~= 1)
         error('t (arg3) must be a scalar!');
      end
   end

      % check if pseudo eigenfunction is required
      
   if (length(idx) == 1 && idx(1) == 0)
      psi = 0*dat.zspace;  ev = 0;    % pseudo eigen function for idx = 0
      return;
   end
   
   if (any(idx ~= floor(idx) | idx == 0))    % pseudo eigen function
      for (i=length(idx):-1:1)
         fidx = floor(idx(i));  lambda = idx(i) - fidx;   
         [psi1,ev1] = eig(obj,fidx,t);
         [psi2,ev2] = eig(obj,fidx+1,t);
         psi(:,i) = psi1*(1-lambda) + psi2*lambda;
         ev(i) = ev1*(1-lambda) + ev2*lambda; 
      end
      return
   end
      
      % if basis has not been provided we need to calculate basis
      % and energy values
      
   if (m*n == 0)                         % basis has not been provided
      [psi,ev] = eigen(obj,kind,idx);    % calculate eigen funcs & values
   else
      psi = Psi(:,idx);                  % eigen functions
      ev = energy(idx);                  % eigen values
   end

      % post processing (time dependance)
      
   if (t ~= 0)
      [m,n] = size(psi);
      for (j=1:n)
         Ej = ev(j);
         omegaj = Ej/hbar;
         psi(:,j) = psi(:,j) * exp(-iu*omegaj*t);
      end
   end
   
   profiler('quon_eig',0);
   return
   
%==========================================================================

function [psi,ev] = eigen(obj,kind,idx)
%
% EIGEN     Calculate eigen functions & eigen values

   switch kind
      case 'box'
         [psi,ev] = boxeig(obj,idx);         % particle in a box
      case 'harmonic'
         [psi,ev] = harmeig(obj,idx);        % harmonic oscillator
      otherwise
         kind, error('unknown quon kind!');
   end
   return
   
%==========================================================================
   
function [psi,ev] = boxeig(obj,idx)
%
% BOXEIG     Calculate eigen functions & eigen values of a quon in a box
%
   dat = data(obj);
   hbar = dat.hbar;                 % reduced Planck constant
   z = dat.zspace(:);               % z-space
   m = dat.m;                       % particle mass
   L = either(get(obj,'L'),1);      % width of box
   
   for (j=1:length(idx))
      kj = idx(j)*pi/L;
      ev(j) = (hbar*kj)^2 / (2*m);
      psi(:,j) = sqrt(2/L) * sin(kj*(z-min(z)));
   end
   return

%==========================================================================
   
function [psi,ev] = harmeig(obj,idx)
%
% HARMEIG     Calculate eigen functions & eigen values of a quon of an
%             harmonic oscillator
%
   dat = data(obj);
   hbar = dat.hbar;                    % reduced Planck constant
   z = dat.zspace(:);                  % z-space
   m = dat.m;                          % particle mass
   omega = either(get(obj,'omega'),1); % eigen frequency of oscillator
   
      % calculate eigen values

   idx = idx - 1;                      % translate index: 1:n -> 0:(n-1)
   ev = (idx(:) + 1/2) * hbar*omega;   % this was easy 

   z = z(:);  z0 = 0;
   nmax = max(idx(:));
   psi = zeros(length(z),nmax+1);

   for (n=0:nmax)
      if (n == 0)
         Hn = z*0 + 1;    % H0 = 1
      elseif (n == 1)
         Hn1 = Hn;
         Hn = 2*(z-z0);        % H1 = 2*z
      else
         Hn2 = Hn1;  Hn1 = Hn;
         Hn = 2*Hn1.*(z-z0) - 2*(n-1)*Hn2;
      end

      An = 1/sqrt(sqrt(pi)*2^n*gamma(n+1));
      psin = An * exp(-(z-z0).*(z-z0)/2) .* Hn;

      psi(:,n+1) = psin;
   end

   psi = psi(:,idx+1);     % pick from table
   return

% eof