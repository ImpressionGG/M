function [key,modifier] = keyhit(obj,callback,callargs)
%
% KEYHIT   Default handler for key hit
%
%             keyhit(arg(gfo,{}));  % install keyhit function in figure
%             keyhit(obj);          % internal handling of key hit callback
%
%          Get key and modifier of last keyhit event:
%
%             [key,modifier] = keyhit(obj);   % of last keyhit event
%
%          Install user callbacks. Besides of setting up the user callback
%          also the internal callback will be installed
%
%             keyhit(gfo,callback,callargs);          % setup user callback
%             keyhit(gfo,callback);                   % callargs = {};
%
%             keyhit(gfo,'KeyHit');                   % s/u user callback
%             keyhit(gfo,'Execute',{'KeyHit'});       % s/u user callback
%
%          Remark: for setting up a callback KEYHIT is intelligent enough
%          to add a proper M-FILE call which contains the callback function.
%          E.g if CbKeyHit is a local function of M-file ANALYSE and
%          the call keyhit(gfo,'CbKeyHit') is invoked from M-file ANALYSE
%          then a callback 'analyse(arg(gfo,{'KeyHit'})) will be con-
%          structed and stored in the setting 'shell.keyhit'.
%
%          See also: CORE, BUTPRESS, REFRESH
%
   if  (nargout > 0)             % then get key and modifier from gso
      key = gso('keyhit.key');   modifier = gso('keyhit.modifier');
      gso('keyhit.key','');      gso('keyhit.modifier','');
      return
   end

% otherwise begin processing of all calls without output args

   list = arg(obj,0);            % get arguments
   
% if cmd is non-empty then we invoke the setup call to setup the internal
% KEYHIT callback

   if (isempty(list) && nargin == 1)
      Setup(obj);
      return;
   end

% Otherwise, if we have 1 input arg then we execute the callback. We are
% refering back to the shell settings 'keyhit' and 'keyhitargs'
   
   if (nargin == 1)
      key = get(gcbf,'currentkey');
      modifier = get(gcbf,'currentmodifier');
      
      if ~some(match(key,{'shift','control','alt'}))
         if strcmp(modifier,'shift')
            key = ['shift-',key];
         end
         if strcmp(modifier,'alt')
            key = ['alt-',key];
         end
         if strcmp(modifier,'control')
            key = ['ctrl-',key];
         end
      end

      gso('keyhit.key',key);
      gso('keyhit.modifier',modifier);
      
      callback = setting('shell.keyhit');
      callargs = setting('shell.keyargs');
   
      if (callback)
         if ~iscell(callargs)
            callargs = {callargs};
         end

         %callargs{end+1} = arg(obj,1);   % append KEY at the end of list
         callargs{end+1} = key;           % append KEY at the end of list
         callargs{end+1} = modifier;      % append MODIFIER at list end
         %obj = arg(obj,[],callargs);     % set arguments
         obj = set(obj,'arg',callargs);   % set arguments
         if ~strcmp(key,'control')
            eval(callback);
            'good for a break';
         end
      end
      return
   end
   
% For 2 or 3 args we just setup the shell settings
   
   if (nargin < 3)
      callargs = {};
   end
   
   if (nargin >= 2 && nargin <= 3)
      if ~ischar(callback)
         error('character string expected for arg2 (callback)');
      end
      func = callback;      
%       stack = dbstack;           % get calling stack 
%       path = stack(2).file;      % get path of mfile name
%       [p,mfile,ext] = fileparts(path);
      mfile = caller(obj);
      callback = [mfile,'(obj);'];

      if ~iscell(callargs)
         callargs = {callargs};
      end
      callargs = cons(func,callargs);
      
      setting('shell.keyhit',callback);
      setting('shell.keyargs',callargs);
      
      Setup(obj);   % install internal callback
      return
   end
   
% for more than 3 input args we report an error

   if (nargin > 3)
      error('max 3 input args expected!');
   end
   return
   
%==========================================================================
% Setup Internal Callback
%==========================================================================

function Setup(obj)
%
% SETUP    Setup internal callback
%
   %set(gcf,'KeyPressFcn',@(fig,event) keyhit(arg(gfo,[],event.Key)));
   set(gcf,'KeyPressFcn',@(fig,event) keyhit(arg(gfo,{event.Key})));
   return;
