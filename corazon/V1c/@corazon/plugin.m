function oo = plugin(o,varargin)
%
% PLUGIN   Plugin manager method
%
%             list = plugin(o)         % get plugin list
%             plugin(o)                % print registered plugins
%
%             plugin(o,list)           % replace plugin list by arg2
%             plugin(o,{})             % clear plugin list
%
%             plugin(o,key,cblist)     % register plugin callback
%             plugin(o,key)            % provide plug point
%
%          Example 1: corazon/shell/Info provides a plugin point
%
%             function oo = Info(o)    % corazon/shell/Info function
%                oo = menu(o,'Info');  % add Info menu
%                key = 'corazon/menu/Info';
%                plugin(oo,key)        % provide plugin point
%             end
%
%          Example 2: a plugin function xyplot registers two plugin
%          menu items
%
%             function o = Register(o)
%                plugin(o,'espresso/shell/Plot','xyplot','Plot');
%                plugin(o,'corazon/menu/Info','xyplot','Info');
%             end
%
%          Copyright (c): Bluenetics 2020 
%
%          See also: CORAZON
%
   [gamma,o] = Plugin(o,varargin,nargout); % pass to Event work horse
   [gammas,oos] = gamma(o);            % execute work horse
   
   for (i=1:size(gammas,1))
      oo = gammas{i,1}(oos{i});        % execute all actions
   end
end

%==========================================================================
% Plugin Manager
%==========================================================================

function [gamma,oo] = Plugin(o,ilist,nout)                             
%
% PLUGIN   Plugin work horse
%
%             [gamma,oo] = Plugin(o,ilist,nout)
%
   o.profiler('plugin',1);
   nin = 1 + length(ilist);            % nargin of calling function
%
% one input argument
% a) list = plugin(o) % get plugin list
% b) plugin(o) % print registered plugins
%
   while (nin == 1)
      if (nout == 0)
         %ShowPlugin(o,plugins);
         gamma =@ShowPlugin;  oo = o;
      else
         oo = o;                       
         gamma = @FollowupGet;         % return plugin list
      end
      o.profiler('plugin',0);
      return
   end
%
% two input args
% a) plugin(o,list) % replace plugin list by arg2
% b) plugin(o,{}) % clear plugin list
% c) plugin(o,key) % provide plugin point
%
   while (nin == 2)
      if iscell(ilist{1})              % arg2 is a list
         % plugins = key;              % replace plugin list by arg2
         list = ilist{1};              % arg1 is a list
         oo = arg(o,{list});           % pass new plug list as arg1
         gamma = @SetPlugList;         % follow-up with SetPlugList
      elseif ischar(ilist{1})          % arg2 is a char key
         %list = PlugPoint(o,key);     % provide plug point
         key = ilist{1};               % get input arg
         oo = arg(o,{key});
         gamma = @PlugPoint;
      else
         error('list or char expected for arg2!');
      end
      o.profiler('plugin',0);
      return
   end
%
% three input args
% a) plugin(o,key,cblist) % register plugin callback
%   
   while (nin == 3) && ischar(ilist{1}) && iscell(ilist{2})
      key = ilist{1};  cblist = ilist{2};
      % plugins = Register(o,key,cblist,plugins);
      gamma = @Register;
      oo = arg(o,ilist);
      o.profiler('plugin',0);
      return
   end
%
% Anything beyond this point indicates bad calling syntax
%
   error('bad calling syntax!');
end

%==========================================================================
% Work Horses
%==========================================================================

function [gammas,oos] = FollowupGet(o) % Prepare Running GetPluginList 
   gammas = {@GetPlugList};  oos = {o};
end
function [gammas,oos] = SetPlugList(o) % Set PlugList                  
   list = arg(o,1);                    % get plugin list to replace
   Persistent(list);                      % set plugin list
   gammas = {};  oos = [];             % no followups
end
function [gammas,oos] = PlugPoint(o)   % Provide Plug Point            
   o.profiler('PlugPoint',1);
   plugkey = arg(o,1);                 % fetch arg1
   is = @isequal;                      % short hand
   
   so = pull(o);                       % shell object
   list = Persistent;                  % get plugin list

   olist = {};  gammas = {};  oos = {};
   for (i=1:length(list))
      entry = list{i};
      key = entry{1};  
      cblist = entry{2};
      tag = entry{3};
      %if isequal(plugkey,key) && isequal(o.tag,tag)
      if is(plugkey,key) && is(so.tag,tag)
         olist{end+1} = key;
         o.profiler('PlugPointCall',1);
         %call(o,cblist);
         [oo,gamma] = call(o,cblist);
         %gammas{end+1,1} = gamma;
         gammas(end+1,1:length(cblist))=[{gamma},cblist(2:end)];
% introduced cast in next statement
%        oos{end+1} = oo; 
         oos{end+1} = cast(oo,tag);    % cast in order that callback works
         o.profiler('PlugPointCall',0);
      end
   end
   
      % register caller in plugin track list
      
%  path = mseek(o);
%  list = control(pull(o),'plugin');   % get actual plugin track list
%  for (i=1:length(list))
%     entry = list{i};
%     if is(plugkey,entry{1}) && is(path,entry{2}) && is(o.tag,entry{3})
%        o.profiler('PlugPoint',0);
%        return
%     end
%     cblist = entry{2};
%     tag = entry{3};
%  end
%    
%  list{end+1} = {plugkey,path,o.tag}; % update plugin track list
%  control(o,'plugin',list);           % update control settings

   gammas(end+1,1:3) = {@Track,plugkey,olist};
   oos{end+1} = arg(o,{plugkey,olist});
   o.profiler('PlugPoint',0);
end
function [gammas,oos] = Register(o)    % Register a Plugin Callback    
%
% REGISTER   Register a plugin entry. Plugin-entries are stored as 
%            cell arrays: {key,cblist,tag}
%
%            Requires two input args
%               key      arg(o,1)      % plug key
%               cblist   arg(0,2)      % plugin callback list
%
   gammas = {};  oos = [];             % no followups

   key = arg(o,1);                     % get plugin key
   cblist = arg(o,2);                  % get plugin callback list
   list = Persistent;                  % get plugin list
   
   is = @isequal;                      % short hand
   tag = o.tag;
   
      % search if entry is already registered
      
   for (i=1:length(list))
      entry = list{i};
      if is(entry{1},key) && is(entry{2},cblist) && is(entry{3},tag)
         return                        % plugin already registered
      end
   end
   
   list{end+1} = {key,cblist,tag};
   Persistent(list);                   % refresh plugin list
end

%==========================================================================
% Show Plugin Register and Plugin Points
%==========================================================================

function [gammas,oos] = ShowPlugin(o)  % Show Plugin Info              
   plugins = Persistent;               % get persistent plugin list
   fprintf('List of plugin points:\n');
   list = control(o,'plugin');
   for (i=1:length(list))
      entry = list{i};
      key = entry{1};
      path = entry{2};
      tag = entry{3};
      
      fprintf('   Class %s: plug point [%s] @ ',tag,key);
      for (j=1:length(path))
         item = path{j};
         if (length(item) > 0 && item(1) == '#')
            fprintf('Menubar');
         else
            fprintf('>%s',item);
         end
      end
      fprintf('\n');
   end
   fprintf('\n');
   
   fprintf('List of registered plugin callbacks:\n');
   for (i=1:length(plugins))
      entry = plugins{i};
      key = entry{1};
      cblist = entry{2};
      tag = entry{3};
      fprintf(['   Class ',tag,': registered [',key,'] @ callback ']);
      if ~iscell(cblist)
         fprintf('...');
      else
         fprintf('{');
         sep = '';
         for (j=1:length(cblist))
            if ischar(cblist{j})
               fprintf('%s''%s''',sep,cblist{j});
            elseif isa(cblist{j},'function_handle')
               fprintf('%s@%s',sep,char(cblist{j}));
            else
               fprintf('%s...',sep);
            end
            sep = ',';
         end
         fprintf('}');
      end
      fprintf('\n');
   end
   if isempty(plugins)
      fprintf('   *** no plugins registered ***\n');
   end
   
   gammas = {};  oos = {};
end

%==========================================================================
% Managing the Plug List
%==========================================================================

function list = Persistent(list)       % Get/Set Persistent Plug List  
%
% PERSISTET Managing the persistent plug list
%
%              Persistent(list)        % set plug list
%              list = Persistent       % get plug list
%
   persistent plugins;                 % persistent list of plugins
   if (nargin == 0)
      list = plugins;
   else
      plugins = list;
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function oo = GetPlugList(o)           % Get PlugList                  
   oo = Persistent;                    % get plugin list
end
function oo = Track(o)                 % Track Plugin Callers          
   o.profiler('Track',1);
   is = @isequal;                      % short hand
   plugkey = arg(o,1);                 % fetch arg1
   olist = arg(o,2);                   % fetch arg2
   path = mseek(o);

   oo = olist;                         % return olist (from PlugPoint)
   list = control(pull(o),'plugin');   % get actual plugin track list
   for (i=1:length(list))
      entry = list{i};
      ekey = entry{1};  epath = entry{2};  etag = entry{3};
      
      if is(plugkey,ekey) && is(path,epath) && is(o.tag,etag)
         o.profiler('Track',0);
         return                        % found! no list update!
      end
   end
   
   list{end+1} = {plugkey,path,o.tag}; % update plugin track list
   control(o,'plugin',list);           % refresh control settings

   o.profiler('Track',0);
end

