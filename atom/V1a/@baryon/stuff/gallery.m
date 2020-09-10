function [oo,cur] = gallery(o,arg2,arg3)
%
% GALLERY   Manage Gallery
%
%    1) Add a gallery entry: for two input arguments options, title and 
%    comment are chosen from arg2. With one input arg options are chosen
%    from arg1 while a dialog for title and comments is opened.
%
%       gallery(pull(o))               % add to gallery - open dialog
%       o = gallery(o,oo)              % add to gallery - no dialog
%
%    2) Get i-th gallery entry or number of gallery entries
%
%       gallery(o,i);                  % launch gallery entry of i-th index
%       entry = gallery(o,i);          % get entry of i-th index
%       n = gallery(o,inf);            % get number of gallery entries
%
%    3) Clear all gallery entries
%
%       gallery(o,[]);
%
%    4) Special functions
%
%       gallery(o,'Display')           % display gallery entry
%       gallery(o,'Edit')              % edit gallery entry
%       gallery(o,'Up')                % move gallery entry up
%       gallery(o,'Down')              % move gallery entry down
%       gallery(o,'Delete')            % delete gallery entry
%
%    5) Get/set gallery parameters
%
%       [list,cur] = gallery(o)        % get gallery list & current index
%       gallery(o,list,cur)            % set gallery parameters
%
%    Example 1: Add to gallery with dialog
%       gallery(o);
%
%    Example 2: refresh according to i-th gallery entry
%       oo = gallery(o,i);             % fetch i-th gallery entry
%       if is(oo)
%          refresh(oo);                % refresh object
%       end
%
%    See also: CARABAO, MENU
%
   'use "while-if" clauses!';          % 'return* at loop works as an 'if' 
%
% One input argument: add to gallery
% a) gallery(o)                        % add to gallery - open dialog
% b) [list,cur] = gallery(o)           % get gallery list & current index
%
   while (nargin == 1)                 % one input arg                 
      if (nargout == 0)
         o = Dialog(o);                % dialog for title & comment
         if ~isempty(o)
            title = get(o,'title');
            comment = get(o,'comment');
            o = what(o,title,comment);
            gallery(o,o);              % add to gallery
         end
      else                             % return gallery parameters
         oo = opt(o,{'gallery.list',{}});
         cur = opt(o,{'gallery.current',0});
      end
      return
   end
%
% Two input arguments and arg2 is an object
% a) o = gallery(o,oo) % add to gallery - no dialog
%
   while (nargin == 2) && isobject(arg2)  % add to gallery             
      oo = arg2;                       % arg2 is actually an object
      Add(o,oo);
      return
   end
%
% Two input arguments and arg2 is a double (or INF)
% a) entry = gallery(o,i) % get i-th gallery entry
% b) gallery(o,i) % launch gallery entry of i-th index
% c) n = gallery(o,inf) % return number of gallery entries
% d) gallery(o,[]) % clear gallery
%
   while (nargin == 2) && isa(arg2,'double')                           
      idx = arg2;                      % arg2 is an index
      if isinf(idx)
         list = opt(o,{'gallery.list',{}});
         oo = length(list);
      elseif isempty(idx)
         Clear(o);
      else                             % launch gallery entry
         oo = Fetch(o,idx);
         if (nargout >= 1)
            return;                    % return as output arg
         elseif ~isempty(o)
            pair = control(oo,'what');
            rebuild(oo);               % rebuild menu structure
            %refresh(oo);              % refresh screen
            what(oo,pair{1},pair{2});  % update 'what info' from object
         end
      end
      return
   end
%
% Two input arguments and arg2 is a string
% a) gallery(o,idx,'Display') % display gallery entry
% b) gallery(o,idx,'Edit') % edit gallery entry
% c) gallery(o,idx,'Up') % move gallery entry up
% d) gallery(o,idx,'Down') % move gallery entry down
% e) gallery(o,idx,'Delete') % delete gallery entry
%
   while (nargin == 2) && ischar(arg2)                                 
      mode = arg2;                     % arg2 is a mode argument
      switch mode
         case 'Display'
            DisplayEntry(o);
         case 'Edit'
            EditEntry(o);
         case 'Up'
            MoveEntryUp(o);
         case 'Down'
            MoveEntryDown(o);
         case 'Delete'
            DeleteEntry(o);
         otherwise
            error('bad mode!');
      end
      return
   end
%
% Three input args
% a) gallery(o,list,cur) % set gallery parameters
%
   while (nargin == 3)                                                 
      list = arg2;                     % arg2 is the gallery list
      cur = arg3;                      % agr3 is the current index
      setting(o,'gallery.list',list);  % update gallery list
      setting(o,'gallery.current',cur);% update current index
      return
   end
%
% Running beyond this point indicates a syntax error
%
   error('bad calling syntax!');
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = Dialog(o,n)               % Dialog for Title & Comments   
%
   [either,is,trim] = util(o,'either','is','trim');
   
   if (nargin < 2)                     % then add entry
      n = gallery(o,inf) + 1;
      pair = either(control(o,'what'),{'',''});   
      title = either(pair{1},sprintf('Gallery #%g',n));
      comment = pair{2};
   else
      [list,cur] = gallery(o);         % fetch list & current index
      entry = list{n};
      title = entry.title;             % fetch title of gallery entry
      comment = entry.comment;         % fetch comment of gallery entry
   end
%
% We have to convert comments into a text block
%
   text = '';
   for (i=1:length(comment))
      line = comment{i};
      if is(line)
         text(i,1:length(line)) = line;
      end
   end
%
% Now prepare for the input dialog
%
   prompts = {'Title','Comment'};
   values = {title,text};
   
   values = inputdlg(prompts,'New Gallery Entry',[1 50;10 50],values);   
   if isempty(values)
      o = [];
      return                           % user pressed CANCEL
   end
   
   title = either(values{1},title);
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = trim(text(i,:),+1);    % right trim
   end
   
   o = set(o,'title',title);
   o = set(o,'comment',comment);
end

function Add(o,oo)                     % Add Gallert Entry to Settings 
%
% ADD   Add new option setting to gallery
%
   oo = clean(oo);                     % remove what should not be
%
% get options and clean some specific options we don't want to store
%
   opts = opt(oo);
   opts = Clean(opts,'gallery');       % don't store gallery options
   opts = Clean(opts,'control');       % don't store control options
%
% prepare a gallery entry and add entry to gallery list
%
   entry.title = get(oo,'title');
   entry.comment = get(oo,'comment');
   entry.options = opts;
   entry.control.refresh = control(o,'refresh');
   entry.control.current = control(o,'current');
   
   [list,cur] = gallery(o);            % fetch list & current index
   list{end+1} = entry;                % add options as a gallery entry
   cur = length(list);                 % new current index
   
   gallery(o,list,cur);                % update gallery list & current idx
   oo = pull(o);                           % refresh object
   
   Refresh(oo);                        % refresh Gallery menu
end   
 
function Clear(o)                      % Clear all gallery entries     
   gallery(o,{},0);                    % update gallery list & current idx
   Refresh(o);
end

function oo = Fetch(o,idx)             % Fetch i-th Gallery Entry      
%
% FETCH   Fetch i-th gallery entry to prepare an object ready for refresh
%
%    Example:
%       oo = gallery(o,i);             % fetch i-th gallery entry
%       if is(oo)
%          refresh(oo);                % refresh object
%       end
%
   is = @carabull.is;                  % short hand
   
   template = opt(o,{'gallery.template',0});
   [~,curidx] = current(o);            % save current index
      
   if ~(length(idx) == 1 && idx == round(idx))
      error('index (arg2) must be an integer scalar or INF!');
   end
   if (idx <= 0)
      error('index (arg2) must be > 0!');
   end
   
   [list,cur] = gallery(o);            % fetch list & current index
%
% if index out of range we cannot continue and return with empty object
%
   if idx > length(list)
      oo = [];
      return
   end
   
   gallery(o,list,idx);                % update gallery list & current idx
%
% index is in proper range: we fetch the gallery entry from the list,
% and overwrite the current options with gallery options in order to 
% prepare the object for being ready for refresh
%
   entry = list{idx};                  % get required gallery entry
   settings = setting(o);              % get current settings

   flds = fields(entry.options);
   assert(~is('gallery',flds));        % flds must not contain 'gallery'
   assert(~is('control',flds));        % flds must not contain 'gallery'
   
   for (i=1:length(flds))
      tag = flds{i};
      value = getfield(entry.options,tag);
      settings = setfield(settings,tag,value);
   end
   setting(o,settings);                % refresh settings
%
% restore control options
%
   flds = fields(entry.control);
   for (i=1:length(flds))
      tag = flds{i};
      value = getfield(entry.control,tag);
      control(o,tag,value);
   end
%
%  restore refresh settings & store options back
%
   if (template)                       % to be executed as template?
      control(o,'current',curidx);     % select current object
   end
%
% Now redefine refresh callback with proper expression
%
   if (nargout == 0)
      refresh(o);                      % invoke refresh callback
   end
   Refresh(o);                         % refresh check mark in Gallery menu
%
% construct, restore & refresh 'what info'
%
   what = {entry.title,entry.comment};
   control(o,'what',what);             % refresh 'what info'
   oo = control(o,'what',what);        % refresh 'what info'
end

function Refresh(o)                    % Refresh Gallery Menu          
   o = pull(o);                        % refresh options
   menu(o,'Gallery');                  % refresh Gallery menu
   menu(o,'Select');                   % refresh Select menu
end

function opts = Clean(opts,tag)        % Clean Options from a Field    
   if ~isempty(opts)
      if isfield(opts,tag)
         opts = rmfield(opts,tag);
      end
   end
end

%==========================================================================
% Special Functions
%==========================================================================

function DisplayEntry(o)               % Display Current Gallery Entry 
   [list,cur] = gallery(o);            % fetch list & current index
   if (1 <= cur && cur <= length(list))
      entry = list{cur};
      message(o,entry.title,entry.comment);
   else
      message(o,'Empty Gallery!');
   end
end

function EditEntry(o)                  % Edit Current Gallery Entry    
   [list,cur] = gallery(o);            % fetch list & current index
   if (1 <= cur && cur <= length(list))
      o = Dialog(o,cur);
      if ~isempty(o)
         entry = list{cur};            % fetch entry from list
         entry.title = get(o,'title');
         entry.comment = get(o,'comment');
         list{cur} = entry;            % store entry back to list
         gallery(o,list,cur);          % update gallery list & current idx
         Refresh(pull(o));
      end
   end
end

function MoveEntryUp(o)                % Move Gallery Entry Up         
   [list,cur] = gallery(o);            % fetch list & current index
   if (cur > 1)
      tmp = list{cur-1};
      list{cur-1} = list{cur};         % swap entries
      list{cur} = tmp;
      gallery(o,list,cur-1);           % update gallery list & current idx
   end
   Refresh(pull(o));
end

function MoveEntryDown(o)              % Move Gallery Entry Down       
   [list,cur] = gallery(o);            % fetch list & current index
   if (cur < length(list))
      tmp = list{cur+1};
      list{cur+1} = list{cur};         % swap entries
      list{cur} = tmp;
      gallery(o,list,cur+1);           % update gallery list & current idx
   end
   Refresh(pull(o));
end

function DeleteEntry(o)                % Delete Current Gallery Entry  
   [list,cur] = gallery(o);            % fetch list & current index
   if (1 <= cur && cur <= length(list))
      list(cur) = [];
      if (length(list) == 0)
         cur = 0;
      elseif (cur > length(list))
         cur = length(list);
      end
      gallery(o,list,cur);             % update gallery list & current idx
      if (cur > 0)
         oo = gallery(pull(o),cur);    % reselect gallery entry & refresh
         if ~isempty(oo)
            refresh(oo);
         end
      else
         message(o,'Empty Gallery');
      end
      Refresh(pull(o));
   end
end
