function hdl = surf(obj,X,Y,Z,C)
% 
% SURF   surface plot of 3D object, optional call to update.
%
%           hdl = surf(obj,X,Y,Z,'b')         % surface plot
%           hdl = surf(obj,X,Y,Z,C)           % surface plot
%
%           update(gao,surf(obj,X,Y,Z,col))   % surface plot
%           surf(obj,X,Y,Z,col)               % same as above
%
%        Do a 3D rotation before surface plotting:
%
%           obj = option(core,'azimuth',pi/3,'elongation',pi/4);
%           surf(obj,X,Y,Z,col);              % 3D rotate before surf
%  
%        See also: CORE CINDEX UPDATE
%
   [X,Y,Z] = rot(obj,X,Y,Z);   
   
   if any(size(X)~=size(C))
      col = C;
      C = cindex(obj,ones(size(X)),col);         % color indices
   end
   hdl = surf(X,Y,Z,C,'EdgeColor','none');
   
   if (nargout == 0)
      update(gao,hdl);
   end
   return
end   
