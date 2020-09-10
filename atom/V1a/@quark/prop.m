function o = prop(o,tag,value)
%
% PROP   Get/set a QUARK object's property
%
%    Syntax:
%       bag = prop(o)                  % same as bag = struct(o)
%       value = prop(o,tag);           % get an object property
%       o = prop(o,tag,value);         % set an object property
%
%    Examples:
%       data = prop(o,'data');         % get object's data
%       o = prop(o,'data',data);       % set object's data
%
%       x = prop(o,'data.x');          % get object's data.x
%       o = prop(o,'data.x',x);        % set object's data.x
%
%       ti = prop(o,'par.title');      % get an object parameter
%       o = prop(o,'par.title',ti);    % set an object parameter
%
%    Code lines: 11
%
%    See also: QUARK, GET, SET, VAR, OPT, WORK, TYPE
%
   if (nargin == 1)
      o = struct('tag',o.tag,'type',o.type,'par',o.par,'data',[],'work',o.work);
   elseif (nargin == 2)
      o = eval(['o.',tag],'[]');
   elseif (nargin == 3)
      eval(['o.',tag,' = value;']);
   else
      error('1, 2 or 3 input args expected!')
   end
end
