function obj = mitem(obj,label,callback,userdata,varargin)
% 
% MITEM   Add a menu item to build-up a menu structure conveniently
%      
%            ob0 = core;                               % top menu item
%            ob1 = mitem(ob0,label,callback);          % roll down item
%            ob2 = mitem(ob1,label,callback,userdata); % roll down item
%
%         We can provide further parameters
%
%            cb = call('KeyCallback');
%            mitem(obj,'Key',cb,[3 4],'visible','on','enable','off');
%
%         or
%
%            ud = {'KeyCallback',[3 4]};
%            mitem(obj,'Key',call,ud,'visible','on','enable','off');
%
%         Retrieving a menu handle: the menu handle is stored as the
%         parameter 'mitem.hdl' and can be retrieved as follows:
%
%            hdl = mitem(obj);                         % retrieve handle
%            hdl = get(obj,'mitem.hdl');               % same as above
%
%         Seeking a label in the menu tree:
%
%            obx = mtree(obj,{label})         % seek menu item with label
%            obx = mtree(obj,{'Play'})        % seek menu item 'Play'
%
%         If the parameter hdl.item is empty the value of gcf will be 
%         returned. Thus hdl = item(core) is the same as hdl = gfc. 
%
%         Example:
%            ob1 = mitem(core,'Play');                 % top menu item
%            ob2 = mitem(ob1,'Sine',call,'Sine');      % add 'Sine' entry
%            set(mitem(ob2),'visible','on');           % set uimenu param.
%            set(mitem(ob2),'enable','off');           % set uimenu param.
%
%        See also: CORE UIMENU
%
   men = either(option(obj,'mitem.hdl'),gcf);
   
      % handle the case where we have to seek for a label
      
   if (nargin == 2)
      if iscell(label)
         hdl = Seek(men,label{1});
         obj = iif(hdl==0,[],option(obj,'mitem.hdl',hdl));
         return
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
   
   if (nargin == 1)
      obj = men;
      return
   else
      if (nargin > 4 && rem(nargin,2) ~= 0)
         error('even number of input args expected!');
      end
      
      lb = label;  cb = callback;  ud = userdata;
      
      hdl = uimenu(men,'label',lb,'callback',cb,'userdata',ud);
      obj = option(obj,'mitem.hdl',hdl);

         % handle seperator case
         
      if (all(lb == '-') || all(lb=='_'))
         set(hdl,'Separator','on','visible','off','userdata',inf);
      end
     
         % set further parameters if provided
         
      i = 1;
      while (i < length(varargin))
         parameter = varargin{i};  value = varargin{i+1};
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
%    
%    if isempty(children)  % then we have a node object
%       typ = get(parent,'type');      % easier to debug
%       if strcmp(typ,'uimenu')
%          label = get(parent,'label');
% fprintf([label,'\n']);         
%          if strcmp(label,mountpt)
%             hdl = parent;
%             return
%          end
%       end
%       return
%    end
      
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
