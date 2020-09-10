function obj = fillr(rect,color)
%
% FILLR   Fill rectangle: fillr([x y w h])
%
   if ( nargin < 2 ) color = 'y'; end

   x1 = rect(1);  x2 = rect(1) + rect(3);
   y1 = rect(2);  y2 = rect(2) + rect(4);

   x = [x1 x1 x2 x2 x1];
   y = [y1 y2 y2 y1 y1];

   obj = fill(x,y,color);

% eof
