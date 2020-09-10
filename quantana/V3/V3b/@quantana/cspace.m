function [t,z,y,x] = cspace(obj)
%
% CSPACE   Coordinate Space; fetches parameters from global settings
%
%             menu(quantana);
%             obj = gcfo;
%             [t,z,y,x] = cspace(obj)
%
%          See also: QUANTANA
%
   size = option(obj,'global.size'); 
   nx = size;  ny = size;  nz = size;  nt = size;
   
   if ~isempty(option(obj,'global.nx'))
       nx = option(obj,'global.nx');
   end
   
   if ~isempty(option(obj,'global.ny'))
       ny = option(obj,'global.ny');
   end
   
   if ~isempty(option(obj,'global.nz'))
       nz = option(obj,'global.nz');
   end
   
   if ~isempty(option(obj,'global.nt'))
       nt = option(obj,'global.nt');
   end
   
   tmin = option(obj,'global.tmin'); 
   tmax = option(obj,'global.tmax'); 

   xmin = option(obj,'global.xmin'); 
   xmax = option(obj,'global.xmax'); 
   
   ymin = option(obj,'global.ymin'); 
   ymax = option(obj,'global.ymax'); 
   
   zmin = option(obj,'global.zmin'); 
   zmax = option(obj,'global.zmax'); 

   t = (tmin:(tmax-tmin)/nt:tmax)';
   x = (xmin:(xmax-xmin)/nx:xmax)';
   y = (ymin:(ymax-ymin)/ny:ymax)';
   z = (zmin:(zmax-zmin)/nz:zmax)';

end

