function charm(o,arg,value)            % Menu Charm Functionality      
% 
% CHARM   Add a charm functionality to a menu item
%
%    The charm functionality allows to edit a double or character setting
%    The type (double or char) cannot be changed (only the value).
%
%    Example
%
%       setting(o,{'value'},1.2);      % provide default for value
%
%       o = mitem(o,'Simple');               % add menu item
%       oo = mitem(o,'Value',{},'value');    % add menu sub-item
%
%       charm(oo);                     % charm functionality (no refresh)
%       charm(oo,{@refresh});          % charm functionality (with refresh)
%       charm(oo,{});                  % same as above
%
%    Change a setting from command line & update charm display
%
%       charm(o,tag,value);            % change value from command line
%
%    Process CHARM callback:
%
%       charm(corazon,inf)             % process CHARM callback
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, MENU, MITEM, CHOICE, CHECK, DEFAULT
%
   %CHM = 'charm(corazon,inf);'; 
%
% One input arg
% a) charm(oo) % charm functionality (no refresh)
%
   while (nargin == 1)                 % charm funct. without refresh  
      callbacks = {{@Edit}};
      Setup(o,{@CharmCb,callbacks});
      %Setup(o,CHM);
      return
   end
%
% Two input args and arg2 is INF
% a) charm(corazon,inf);               % charm callback (edit value!)
%
   while (nargin == 2 && isequal(arg,inf))                             
      Edit(o);
      return
   end
%
% Two input args and arg2 is a (empty or nonempty) string
% a) charm(oo,'refresh(corazon)') % charm functionality (with refresh)
% b) charm(oo,'') % charm functionality, default refresh
%
   while (nargin == 2) && ((ischar(arg)) || iscell(arg))                             
      callback = arg;                  % arg is a callback
      if isempty(callback)
         %callback = 'refresh(corazon);';
         callback = {@refresh};
      end

      callbacks = {{@Edit},callback};
      Setup(o,{@CharmCb,callbacks});
       
      %CHMR = [CHM,callback];
      %Setup(o,CHMR);                  % setup check functionality
      return
   end
%
% Three input args
% a) charm(o,tag,value) % change value from command line
%
   while (nargin == 3)  
      tag = arg;
      Change(o,tag,value);
      return
   end
%
% Anything beyond this point indicates bad calling syntax
%
   error('bad calling syntax!');
end

%==========================================================================
% Charm Callback
%==========================================================================

function o = CharmCb(o)
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

function Setup(o,callback)             % Setup Check Functionality     
   hdl = work(o,'mitem');              % graphics handle
   tag  = get(hdl,'userdata');    
   oo = mitem(o,'',callback);
   Update(oo,tag);   
end

function Update(o,tag)                 % Update                        
   if (~isstr(tag))
      error('Check(): string expected for user data!');
   end
   
   value = setting(o,tag);
   if isa(value,'double') && isscalar(value)
      label = sprintf('%g',value);      
   elseif ischar(value) && ((size(value,1) == 1) || isempty(value))
      label = value;
   else
      error('value of setting must be scalar double or char row!');
   end
   
   hdl = work(o,'mitem');              % graphics handle
   set(hdl,'label',label);
end

function o = Edit(o)                   % Edit Value                    
   iif = @corazito.iif;                % short hand
   either = @corazito.either;          % short hand

   hdl = gcbo;                         % get current callback object
   o = work(o,'mitem',hdl);            % Update picks handle from work
   tag  = get(get(hdl,'parent'),'userdata');    
   if (~isstr(tag))
      error('Check(): string expected for user data!');
   end

   value = setting(o,tag);
   if ischar(value) && isempty(value)
      str = '';
   elseif ischar(value)
      str = value(1,:);
   elseif isa(value,'double')
      value = either(value,0);
      str = sprintf('%f',value);
      idx = find(str=='.');
      while (~isempty(idx) && str(end) == '0')
         str(end) = '';
         if str(end) == '.'
            str(end) = '';
            break;
         end
      end
   else
      error('double or char expected for value!');
   end
   
      % open an input dialog
      
   prompts = {tag};  values = {str};
   answers = inputdlg(prompts,'Edit Parameter',[1 40],values);
   if isempty(answers)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   if ischar(value)
      value = either(answers{1},value);
   else % double
      value = sscanf(either(answers{1},'0'),'%f');
   end
   
   setting(o,tag,value);               % update setting
   Update(o,tag);                      % update label
end

function Change(o,tag,value)           % Change From Command Line      
%
% CHANGE    Change parameter from program level and update check mark
%
%              Change(o,parameter,value)
%              Change(o,'play.bullets',true)
%
   iif = @corazito.iif;                % short hand
   
   if ~ischar(tag)
      error('tag (arg2) must be a character string!');
   end
   
   oo = mseek(o,tag);
   if isempty(oo)
      error(['could not find userdata: ',tag]);
   end

   hdl = work(oo,'mitem');
   %value = iif(value,true,false);      % convert to boolean value
   setting(o,tag,value);
   
   kids = get(hdl,'children');
   ooo = work(oo,'mitem',kids(1));
   Update(ooo,tag);
   %set(hdl,'check',iif(value,'on','off'));
end   

