function [psi,ev] = eig(obj,idx,z,t)
%
% EIG    Get eigenfunctions of harmonic oszillator (returned in a matrix
%
%           osc = harmonic(hbar*omega,-10:0.1:10);  % harmonic oscillator
%
%        Get n-th eigen function & eigenvalue
%
%           [psi,ev] = eig(osc,n);    % get n-th eigen function & e.v.
%
%        Get a range of eigen functions & according eigenvalues. Result
%        id returned by a matrix for the eigen functions, and a vector 
%        for the eigen values
%
%           [PSI,EV] = eig(osc,0:6);  % get eigen functions % e.v.
%
%        Specify also z-space and optionally evaluate at t
%
%           [PSI,EV] = eig(osc,0:6,-10:0.1:10);  % get e.f. & e.v.
%           [PSI,EV] = eig(osc,0:6,z,t);         % get e.f(t) % e.v.
%
%        See also: HARMONIC, SETUP, COHERENT
%
   if (nargin == 4)
      if (length(t) ~= 1)
         error('t (arg4) must be a scalar!');
      end
   end

      % retrieve working data

   dat = data(obj);  hbar = dat.hbar;  omega = dat.omega;  m = dat.m;
   iu = sqrt(-1);  F = dat.F;
   
      % calculate potential translation: VF(z) = V(z-z0) - V0
      
   z0 = -F/(m*omega^2);  V0 = -z0*F/2;
   
   if (nargin < 3)
      z = dat.zspace;
   end

      % see if psi-functions have been already calculated

   psi = get(obj,'psi');      % get pre calculated psi table
   [m,nplus1] = size(psi);

      % take care about idx (arg2)
      
   if (nargin < 2)
      idx = 0:nplus1;
      if (length(idx)==1)
         idx = 0:25;
      end
   end
   
   if (any(floor(idx) ~= idx) || any(idx < 0))
      error('arg2 must be integer indicess and >= 0!');
   end

      % calculate eigen values

   ev0 = (idx(:) + 1/2) * hbar*omega;     % this was easy 
   ev0 = ev0 .^ dat.pseudo;               % apply pseudo factor
   ev0 = ev0 - 0.5^dat.pseudo + 1;        % ev0(1) needs to be 1 !
   ev = ev0 - V0;                         % correction @ external force 

      % continue
      
   nmax = max(idx);

   if (nmax+1 > nplus1)  % then we have further to calculate
      z = z(:);
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
   end

      % no table of eigen functions is calculated
      % we need to select by index

   psi = psi(:,idx+1);     % pick from table

      % do we have to respect time?

   if (nargin >= 4)   % then calculate the time dependent eigen state
      [mpsi,npsi] = size(psi);
      for (j=1:npsi)
         Ej = ev0(j);
    Ej = ev(j);
         omegaj = Ej/hbar;
         psi(:,j) = psi(:,j) * exp(-iu*omegaj*t);
      end
   end
   return

% eof