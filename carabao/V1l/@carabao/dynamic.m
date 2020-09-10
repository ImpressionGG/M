function oo = dynamic(o,oo)
%
% DYNAMIC   Add a menu and mark it as dynamic, or update all dynamic menus
%
%    Syntax
%
%       dynamic(o);            % make menu item a dynamic menu
%       enabled = dynamic(o)   % is dynamic mode enabled
%
%       o = dynamic(o,true);   % enable dynamic shell
%       o = dynamic(o,false);  % disable dynamic shell
%
%       oo = dynamic(o,oo)     % update all dynamic menus
%
%    Example: setup Plot and Animation menu as dynamic menus
%
%       o = dynamic(o,{'Plot','Animation'});  % setup dynamic menus
%
%    Dynamic menus are updated after each object selection change (usually
%    initiated by method CURRENT). The process is as follows:
%
%    1) Any dynamic shell must define the dynamic menu items by providing
%    the string 'Dynamic' in the user data.
%    2) Any object that wants to utilize dynamic menus must
%       a) support & publish local functions that build-up the dynamic menu
%       b) provide & publish a local shell function 'Dynamic' which returns
%       a list of the dynamic menu items to be activated
%    3) Upon object selection the shell must run the following process, 
%    which is supported by invoking oo = dynamic(o,oo):
%       a) clearing all dynamic menus and making them invisible
%       b) asking the object's shell for the list of dynamic items (by
%       invoking the published 'Dynamic' function
%       c) building up the dynamic menu items by invoking the according
%       local functions
%
%    See also: CARABAO, MENU, CURRENT
%
   [is,iif,either] = util(o,'is','iif','either');  % need some utility
%
% one input arg
% a) dynamic(o) % make menu item a dynamic menu
% b) enabled = dynamic(o) % is dynamic mode enabled
%
   while (nargin == 1)                                                 
      if (nargout == 0)
         enabled = Enabled(o);
         if ~enabled                   % dynamic shell not enabled?
            oo = o;                    % copy by default to out arg
            return                     % then ignore - good bye!
         end
      
         hdl = work(o,'mitem');        % get menu item handle
         label = get(hdl,'label');     % get label
         
            % add to list, if not in list
            
         list = control(pull(o),'dynamic');
         if ~iscell(list)
            list = {};                 % make a list if no list
         end
         
         if ~is(label,list)            % if label not in list
            list{end+1} = label;
            control(o,'dynamic',list);
         end
         
         key = Key(label);             % construct key
         set(hdl,'userdata',key);      % mark menu with key in userdata    
         set(hdl,'visible','off');     % make invisible
      else
         oo = Enabled(o);              % is dynamic mode enabled
      end
      return
   end
%
% two input args and arg2 is not a list
% a) oo = dynamic(o,oo) % update all dynamic menus
%
   while (nargin == 2) && isobject(oo) % update all dynamic menus      
      if ~Enabled(o);                  % dynamic shell not enabled?
         return                        % then ignore - good bye!
      end
         
      o = pull(o);                     % update shell object & options
      ShowMenus(o,oo);                 % dynamic menu control               
      return
   end
%
% two input args and arg2 is a list
% a) o = dynamic(o,true) % enable dynamic shell
% b) o = dynamic(o,false) % disable dynamic shell
%
   while  (nargin == 2) && (isa(oo,'double') || isa(oo,'logical'))     
      value = iif(oo,true,false);        
      oo = control(o,{'dynamic'},value); % setup dynamic property
      return
   end
%
% anything else indicates a syntax error
%
   error('bad calling syntax!');
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function enabled = Enabled(o)          % Are Dynamic Menus Enabled     
%
% ENABLED   Are dynamic menus enabled?
%
%     Different cases:
%        a) there is no dynamic menu control: control(o,'dynamic') = 0
%        b) dynamic control is enabled, all dynamic menus except the 
%           listed ones are deleted if selected object class changes
%              => 
%     Note: let dyn = control(o,'dynamic');
%
%        dyn = 0:        enabled = false, list = {}
%        dyn = {}:       enabled = true,  list = {}
%        dyn = {'Plot'}: enabled = true,  list = {'Plot'}
%
   dyn = control(pull(o),'dynamic');
   assert(isequal(dyn,0) || isequal(dyn,1) || iscell(dyn));
   enabled = ~isequal(dyn,0);
end

function key = Key(label)              % Get Key                       
   key = ['[',label,']'];              % put label between brackets
end

function ShowMenus(o,oo);              % Dynamic Menu Show             
   is = @carabao.is;                   % short hand
   iif = @carabao.iif;                 % short hand

   dyn = control(o,'dynamic');
   assert(isequal(dyn,0) || iscell(dyn));
   slist = iif(iscell(dyn),dyn,{});    % shell's list
   
         % get list of object's dynamic menu items
         
   gamma = eval(['@',launch(oo)]);     % get launch function
   olist = gamma(oo,'Dynamic');        % object's list of dynamic menus
      
   o = mitem(o);                       % setup as a figure root
   fig = figure(o);                    % get seek root handle
   for (i=1:length(slist))
      label = slist{i};                % get i-th label
      key = Key(label);                % make key
      hdl = findobj(fig,'userdata',key);
      if isscalar(hdl)                 % menu item found?
         if is(label,olist)
            parent = get(hdl,'parent');
            oo = work(oo,'mitem',parent);
            gamma(oo,label);           % build-up dynamic menu
         else
            set(hdl,'visible','off');
         end
      else
         fprintf('*** warning: multiple keys found during dynamic menu control!\n');
      end
   end
end

