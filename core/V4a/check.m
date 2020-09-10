function value = check(itm,value,arg3)
% 
% CHECK    Change check-mark of toggling menu item and accordingly update
%          related user data.
%      
%             value = check(itm);     % toggle menu item's check and user flag
%             value = check(itm,1);   % check menu item and set user flag
%             value = check(itm,0);   % uncheck menu item and clear user flag
%             value = check(itm,'');  % check menu item according to setting
%
%          Example: Let's think of a figure's user data 'flag1' and flag2
%          which we want to uncheck and check during initialization. First 
%          (after definition of shortcuts) we create a new roll down menu.
%         
%             UD = 'userdata';  CB = 'callback';
%             LB = 'label';     CHK = 'check(gcbo);'
%
%             men = uimenu(gcf,LB,'Play');  % create roll down menu 'Play'
%
%          After definition of default settings for flag1 and flag2 we
%          create two menu items in the roll down menu with check
%          functionality
%
%             default('flag1',0);   % default setting for flag1
%             default('flag2',1);   % default setting for flag2
%
%             itm = uimenu(men,LB,'Flag1',CB,CHK,UD,'flag1');
%                   check(itm,'');  % set check according to setting('flag1')
%
%             itm = uimenu(men,LB,'Flag2',UD,'flag2');
%                   check(itm,CHK); % easier way of providing check functionality
%         
%          Change menu parameter setting at program level
%
%             check(parname,value)
%             check('bullets',1);
%
%          See also: SHELL SETTING OPTION CHOICE GFO MYADDON
%
   if (nargin >= 1)
      if isobject(itm)
          fprintf(['*** Warning: the current usage of check with an ',...
             'object as first arg will be obsolete in future!\n       ',...
             '       Please change the check() call ''check(obj,itm,..)'' ',...
             'by removing the object argument\n',...
             '             => ''check(itm,..)''!\n']);
         if (nargin == 1)
            value = check;
         elseif (nargin == 2)
            value = check(value);         % shift itm <- value
         elseif (nargin == 3)
            value = check(value,arg3);    % shift itm <- value <- arg3
         else
            error('check(): max 3 args expected for old style call');
         end
         return
      end
   end

% from here we only deal with new style calls

   if (nargin < 1)
      error('check(): 1 or 2 args expected!');
   end

% in case of two arguments where first argument is a character string a
% the calling syntax means that we want to change a menu item from the
% command line.

   if (nargin == 2)
      if ischar(itm)
         change(itm,value);
         return               % done - stop further processing
      end
   end

% Now continue with normal processing where first argument (itm) means
% always a handle to a menu item
   
   name  = get(itm,'userdata');    
   if (~isstr(name))
      error('check(): string expected for user data!');
   end
   
   if (nargin == 1)   % toogle menu item's checkings and update user data
      checked = get(itm,'check');
      if (strcmp(checked,'off'))  % if menu item is checked
         set(itm,'check','on');  
         value = 1;
      else                       % else menu item is unchecked
         set(itm,'check','off');
         value = 0;
      end
      setting(name,value);
      
   elseif (nargin == 2)   % initialize
      if ischar(value)
         callback = value;
         if ~isempty(callback)
            set(itm,'callback',callback);
         end
         value = setting(name);
         check(itm,value);
      elseif (value)  % if menu item is to be checked
         set(itm,'check','on');
         value = 1;
      else                       % else menu item is to be unchecked
         set(itm,'check','off');
         value = 0;
      end
      setting(name,value);
   end
   
   return
   
%==========================================================================
% Change parameter from program level
%==========================================================================

function found = change(parameter,value,tree)
%
% CHANGE    Change parameter from program level
%
%              change(parameter,value)
%
   if (nargin == 2)
      success = change(parameter,value,gcf);
      if (~success)
         parameter,value
         error('could not find parameter in menu!');
      end
      return
   else
      type = get(tree,'type');
      ud = get(tree,'userdata');
      if (~ischar(ud))
         ud = '';
      end
      
      if (strcmp(type,'uimenu') && strcmp(ud,parameter))
         %update(tree,value);     % update setting & menu checks
         check(tree,value);       % update menu checks
         found = 1;
         return
      else
         ch = child(tree);
         for (i = 1:length(ch))
            found = change(parameter,value,ch(i));
            if (found)
               return;
            end
         end
         found = 0;
      end
   end
   

% eof
