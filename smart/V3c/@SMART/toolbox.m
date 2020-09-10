function out = toolbox(obj,mode,arg1)
%
% TOOLBOX   Request or change global settings of SMART toolbox
%           As a SMART method first argument has always to be a SMART
%           object. Since this argument has no further meaning, a generic
%           SMART object (such as 'smart') will do its job.
%
%              out = toolbox(smart,mode,...)
%
%           The TOOLBOX function provides several modes:
%
%              'hook'     Handle for hooking in Add-On menu items
%              'addon'    Setup or get list for add-On menu items
%              'launch'   Setup Smart Launch Base
%
%           HOOK: get (toolbox provided) hook for Add-On menu items
%
%              aon = toolbox(smart,'hook');  % handle for hooking Add-Ons
%
%           ADDON:     Setup or get list for Add-On menu items
%
%              list = toolbox(smart,'addon');   % get current Add-On list
%              toolbox(smart,'addon','mytool'); % add 'mytool' to Add-On list
%              toolbox(smart,'addon',{'tool1','tool2');  % initialize new addon list
%
%           LAUNCH:    Setup Launch Base
%
%              toolbox(smart,'launch');   % get current launch base function 
%              toolbox(smart,'launch','gmabase'); % use 'gmabase' for launch
%
%           VERSION:   Get Chameo toolbox version
%
%              toolbox(smart,'launch');   % get current launch base function 
%              toolbox(smart,'launch','gmabase'); % use 'gmabase' for launch
%
%           SMART Toolbox does not depend on other user provided tool boxes.
%
%           See also: SMART, SMART/CRASH
%
   VERSION = 'V1I';
   
   switch mode
       case 'hook'
          out = hook;
       case 'addon'
%           arg1 = eval('arg1','NaN');
          if ( nargin < 3 ),
             arg1 = 'NaN';
          end
          out = addon(arg1);
       case 'launch'
%           arg1 = eval('arg1','NaN');
          if ( nargin < 3 ),
             arg1 = 'NaN';
          end
          out = launch(arg1);
       case 'version'                    % CHAMEO toolbox version
          out = VERSION;
       otherwise
          error(['hook(): unknown mode: ',mode]);
   end
   return
   
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
%          out = aon;                         % return value is 'aon'
         return;   
      end
      ch = children(i);
      udata = get(ch,'userdata');
      if ischar(udata)
         if (strcmpi(udata,'addon'))
            aon = ch;                       % ok, hook is this child  
            children = get(aon,'children'); % or children of child
            i = 0;                          % check from 1st child
         end
      end
   end
   return

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
   persistent ChameoAddonList % global ChameoAddonList
%    ChameoAddonList = eval('ChameoAddonList;','{}');   % assure initialized
   if isempty(ChameoAddonList),
     ChameoAddonList={};
   end
   
   list = ChameoAddonList;                     % retrieve AddOn list
   if (isempty(list))
      list = {};
   end
   
   if (ischar(arg))
      for i=1:length(list),
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
   ChameoAddonList = list;                     % store to global variable
   return
   
%==========================================================================   

function func = launch(arg)
%
% LAUNCH  Get or set current launch base function.
%
%            obj = smart;              % create CHAMEO object
%
%            func = launch(obj);        % get current launch base
%            launch(obj,'gmabase');     % define 'gmabase' for launch
%            launch(obj,'')             % reset launch base
%            launch(obj,NaN)            % reset launch base
%
   persistent ChameoLaunchBase % global ChameoLaunchBase
%    ChameoLaunchBase = eval('ChameoLaunchBase;','[]');  % assure initialized
   if isempty(ChameoLaunchBase),
     ChameoLaunchBase=[];
   end
   
   func = ChameoLaunchBase;                    % retrieve launch base
   if (isempty(func))
       func = '';                              % always use empty string
   end
   
   if (ischar(arg))
      func = arg;                              % set arg1 as launch base
   elseif (isnan(arg))
      % done                                   % just retrieve list
   else
      error('string or [] expected for arg1!');
   end
   ChameoLaunchBase = func;                    % store to global variable
   return
   
%eof