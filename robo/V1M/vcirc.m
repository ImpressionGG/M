function V = vcirc(r,points)
%
% VCIRC     Vector Set representing circle with origin at (0,0)
%
%              V = vcirc(r,points)
%              V = vcirc([a,b],points)   % draw ellipse
%              V = vcirc                 % r = 1;  points = 100
%
%           Use vmove for origin offset!
%
%           See also: ROBO, VPLT, VCAT, VLETTER, VCHIP
%
   if ( nargin < 1 ) r = 1; end
   if ( nargin < 2 ) points = 100; end

   phi = 0:2*pi/points:2*pi;
   
   if (length(r)==1) r = [r r]; end
   a = abs(r(1));  b = abs(r(2));
   
   V = [a*cos(phi); b*sin(phi)];

% eof