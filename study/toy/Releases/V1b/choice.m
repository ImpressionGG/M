function value = choice(itm,value,dummy)
% 
% CHOICE   Choose from a number of alternative options
%          Example:
%
%             UD = 'userdata';  CB = 'callback';              % shorthands
%             LB = 'label';     CHC = 'choice(gfo,gcbo);'     % shorthands
%
%             menu(shell);           % open SHELL object's menu 
%
%             default('color','red');
%             men = uimenu(gcf,'label','Color',UD,'color');
%                   choice(men,{{'Red','red'},{'Green','green'},{'Blue','blue}},CHC);
%
%             default('gain',1.0);
%             men = uimenu(gcf,'label','Gain',UD,'gain');
%                   choice(men,[0.5 1.0 1.5],CHCR);
%
%             default('gain',1.0);
%             men = uimenu(gcf,'label','Gain',UD,'gain');
%                   uimenu(men,LB,'0.5',CB,CHCR,UD,0.5);
%                   uimenu(men,LB,'1.0',CB,CHCR,UD,'1.0');
%                   uimenu(men,LB,'1.5',CB,CHCR,UD,'1.5');
%                   choice(men,setting('color'));  % initialized, selected
%
%          Change menu parameter setting at program level
%
%             choice(parname,value)
%             choice('controller.Kp',5.3);
%
%          See also: CHAMEO SETTING OPTION CHECK GCFO ADDON MYTOOL
%
   if (nargin >= 1)
      if isobject(itm)
          fprintf(['*** Warning: the current usage of choice() with an ',...
             'object as first arg will be obsolete in future!\n       ',...
             '       Please change the choice() call ''choice(obj,itm,..)'' ',...
             'by removing the object argument\n',...
             '             => ''choice(itm,..)''!\n']);
         if (nargin == 1)
            value = choice;
         elseif (nargin == 2)
            if (ischar(itm))
               change(itm,value);    % program level change of parameter
            else
               value = choice(value);         % shift itm <- value
            end
         elseif (nargin == 3)
            value = choice(value,dummy);   % shift itm <- value <- dummy
         else
            error('check(): max 3 args expected for old style call');
         end
         return
      end
   end

% from here we only deal with new style calls

   if (nargin < 1)
      error('choice(): 1 or 2 args expected!');
   end
   
   if (nargin == 1)   % make current choice as new selection

      parent = get(itm,'parent');
      name  = get(parent,'userdata');    
      if (~isstr(name))
         error('choice(): string expected for user data!');
      end
      
      chld = get(parent,'children');
      set(chld,'check','off');     % uncheck all
      set(itm,'check','on');       % check selected item
      
      value = get(itm,'userdata');
      setting(name,value);
      
   elseif (nargin == 2)   % initialize
      if (ischar(itm))
         change(itm,value);    % program level change of parameter
         return
      end
      parent = itm;                % make it more transparent
      chld = get(parent,'children');

      name  = get(parent,'userdata');    
      if (~isstr(name))
         error('choice(): string expected for user data!');
      end

      for (i=1:length(chld))
         ch = chld(i);
         ud = get(ch,'userdata');
         
         match = matching(ud,value);
         if (match)
             set(chld,'check','off');     % uncheck all children
             set(ch,'check','on');
             setting(name,value);
             return
         end             
      end
       
         % if not found there is a possibility for automatic
         % extent of the menu
         
      if (isa(value,'double'))
         label = sprintf('(%g)',value);
         callback = get(chld(1),'callback');
         uimenu(parent,'label',label,'callback',callback,'userdata',value);
         choice(name,value);              % another call to check menu item
      else
         error('choice(): value does not match!');
      end
       
   elseif (nargin == 3)   % menu setup
      setup(itm,value,dummy);
   end
   return
   
%==========================================================================   

function match = matching(x,y)
%
% MATCHING     Check if two data items are matching each other. For
%              elementary data a direct compare is made. For list data
%              the matching check is to be performed recursively
%
   match = 0;   % by default initialized as 'not matching'

   if (~strcmp(class(x),class(y)))
      return;                % does not match since different data classes
   end

   if (isempty(x)) x = []; end  % no trouble with empty 0x0, 0x1, 1x0
   if (isempty(y)) y = []; end  % no trouble with empty 0x0, 0x1, 1x0
         
   if (any(size(x)~=size(y)))
      return;                % does not match since different dimensions
   end

   x = x(:);  y  = y(:);
   
   switch class(x)           % dispatch data class
      case {'double','char'}
         if (any(abs(x-y)>1e4*eps))    % use the tolerant comparison
             return;         % does not match since different values            
         end                 % otherwise match
      case {'cell'}
         for (i=1:length(x))
            if (~matching(x{i},y{i}))
               return;       % does not match since different cell elements            
            end              % otherwise match
         end
      otherwise
         return;             % no match, e.g. no match allowed for objects         
   end
   match = 1;                % both data  x and y are matching!
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
         update(tree,value);     % update setting & menu checks
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
  
%==========================================================================   

function update(itm,value)
%
% UPDATE   Update a menu choice. Allow also a value which is not
%          provided as a pre-defined choice.
%
%             update(itm,value)    % itm is a handle to UIMENU
%
   parent = itm;                % make it more transparent
   chld = get(parent,'children');

   name  = get(parent,'userdata');    
   if (~isstr(name))
      error('update(): string expected for user data!');
   end

   set(chld,'check','off');     % uncheck all children
   setting(name,value);         % change setting
   
   for (i=1:length(chld))
      ch = chld(i);
      ud = get(ch,'userdata');

      match = matching(ud,value);
      if (match)
         set(ch,'check','on');
         return
      end             
   end

      % here we end up if no match has been found
      % in case of a double we are allowed to extend the menu
      
   if (isa(value,'double'))
      label = sprintf('(%g)',value);
      callback = get(chld(1),'callback');
      uimenu(parent,'label',label,'callback',callback,'userdata',value);
      choice(name,value);              % another call to check menu item
   else
      error('choice(): value does not match!');
   end
   
   return

%==========================================================================   

function setup(itm,list,callback)
%
% SETUP    Support convenient setup of a menu structure
%
%             default('color','red');
%             men = uimenu(gcf,'label','Color',UD,'color');
%                   uimenu(men,LB,'Red',CB,CHC,UD,'red');
%                   uimenu(men,LB,'Green',CB,CHC,UD,'green');
%                   uimenu(men,LB,'Blue',CB,CHC,UD,'blue');
%                   choice(men,setting('color'));  % initialized, selected
%
%             default('gain',1.0);
%             men = uimenu(gcf,'label','Gain',UD,'gain');
%                   uimenu(men,LB,'0.5',CB,CHCR,UD,0.5);
%                   uimenu(men,LB,'1.0',CB,CHCR,UD,'1.0');
%                   uimenu(men,LB,'1.5',CB,CHCR,UD,'1.5');
%                   choice(men,setting('color'));  % initialized, selected
%
%             default('spin','UP');
%             men = uimenu(gcf,'label','Spin',UD,'spin');
%                   uimenu(men,LB,'UP',CB,CHC,UD,'UP');
%                   uimenu(men,LB,'DOWN',CB,CHC,UD,'DOWN');
%                   choice(men,setting('spin'));  % initialized, selected
%
%          Convenient menu setup:
%
%             default('color','red');
%             men = uimenu(gcf,'label','Color',UD,'color');
%                   choice(men,{{'Red','red'},{'Green','green'},{'Blue','blue}},CHC);
%
%             default('gain',1.0);
%             men = uimenu(gcf,'label','Gain',UD,'gain');
%                   choice(men,[0.5 1.0 1.5],CHCR);
%
%             default('spin','UP');
%             men = uimenu(gcf,'label','Spin',UD,'spin');
%                   choice(men,{'UP','DOWN'},CHC);
%
   LB = 'label';  CB = 'callback';  UD = 'userdata';  VS = 'visible';
   
   if (isa(list,'double'))
      
      array = list(:);
      for (i=1:length(array))
         value = array(i);  label = sprintf('%g',value);
         uimenu(itm,LB,label,CB,callback,UD,value);
      end
      
   elseif (iscell(list))
      
      for (i=1:length(list))
         entry = list{i};
         if (ischar(entry))
            value = entry;  label = entry;  
            uimenu(itm,LB,label,CB,callback,UD,value);
         elseif (iscell(entry))
            value = entry{2};  label = entry{1};  
            uimenu(itm,LB,label,CB,callback,UD,value);
         else
            error('bad list item!');
         end
      end
      
   else
      error('bad type for choice parameter list');
   end
   
   ud = get(itm,'userdata');
   if (~ischar(ud))
      error('user data of a choice menu item must be character type!');
   end
   
   choice(itm,setting(ud));
   return
   
% eof
