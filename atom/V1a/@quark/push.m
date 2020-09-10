function oo = push(nuc,o)
%
% PUSH   Push object into a figure
%
%    Function can be used to push a QUARK object (called with 1 arg) or
%    to push any object (called with 2 args) into a figure.
%
%           push(quark,o)              % push any object o into a figure
%           push(o)                    % push QUARK object o into a fig
%
%    Code lines: 20
%
%    See also: QUARK, GLUON, GCF, FIGURE, PULL
%
   if (nargin < 2)
      o = nuc;                         % in case of CARACOW object pushing
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
   o.wrk = [];
%   
% next store object handle in figure's userdata.
%
   gob = gluon;                        % work with the GLUON shelf
   shelf(gob,fig,'object',o);          % store o in shelf @ tag 'object'
%
% if out args then refresh object by pulling
%
   if (nargout > 0)
      o = figure(o,fig);               % set object's figure handle
      oo = pull(o);
   end
end
