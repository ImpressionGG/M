function out = toolbox(obj,mode,arg1)
%
% TOOLBOX   Request or change global settings of SMART toolbox
%
%    As a SMART method first argument has always to be a SMART
%    object. Since this argument has no further meaning, a generic
%    SMART object (such as 'smart') will do its job.
% 
%     out = toolbox(smart,mode,...)
% 
%    The TOOLBOX function provides several modes:
% 
%       'hook'     Handle for hooking in plug-in menu items
%       'plugin'   Setup or get list for plug-in menu items
%       'database' Setup Smart Data Base
%       'home'     Setup a home root directory
%       'work'     Setup a working root directory
% 
%    HOOK: get (toolbox provided) hook for Add-On menu items
% 
%       aon = toolbox(smart,'hook');  % handle for hooking Add-Ons
% 
%    PLUGIN:     Setup or get list for Plug-In menu items
% 
%       list = toolbox(smart,'plugin');  % get current Plug-In list
%       toolbox(smart,'plugin','mytool'); % add 'mytool' to Plug-In list
%       toolbox(smart,'plugin',{'tool1','tool2');  % initialize new plug-in list
% 
%    DATABASE:    Setup Data Base
% 
%     toolbox(smart,'database');   % get current launch base function 
%     toolbox(smart,'database','tf181db'); % use 'tf181db' for data base
% 
%    VERSION:   Get CORE toolbox version
% 
%     toolbox(smart,'launch');   % get current launch base function 
%     toolbox(smart,'launch','gmabase'); % use 'gmabase' for launch
% 
%    SMART Toolbox does not depend on other user provided tool boxes.
% 
%    See also: CORE
%
   switch mode
       case 'hook'
          out = hook;
       case {'addon','plugin'}
          arg1 = eval('arg1','NaN');
          out = addon(arg1);
       case 'database'
          arg1 = eval('arg1','NaN');
          out = database(arg1);
       case 'launch'
          arg1 = eval('arg1','NaN');
          out = launch(arg1);
       case 'work'
          arg1 = eval('arg1','NaN');
          path = work(arg1);
          if (nargout >= 1 || nargin >= 3)
             out = path;
          else
             cd(path);
             fprintf(['Current working directory: ',upath(obj,path),'\n']);
          end
       case 'home'
          arg1 = eval('arg1','NaN');
          path = home(arg1);
          if (nargout >= 1 || nargin >= 3)
             out = path;
          else
             cd(path);
             fprintf(['Current home directory: ',upath(obj,path),'\n']);
          end
       case 'version'                    % CORE toolbox version
          out = version(shell);
       otherwise
          error(['hook(): unknown mode: ',mode]);
   end
   return
end

%==========================================================================
% Auxillary functions
%==========================================================================

function aon = hook 
%
% HOOK    Get (toolbox provided) hook for Add-On menu items
%         By default HOOK provides a handle of the current figure (GCF). 
%         If, however, a recursive sequence of children is found with
%         userdata = 'addon', then the last handle of this sequence is
%         returned. This allows a general control for the hook-in location
%         of Add-On menu items.
%
%         Example:
%            men = uimenu(gcf,'label','Menu 1');
%            men = uimenu(gcf,'label','Menu 2','userdata','addon');
%                  uimenu(men,'label','Stuff 1');
%                  uimenu(men,'label','Add-Ons','userdata','addon');
%                  uimenu(men,'label','Stuff 2');
%            men = uimenu(gcf,'label','Menu 3');
%
%            aon = addon(obj);   % get add-on hook proposed by toolbox
%
%         The subsequent call to ADDON (without input args) returns the
%         handle to the sub-menu entry which is labelled 'Add-Ons'.
%
%
   aon = gcf;
   children = get(aon,'children');
   i = 0;
   while (1)
      i = i + 1;
      if (i > length(children))
         out = aon;                         % return value is 'aon'
         return;   
      end
      ch = children(i);
      udata = get(ch,'userdata');
      if isstr(udata)
         if (strcmp(lower(udata),'addon'))
            aon = ch;                       % ok, hook is this child  
            children = get(aon,'children'); % or children of child
            i = 0;                          % check from 1st child
         end
      end
   end
   return
end

%==========================================================================   

function list = addon(arg)
% ADDON   Menu extension for CHAMEO objects. A single input argument is 
%         used for manipulating current Add-On lists.
%
%            obj = smart;                     % create CHAMEO object
%
%            list = addon(obj,'mytool');       % add 'mytool' to addon list
%            list = addon(obj,{aon1','aon2'}); % setup specified addon list
%            list = addon(obj,{})              % reset addon list
%            list = addon(obj,NaN)             % retrieve addon list
%
   list = gso('plugin');
   if (isempty(list))
      list = {};
   end
   
   if (isstr(arg))
      for (i=1:length(list))
          if (strcmp(list{i},arg))
              return;                          % if found in list then done
          end
      end                                    
      list{length(list)+1} = arg;              % else append arg1 to list
   elseif (iscell(arg))
      list = arg;                              % replace current AddOn list
   elseif (isnan(arg))
      % done                                   % just retrieve list
   else
      error('string or cell array expected for arg1!');
   end

   gso('plugin',list);                         % store to global variable
   return
end

%==========================================================================   

function func = launch(arg)
%
% LAUNCH  Get or set current launch base function.
%
%            obj = smart;              % create SMART object
%
%            func = launch(obj);        % get current launch base
%            launch(obj,'gmabase');     % define 'gmabase' for launch
%            launch(obj,'')             % reset launch base
%            launch(obj,NaN)            % reset launch base
%
   func = gso('launch');                % retrieve launch base
   if (isempty(func))
       func = '';                       % always use empty string
   end
   
   if (isstr(arg))
      func = arg;                       % set arg1 as launch base
   elseif (isnan(arg))
      % done                            % just retrieve list
   else
      error('string or [] expected for arg1!');
   end
   gso('launch',func);                  % store to global variable
   return
end

%==========================================================================   

function func = database(arg)
%
% DATABASE  Get or set current data base function.
%
%            obj = smart;              % create SMART object
%
%            func = database(obj);      % get current data base base
%            database(obj,'gmabase');   % define 'gmabase' for database
%            database(obj,'')           % reset data base
%            database(obj,NaN)          % reset data base
%
   func = gso('database');              % retrieve data base
   if (isempty(func))
       func = '';                       % always use empty string
   end
   
   if (isstr(arg))
      func = arg;                       % set arg1 as launch base
   elseif (isnan(arg))
      % done                            % just retrieve list
   else
      error('string or [] expected for arg1!');
   end
   gso('database',func);                % store to global variable
   return
end

%==========================================================================   
   
function path = work(arg)
%
% WORK   Get or set current working directory.
%
%            obj = smart;               % create SMART object
%
%            path = work(obj);          % get current working directory
%            work(obj,'e:/TF181/m');    % define current working directory
%            work(obj,'');              % reset current working directory
%            work(obj,NaN);             % reset current working directory
%
   path = gso('work');                  % retrieve current working dir
   if (isempty(path))
       path = '';                       % always use empty string
   end
   
   if (isstr(arg))
      path = arg;                       % set arg1 as current working dir
   elseif (isnan(arg))
      % done                            % just retrieve working dir
   else
      error('string or [] expected for arg1!');
   end
   gso('work',path);                    % store to screen settings
   return
end

function path = home(arg)
%
% HOME   Get or set current working directory.
%
%            obj = smart;               % create SMART object
%
%            path = home(obj);          % get current working directory
%            home(obj,'e:/TF181/m');    % define current working directory
%            home(obj,'');              % reset current working directory
%            home(obj,NaN);             % reset current working directory
%
   path = gso('home');                  % retrieve current home dir
   if (isempty(path))
       path = '';                       % always use empty string
   end
   
   if (isstr(arg))
      path = arg;                       % set arg1 as current home dir
   elseif (isnan(arg))
      % done                            % just retrieve working dir
   else
      error('string or [] expected for arg1!');
   end
   gso('home',path);                    % store to screen settings
   work(path);
   return
end   
