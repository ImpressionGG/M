%
% PROP   Get/set a CORAZITA object's property
%
%    Syntax:
%       bag = prop(o)                  % same as bag = struct(o)
%       value = prop(o,tag);           % get an object property
%       o = prop(o,tag,value);         % set an object property
%
%    Multiple Get
%
%       list = prop(o,{'par.system'},'A,B,C')      % direct get
%       list = prop(o,{'par.system'},{'A,B',A,B})  % conditional get
%
%    Multiple Set
%
%       o = prop(o,{'par.system'},'A,B,C',A,B,C)   % direct set 
%       o = prop(o,{'par.system'},'A,B,C',{A,B,C}) % direct set 
%
%       o = prop(o,{'par.system'},{'A,B'},A,B)     % conditional set 
%       o = prop(o,{'par.system'},{'A,B'},{A,B})   % conditional set 
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
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITA, GET, SET, VAR, OPT, WORK, TYPE
%
