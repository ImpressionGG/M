function fig = figure(o,fig)
%
% FIGURE   Get/Set figure handle of an object
%
%             o = figure(o,fig)        % set object's figure handle 
%             fig = figure(o);         % get object's figure handle
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZITA, WORK, AXES
%
   if (nargin == 1) && isfield(o.work,'figure')
      fig = o.work.figure;
   elseif (nargin == 1)
      fig = [];
   elseif (nargin == 2)
      o.work.figure = fig;             % set object's figure handle
      fig = o;
   else
      error('1 or 2 input args expected!');
   end
end

