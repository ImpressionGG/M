function oo = call(o,varargin)         % General Callback Function    
%
% CALL   Call a callback
%
%    Pull object from figure and invoke menu callback which is stored in
%    the user data of the calling menu item
%
%       oo = call(caracow);            % call (invoke) callback
%       oo = call(o,cblist);           % call (invoke) callback list
%       oo = call(o,cblist,[],[]);     % master invoke callback list
%
%       callback = call(o,tag,cblist)  % construct callback
%    
%    See also: CARACOW, MENU, SHELL
%
   if (nargin <= 1)
      cblist = get(gcbo,'userdata');   % get list from GCBO function
      o = pull(o);                     % also pull object from figure
   elseif (nargin == 2) || (nargin == 4)
      cblist = varargin{1};
   elseif (nargin == 3)                % construct callback
      oo = {@carabull.master,varargin{1},varargin{2}}; 
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
