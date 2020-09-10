function paste(o,ilist,refreshing)     % Paste Object(s) into Shell    
%
% PASTE   Paste an object into current shell
%
%    Paste a Carabao object or a list of Carabao objects into current
%    shell.
%
%       paste(oo);                     % paste object into shell
%
%       paste(o,{o1,o2,...})           % paste a list of objects
%       paste(o,{o1,o2,...},false)     % paste objects without refreshing
%
%    With two arguments called the first argument determines the figure
%    if a figure handle is proided.
%
%       paste(o,{o1,o2,...})           % paste a list of objects
%
%    See also: CARABAO, CURRENT
%
   [either] = util(o,'either');             % need some utility
 
   if (nargin == 1)
      oo = pull(o);
      co = cast(oo,'carabao');
      paste(co,{o});
      return
   end
   
   if (nargin < 3)
      refreshing = true;
   end
   
   if (nargin == 1)
      if container(o)
         list = data(o);                    % get list of objects;
      else
         list = {o};                        % make list of objects to add
      end
   elseif (nargin >= 2)
      if isempty(ilist)
         return                             % don't cause an error
      elseif iscell(ilist)                  % list of objects?
         list = ilist;                      % copy input list
      else
         error('list expected for arg2!');
      end
   end
   
% finally we have a list with only trace objects. We can assert that
% But we also need to be sure that the figure object is a container object,
% otherwise we will alert and stop

   for (i=1:length(list))
      if ~isa(list{i},'carabao');
         error('all objects to paste must be CARABAO objects!');
      end
      if container(list{i});
         error('all objects to paste must be nön-container objects!');
      end
   end
   
   o = pull(carabao);                  % get figure object
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
      o = pull(carabao);               % get figure object
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
   o = add(o,list);                    % add list to object
   o = push(o);                        % push object back to shell
   o = current(o,'Last');              % set last trace as current trace
   
   if (refreshing)
      refresh(o);                      % refresh the screen
   end
end

