function hax = axes(o,hax)
%
% AXES     Get/Set axes handle of an object
%
%             o = axes(o,hax)          % set object's axes handle 
%             hax = axes(o);           % get object's axes handle
%
%          Copyright(c): Bluenetics 2021 
%
%          See also: CORAZITA, WORK, FIGURE
%
   if (nargin == 1) && isfield(o.work,'axes')
      hax = o.work.axes;
   elseif (nargin == 1)
      hax = [];
   elseif (nargin == 2)
      o.work.axes = hax;               % set object's axes handle
      hax = o;
   else
      error('1 or 2 input args expected!');
   end
end

