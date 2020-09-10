function hdl = mount(obj,mountpt,varargin)
%
% MOUNT    Mounting a menu root on a given mount location (mount point)
%
%    Arg2 (mountpt) can be either a double value or a string. 
%          
%       hdl = mount(obj,mountpt,varargin)
%
%    If only two arguments are provided then the handle of any
%    matching menu item is seeked. This call is used for adding
%    menu items to existing roll down menus.
%
%    Double type mount point:
%    ========================
%
%       mpt = uimenu(gcf)  % create menu item to serve as mount point
%       hdl = mount(obj,mpt,'label','Tools')  % mount only if free
%             
%       sub = mount(obj,uimenu(men));
%             
%
%    In case of double type arg2 will directly denote a parent handle
%    of figure's menu structure where the menu item is to be mounted.
%
%    Character string type mount point:
%    ==================================
%
%       hdl = mount(obj,'<file>','label','File');  % mount @ <file>
%
%    The whole menu tree is searched for a menu item with a label
%    equal to mountpt (in the above example: mountpt = '<file>').
%    If this menu item is not found (or if mountid = '') then a new
%    menu item is being created with parent gcf!
%
%    Mounting in the top menu bar
%    ============================
%
%       hdl = mount(obj,0,'label','File');  % mount in gcf's menu bar
%       hdl = mount(obj,'','label','File'); % mount in gcf's menu bar
%
%    This calls are working in compliancy with double type mountpt
%    or character string type mountpt behavior.
%            
%    See also: CORE, MENU
%
   if (isa(mountpt,'double'))
      hdl = mountpt;
   else
      parent = gcf;
      free = ~isempty(varargin);        % seek only for free
      hdl = seek(parent,mountpt,free);  % seek complete menu tree of gcf
   end
   
   if (hdl == 0)
      hdl = uimenu(parent);
   else
      set(hdl,'visible','on');   % make mount point menu entry visible
   end
   
% change parameters according to varargin list

   for (i=1:length(varargin)/2)
      attrib = varargin{i*2-1};
      value = varargin{i*2};
      set(hdl,attrib,value)
   end
      
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function hdl = seek(parent,mountpt,free)
%
% SEEK     Seek mount point of parent and complete subtree
%          If free = 1 then seek only for a free mount point.
%          if free = 0 then seek for any mount point.
%          Return handle if successful or 0 otherwise.
%
   hdl = 0;   % default init
   children = get(parent,'children');
   children = children(end:-1:1);       % swap index order
   
   if isempty(children)  % then we have a node object
      typ = get(parent,'type');      % easier to debug
      if strcmp(typ,'uimenu')
         label = get(parent,'label');
         if strcmp(label,mountpt)
            visible = get(parent,'visible');
            if ~free || strcmp(visible,'off')  
               hdl = parent;
            end
         end
      end
      return
   end
      
% otherwise seek all children including sub trees

   for i=1:length(children)
      chld = children(i);
      typ = get(chld,'type');      % easier to debug
      hdl = seek(chld,mountpt,free);
      if (hdl ~= 0)
         return       % found! 
      end
   end
   return   % not found
end   
   