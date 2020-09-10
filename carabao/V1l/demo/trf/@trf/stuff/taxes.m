function taxes(obj,tmin,tmax,ymin,ymax)
%
% TAXIS    Draw time axis based on object options
%
%             G = tff(1,[1 2]);
%             taxes(G,tmin,tmax,ymin,ymax);
%             
%          Alternative
%
%             G = option(G,'time.tmin',0,'time.tmax',10);        % time range
%             G = option(G,'time.ymin',0,'time.ymax',1.5);       % y range
%             taxes(G);
%
%          See also: TFF, BODE, BAXES, STEP, TAXES
%
   if (nargin < 2)
      tmin = either(option(obj,'time.tmin'),0);
   end
   
   if (nargin < 3)
      tmax = either(option(obj,'time.tmax'),10);
   end
   
   if (nargin < 4)
      ymin = either(option(obj,'time.ymin'),0);
   end
   
   if (nargin < 5)
      ymax = either(option(obj,'time.ymax'),1.5);
   end
   
   timeaxes(tmin,tmax,ymin,ymax);
   return
%   