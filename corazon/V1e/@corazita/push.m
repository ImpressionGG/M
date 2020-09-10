function oo = push(corazita,o)
%
% PUSH   Push object into a figure
%
%    Function can be used to push CORAZITA object (called with 1 arg) or
%    to push any object (called with 2 args) into a figure.
%
%           push(corazita,o)            % push any object o into a figure
%           push(o)                    % push CORAZITA object o into a fig
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITA, GCF, FIGURE, PULL
%
   if (nargin < 2)
      o = corazita;                         % in case of CORAZITA object pushing
   end
   
   fig = figure(o);                    % first choice for fig handle
%
% the provided figure handle fig = figure(o) could be empty. In this case
% use the default fig = gcf instead. If no figure is open stop processing
%
   if isempty(fig)
      fig = gcf(o);                    % get current figure
   end
   
   if ishandle(fig)
      o = figure(o,fig);               % set object's figure handle
   else
      o = figure(o,[]);                % clear object's figure handle
      oo = [];
      return
   end
%
% clean working property
%
   o.work = [];
%   
% next store object handle in figure's userdata.
%
   cob = corazito;                     % work with the CORAZITO shelf
   shelf(cob,fig,'object',o);          % store o in shelf @ tag 'object'
%
% if out args then refresh object by pulling
%
   if (nargout > 0)
      o = figure(o,fig);               % set object's figure handle
      oo = pull(o);
   end
end

