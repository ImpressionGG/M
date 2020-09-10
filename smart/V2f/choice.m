function value = choice(itm,value,dummy)
% 
% CHOICE   Choose from a number of alternative options
%          Example:
%
%             obj = chameo;          % need chameo object to access methods
%             menu(obj);             % open CHAMEO object's menu 
%
%             men = uimenu(gcf,'label','Color','userdata','color');
%             itm1 = uimenu(men,'label','Red','callback','choice(gcfo,gcbo);','userdata','red');
%             itm2 = uimenu(men,'label','Green','callback','choice(gcfo,gcbo);','userdata','green');
%             itm3 = uimenu(men,'label','Blue','callback','choice(gcfo,gcbo);','userdata','blue');
%             itm4 = uimenu(men,'label','Show','callback','option(gcfo)');
%
%             choice(obj,men,'red');  % init menu item & user data to select 'red'as choice
%             choice(obj,men,'blue'); % now select blue
%
%             setting('color')        % display menu setting of 'color'
%
%          Note: in a real program short hands would enhence overview.
%          In addition menu handles (such as itm1,itm2,...) do not have to
%          be numbered when initialization happens immediately. See the
%          same code with these modifications.
%
%             UD = 'userdata';  CB = 'callback';
%             LB = 'label';     CHC = 'choice(gcfo,gcbo);'
%
%             men = uimenu(gcf,'label','Color',UD,'color');
%                   uimenu(men,LB,'Red',CB,CHC,UD,'red');
%                   uimenu(men,LB,'Green',CB,CHC,UD,'green');
%                   uimenu(men,LB,'Blue',CB,CHC,UD,'blue');
%                   choice(obj,men,'red');     % initialized, selected
%                   uimenu(men,LB,'Show',CB,'setting');
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
            value = choice(value);         % shift itm <- value
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
       error('choice(): value does not match!');
       
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
   
% eof
