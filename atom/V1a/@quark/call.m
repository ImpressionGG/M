function oo = call(o,varargin)         % General Callback Function    
%
% CALL   Call a callback
%
%    Pull object from figure and invoke menu callback which is stored in
%    the user data of the calling menu item
%
%       oo = call(quark);              % call (invoke) callback
%       oo = call(o,cblist);           % call (invoke) callback list
%       oo = call(o,cblist,[],[]);     % master invoke callback list
%
%       callback = call(o,tag,cblist)  % construct callback
%    
%    See also: QUARK, MENU, SHELL
%
   if (nargin <= 1)
      cblist = get(gcbo,'userdata');   % get list from GCBO function
      o = pull(o);                     % also pull object from figure
   elseif (nargin == 2) || (nargin == 4)
      cblist = varargin{1};
   elseif (nargin == 3)                % construct callback
%     oo = {@gluon.master,varargin{1},varargin{2}}; 
      oo = {@Master,varargin{1},varargin{2}}; % OCTAVE HACK !!! 
      return
   else
      error('bad calling syntax!');
   end
%
% process callback list, finally execute callback
%
   if isempty(cblist)
      oo = [];
   else
      func = cblist{1};
      if ischar(func)
         gamma = eval(['@',func]);
      elseif isa(func,'function_handle')
         gamma = func;
      else
         error('1st list element must be fct. name (char) or fct. handle!');
      end
      
      o = arg(o,cblist(2:end));        % set arg list
      oo = gamma(o);                   % invoke callback
   end
end

%===============================================================================
% master invoker
%===============================================================================

function oo = Master(obj,evt,tag,cblist)  % Master Callback            
%
% MASTER   Master callback
%
%    Serves as first callback (supporting MATLAB callback interface)
%    and forwards to QARK style callback.
%
%           oo = master(obj,evt,arg1,arg2,...)
%
%        See also: GLUON
%
   gluon.master(obj,evt,tag,cblist);   % delegate to static gluon function
end
