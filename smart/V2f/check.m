function value = check(itm,value,dummy)
% 
% CHECK    Change check-mark of toggling menu item and accordingly update
%          related user data.
%      
%             value = check(obj,itm);   % toggle menu item's check and user flag
%             value = check(obj,itm,1); % check menu item and set user flag
%             value = check(obj,itm,0); % uncheck menu item and clear user flag
%
%          Example: Let's think of a figure's user data 'flag1' and flag2
%          which we want to uncheck and check during initialization. We
%          create a menu and two menu items
%         
%             obj = smart;           % need SMART object to access methods
%             menu(obj);             % open SMART object's menu 
%
%             men = uimenu(gcf,'label','Play');
%             itm1 = uimenu(men,'label','Flag1','callback','check(gcbo);','userdata','flag1');
%             itm2 = uimenu(men,'label','Flag2','callback','check(gcbo);','userdata','flag2');
%             itm3 = uimenu(men,'label','Show','callback','option(gcfo)');
%
%             check(itm1,0);         % uncheck menu item, clear userdata
%             check(itm2,1);         % check menu item, set userdata
%
%             setting('flag1')       % display menu setting of flag 1
%             setting('flag2')       % display menu setting of flag 2
%
%          Note: in a real program short hands would enhence overview.
%          In addition menu handles (such as itm1,itm2) do not have to be
%          numbered when initialization happens immediately. See the same 
%          code with these modifications.
%
%             UD = 'userdata';  CB = 'callback';
%             LB = 'label';     CHK = 'check(gcbo);'
%
%             men = uimenu(gcf,'label','Play');
%             itm = uimenu(men,LB,'Flag1',CB,CHK,UD,'flag1');
%                   check(itm,0);     % initialized, unchecked
%             itm = uimenu(men,LB,'Flag2',CB,CHK,UD,'flag2');
%                   check(itm,1);     % initialized, checked
%                   uimenu(men,LB,'Show',CB,'option(gfo)');
%         
%          See also: CHAMEO SETTING OPTION CHOICE GCFO ADDON MYTOOL
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
            value = check(value,dummy);   % shift itm <- value <- dummy
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
       if (value)  % if menu item is to be checked
           set(itm,'check','on');
           value = 1;
       else                       % else menu item is to be unchecked
           set(itm,'check','off');
           value = 0;
       end
       setting(name,value);
   end
   
   return
   
% eof
