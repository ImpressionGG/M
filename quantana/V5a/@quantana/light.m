function [obj,lhdl] = light(obj,pos,col,rvisu)
%
% LIGHT   Add (one time) a light to current axes. In case of 4 arguments
%         we also have visualisation, where argument 4 is the radius of a
%         sphere.
%
%            lhdl = light(quantana,[x1 y1 z1])
%            lhdl = light(quantana,[x1 y1 z1],[r1 g1 b1])
%            lhdl = light(quantana,[x1 y1 z1],'w')
%            lhdl = light(quantana,[x1 y1 z1],[])    % white coloe
%            lhdl = light(quantana,[x1 y1 z1],col,0.2)  % visualize (r=0.2)
%
%         if rvisu (arg 4) is not provided then the parameter will be taken
%         from option 'light.rvisu', else is set zero.
%
%         See also: QUANTANA, SURF
%
   if (nargin < 2)
      pos = [40 100 20];
   end

   if (nargin < 3)
      col = [1 1 1];
   else
      if (isempty(col))
         col = [1 1 1];
      end
   end

   if (nargin < 4)
      rvisu = option(obj,'light.rvisu');
      if (isempty(rvisu))
         rvisu = 0;
      end
   end

   col = color(col);   % convert to RGB values
   
   x = pos(1);  y = pos(2);  z = pos(3);  r = rvisu;
   if (rvisu)
      [X,Y,Z] = sphere;
      
      C = cindex(obj,ones(size(Z)),col);
      
      hdl = surf(x+r*X,y+r*Y,z+r*Z,C,'edgecolor','none');
      alpha(hdl,1);
      hold on;
   else
      plot([x x],[y y],'k');
   end
      
   lhdl = light('Position',pos,'color',col);
   hold on;

   hdl = get(obj,'light.hdl');
   hdl = [hdl lhdl];
   obj = set(obj,'light.hdl',hdl);
   return
   
% eof   
            