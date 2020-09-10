function o = add(o,list)
% 
% ADD   Add a trace object or list of objects to data
%
%    Syntax
%       o = add(carabao,o1)          % add o1 to empty data list
%       o = add(o,o2)                % add a further object o2 to data list
%       o = add(o,{o3,o4})           % add all objects of list to data list 
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
%    See also: CARABAO, PASTE
%
   either = util(o,'either');          % need some utility
   
   len = data(o,inf);                  % get length of list
      
% arg2 is either a list or 'object' (no list). In case of an 'object' we
% pack the object into a list. Note that ADD does not really check whether
% list elements are objects.

   if ~iscell(list)
      list = {list};                 % make a list
   end

% add the objects

   olist = either(data(o),{});

   if ~iscell(olist)
      error('object''s data type is not for adding objects!')
   end
   
   for (i=1:length(list))
      oo = list{i};                    % pick i-th object from list
      oo = clean(oo);                  % cleanup oject
      olist{end+1} = oo;
   end
   
   o = data(o,olist);
   return
end   

