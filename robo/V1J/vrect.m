function V = vrect(w,h)
%
% VRECT     Vector Set to plot a rectangle
%
%              V = vrect(width,height)
%
%           See also: ROBO, VPLT, VCAT, VLETTER, VCHIP
%

   V = [0 0; w 0; w h; 0 h; 0 0]';

% eof