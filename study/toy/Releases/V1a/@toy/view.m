function view(obj,varargin)
%
% VIEW   View callback manager:
%
%    The vie method offers functions to handle key hit events
%
%       a) handles key press events
%       b) handles callbacks to assign the view
%       c) handles general callbacks, e.g. to popup context help
%
%    a) Setup generic key hit handler function
%    =========================================
%
%       view(toy,'setup');    % install generic keyhit handler
%
%    b) Handling Key Press Events
%    ============================
%
%       view(obj,owner,key,modifier)
%       view(obj,'Navigate','ctrl-u',{'control'})
%
%    c) Assigning a View Owner
%    =========================
%
%    Before a view can be used to handle key press events it must be
%    assigned to a proper view owner who handles all the key press
%    events:
%
%       view(obj,'Owner',owner,handles);  
%       view(obj,'Owner','Navigate',...);  
%
%       view(obj,'Owner',{'view','Navigate',...});    % same as above  
%       view(obj,'Owner',{'demo','ViewOwner'},{});    % custom owner
%
%    During view assignment there are two parameters set via GAO.
%    First with gao('keyhit','view') the method view is assigned
%    with key press events, and with gao('owner',owner) the view
%    owner is defined.
%
%    How it works
%    ============
%
%    In case of a keypress event the install KeyHit handler will
%    determine via gao('keyhit') that VIEW has to be called to handle
%    the key hit event via the gao('owner') callback. Thus a typical
%    KeyHit(obj) handler could look like:
%
%       function KeyHit(obj)
%          keyhit = gao('keyhit'); owner = gao('owner');
%          if some(keyhit,owner)
%             obj = arg(obj,cons(owner,args(obj)));
%             eval([keyhit,'(obj);']);
%          end
%          return
%       end
%
%    A usual way to setup view functionality is to provide the
%    two staements at the end of the demo menu setup, where the 
%    second statement definig view ownership must be called after
%    every CLS (clear screen) call.
%
%       view(obj,'Setup');             % setup keyhit handler
%       view(obj,'Owner','Navigate')   % current view owner is 'Navigate'
%
%    The method to trigger all keyhit initializing actions by GAO
%    settings is efficient since the GAO settings are cleared with
%    each call to CLS. So it will be made sure that no historical
%    settings influence a faulty behaviour, once a new graphics 
%    initiated by a CLS command is built-up.
%
%    See also: TOY, KEYHIT, CLS, GAO
%
   [cmd,obj,list,func] = dispatch(obj,varargin);  % prepare dispatching
   
   if strcmp(func,'Setup')            % don't nest the function deeper     
      keyhit(obj,'KeyHit',{});        % keyhit will install a callback
      return                          % to here!
   end
   
   eval(cmd);                                % actual dispatching 
   return  
end

%==========================================================================
% Keyhit Callback
%==========================================================================

function KeyHit(obj)
%
% KeyHit   Setup key hit callback handler
%
   [cmd,obj,modifier,key] = dispatch(obj);       % prepare dispatching

   owner = setting('view.owner');
   if ~isempty(owner)
      obj = arg(obj,{key,modifier});
      cmd = [owner,'(obj);'];
      eval(cmd);
   end
   return
end

%==========================================================================
% Assigning a View Owner
%==========================================================================
   
function Owner(obj)
%
% OWNER   This callback is executed when a usual menu callback invokes
%             
%             view(obj,'Owner',owner,handles,signals);  
%             view(obj,'Owner','Master',handles,{'T','A','Delta'});  
%             view(obj,'Owner','Junior');  
%
%             view(obj,'Owner',{'view','JuniorHandler'});  % same as above  
%             view(obj,'Owner',{'t2t,'ViewOwner'});        % custom owner  
%
%         We may assume that the menu callback has cleared the screen
%         and with the first plot a new axis object has been created
%         with GAO owner empty. This function extracts the GAO owner
%         by looking up the stack.
%
   [owner,obj,list] = arg(obj);      % split arguments
   manager = mfilename;              % this is 'view'
   
      % store item in view parameters
      
   topic = arg(obj,1);
   task = arg(obj,2);

   setting('view.topic',topic);
   setting('view.task',task);
   
      % for a custom view owner the value of owner is a list which contains
      % the callback manager and the callback function. In case of a list
      % we must split it up
      
   if iscell(owner)
      manager = owner{1};  owner = owner{2};
   end
   
   gao('keyhit',manager);            % set key hit event callback manager
   gao('owner',owner);               % set GAO owner
   
   setting('view.owner',owner);
   
   list = cons(owner,cons('init',list));
   obj = arg(obj,list); 
   cmd = [manager,'(obj);'];         % setup an initializing request
   eval(cmd);
   return
end

%==========================================================================
% General Key Handler
%==========================================================================

function [retkey,modifier] = General(obj)
%
% GENERAL   General key handler. 
%
%    This handler must be called separately by each view owner function
%
%       [key,modifier,view] = General(obj)
%
%    if key is empty then we replace key by 'init'. Also if key
%    can be processed in function General() then we will replace
%    key by the value 'general'. Otherwise we will return key
%    changed to the caller.
%
   key = either(arg(obj,1),'init');
   modifier = either(arg(obj,2),{});

   retkey = 'general';         % return 'general' pseudo key by default
   switch key
       case 'return'      
         refresh(obj);
         return
   end
   retkey = key;                       % did not process
   return                              % continue processing
end

%==========================================================================
% Navigation Owner for KeyHit Events
%==========================================================================

function Navigate(obj)
%
% NAVIGATE   Navigation handler for view. 
%
%    Does general key handling and some few special stuff.
%
   [key,modifier] = General(obj);     % general processing
   view = setting('view');            % return key = 'general' if processed
      
   switch key
      case 'general'                  % general key already processed?
         return                       % in this case we are done!
      case 'init'                     % initialize
         'done';          
      case {'pageup','uparrow'}       % previous demo
         NavigateProceed(obj,-1);
      case {'pagedown','downarrow'}   % next demo
         NavigateProceed(obj,+1);
      case {'h'}
         NavigateHelp(obj);
      case 'escape'
         busy(obj,'escape');
         pause(1.0);
         ready(obj);                  % set cursor to ready mode                  
   end
   return
end

%==========================================================================
% Navigate to Next Demo
%==========================================================================

function NavigateProceed(obj,dir)
%
% NAVIGATE-PROCEED
%
%    NavigateProceed(obj,+1)    % next
%    NavigateProceed(obj,-1)    % previous
%
   task = setting('view.task');
   scratch = isempty(task);                    % start from scratch
   
   task = either(task,'Create Generic Toy');   % provide task default
   item = Locate(task);
   
      % if we don't start from scratch then we proceed moving
      % in the menu tree according to the given direction (dir)
         
   if (item)
      if (~scratch)                 
         item = TreeMove(item,dir);      
      end
      
      if (item)
         top = get(get(item,'parent'),'label');
         task = get(item,'label');
         obj = topic(obj,top,task);
         
         setting('view.topic',top);
         setting('view.task',task);

         typ = get(item,'type');
         callback = get(item,'callback');
         callargs = get(item,'userdata');
         obj = arg(obj,[],callargs);
         
               % substitute 'gfo' with 'obj'
            
         idx = findstr(callback,'gfo');
         for (i=1:length(idx))
            callback(idx(i):idx(i)+2) = 'obj';
         end
         eval(callback);
      else
         beep
         msgbox('No more demos to step back!');
      end
   end
   
   return
end

%==========================================================================
% Navigate to Help Screen
%==========================================================================

function NavigateHelp(obj)
%
% NAVIGATE-HELP   Navigate to help screen
%
   cls;
   sz = 4;  line = 3*sz;
   text(gao,'','position','home','size',sz);
   
   text(gao,'§§Hot Key Help');
   
   line = Write(line,sz,'<down>, <page-down>','next demo screen');
   line = Write(line,sz,'<up>, <page-up>','previous demo screen');
   line = line+sz;
   line = Write(line,sz,'<enter>','refresh screen');
   line = Write(line,sz,'<h>','hot key help');
   return
end


function line = Write(line,sz,ltxt,rtxt)
%
% WRITE    Write a line with left text and right text  
%
   text(gao,ltxt,'position',[0 line],'size',sz);
   text(gao,rtxt,'position',[40 line],'size',sz);
   line = line+1.5*sz;
   return
end

%==========================================================================
% Refresh
%==========================================================================

function MasterRefresh(obj)
%
% MASTER-REFRESH   Refresh View
%
   fprintf('*** refresh\n');
   beep;
   return
end

%==========================================================================
% Locate Label
%==========================================================================

function hdl = Locate(label,parent)
%
% LOCATE   Locate Label in menu tree
%
   if (nargin < 2)
      parent = gcf;
   end
   
   children = get(parent,'children');
   for (i=1:length(children))
      hdl = children(i);
      typ = get(hdl,'type');
      if strcmp(typ,'uimenu')
         lab = get(hdl,'label');
         if strcmp(lab,label)
            return
         end
         hdl = Locate(label,hdl);
         if (hdl ~= 0)
            return
         end
      end
   end
   
   hdl = 0;   % not found
   return
end

%==========================================================================
% Move Forward/Backward In Menu Tree
%==========================================================================

function hdl = TreeMove(item,dir)
%
% NAVIGATE-FORWARD   Navigate forward in menu tree
%
%    TreeMove(item,+1)    % move forward in tree
%    TreeMove(item,-1)    % move backward in tree

   stopper = iif(dir>0,'Info','File');      % stop at File/Info menu
   
   typ = get(item,'type');
   callback = eval('get(item,''callback'');','''''');
   label = eval('get(item,''label'');','''''');
   
   if (item == 0 || item == round(item))
      hdl = 0;
      return
   end

   parent = get(item,'parent');
   children = get(parent,'children');

   
   idx = min(find(children == item));
   if (~isempty(idx))
      while iif(dir>0,idx > 1,idx < length(children))
         idx = idx + iif(dir>0,-1,+1);
         hdl = children(idx);

         %%%%%%%%%%%%%%%%%%%
         children = get(hdl,'children');
         while ~isempty(children)
            if (dir > 0)
               hdl = children(end);
            else
               hdl = children(1);
            end
            children = get(hdl,'children');
         end
         %%%%%%%%%%%%%%%%%%%%
         
         typ = get(hdl,'type');
         callback = get(hdl,'callback');
         label = get(hdl,'label');
         
         if (strcmp(label,stopper))
            hdl = 0;
            return
         end
         
         if (hdl == 0) || (~isempty(callback))
            return
         end
      end
   end
   
   hdl = TreeMove(parent,dir);
   return
end

