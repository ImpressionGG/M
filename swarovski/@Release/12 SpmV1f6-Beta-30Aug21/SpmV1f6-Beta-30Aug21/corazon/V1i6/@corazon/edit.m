%
% EDIT   Edit object parameters
%
%           oo = edit(o);              % edit provided object directly
%           edit(o);                   % edit current object
%           edit(o,idx);               % edit object with index idx
%
%        The edit dialog is constructed on base of the edit property.
%        Example:
%
%           list = {{@new 'PT1'},...
%                   {'V','Gain'},{'T','Time Constant'}}
%           o = set(o,'edit',list);
%
%        if an update callback is provided (get(oo,'update')) then the 
%        update callback will be executed after confirmed exit of the
%        edit mode.
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZON, UPDATE
%
