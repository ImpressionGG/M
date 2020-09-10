function hax = subplot(o,varargin)
%
% SUBPLOT   Select subplot - handle dark mode
%
%              hax = subplot(o,311);
%              hax = subplot(o,3,1,1);
%              hax = subplot(o,[3 1 1]);
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CORAZON, PLOT, CLS
%
   if (nargin >= 2)
      sub = varargin{1};               % short hand
   end
   
      % dispatch arg list
      
   if (nargin == 2 && length(sub) == 1)
      hax = subplot(sub);
      dark(o,'Axes');
   elseif (nargin == 2 && length(sub) == 3)
      hax = subplot(sub(1),sub(2),sub(3));
      dark(o,'Axes');
   elseif (nargin == 4)
      hax = subplot(varargin{1},varargin{2},varargin{3});
      dark(o,'Axes');
   end
end
