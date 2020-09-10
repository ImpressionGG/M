function obj = gauss(obj,sigma,center)
% 
% GAUSS    Create Gaussian free particle with normalized wave function
%
%              obj = gauss(free,sigma,center)     % gaussian wave packet
%              obj = gauss(free(-5:0,1:5),0.5,2)  % sigma=0.5, center=2
%
%              obj = gauss(free);
%
%          See also FREE, QUANTANA, FREE/DEMO
%   
   if (nargin < 2)
      sigma = 1;
   end
   
   if (nargin < 3)
      center = 0;
   end
   
   fmt = format(obj);
   dat = data(obj);         % retrieve object's data
   par = get(obj);
   
   z = zspace(obj);
   envelope = bell(z,sigma,center); 
   psi = dat.psi .* envelope;
   psi = normalize(psi,z);
   
   dat.psi = psi;
   dat.sigma = sigma;
   dat.center = center;
   
   obj = free(fmt,par,dat);  % create new object with updated data

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