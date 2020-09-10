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
%       view(core,'Setup');    % install generic keyhit handler
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
%    1) Navigation
%
%       view(obj,'Owner','Navigate',...);  
%       view(obj,'Owner',owner,'My Topic','My Task');  
%
%       view(obj,'Owner',{'view','Navigate',...});    % same as above  
%       view(obj,'Owner',{'demo','ViewOwner'},{});    % custom owner
%
%    2) Default
%
%       view(obj,'Owner','Default',handler,khitfunc);  
%       view(obj,'Owner','Default','apparatus','KeyHit');  
%       view(obj,'Owner','Default','detector','KeyHit');  
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
%    See also: CORE, KEYHIT, CLS, GAO
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
         navigation(obj,-1);
      case {'pagedown','downarrow'}   % next demo
         navigation(obj,+1);
      case 'escape'
         busy(obj,'escape');
         pause(1.0);
         ready(obj);                  % set cursor to ready mode                  
   end
   return
end
