function obj = gauss(obj,sigma,center)
% 
% GAUSS    Create Gaussian quon particle with normalized wave function
%
%              qob = quon(envi(quantana));        % quan object
%              obj = gauss(qob,sigma,center)      % gaussian wave packet
%              obj = gauss(qob,0.5,2)             % sigma=0.5, center=2
%
%              obj = gauss(qob);
%
%          See also QUON, QUANTANA, FREE/DEMO
%   
   if (nargin < 2)
      sigma = 1;
   end
   
   if (nargin < 3)
      center = 0;
   end
   
   fmt = format(obj);
   dat = data(obj);                         % retrieve object's data
   par = get(obj);
   
   z = zspace(obj);
   envelope = bell(z,sigma,center); 
   if (all(abs(dat.psi)==abs(dat.psi(1))))  % e.g. for free particles
      psi = dat.psi .* envelope;
   else                                     % for other particles
      psi = envelope;
   end
   psi = normalize(psi,z);
   
   dat.psi = psi;
   dat.sigma = sigma;
   dat.center = center;
   
   obj = quon(fmt,par,dat);  % create new object with updated data

   obj = set(obj,'title',sprintf('%g@%g',sigma,center'));
   
   return           

%==========================================================================

function psi = bell(z,sigma,p)
%
% BELL   Bell shape function at position p
%
   z0 = (max(z)+min(z))/2;
   psi0 = exp(-((z-z0)/sigma).^2);
   A0 = 1/sum(psi0);               % just to calculate constant A0

   psi = A0*exp(-((z-p)/sigma).^2);
   return
   
% eof   