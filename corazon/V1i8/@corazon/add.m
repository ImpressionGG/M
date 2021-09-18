% 
% ADD   Add a trace object or list of objects to data
%
%    Syntax
%       [o,idx] = add(corazon,o1)    % add o1 to empty data list
%       [o,idx] = add(o,o2)          % add a further object o2 to data list
%       [o,idx] = add(o,{o3,o4})     % add all objects of list to data list 
%
%    Note: for each trace object that enters the trace list, the work
%    environment of the entered trace will be cleared. This is in diffe-
%    rence to the case where the list is directly set!
%
%    Note: it is assumed that in case of trace lists all elements of the
%    list are (trace) objects. For future expansion, however, this list
%    must not contain objects, and ADD will also not take care of the type
%    of the actual list elements or 'object' to be added.
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, PASTE
%
