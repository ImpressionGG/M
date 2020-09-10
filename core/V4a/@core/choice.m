function choice(obj,arg2,arg3,varargin)
% 
% CHOICE   Add a choice functionality to a menu item
%
%    Compact setup of choice rolldown menus based on lists like
%    {{'Red','r'},{'Blue','b'},{'Green','g'}} or numerical vectors
%    like 1:5, [1 2 5 10] or [0:0.1:0.9, 1:5]. CHOICE always refers to 
%    a setting which has to be refered in the parent item of the rolldown
%    menu.
%
%       default('color','r');                 % set default for color
%
%       ob1 = mitem(core,'Simple');           % add rolldown header item
%       ob2 = mitem(ob1,'Color','','color');  % add roll down menu item
%
%       choice(ob2,{{'Red','r'},{'Blue','b'}});          % no refresh
%       choice(ob2,{{'Red','r'},{'Blue','b'}},'');       % default refresh
%       choice(ob2,{{'Off',0},{'On',1}},'refresh(gfo)'); % user refresh
%       
%       choice(ob2,1:5,{'Blue','b'}});        % no refresh
%       choice(ob2,1:5,'');                   % default refresh
%       choice(ob2,1:5,'refresh(gfo)');       % user refresh
%
%    Alternative way to setup a choice menu. This menu is helpful if
%    additional settings like ENABLE or VISIBILITY have to be provided.
%
%       default('color','r');                 % set default for color
%
%       ob1 = mitem(core,'Simple');           % add rolldown header item
%       ob2 = mitem(ob1,'Color','','color');  % add roll down menu item
%
%       choice(ob2,'Green','g');              % choice item, no refresh
%       choice(ob2,'Blue','b','');            % choice item, default refresh
%       choice(ob2,'Red','r',call('refresh'));% choice item, user refresh
%
%    Set additional attributes of menu item:
%
%       choice(ob2,'Green','g','enable','off','visible','on');
%       choice(ob2,'Blue','b','','enable','off','visible','on');
%       choice(ob2,'Red','r',call('refresh'),'enable','off','visible','on');
%
%    See also: SHELL, MENU, MITEM, CHECK, DEFAULT, CHOICE
%
   CHC = 'choice(gcbo);';
   
   if (nargin == 2)
      list = arg2;
      if iscell(list) || isa(list,'double')
         choice(mitem(obj),list,CHC);
      else
         error('cell array or double array expected for arg2!');
      end
      
   elseif (nargin >= 3 && rem(nargin,2)==1)  % odd number of args
      
      label = arg2;  list = arg2;     % arg2 is either list or label
      callback = arg3;  ud = arg3;    % arg3 is either callback or userdata
      
      if iscell(list) || isa(list,'double')
         if isempty(callback)
            [func,mfile] = caller(obj);
            callback = call('refresh',mfile);
         end   
         CHCR = [CHC,callback];
         choice(mitem(obj),list,CHCR);
      elseif ischar(label)
         hdl = uimenu(mitem(obj),'label',label,'callback',CHC,'userdata',ud);
         try                             % value might not match
            choice(obj,{},CHC);          % provide check if setting matches
         catch
         end
         
         i = 1;
         while (i <= length(varargin))
            parameter = varargin{i};
            value = varargin{i+1};
            set(hdl,parameter,value);
            i = i+2;
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
            [func,mfile] = caller(obj);
            callback = call('refresh',mfile);
         end   
         CHCR = [CHC,callback];
         hdl = uimenu(mitem(obj),'label',label,'callback',CHCR,'userdata',ud);
         try                             % value might not match
            choice(obj,{},CHCR);         % provide check if setting matches
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
         error('character stringexpected for arg2!');
      end         
   else
      error('2 or 3 input args expected!');
   end
   return
end
