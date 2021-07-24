%
% DATA   Get or set object data settings
%  
%    Object data is stored in object's data properties.
%  
%       bag = data(o)                  % get data settings
%       data(o,bag)                    % refresh all data settings
%
%    Get/set specific data setting
%
%       x = data(o,'x')                % get value of specific data 
%       o = data(o,'x',x)              % set value of specific data
%
%       x = data(o,{'x',3})            % get with default value (if empty)
%       o = data(o,{'x'},3)            % set with default value (if empty)
%
%    Multiple Data Get
%
%       [x,y,z] = data(o,'x','y','z')  % multiple data get
%       [x,y,z] = data(o,'x,y,z')      % multiple data get
%
%    Multiple Data Set
%
%       o = data(o,'x',1,'y',2,...)    % multiple data set
%       o = data(o,'x,y',x,y)          % multiple data set
%
%    Package management
%
%       oo = data(o,{o1,o2,o3});       % set list of traces
%       list = data(o);                % return list of traces
%       oo = data(o,0);                % return container object            
%       oo = data(o,3);                % return 3rd object in list            
%       o = data(o,3,oo);              % replace 3rd object in list            
%
%    Indexing can only happen if the data is actually a list. With the 
%    syntax we can investigate the length of the list (or NaN is returned
%    if data is no list).
%
%       len = data(o,inf)              % length of list or NaN
%
%       dat = {o1,o2,o3}               % define as list of objects
%       len = data(data(o,dat),0)      % return 3
%         
%       dat = struct('x',x,'y',y)      % define data as structure
%       len = data(data(o,dat),0)      % return NaN
%
%    Note: it is assumed that in case of object lists all elements of the
%    list are (non-container) objects. For future expansion, however, this
%    list must not contain objects, and DATA will also not take care of the
%    type of the actual list elements.
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, PROP
%
