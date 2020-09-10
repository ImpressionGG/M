function ball(obj,offset,r,col,alfa,points)
%
% BALL   Plot a ball sphere
%
%           ball(toy,[0 0 z],r,col,alpha,points);
%
%        See also: CORE
%
   profiler('ball',1);
   
   if (nargin < 3)
      r = 1;
   end

   if (nargin < 4)
      col = 'w';
   end

   if (nargin < 5)
      alfa = 1;
   end

   if (nargin < 6)
      points = 50;
   end
   
   X0 = offset(1);  Y0 = offset(2);  Z0 = offset(3);
   [x,y,z] = sphere(points);
   
   %kv = 0.2;
   %y = y.*(1+abs(kv*v)-kv*v*x);
   %z = z.*(1+abs(kv*v)-kv*v*x);
   
   hdl = surf(r*x+X0,r*y+Y0,r*z+Z0,'edgecolor','none');
   set(hdl,'FaceColor',col)
   alpha(hdl,alfa);
   update(gao,hdl);

   profiler('ball',0);
   return
   
% eof   