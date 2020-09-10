function check(o,arg,value)            % Menu Check Functionality      
% 
% CHECK   Add a check functionality to a menu item
%
%    Example
%
%       setting(o,{'bullets'},1);      % provide default for bullets
%
%       o = mitem(o,'Simple');                   % add menu item
%       oo = mitem(o,'Bullets',{},'bullets');    % add menu sub-item
%
%       check(oo);                     % check functionality (no refresh)
%       check(oo,'refresh(carabao)');  % check functionality (with refresh)
%       check(oo,'');                  % same as above
%
%    Change a setting from command line & update check mark
%
%       check(o,tag,value);            % change value from command line
%
%    Process CHECK callback:
%
%       check(carabao,inf)             % process CHECK callback
%
%    See also: CARABAO, MENU, MITEM, CHOICE, CHARM, SETTING
%
   %CHK = 'check(carabao,inf);'; 
%
% One input arg
% a) check(oo) % check functionality (no refresh)
%
   while (nargin == 1)                 % check funct. without refresh  
      %callbacks = {{@check},callback};
      callbacks = {{@Toggle}};
      Setup(o,{@CheckCb,callbacks});
      %Setup(o,CHK);
      return
   end
%
% Two input args and arg2 is INF
% a) check(carabao,inf) % check callback (toggle!)
%
   while (nargin == 2 && isequal(arg,inf))                             
      Toggle(o);
      return
   end
%
% Two input args and arg2 is a (empty or nonempty) string or list
% a) check(oo,'refresh(carabao)') % check functionality (with refresh)
% b) check(oo,{}) % check funct., default refresh
%
   while (nargin == 2 && (ischar(arg)||iscell(arg)))                             
      callback = arg;                  % arg is a callback
      if isempty(callback)
         %callback = 'refresh(carabao);';
         callback = {@refresh};
      end

      callbacks = {{@Toggle},callback};
      Setup(o,{@CheckCb,callbacks});
      
%       CHKR = [CHK,callback];
%       Setup(o,CHKR);                   % setup check functionality
      return
   end
%
% Three input args
% a) check(o,tag,value) % change value from command line
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
% Check Callback
%==========================================================================

function o = CheckCb(o)
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

function Setup(o,cblist)               % Setup Check Functionality     
   iif = @carabull.iif;                % short hand
   
   hdl = work(o,'mitem');              % graphics handle
   tag  = get(hdl,'userdata');    
   if (~isstr(tag))
      error('Check(): string expected for user data!');
   end

   callback = call(o,o.tag,cblist);
   set(hdl,'callback',callback);
   value = setting(o,tag);
   set(hdl,'check',iif(value','on','off'));
end

function o = Toggle(o)                 % Toggle Check Mark             
   iif = @carabull.iif;                % short hand
   either = @carabull.either;          % short hand

   hdl = work(o,'object');             % get current callback object
   tag  = get(hdl,'userdata');    
   if (~isstr(tag))
      error('Toggle(): string expected for user data!');
   end

   value = setting(o,tag);
   value = either(~value,true);
   setting(o,tag,value);

   set(hdl,'check',iif(value,'on','off'));
end

function Change(o,tag,value)           % Change From Command Line      
%
% CHANGE    Change parameter from program level and update check mark
%
%              Change(o,parameter,value)
%              Change(o,'play.bullets',true)
%
   iif = @carabull.iif;                % short hand
   
   if ~ischar(tag)
      error('tag (arg2) must be a character string!');
   end
   
   oo = mseek(o,tag);
   if isempty(oo)
      error(['could not find userdata: ',tag]);
   end

   hdl = work(oo,'mitem');
   value = iif(value,true,false);      % convert to boolean value
   setting(o,tag,value);

   set(hdl,'check',iif(value,'on','off'));
end   
