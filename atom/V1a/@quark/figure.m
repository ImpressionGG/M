function fig = figure(o,fig)
%
% FIGURE   Get/Set figure handle of an object
%
%             o = figure(o,fig)        % set object's figure handle 
%             fig = figure(o);         % get object's figure handle
%
%          Code lines: 10
%
%          See also: QUARK, WORK
%
   if (nargin == 1) && isfield(o.wrk,'figure')
      fig = o.wrk.figure;
   elseif (nargin == 1)
      fig = [];
   elseif (nargin == 2)
      o.wrk.figure = fig;              % set object's figure handle
      fig = o;
   else
      error('1 or 2 input args expected!');
   end
end

