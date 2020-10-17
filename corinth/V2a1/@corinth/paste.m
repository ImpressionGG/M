function paste(o,ilist,refreshing)     % Paste Object(s) into Shell    
%
% PASTE   Paste an object into current shell
%
%    For CORINTH class the paste method had to be adopted, since the
%    corazon/paste method uses the add method to add an object to container
%    list. corinth/paste has been rewritten and uses local Add.s
%
%    Paste a Corazon object or a list of Corazon objects into current
%    shell.
%
%       paste(o,{o1,o2,...})           % paste a list of objects
%       paste(o,{o1,o2,...},false)     % paste objects without refreshing
%
%    Inherit launch function before pasting:
%
%       paste(oo);                     % inherit launch function and paste
%       paste(o,oo);                   % inherit launch function and paste
%
%    With two arguments called the first argument determines the figure
%    if a figure handle is proided.
%
%       paste(o,{o1,o2,...})           % paste a list of objects
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, CURRENT
%
   [either] = util(o,'either');        % need some utility
 
      % dispatch syntax: paste(oo)
      
   if (nargin == 1)
      oo = pull(o);
      o = launch(o,launch(oo));        % provide shell's launch function

      co = cast(oo,'corazon');
      paste(co,{o});
      return
   end
   
      % otherwise dispatch syntax: paste(o,oo)
      
   if (nargin == 2 && isa(ilist,'corazon'))  
      oo = ilist;
      oo = launch(oo,launch(o));       % provide shell's launch function
      paste(o,{oo});                   % use the general case of pasting
      return
   end

      % continue dispatching more general cases
   
   if (nargin < 3)
      refreshing = true;
   end
   
   if (nargin == 1)
      if container(o)
         list = data(o);               % get list of objects;
      else
         list = {o};                   % make list of objects to add
      end
   elseif (nargin >= 2)
      if isempty(ilist)
         return                        % don't cause an error
      elseif iscell(ilist)             % list of objects?
         list = ilist;                 % copy input list
      else
         error('list expected for arg2!');
      end
   end
   
% finally we have a list with only trace objects. We can assert that
% But we also need to be sure that the figure object is a container object,
% otherwise we will alert and stop

   for (i=1:length(list))
      if ~isa(list{i},'corazon');
         error('all objects to paste must be CORAZON objects!');
      end
      if container(list{i});
         error('all objects to paste must be container objects!');
      end
   end
   
   o = pull(corazon);                  % get figure object
   if isempty(o)
      error('no shell to paste object!');
   end
   
   if ~container(o)
      opts = opt(o);                   % save options
      o = construct(o,class(o));
      o.data = {};                     % create a container object
      o = opt(o,opts);                 % copy options
      callback = control(o,'refresh'); % save current refresh callback
      o = control(o,'refresh',{'menu','About'});
      launch(o);
      refresh(o,callback);             % restore original refresh callback
      o = pull(corazon);               % get figure object
   end
      
% now let's add the list to the figure object

   enabled = dynamic(o);               % is dynamic shell enabled?
   if (~enabled)                       % if no dynamic shell
      for (i=1:length(list))
         if ~isequal(class(o),class(list{i}))
            message(o,['Can only paste objects of class ',class(o),'!']);
            return
         end
      end
   end
%
% otherwise add object to list of objects and select last object in list
% as current object
%
   number = length(o.data);
   
   [o,idx] = Add(o,list);              % add list to object
   o = push(o);                        % push object back to shell
   
   if isempty(idx)
      o = current(o,'Last');           % set last trace as current trace
   else
      o = current(o,idx(end));
   end
   
%  o = current(o,number+1);            % set last trace as current trace
   
   if (refreshing)
      refresh(o);                      % refresh the screen
   end
end

%==========================================================================
% Local Add (to add objects to container list) 
%==========================================================================

function [o,idx] = Add(o,list)                                         
% 
% ADD   Add a trace object or list of objects to data
%
%    Syntax
%       [o,idx] = Add(corazon,o1)    % add o1 to empty data list
%       [o,idx] = Add(o,o2)          % add a further object o2 to data list
%       [o,idx] = Add(o,{o3,o4})     % add all objects of list to data list 
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
   
      % first run (works if object IDs provided)
      
   oids = {};
   for (i=1:length(list))
      oo = list{i};
      oid = get(oo,'oid');
      if ~isempty(oid)
         oids{end+1} = oid;
      end
   end
   
   if (length(oids) == length(list))   % then all oids available
      [oids,index] = sort(oids);
      list = list(index);
      map(index) = 1:length(index);    % create index map
      idx = map(idx);                  % map indices
      return                           % lucky - bye!
   end
   
      % second run
      
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
         oo = var(oo,'done',true);     % mark as done
         packages{end+1} = oo;
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
   while ~isempty(packages)
      po = packages{1};                % with k-th package object
      packages(1) = [];                % reduce packages list
      
         % first put package object into sorted list
         
      pid = get(po,{'package','?#?'}); % get package ID
      slist{end+1} = po;               % add package object to sorted list
      
         % next find ozher packages with same package id, which have to be 
         % put into sorted list
      
      pdx = [];                        % get indices with matching pid 
      for (i=1:length(packages))
         po = packages{i};
         if isequal(pid,get(po,{'package','?-?'}))
            pdx(end+1) = i;
            slist{end+1} = po;
         end
      end
      packages(pdx) = [];
         
         % finally add data objects with matching package ID to be
         % added to sorted list
         
      for (i=1:length(list))
         oo = list{i};
         if ~var(oo,{'done',0})
            if ~type(oo,{'pkg'}) && is(get(oo,'package'),pid)
               slist{end+1} = oo;         % add matching data object to slist
               oo = var(oo,'done',true);
               list{i} = oo;              % mark as 'done'
            end
         end
      end      
   end
 
      % finally add all objects with non-assigned package ID
      
   for (i=1:length(list))
      oo = list{i};
      if ~var(oo,{'done',0})
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
