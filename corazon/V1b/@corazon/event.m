function oo = event(o,varargin)
%
% EVENT   Register an event or invoke event
%
%    1) Register an event
%
%       event(o,'Current',cblist)      % add cblist to 'Current' registry 
%       event(o,'Current',o)           % add call to current function
%
%    2) Invoke an event
%
%       event(o,'Current')             % invoke event 'Current'
%       event(arg(o,args),'Current')   % invoke event, passing args
%
%    3) Reset event registrations
%
%       event(o,{})                    % reset all events
%       event(o,{},'Current')          % reset registry for 'Current'
%
%    4) Show event registry
%
%       event(o)                       % show event registry
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, WRAP, REBUILD, CURRENT
%
   [gammas,oos] = Event(o,varargin);   % pass to Event work horse
   for (i=1:length(gammas))
      oo = gammas{i}(oos{i});          % execute all actions
   end
end

function [gammas,oos] = Event(o,ilist) 
%
% EVENT   Working horse for EVENT method. The local function must return
%         a list of actions {{gamma1,o1},{gamma2,o2},...,{gamman,on}}
%         which will be executed by the caller.
%
   Nargin = 1 + length(ilist);
   if (Nargin == 1)
      [gammas,oos] = Show(o);          % show event registry
      return
   end
%
% Two input args
% a) event(o,'current') % invoke event 'current'
% b) event(arg(o,args),'current') % invoke event, passing args
% c) event(o,{}) % reset all events
%
   if (Nargin == 2)
      tag = lower(ilist{1});
      if ischar(tag)
         [gammas,oos] = Actions(o,tag);
      elseif iscell(tag) && isempty(tag)
         [gammas,oos] = Reset(o);
      else
         error('bad calling syntax for 3 input args!');
      end
      return
   end
%
% Three input args
% a) event(o,'current',cblist) % add cblist to 'current' registry 
% b) event(o,'current',o) % add call to current function
% c) event(o,{},'current') % reset registry for 'current'
%
   if (Nargin == 3)
      tag = lower(ilist{1});  cblist = ilist{2};
      if ischar(tag)
         [gammas,oos] = Register(o,tag,cblist);
      elseif iscell(tag) && isempty(tag)
         [gammas,oos] = Reset(o,cblist);
      else
         error('bad calling syntax for 3 input args!');
      end
      return
   end
%
% Running beyond this point indicates bad calling syntax
%
   error('bad calling syntax!');
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [gammas,oos] = Register(o,tag,cblist)    % Register an Event             
%
% REGISTER   Register a callback
%
%               oo = register(o,'current',cblist)  % explicit callback list
%               oo = register(o,'current',o)       % call current function
%
   gammas = {}; oos = {};              % default: no actions to follow up
   if isobject(cblist)
      [func,file] = caller(o,3);       % get calling function
      handler = eval(['@',file]);
      cblist = [{handler,func},arg(o,0)];
   end
   
      % construct triplet containing cblist, object class and menu path
      
   mpath = mseek(o);                   % get menu path
   triplet = {cblist,class(o),mpath};
   
      % add to event registry
      
   assert(ischar(tag));
   registry = control(pull(o),{'events',{}});
   entry = o.assoc(tag,registry);
   
      % check if triplet is already in event list (in this case return)
      
   for (i=1:length(entry))
      if isequal(entry{i},triplet)
         return                        % already found => nothing to add
      end
   end
   
      % otherwise we add triplet to entry and update registry with entry
   
   entry = [entry,{triplet}];
   registry = o.assoc(tag,registry,{tag,entry});
   
      % update registry
      
   control(o,'events',registry);       % update registry
end
function [gammas,oos] = Reset(o,tag)   % Reset an Event List           
   if (nargin <= 1)
      registry = {};
      control(o,'events',registry);    % clear total registry
   else
      registry = control(o,{'events',{}});
      registry = o.assoc(tag,registry,{});   % clear registry entry (tag)
   end
   gammas = {};  oos = {};             % no actions to follow up
end
function [gammas,oos] = Actions(o,tag) % Events Actions   

      % introducing pull(o) to make sure we work with a refreshed object
      
   %registry = control(pull(o),{'events',{}});
   o = o.either(pull(o),o);            % refresh
   registry = control(o,{'events',{}});
   
   entry = o.assoc(tag,registry);      % get tag entries
   gammas = {};  oos = {};             % init empty action list
   for (i=1:length(entry))
      triplet = entry{i};
      cblist = triplet{1};
      class = triplet{2};
      mpath = triplet{3};
      
      oo = cast(o,class);
      fig = figure(o);
      oo.work.mitem = fig;             % set figure
      oo.work.event = tag;             % set event tag
      oo = mseek(oo,mpath);            % seek & set mitem handle
      if ~isempty(oo)                  % if menu item found
         [oo,gamma] = call(oo,cblist); % get calling stuff
         % oo = gamma(oo);             % actual call
         gammas{end+1} = gamma;        % add to action list
         oos{end+1} = oo;              % add to object list
      end
   end
end
function [gammas,oos] = Show(o)        % Show Event Registry
   registry = control(pull(o),{'events',{}});
   fprintf('Event Registry:\n');
   for (i=1:length(registry))
      pair = registry{i};
      tag = pair{1};  entry = pair{2};
      fprintf('   Event ''%s'':\n',tag);
      for (j=1:length(entry))
         triplet = entry{j};
         cblist = triplet{1};
         class = triplet{2};
         mpath = triplet{3};
         fprintf('      {');
         sep = '';
         for (k=1:length(cblist))
            cbitem = cblist{k};
            if ischar(cbitem) || isa(cbitem,'function_handle')
               cbitem = char(cbitem);
            else
               cbitem = '...';
            end
            fprintf([sep,'''',cbitem,'''']);  sep = ',';
         end
         fprintf('} %s {',class);
         sep = '';
         for (k=1:length(mpath))
            fprintf([sep,mpath{k}]);  sep = ',';
         end
         fprintf('}\n');
      end
   end
   gammas = {};  oos = {};             % no furter action
end
