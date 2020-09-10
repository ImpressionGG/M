function out = well(obj,center,a,b,col,trsp,np);
%
% WELL   3D plot of cylindrical potential well
%
%           hdl = well(obj,center,a,b,color,transparency)
%
%        Defaults
%           hdl = well(obj)   % center = 0, a = 0.25, b = 1
%                             % color = 'b', transparency = 0.2
%
%
%        See also: QUANTANA, PALE, WING, BALLEY
%
   if (nargin < 2)  center = 0; end
   if (nargin < 3)  a = 0.25; end
   if (nargin < 4)  b = 2; end
   if (nargin < 5)  col = 0.4*[1 1 1]; end
   if (nargin < 6)  trsp = 0.2; end
   if (nargin < 7)  np = 100; end     % number of segments around cylinder
   
   p  = 0 : 2*pi/np : 2*pi;          % angular coordinate around cylinder          
   z = [-a -a a a];                  % z-coordinate od cylinder
   r = [ 0  b b 0];                  % radial coordinate of cylinder

   [P,Z] = meshgrid(p,z);            % calculate mesh grid   
   [P,R] = meshgrid(p,r);            % calculate mesh grid   
   
   X = Z;
   Y = R.*cos(P);
   Z = R.*sin(P);
   
   caxis manual;  caxis([0 1]);
   C = cindex(obj,0*Z+1,col);        % color indices

   hdl = surf(X+center,Y,Z,C,'EdgeColor','none');
   alpha(hdl,trsp);
   
   caxis([0 1]);                     % need to set again, as surf changes 
   
   daspect([1 1 1]);                 % set uniform data aspect ratios
   if (nargout > 0)
      out = hdl;
   end
   return
   
% eof