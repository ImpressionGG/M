function obj = navigation(obj,arg2,arg3)
% 
% NAVIGATION   Setup navigation control
%    
%    There are two versions of calling syntax
%
%       navigation(obj)                    % setup view handler
%       navigation(obj,steps)              % navigate steps for/back-ward
%       obj = navigation(obj,from,to);     % setup navigation limits
%
%    1) Called with 1 input arg NAVIGATION sets up a proper view handler for
%    navigation. This will usually implicitely be done if method TUT is
%    called with 1 or more output arguments.
%
%       navigation(obj)                    % setup view handler
%    
%    2) Called with 2 input args NAVIGATION navigates through the menu
%    structure, either n steps forward if the second argument (steps) is
%    positive, or n steps backward, if the second argument is negaive.
%
%       navigation(obj,steps)              % navigate steps for/back-ward
%
%       navigation(obj,+1)                 % navigate 1 step forward
%       navigation(obj,+n)                 % navigate n steps forward
%       navigation(obj,-1)                 % navigate 1 step backward
%       navigation(obj,-n)                 % navigate n steps backward
%
%    3) The alternative call is with 3 input arguments is for extraction of
%    topic and task from a menu item call, as well as setting up the
%    navigation limits (which are stored in the view options). The call
%    statement with 3 input args should be usually be provided as the first
%    line of a menu package handler if the provided functionality is re-
%    quired.
%
%    Example: (first lines of a package handler function)
%
%       obj = navigation(obj,'Demo1','Demo2');
%       [cmd,obj,list,func] = dispatch(obj,varargin,{{'@','invoke'}},'Setup');
%       eval(cmd);
%       return
%
%    The first statement (call to NAVIGATE) sets up topic & task in the
%    view options, and stores the two stopper menu labels (here 'Demo1' and
%    'Demo2' in the view labels). In addition by an implicite call to GCBO
%    the topic and task of a menu item will be extracted.
%
%    See also: CORE, TOPIC, VIEW
%
   if (nargin == 1)                         % setup view handler
      [top,task] = topic(obj);
      view(obj,'Owner','Navigate',top,task);
      return
   elseif (nargin == 2)
      steps = arg2;
      Navigate(obj,steps);
   elseif (nargin == 3)
      from = arg2;  to = arg3;
      if ~ischar(from) || ~ischar(to)
         error('arg2 (from) and arg3 (to) must be character strings!');
      end
      setting('view.stopper.from',from);
      setting('view.stopper.to',to);
      obj = topic(obj,gcbo);  % extract topic & task from current menu item
   else
      error('1 or 3 input args expected!');
   end
   return
end

%==========================================================================
% Navigate to Next Demo
%==========================================================================

function Navigate(obj,dir)
%
% NAVIGATE
%
%    Navigate(obj,+1)    % next
%    Navigate(obj,-1)    % previous
%
   task = setting('view.task');
   item = either(setting('view.item'),gcf);    % item handle
   
   scratch = isempty(task);                    % start from scratch
   
   task = either(task,'Create Generic Toy');   % provide task default
   obj = Locate(mitem(obj,{item}),task);
   
      % if we don't start from scratch then we proceed moving
      % in the menu tree according to the given direction (dir)
         
   if ~isempty(obj)
      if (~scratch)  
         obj = TreeMove(obj,dir);      
      end
      
      if ~isempty(obj)
         item = mitem(obj);
         top = get(get(item,'parent'),'label');
         task = get(item,'label');
         obj = topic(obj,top,task);
         
         setting('view.topic',top);
         setting('view.task',task);
         setting('view.item',mitem(obj));

         typ = get(item,'type');
         callback = get(item,'callback');
         callargs = get(item,'userdata');
         %obj = arg(obj,[],callargs);
         obj = set(obj,'arg',callargs);
         
               % substitute 'gfo' with 'obj'
            
         idx = findstr(callback,'gfo');
         for (i=1:length(idx))
            callback(idx(i):idx(i)+2) = 'obj';
         end
         eval(callback);
      else
         beep
         if (dir > 0)
            msgbox('No more demos to step forward!');
         else
            msgbox('No more demos to step back!');
         end
      end
   end
   
   return
end

%==========================================================================
% Locate Label
%==========================================================================

function obj = Locate(obj,label)
%
% LOCATE   Locate Label in menu tree
%
   try
      out = mitem(obj,{label});  % locate menu item per label
   catch
      out = [];
   end
   
   if isempty(out)   
      obj = mitem(obj,{gcf});    % recovery in case of Clone & Rebuild
      out = mitem(obj,{label});  % locate menu item per label
   end
   obj = out;
   return
end

%==========================================================================
% Move Forward/Backward In Menu Tree
%==========================================================================

function obj = TreeMove(obj,dir)
%
% NAVIGATE-FORWARD   Navigate forward in menu tree
%
%    TreeMove(item,+1)    % move forward in tree
%    TreeMove(item,-1)    % move backward in tree

   from = either(option(obj,'view.stopper.from'),'From???');
   to = either(option(obj,'view.stopper.to'),'To???');
   stopper = iif(dir<0,from,to);   % stop at from/to menu item

   while(1)
      obj = mitem(obj,dir);   % move forward/backward in menu tree
      if isempty(obj)
         return         % end of movement in menu tree
      end
      
      hdl = mitem(obj);
      typ = get(hdl,'type');
      callback = eval('get(hdl,''callback'');','''''');
      label = eval('get(hdl,''label'');','''''');
   
      if strcmp(label,stopper)
         obj = [];           % end of tree move sequence
         return
      elseif ~isempty(callback)
         return              % proper menu item found
      end
   end
end

