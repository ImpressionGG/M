function o = choice(o,arg2,arg3,varargin)
% 
% CHOICE   Add a choice functionality to a menu item
%
%    Compact setup of choice rolldown menus based on lists like
%    {{'Red','r'},{'Blue','b'},{'Green','g'}} or numerical vectors
%    like 1:5, [1 2 5 10] or [0:0.1:0.9, 1:5]. CHOICE always refers to 
%    a setting which has to be refered in the parent item of the rolldown
%    menu.
%
%       setting(o,{'color'},'r');           % provide default for color
%
%       o = mhead(baryon,'Simple');         % add menu header item
%       oo = mitem(o,'Color','','color');   % add menu item
%
%       choice(oo,{{'Red','r'},{'Blue','b'}});          % no refresh
%       choice(oo,{{'Red','r'},{'Blue','b'}},'');       % default refresh
%       choice(oo,{{'Off',0},{'On',1}},{@refresh});     % user refresh
%       
%       choice(oo,1:5,{'Blue','b'}});       % no refresh
%       choice(oo,1:5,{});                  % default refresh
%       choice(oo,1:5,'refresh(baryon)');   % user refresh
%
%    Change a setting from command line & update check mark
%
%       choice(o,tag,value);            % change value from command line
%
%    Example 1:
%       setting(o,{'color'},'r');             % set default for color
%       oo = mitem(o,'Color','','color');     % add menu item
%       choice(oo,{{'Red','r'},{'Blue','b'}},{});   % default refresh
%
%    Example 2:
%       setting(o,{'level'},1);               % set default level
%       oo = mitem(o,'Level','','level');     % add menu item
%       choice(oo,[0,1,2,3],{});              % default refresh
%
%    Example 3: choice list contains a separator ({})
%       setting(o,{'class'},'*');             % set default class
%       choices = {{'all','*'},{},{'ball','b'},{'cube','c'}};
%       oo = mitem(o,'Classes','','class');   % add menu item
%       choice(oo,choices,{});                % default refresh
%
%    See also: BARYON, SHELL, MENU, MITEM, CHECK, CHARM, SETTING
%
   if (nargin == 1)
"Choice: nargin=1"
      o = pull(quark);
      Choice(o,gcbo);                    % delegate with current object
   elseif (nargin == 2)
"Choice: nargin=2"
      list = arg2;
      if iscell(list) || isa(list,'double')
         mhdl = work(o,'mitem');
         callbacks = {{@choice}};
         Choice(o,mhdl,list,{@ChoiceCb,callbacks});
      else
         error('cell array or double array expected for arg2!');
      end
      
   elseif (nargin >= 3 && rem(nargin,2)==1)  % odd number of args
      
      label = arg2;  list = arg2;     % arg2 is either list or label
      callback = arg3;  ud = arg3;    % arg3 is either callback or userdata
      
      if iscell(list) || isa(list,'double')
         if isempty(callback)
            %callback = 'refresh(pull(quark));';
            callback = {@refresh};
         end   
         mhdl = work(o,'mitem');
         callbacks = {{@choice},callback};
         Choice(o,mhdl,list,{@ChoiceCb,callbacks});
      elseif ischar(label)
         if (nargin == 3)
            tag = arg2;  value = arg3;
            fig = figure(o);
            if isempty(fig)
               Change(o,tag,value);
            else
               Change(o,tag,value,fig);
            end
            return
         else
            error('implementation restriction!');
         end
      else
         error('character string or cell array expected for arg2!');
      end
      
   elseif (nargin >= 4 && rem(nargin,2) == 0)  % even number of args
      
      label = arg2;                   % arg2 is label
      ud = arg3;                      % arg3 is userdata
      callback = varargin{1};         % arg4 is callback
      
      if ischar(label)
         if isempty(callback)
%           [func,mfile] = caller(o);
%           callback = call('refresh',mfile);
            callback = 'refresh(pull(quark));';
         end   
         CHCR = [CHC,callback];
         hdl = uimenu(mitem(o),'label',label,'callback',CHCR,'userdata',ud);
         try                             % value might not match
            choice(o,{},CHCR);           % provide check if setting matches
         catch
         end
         
         i = 2;
         while (i <= length(varargin))
            parameter = varargin{i};
            value = varargin{i+1};
            set(hdl,parameter,value);
            i = i+2;
         end
      else
         error('character string expected for arg2!');
      end         
   else
      error('2 or 3 input args expected!');
   end
   return
end

%==========================================================================
% Choice Callback
%==========================================================================

function o = ChoiceCb(o)
   callbacks = arg(o,1);
   for (i=1:length(callbacks))
      callback = callbacks{i};
      call(o,callback);
      o = pull(o);                     % refresh object
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function value = Choice(o,itm,value,dummy)    % Choice from Options      
% 
% CHOICE   Choose from a number of alternative options
%
   nin = nargin -1;
   
   if (nin < 1)
      error('Choice(): 1 or 2 args expected!');
   end
   
   if (nin == 1)   % make current choice as new selection

      parent = get(itm,'parent');
      name  = get(parent,'userdata');    
      if (~ischar(name))
         error('Choice(): string expected for user data!');
      end
      
      chld = get(parent,'children');
      set(chld,'checked','off');     % uncheck all
      set(itm,'checked','on');       % check selected item
      
      value = get(itm,'userdata');
      setting(o,name,value);
      
   elseif (nin == 2)   % initialize
      if (ischar(itm))
         Change(o,itm,value);    % program level change of parameter
         return
      end
      parent = itm;                % make it more transparent
      chld = get(parent,'children');

      name  = get(parent,'userdata');    
      if (~ischar(name))
         error('Choice(): string expected for user data!');
      end

      for (i=1:length(chld))
         ch = chld(i);
         ud = get(ch,'userdata');
         
         %match = Matching(ud,value);
         match = isequal(ud,value);
         if (match)
             set(chld,'checked','off');     % uncheck all children
             set(ch,'checked','on');
             setting(o,name,value);
             return
         end             
      end
       
         % if not found there is a possibility for automatic
         % extent of the menu
         
      if (isa(value,'double'))
         label = sprintf('(%g)',value);
         callback = get(chld(1),'callback');
         uimenu(parent,'label',label,'callback',callback,'userdata',value);
         Choice(o,name,value);              % another call to check menu item
      else
         error('Choice(): value does not match!');
      end
       
   elseif (nin == 3)   % menu setup
      Setup(o,itm,value,dummy);
   end
   return
end

%==========================================================================
% Change parameter from program level
%==========================================================================

function found = Change(o,parameter,value,tree)
%
% CHANGE    Change parameter from program level
%
%              Change(o,parameter,value)
%
   nin = nargin - 1;
   if (nin == 2)
      success = Change(o,parameter,value,gcf);
      if (~success)
         %parameter,value
         error(['could not find parameter "',parameter,'" in menu!']);
      end
      return
   else
      type = get(tree,'type');
      ud = get(tree,'userdata');
      if (~ischar(ud))
         ud = '';
      end
      
      if (strcmp(type,'uimenu') && strcmp(ud,parameter))
         Update(o,tree,value);     % update setting & menu checks
         found = 1;
         return
      else
         %ch = child(tree);
         ch = get(tree,'children');
         for (i = 1:length(ch))
            found = Change(o,parameter,value,ch(i));
            if (found)
               return;
            end
         end
         found = 0;
      end
   end
end

function Update(o,itm,value)           % Update a Menu Choice          
%
% UPDATE   Update a menu choice. Allow also a value which is not
%          provided as a pre-defined choice.
%
%             Update(o,itm,value)      % itm is a handle to UIMENU
%
   parent = itm;                       % make it more transparent
   chld = get(parent,'children');

   name  = get(parent,'userdata');    
   if (~ischar(name))
      error('Update(): string expected for user data!');
   end

   set(chld,'checked','off');          % uncheck all children
   setting(o,name,value);              % change setting
   
   for (i=1:length(chld))
      ch = chld(i);
      ud = get(ch,'userdata');

      %match = Matching(ud,value);
      match = isequal(ud,value);
      if (match)
         set(ch,'checked','on');
         return
      end             
   end

      % here we end up if no match has been found
      % in case of a double we are allowed to extend the menu
      
   if (isa(value,'double'))
      label = sprintf('(%g)',value);
      callback = get(chld(1),'callback');
      uimenu(parent,'label',label,'callback',callback,'userdata',value);
      Choice(o,name,value);            % another call to check menu item
   else
      error('Choice(): value does not match!');
   end
   
   return
end

function Setup(o,itm,list,callback)    % Convenient Menu Setup         
%
% SETUP    Support convenient setup of a menu structure
%
%             default('color','red');
%             men = uimenu(gcf,'label','Color',UD,'color');
%                   uimenu(men,LB,'Red',CB,CHC,UD,'red');
%                   uimenu(men,LB,'Green',CB,CHC,UD,'green');
%                   uimenu(men,LB,'Blue',CB,CHC,UD,'blue');
%                   Choice(o,men,setting('color'));  % initialized, selected
%
%             default('gain',1.0);
%             men = uimenu(gcf,'label','Gain',UD,'gain');
%                   uimenu(men,LB,'0.5',CB,CHCR,UD,0.5);
%                   uimenu(men,LB,'1.0',CB,CHCR,UD,'1.0');
%                   uimenu(men,LB,'1.5',CB,CHCR,UD,'1.5');
%                   Choice(o,men,setting('color'));  % initialized, selected
%
%             default('spin','UP');
%             men = uimenu(gcf,'label','Spin',UD,'spin');
%                   uimenu(men,LB,'UP',CB,CHC,UD,'UP');
%                   uimenu(men,LB,'DOWN',CB,CHC,UD,'DOWN');
%                   Choice(o,men,setting('spin'));  % initialized, selected
%
%          Convenient menu setup:
%
%             default('color','red');
%             men = uimenu(gcf,'label','Color',UD,'color');
%                   Choice(o,men,{{'Red','red'},{'Green','green'},{'Blue','blue}},CHC);
%
%             default('gain',1.0);
%             men = uimenu(gcf,'label','Gain',UD,'gain');
%                   Choice(o,men,[0.5 1.0 1.5],CHCR);
%
%             default('spin','UP');
%             men = uimenu(gcf,'label','Spin',UD,'spin');
%                   Choice(o,men,{'UP','DOWN'},CHC);
%
   %LB = 'label';  CB = 'callback';  UD = 'userdata';  VS = 'visible';
   
   o = work(o,"mitem",itm);                 % store parent item handle in work
   if (isa(list,'double'))
      array = list(:);
      for (i=1:length(array))
         value = array(i);  label = sprintf('%g',value);
         %uimenu(itm,LB,label,CB,callback,UD,value);
         mitem(o,label,callback,value);
      end
   elseif (iscell(list))
      for (i=1:length(list))
         entry = list{i};
         if (ischar(entry))
            value = entry;  label = entry;  
            %uimenu(itm,LB,label,CB,callback,UD,value);
            mitem(o,label,callback,value);
         elseif isempty(entry)
            mitem(o,'-');
         elseif (iscell(entry))
            value = entry{2};  label = entry{1};  
            %uimenu(itm,LB,label,CB,callback,UD,value);
            mitem(o,label,callback,value);
         else
            error('bad list item!');
         end
      end
   else
      error('bad type for choice parameter list');
   end

      % do some final checks
      
   ud = get(itm,'userdata');
   if (~ischar(ud))
      error('user data of a choice menu item must be character type!');
   end
   
   value = setting(o,ud);
   if isempty(value)
%     error(['setting ''',ud,''' of choice menu item must be nonempty!']);
   end
   Choice(o,itm,value);
end

