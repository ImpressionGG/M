function baxes(obj,omin,omax,mmin,mmax,pmin,pmax)
%
% BAXIS    Draw bode axis based on object options
%
%             G = tff(1,[1 2]);
%             baxes(G,omin,omax,mmin,mmax,pmin,pmax);
%             
%          Alternative
%
%             G = option(G,'bode.omin',1e-2,'bode.omax',1e+3);   % omega range
%             G = option(G,'bode.mmin',-80, 'bode.mmax',+80);    % magnitude range
%             G = option(G,'bode.pmin',-270,'bode.pmax',+90);    % phase range
%             baxes(G);
%
% 
%
%          See also: TFF, BODE, BAXES
%
   if (nargin < 2)
      omin = either(option(obj,'bode.omin'),1e-2);
   end
   
   if (nargin < 3)
      omax = either(option(obj,'bode.omax'),1e+3);
   end
   
   if (nargin < 4)
      mmin = either(option(obj,'bode.mmin'),-80);
   end
   
   if (nargin < 5)
      mmax = either(option(obj,'bode.mmax'),+80);
   end
   
   if (nargin < 6)
      pmin = either(option(obj,'bode.pmin'),-270);
   end
   
   if (nargin < 7)
      pmax = either(option(obj,'bode.pmax'),+90);
   end
   
   bodeaxes(omin,omax,mmin,mmax,pmin,pmax);
   return
%   