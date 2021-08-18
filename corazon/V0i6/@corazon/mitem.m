function oo = mitem(o,label,clist,userdata,varargin) % Create Menu Item              
%
% MITEM   Add menu item
%
%    A uimenu item will be added with an implicite callback to 'call'.
%    The handle of the new created menu item is stored in the working
%    property work(o,'mitem').
%
%    Callbacks are always passed as calling list with the first list item
%    being a string (function name) or a function handle.
%
%       mitem(o)                       % display menu item info
%       bag = mitem(o);                % get menu item stuff
%       oo = mitem(o,'File');
%       ooo = mitem(oo,'Open',{@Open});
%       ooo = mitem(oo,'Save',{@Save},userdata);
%
%    Separator
%
%       mitem(o,'-');                  % activate separator for next item
%       mitem(o,'');                   % deactivate separator for next item
%
%    Get/set graphics handle
%
%       hdl = mitem(o,inf)             % get graphics handle
%       o = mitem(o,hdl)               % set graphics handle
%       o = mitem(o,figure(o))         % set up as a figure root
%
%    Choice functionality:
%
%       setting(o,{'view.color'},'b');
%
%       o = mitem(o,figure(o));        % set top level handle
%       oo = mitem(o,'View');
%       ooo = mitem(oo,'Color','view.color');
%       choice(ooo,{{'Red','r'},{'Blue','b'}}});   % no refresh
%
%    Alternatively
%
%       choice(ooo,{{'Red','r'},{'Blue','b'}}},{});   % with refresh
%
%    Get/Set menu item stuff
%
%       oo = mseek(o,{'#' 'Plot' 'Overview})
%       stuff = mitem(oo)              % get mitem stuff
%
%       stuff = {'Overview',{@plot 'MyOvw},1,'visible','on','enable','on'}
%       mitem(oo,stuff)                % set menu item stuff
% 
%          bag.label = 'Overview'
%          bag.callback = callback(o,{@Overview})
%          bag.userdata = []
%          bag.enable = 'on'
%          bag.visible = 'on'
%
%          mitem(o,bag)                % set menu stuff
%
%       Syntactic sugar for change of menu item attributes
%
%          mitem(o,{'Overview')        % change label
%          mitem(o,{'Overview',{@Overview},userdata})
%          mitem(o,{'Overview',{@Overview},userdata,'on','on'})
%
%       Example
%
%          oo = mseek(sho,{'#' 'Plot' 'Overview'}
%          mitem(oo,{'Magic',{@(o) disp(magic(3)) }})
%
%    Copyright (c): Bluenetics 2020 
%
%    See also: CORAZON, CHOICE, MSEEK, MHEAD
% 
   o.profiler('mitem',1);              % begin profiling
   
   persistent separator
   tag = 'mitem';                      % tag for mitem handle
   h = work(o,tag);
%
% One input arg
% a) hdl = Mitem(o) % get handle
%
   while (nargin == 1)
      if (nargout == 0)
         Show(o);                      % show menu item info
      else
         %h = gcf;
         %oo = work(o,tag,h);
         %separator = [];              
         oo = Get(o)                   % get menu item stuff       
      end
      o.profiler('mitem',0);           % end profiling
      return
   end
%
% Intermezzo with separator
%
   while nargin == 2 && isequal(label,'-')  % if separator label
      separator = 1;
      oo = [];
      o.profiler('mitem',0);                % end profiling
      return
   end
   while nargin == 2 && isequal(label,'')   % if empty label
      separator = [];
      oo = [];
      o.profiler('mitem',0);                % end profiling
      return
   end
%
% Two input args and arg2 is a string
% a) hh = mitem(h,'File');
%   
   while (nargin == 2) && ischar(label)
      if isempty(get(h,'Children'))
         separator = [];
      end
      
      hh = uimenu(h,'label',label);
      type = get(h,'type');
      %if isprop(h,'visible')          % mind: figures do not have!
      if isequal(type,'uimenu')
         set(h,'visible','on');        % activate visibility
      end
      
      %oo = work(o,tag,hh);            % can be made faster
      oo = o;
      oo.work.(tag) = hh;              
      
      if ~isempty(separator)
         set(hh,'separator','on');
         separator = [];
      end
      o.profiler('mitem',0);           % end profiling
      return      
   end
%
% Two input args and arg2 is not a string
% a) hdl = mitem(o,inf) % get graphics handle
% b) o = mitem(o,hdl) % set graphics handle
%   
   while (nargin == 2) && ~ischar(label)
      hdl = label;                     % label is a graphics handle
      bag = label;                     % or a bag of attributes
      %if isinf(hdl)
      if isequal(hdl,inf)
         oo = work(o,'mitem');
      elseif iscell(bag) || isstruct(bag)
         oo = Set(o,bag);
      else
         oo = work(o,'mitem',hdl);
         separator = [];               % reset separator
      end
      o.profiler('mitem',0);           % end profiling
      return      
   end
%
% Three input args
% a) hhh = mitem(hh,'Load ...',{@Load})
% b) hhhh = mitem(hhh,'Red',{@SetColor 'r'})
% c) hhhh = mitem(hhh,'Blue',{@SetColor 'b'})
% d) hhhh = mitem(hhh,'Color','','view.color')
%   
   while (nargin >= 3)
      if ~(iscell(clist) || ischar(clist)) && (nargin == 3)
         error('calling list (arg3) must be a string or list!');
      end
      
      if isempty(get(h,'Children'))
         separator = [];
      end
      
      hh = uimenu(h,'label',label);    % create uimenu item
      set(h,'visible','on');           % activate visibility
      if ischar(clist)
         set(hh,'callback',clist);
      elseif ~isempty(clist)
         %callback = {@call corazon clist};
         callback = call(o,class(o),clist);  % construct callback
         set(hh,'callback',callback);
      end
      
      if (nargin >= 4)
         set(hh,'userdata',userdata);
      end
      
      if ~isempty(separator)
         set(hh,'separator','on');
         separator = [];
      end
      
      if (nargin >= 5)
         list = varargin;
         if length(list) == 1 && iscell(list{1})
            list = list{1};
         end
         for (i=1:2:length(list)-1)
            set(hh,list{i},list{i+1}); % set other properties
         end
      end
      
      %oo = work(o,tag,hh);            % rewrite to be a bit faster
      oo = o;
      oo.work.(tag) = hh;
      
      o.profiler('mitem',0);           % end profiling
      return
   end
%
% Any move beyond that point indicates a syntax error
%
   error('1,2 or 3 input args expected!')
%
% handle separator
%
end

%==========================================================================
% Get/Set Menu Stuff
%==========================================================================

function bag = Get(o)                  % Get Menu Item Stuff           
   hdl = mitem(o,inf);
   
   bag.label = get(hdl,'label');
   bag.callback = get(hdl,'callback');
   bag.userdata = get(hdl,'userdata');
   bag.visible = get(hdl,'visible');
   bag.enable = get(hdl,'enable');
   bag.separator = get(hdl,'separator');
   bag.hdl = mitem(o,inf);
end
function o = Set(o,bag)                % Set Menu Item Stuff           
%
% SET   Set menu item stuff
%
%          bag.label = 'Overview'
%          bag.callback = callback(o,{@Overview})
%          bag.userdata = []
%          bag.enaable = 'on'
%          bag.visible = 'on'
%
%          mitem(o,bag)                % set menu stuff
%
%       Alternatively
%
%          mitem(o,{'Overview',{@Overview},usedata,'on','on'})
%          mitem(o,{'Overview',{@Overview},usedata})
%
   if iscell(bag)
      list = bag;
      bag = [];
      
      if (length(list) >= 1)
         bag.label = list{1}
      end
      if (length(list) >= 2)
         bag.callback = list{2}
      end
      if (length(list) >= 3)
         bag.userdata = list{3}
      end
      if (length(list) >= 4)
         bag.enable = list{4}
      end
      if (length(list) >= 5)
         bag.visible = list{5}
      end
   end
   
      % make handle available
   
   if ~isfield(bag,'hdl')
      bag.hdl = mitem(o,inf);
   end
   
   if isempty(bag.hdl)
      return
   end
   
         % set defaults for missing fields

   if ~isfield(bag,'callback')
      bag.callback = {};
   end
   if ~isfield(bag,'userdata')
      bag.userdata = [];
   end
   if ~isfield(bag,'enable')
      bag.enable = 'on';
   end
   if ~isfield(bag,'visible')
      bag.visible = 'on';
   end
   if ~isfield(bag,'separator')
      bag.separator = 'off';
   end

      % perform type/value checks
      
   if ~ischar(bag.label)
      error('char string expected for label field');
   end
   if ~(isequal(bag.enable,'on') || isequal(bag.enable,'off'))
      error('''on'' or ''off'' expected for enable field');
   end
   if ~(isequal(bag.visible,'on') || isequal(bag.visible,'off'))
      error('''on'' or ''off'' expected for visible field');
   end
   if ~(isequal(bag.separator,'on') || isequal(bag.separator,'off'))
      error('''on'' or ''off'' expected for separator field');
   end

      % set menu item stuff

   hdl = bag.hdl;                   % short hand

      % special treatment of callback

   if ~IsMasterCallback(o,bag.callback)
      bag.callback = call(o,class(o),bag.callback);
   end

      % set attributes
      
   set(hdl,'label',bag.label);
   set(hdl,'callback',bag.callback);
   set(hdl,'userdata',bag.userdata);
   set(hdl,'visible',bag.visible);
   set(hdl,'enable',bag.enable);
   set(hdl,'separator',bag.separator);
   
   function ok = IsMasterCallback(o,callback)
      ok = false;                      % by defaut
      if (iscell(callback) && ~isempty(callback))
         arg1 = callback{1};
         
         if isa(arg1,'function_handle')
            if isequal(char(arg1),'corazito.master')
               ok = true;              % yes - master callback!
            end
         end
      end
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function Show(o,hdl)                   % Show Menu Item Details        
%
% SHOW   Show menu item details
%
%        mitem(o)
%           figure:   2
%           label:    Version
%           parent:   Info
%           callback: menu(pull(corazon),'Info')
%           userdata: {'1' [3x1]}
%           visible:  on
%           enable:   on
%
   iif = util(o,'iif');                % need some utility
   
   [is,isfigure] = util(o,'is','isfigure');
   [isscreen,isghandle] = util(o,'isscreen','isghandle');
   
   if (nargin < 2)
      hdl = work(o,'mitem');
   end
   
   if isscreen(hdl)
      fprintf('     menu item: #0 (graphics root)\n');
      return
   end
   
   try
      parent = get(hdl,'parent');
      if ~isempty(parent)
         if isfigure(parent) || isscreen(parent)
            parent = sprintf('Figure %g',double(parent));
         else
            parent = get(parent,'label');
         end
      end

      fig = figure(o);   

      if isfigure(hdl) || isscreen(hdl)
         figtxt = iif(isempty(fig),'[]',sprintf('%g',double(fig)));
         fprintf('     menu item: #%s (figure)\n',figtxt);
         if isempty(fig)
            fprintf('     *** mismatch, since ofig(o) = []\n');
         elseif figure(o) ~= fig
            fprintf('     *** mismatch, since ofig(o) = %g\n',ofig(o));
         end
         return
      end

      callback = get(hdl,'callback');
      userdata = get(hdl,'userdata');
      visible = get(hdl,'visible');
      enable = get(hdl,'enable');

      path = {};
      while ~isfigure(hdl)
         label = get(hdl,'label');
         if isempty(label)
            break
         end
         path{end+1} = label;
         hdl = get(hdl,'parent');
      end
      path = path(end:-1:1);              % bring into right order

      figtxt = iif(isempty(fig),'[]',sprintf('%g',fig));
      fprintf('     menu item: #%s',figtxt);
      for (i=1:length(path))
         fprintf('%s%s',' / ',path{i});
      end
      fprintf('\n');
      fprintf('     callback: %s\n',Printable(callback));
      fprintf('     userdata: ');
      switch class(userdata)
         case {'double','char','struct'}
            fprintf('%s',Printable(userdata));
         case 'cell'
            fprintf('{');
            list = userdata;
            for (i=1:length(list))
               if (i==1)
                  fprintf('%s',Printable(list{i}));
               else
                  fprintf(',%s',Printable(list{i}));
               end
            end
            fprintf('}');
      end
      fprintf('\n');
      fprintf('     visible:  %s\n',visible);
      fprintf('     enable:   %s\n',enable);
   catch
      'catched';
   end
end

function str = Printable(ud)           % Convert to Printable Data     
%
%
   switch class(ud)
      case 'double'
         str = sprintf('[%gx%g]',size(ud,1),size(ud,2));
      case 'char'
         if isempty(ud)
            str = '';
         else
            str = ud(1,:);
         end
      case 'struct'
         str = '<struct>';
      case 'function_handle'
         str = ['@',char(ud)];
      case 'cell'
         str = '{';  sep = '';
         for (i=1:length(ud))
            if (i < 5)
               str = [str,sep,Printable(ud{i})];
               sep = ' ';
            else
               str = [str,sep,'...'];
               break
            end
         end
         str = [str,'}'];
      otherwise
         if isobject(ud)
            str = sprintf('[%gx%g %s]',size(ud,1),size(ud,2),class(ud));
         else
            str = '[?]';
         end
   end
   return
end
