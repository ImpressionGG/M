function obj = mitem(obj,label,callback,userdata,varargin)
% 
% MITEM   Building up menu structures and navigate through the menu
%         structure
%
%    1) Add a menu item to build-up a menu structure conveniently
%      
%       ob0 = core;                               % top menu item
%       ob1 = mitem(ob0,label,callback);          % roll down item
%       ob2 = mitem(ob1,label,callback,userdata); % roll down item
%
%    We can provide further parameters
%
%       cb = call('KeyCallback');
%       mitem(obj,'Key',cb,[3 4],'visible','on','enable','off');
%
%    or
%
%       ud = {'KeyCallback',[3 4]};
%       mitem(obj,'Key',call,ud,'visible','on','enable','off');
%
%    Note: when a new menu item is added, the argument list of the returned
%          object is always initialized with {''}. This allows subsequent
%          functions to dispatch on '' (empty string) for building up the 
%          menu structure.
%
%    Example:
%       ob1 = mitem(core,'Play');                 % top menu item
%       ob2 = mitem(ob1,'Sine',call,'Sine');      % add 'Sine' entry
%       set(mitem(ob2),'visible','on');           % set uimenu param.
%       set(mitem(ob2),'enable','off');           % set uimenu param.
%
%    Comment:
%       If a parent menu item of a newly created menu item is
%       invisible the parent item will be actually set visible. This
%       allows to provide hidden menu items which will appear at sudden
%       if child items are added.
%
%    2) Retrieving a menu handle: the menu handle is stored as the
%    parameter 'mitem.hdl' and can be retrieved as follows:
%
%       hdl = mitem(obj);                         % retrieve handle
%       hdl = get(obj,'mitem.hdl');               % same as above
%
%    3) Seeking a label in the menu tree. The label is seeked relative
%    to the menu item indicated by the object (local seek). If we want to
%    seek globally we need to use a generic core object.
%
%       obx = mitem(obj,{'Play'})        % local seek menu item 'Play'
%       obx = mitem(core,{label})        % global seek menu item with label
%
%    4) Setting up an object with a given menu item handle
%
%       obx = mitem(obj,{hdl})           % setup object with handle
%
%    Comment:
%       If the parameter hdl.item is empty the value of gcf will be 
%       returned. Thus hdl = item(core) is the same as hdl = gfc. 
%
%    5) Navigating through the menu tree
%
%       obj = mitem(obj,0)   % relative move upward to parent menu item
%
%       obj = mitem(obj,+1)  % relative move forward +1 step in menu tree
%       obj = mitem(obj,-1)  % relative move backward -1 step in menu tree
%
%       obj = mitem(obj,+n)  % relative move forward +n steps in menu tree
%       obj = mitem(obj,-n)  % relative move backward -n steps in menu tree
%
%    Forward move means advancing to the first child if there are children.
%    In case there are no children then forward move means advancing to the
%    next sibling downward. If there are no more siblings then forward move
%    means advancing up to the next sibling downward of the parrent.
%    
%    Backward move means advancing to deepest grand child of the next sib-
%    ling upward. If the next sibling above the current menu item has no
%    children then backward move means the sibling itself. If there are no
%    more siblings upward then backward move means advancing up to the
%    parent menu item.
%
%    6) Pre-setup of a callback function
%
%    There is a special form of menu item creqation using three arguments:
%    This calling syntax is based on a pre-defined callback and refers to
%    option(obj,'callback') in order to setup the callback.
%
%       obj = option(obj,'callback','Func');
%       ob1 = mitem(obj,'My Function 1',{token1});
%       ob1 = mitem(obj,'My Function 2',{token2});
%
%    Same as:
%
%       ob1 = mitem(obj,'My Function 1',call,{'Func',token1});
%       ob1 = mitem(obj,'My Function 2',call,{'Func',token2});
%
%    A standard technique to build up a menu structure is to use the same
%    function for dispatching the roll down setup and roll down callbacks.
%    This would look like:
%
%       function RollDown(obj)
%          switch(arg(obj,1)
%             case ''          % empty string to cause menu setup
%                ob1 = mitem(obj,'My Rolldown');
%                   ob2 = mitem(ob1,'Menu Item 1',call,{'@RollDown',1});
%                   ob2 = mitem(ob1,'Menu Item 2',call,{'@RollDown',2});
%             case 1
%                ...  % callback actions for 'Menu Item 1'
%             case 2
%                ...  % callback actions for 'Menu Item 2'
%          end
%       end
%
%   This Rolldown can be simplified by using an initial callback setup
%   (stored in option 'callback') and re-writing:
%
%       function RollDown(obj)
%          switch(arg(obj,1)
%             case ''                          % empty string -> menu setup
%                obj = caller(obj,'@');        % setup 'callback' option
%                ob1 = mitem(obj,'My Rolldown');
%                   ob2 = mitem(ob1,'Menu Item 1',{1});
%                   ob2 = mitem(ob1,'Menu Item 2',{2});
%             case 1
%                ...  % callback actions for 'Menu Item 1'
%             case 2
%                ...  % callback actions for 'Menu Item 2'
%          end
%       end
%
%    This standard technique has advantages when code is being copied and
%    pasted. Note also that option 'callback' is inherited by each creation
%    of a new menu item, i.e. is inherited from obj to ob1 in above example!
%
%    Note: the following to staements are equivalent
%
%      obj = caller(obj,'@');
%      obj = option(obj,'callback',['@',caller(obj,0)]);  % s/u callback
%
%    See also: CORE UIMENU
%
   Nargin = nargin;           % copy since we might modify
   ilist = varargin;          % copy since we might modify
   men = either(option(obj,'mitem.hdl'),gcf);
   
      % handle the case where we have to seek for a label
      
   if (nargin == 2)
      if isa(label,'double')
         obj = Move(obj,label);
         return;
      elseif iscell(label)
         arg1 = label{1};
         if ischar(arg1)
            hdl = Seek(men,arg1);
            obj = iif(hdl==0,[],option(obj,'mitem.hdl',hdl));
         elseif isa(arg1,'double')
            obj = option(obj,'mitem.hdl',arg1);
         else
            error('list argument must be character or double!');
         end
         return
      end
   end
   
      % check for the short form which makes use of the implicite
      % access of option 'callback', Such a call would look like:
      %
      %    ob1 = mitem(obj,label,arglist)
      %
      
   if (Nargin == 3)
      if iscell(callback)
         Nargin = 3;  ilist = {};
         args = callback;   % callback is not really a callback
         func = option(obj,'callback');
         userdata = cons(func,args);
         [~,file] = caller(obj); 
         callback = [file,'(gfo)'];
      end
   end
      
      % check if last item on this level was a separator
      
   chld = get(men,'children');
   separator = 0;
   if ~isempty(chld)
      ch = chld(1);
      type = get(ch,'type');
      ud = get(ch,'userdata');
      if (length(ud) == 1 && isa(ud,'double'))
         infinity = isinf(ud);
         separator = (strcmp(type,'uimenu') && infinity);
      end
   end
   
   label = eval('label','''-''');         % default for label = '-'
   callback = eval('callback','''''');    % default for callback = ''
   userdata = eval('userdata','[]');      % default for userdata = []
   
   if (Nargin == 1)
      obj = men;
      return
   else
      if (Nargin > 4 && rem(Nargin,2) ~= 0)
         error('even number of input args expected!');
      end
      
      lb = label;  cb = callback;  ud = userdata;
      
      hdl = uimenu(men,'label',lb,'callback',cb,'userdata',ud);
      obj = option(obj,'mitem.hdl',hdl);
      obj = arg(obj,{''});         % arg(obj,1) will be ''

         % set parent item visible
         
      set(men,'visible','on');     % set menu item visible by default
      
         % handle seperator case
         
      if (all(lb == '-') || all(lb=='_'))
         set(hdl,'Separator','on','visible','off','userdata',inf);
      end
     
         % set further parameters if provided
         
      i = 1;
      while (i < length(ilist))
         parameter = ilist{i};  value = ilist{i+1};
         set(hdl,parameter,value);
         i = i+2;
      end
   end

      % check again if last item on this level was a separator
   
   if (separator)
      set(hdl,'Separator','on');
   end
   
   return
end   

%==========================================================================
% Seek a Menu Item
%==========================================================================

function hdl = Seek(parent,mountpt)
%
% SEEK     Seek mount point of parent and complete subtree
%          Return handle if successful or 0 otherwise.
%
   if (nargin < 3)
      free = 0;                      % seek for any mount point
   end
   
    hdl = 0;   % default init
    children = get(parent,'children');
    children = children(end:-1:1);     % swap index order
      
% in case of a uimenu item check parent label

   if (strcmp(get(parent,'type'),'uimenu'))
      label = get(parent,'label');
      if strcmp(label,mountpt)
         hdl = parent;                  % found: menu item is parent itself
         return
      end
   end
   
% otherwise seek all children including sub trees

   for i=1:length(children)
      chld = children(i);
      typ = get(chld,'type');      % easier to debug

      if strcmp(typ,'uimenu')
         label = get(chld,'label');
         if strcmp(label,mountpt)
            hdl = chld;
            return
         end
      end
      
      hdl = Seek(chld,mountpt);
      if (hdl ~= 0)
         return       % found! 
      end
   end
   return   % not found
end   

%==========================================================================
% Relative Move in Menu Tree
%==========================================================================

function obj = Move(obj,n)
%
% MOVE   Relative move in menu tree
%
%           obj = Move(obj,0)    % move up to parent
%           obj = Move(obj,+n)   % move forward n steps
%           obj = Move(obj,-n)   % move backward n steps
%
%        Return [] if there are no more menu items to move
%
   assert(isa(n,'double'));
   if length(n) ~= 1
      error('scalar expected for number of relative moves (arg2)!');
   end
   
   if round(n) ~= n
      error('integer expected for number of relative moves (arg2)!');
   end
   
      % Ok - arguments look good, start dispatching ...
      
   hdl = mitem(obj);   % retrieve menu handle
   
   if (n == 0)
      parent = get(hdl,'parent');
      type = get(parent,'type');
      
      if strcmp(type,'uimenu')
         obj = mitem(obj,{parent});  % setup parent handle as menu handle
      else
         obj = [];  % no more parent item
      end
   elseif (n >= 1)
      while (n > 0 && ~isempty(obj))
         obj = Forward(obj);
         n = n-1;
      end
   elseif (n <= -1)
      while (n < 0 && ~isempty(obj))
         obj = Backward(obj);
         n = n+1;
      end
   else
      assert(0);  % can only be a bug!
   end
   
% Before return make a final assertion that the type of the located menu 
% item is really of type 'uimenu'

   if ~isempty(obj)
      type = get(mitem(obj),'type');
      assert(strcmp(type,'uimenu'));
   end
   return
end

%==========================================================================
% Move Forward in Menu Tree
%==========================================================================

function obj = Forward(obj)
%
% FORWARD   Move forward in menu tree
%
%    Forward move means advancing to the first child if there are children.
%    In case there are no children then forward move means advancing to the
%    next sibling downward. If there are no more siblings then forward move
%    means advancing up to the next sibling downward of the parrent.
%
   hdl = mitem(obj);               % retrieve menu handle
   label = get(hdl,'label');       % just for debug
   
% Find out if there are children. If yes then advance to the first child.

   children = get(hdl,'children');
   
   for (i=length(children):-1:1)   % reverse order
      child = children(i);
      type = get(child,'type');
      if strcmp(type,'uimenu')
         obj = mitem(obj,{child});  % setup 1st child handle as menu handle
         return
      end
   end
   
% otherwise go to the next sibling. This step will recursively call the
% next sibling search on parentlevel

   obj = Next(obj);  % advance to next sibling in menu tree
   return
end

%==========================================================================
% Move To Next Sibling in Menu Tree
%==========================================================================

function obj = Next(obj)
%
% NEXT   Move to next sibling in menu tree
%
%    Advance to next sibling downward. If there are no more siblings then
%    recursively call NextSibling for the parent.
%
%    If there is no more parent then return [].
%
   hdl = mitem(obj);   % retrieve menu handle
   label = get(hdl,'label');     % just for debug
   parent = get(hdl,'parent');
   %label = get(parent,'label');     % just for debug
   
   if parent == 0  % top graphic root reached (screen handle)
      obj = [];
      return
   end
   
   children = get(parent,'children');
   idx = min(find(children==hdl));      % find actual menu item handle
   
% if there is a sibling downward then return that sibling

   while (idx > 1)
      idx = idx-1;
      sibling = children(idx);
      type = get(sibling,'type');
      if strcmp(type,'uimenu')
         obj = mitem(obj,{sibling});
         return
      end
   end
   
% otherwise we must search recursively in the parent node

   obj = Next(mitem(obj,{parent}));
   label = get(mitem(obj),'label');     % just for debug
   return
end

%==========================================================================
% Move Backward in Menu Tree
%==========================================================================

function obj = Backward(obj)
%
% BACKWARD   Move backward in menu tree
%
%    Backward move means checking if there is an older sibling. If an 
%    older sibling exists then fall down to the oldest of the deepest
%    grand child and return this item. Otherwise return parent item.
%
   hdl = mitem(obj);             % retrieve menu handle
   parent = get(hdl,'parent');   % get parent handle
   
   if parent == 0  % top graphic root reached (screen handle)
      obj = [];
      return
   end
   
   children = get(parent,'children');
   idx = min(find(children==hdl));      % find actual menu item handle

% if idx >= length(children) this means there is no older child. In this
% case we will return the parent object.

   child = [];
   for (i= idx+1:length(children))
      type = get(children(i),'type');
      if strcmp(type,'uimenu')
         child = children(i);
         break;
      end
   end

% if no child can be found then we just return the parent

   if isempty(child)
      obj = mitem(obj,{parent});
      return
   end
   
% Otherwise fall down to the deepest & youngest grand grand ... child

   loop = 1;
   while (loop)
      children = get(child,'children');
      loop = 0;
      for (i=1:length(children))
         type = get(children(i),'type');
         if strcmp(type,'uimenu')
            child = children(i);    % have another grand child found
            loop = 1;               % loop one more with grand grand children
            break;
         end
      end
   end
      
   obj = mitem(obj,{child});
   return
end

