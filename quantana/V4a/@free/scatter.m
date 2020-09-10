function [fob,bob,R] = scatter(obj,mode,arg)
%
% SCATTER    Creates scattering objects. Based on the mode (e.g. 'delta'
%            for scattering at the delta potential a forward (fob) and a
%            backward object (bob) is created which contains the forward
%            and backward wave functions at t = 0. The reflection coeff.
%            R are also returned
%
%               obj = gauss(free,sigma,center);   % wave packet
%
%               [fob,bob,R] = scatter(obj,'delta',alfa) % delta scattering
%
%            Defaults
%               [fob,bob,R] = scatter(obj)   % delta scattering, alfa = 1
%
   if (nargin < 2)
      mode = 'delta';
   end
   
   if (nargin < 3)
      arg = 1;
   end
   
   dat = data(obj);
   par = get(obj);
   fmt = format(obj);

      % forward object
      
   fdat = dat;
   
      % backward object
   
   bdat = dat;
   bdat.center = -bdat.center;
   bdat.psi = bdat.psi(end:-1:1);    % upside down
   bdat.k = -bdat.k;

      % Modify the wave functions according to the transmission and
      % reflection coefficients, which depend on the momentum hbar*k.
      % Note that we have to Fourier transform in order to apply 
      % transmission and reflection, and then transform back.
      
   switch mode
      case 'delta'
         alfa = arg;
         k = kspace(obj);               % get momentum values
         beta = fdat.m*alfa/fdat.hbar^2 ./ k;
         
            % transmission
         
         fphi = dft(quantana,fdat.psi);
         T = 1./(1+beta.*beta);
         fphi = T .* fphi;              % transmission 
         fdat.psi = idft(quantana,fphi);
         
            % reflection
            
         bphi = dft(quantana,bdat.psi);
         R = 1./(1+1./(beta.*beta));
         bphi = R .* bphi;              % transmission 
         bdat.psi = idft(quantana,bphi);
         
      otherwise
         mode
         error('unknown mode!');
   end
   
      % finally create forward and backward objects
      
   fob = free(fmt,par,fdat);      % create forward object
   bob = free(fmt,par,bdat);      % create backward object
      
   fob = set(fob,'title','forward');
   bob = set(bob,'title','back');
   return;
   
%eof
