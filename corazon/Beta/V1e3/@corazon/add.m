function [o,idx] = add(o,list)
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
   either = util(o,'either');          % need some utility
   
   len = data(o,inf);                  % get length of list
   idx = [];                           % init
      
% arg2 is either a list or 'object' (no list). In case of an 'object' we
% pack the object into a list. Note that ADD does not really check whether
% list elements are objects.

   if ~iscell(list)
      list = {list};                   % make a list
   end

% add the objects

   olist = either(data(o),{});

   if ~iscell(olist)
      error('object''s data type is not for adding objects!')
   end
   
   idx = [];
   for (i=1:length(list))
      oo = list{i};                    % pick i-th object from list
      oo = clean(oo);                  % cleanup oject
      olist{end+1} = oo;
      idx(end+1) = length(olist);
   end
   
   [olist,idx] = Sort(o,olist,idx);
   
   o = data(o,olist);
   return
end   

%==========================================================================
% Sort Objects With Respect of package Objects
%==========================================================================

function [list,idx] = Sort(o,list,idx)
%
% SORT    Sort object list with respect to packages. Bring in the order
%         
%            {pkg1, o11,o12,...,o1m1, pkg2, o21,o22,...,o2m2, ...
%             pkg3, o31,o32,...,o3m3, pkgn, on1,on2,...,onmn}
%
   is = @isequal;                      % short hand
   packages = {};                      % init list of packages
   for (i=1:length(list))
      oo = list{i};
     
      if any(idx==i)
         oo = var(oo,'index',i);       % mark as reminder if indexed
      else
         oo = var(oo,'index',[]);      % unmark, since not indexed
      end

         % if package object found => add to package list (packages)
         
      if type(oo,{'pkg'})
         packages{end+1} = oo;
         oo = var(oo,'done',true);     % mark as done
      end
      list{i} = oo;                    % put back into list with marks
   end
   
      % now packages is a list of all package objects; if packages is empty
      % we are done
      
   if isempty(packages)
      return
   end
   
      % otherwise build up sorted list (slist)
      
   slist = {};
   for (k=1:length(packages))
      po = packages{k};                % with k-th package object
      pid = get(po,{'package','?#?'}); % get package ID
      slist{end+1} = po;               % add package object to sorted list
      
      for (i=1:length(list))
         oo = list{i};
         if ~type(oo,{'pkg'}) && is(get(oo,'package'),pid)
            slist{end+1} = oo;         % add matching data object to slist
            oo = var(oo,'done',true);
            list{i} = oo;              % mark as 'done'
         end
      end      
   end
 
      % finally add all objects with empty package ID
      
   for (i=1:length(list))
      oo = list{i};
      if ~var(oo,'done')
         slist{end+1} = oo;            % add unmatched data object to slist
      end
   end      
   
      % now the list is sorted; check equal length of lists
      
   assert(length(list)==length(slist));
      
      % final task is to map indices in compliance
      % with new order; first setup the mapping vector
      
   map = 0*(1:length(list));
   for (j=1:length(idx))
      map(idx(j)) = j;
   end

   list = slist;                       % copy slist to list (out arg)
   for (i=1:length(list))
      oo = list{i};
      index = var(oo,'index');
      if ~isempty(index)
         k = map(index);
         idx(k) = i;                   % re-mapped
      end
      list{i} = var(oo,[]);            % put back cleared into list
   end      
end