function out = pale(obj,value,offset,col);
%
% PALE   Plot a single pale
%
%           hdl = pale(obj,value,offset,color)
%
%        See also: TOY
%
   value = eval('value','1.0');
   offset = eval('offset','[0 0 0]');
   col = eval('col','''r''');

   d = 0.1;     % diameter of pale
   n = 20;      % number of angle increments of pale
   
   h = [0  0 value value value+2.0*d]; 
   r = [0 d/2 d/2     d     0];
   p = 0:2*pi/n:2*pi;
   
   [R,P] = meshgrid(r,p);
   [H,P] = meshgrid(h,p);
   
   X = R.*cos(P);
   Y = R.*sin(P);
   Z = H;
   
   surf(obj,X+offset(1),Y+offset(2),Z+offset(3),col);
   return
   
% eof