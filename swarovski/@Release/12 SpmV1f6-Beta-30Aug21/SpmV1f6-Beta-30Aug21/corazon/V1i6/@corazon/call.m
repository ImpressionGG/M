function [oo,gamma] = call(o,varargin) % General Callback Function    
%
% CALL   Call a callback
%
%    Pull object from figure and invoke menu callback which is stored in
%    the user data of the calling menu item
%
%       oo = call(corazita);            % call (invoke) callback
%       oo = call(o,cblist);           % call (invoke) callback list
%       oo = call(o,cblist,[],[]);     % master invoke callback list
%
%       callback = call(o,tag,cblist)  % construct callback
%    
%    Remark: there is an alternate way to perform the call which is less
%    cumbersome during debuging: instead of performing the call directly
%    we can explicitely request the prepared object with according function
%    handle to be called.
%
%       [oo,gamma] = call(o,...)       % return call parameters
%       oo = gamma(oo);                % actually invoking the call
%
%    Example 1: invoke callback list
%    Instead of invoking
%
%       oo = call(o,cblist)            % call (invoke) callback list
%
%    we can use the equivalent code
%
%       [oo,gamma] = call(o,cblist)    % return call parameters
%       oo = gamma(oo)                 % actual call
%    
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZON, MENU, SHELL
%
   if (nargin <= 1)
      cblist = get(gcbo,'userdata');   % get list from GCBO function
      o = pull(o);                     % also pull object from figure
   elseif (nargin == 2)
      cblist = varargin{1};
   elseif (nargin == 3)                % construct callback
      oo = {@corazito.master,varargin{1},varargin{2}}; 
      return
   elseif (nargin == 4)                % master entry (dummy arg3, arg4)
      oo = Invoke(o,varargin);         % invoke master level callback
      return
   else
      error('1,2 or 3 input args expected!');
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
         %error('1st list element must be fct. name (char) or fct. handle!');
         oo = [];
         gamma=@(o)[];                 % empty returning function
         return
      end
      
      o = arg(o,cblist(2:end));        % set arg list
      if (nargout <= 1)
         oo = gamma(o);                % invoke callback
      else
         oo = o;                       % return parameters
      end
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = Invoke(o,ilist)           % Invoke Master Level Callback  
   toplevel = (length(dbstack) <= 3);  % do we have a top level condition?

   cblist = ilist{1};                  % callback list
   bo = ilist{2};                      % base object
   tag = ilist{3};                     % tag provided by callback
   
   if container(o) && ~isequal(class(o),tag)
      o = cast(o,tag);                 % cast shell object
      o.tag = class(bo);               % counter balancing!
   end
   
   if toplevel                         % only on top level
      o.profiler([]);                  % init profiling
   end
   
   debug = opt(o,{'control.debug',0});
   if (debug)
      Clc(o,toplevel);                 % clear command window
      tic;                             % start tic/toc timer
      [oo,gamma] = call(o,cblist);     % get invoking stuff
      gamma(oo);                       % invoke callback
      control(o,'toc',toc);            % store elapsed time in control opts
   else                                % no debug mode
      try
         call(o,cblist);               % invoke callback
      catch err
         message(o,err);               % report error
      end
   end
   
   if control(o,'profiling') >= 2
      o.profiler;                      % print profiling information
   end
end
function Clc(o,toplevel)               % Clear Command Window          
   if opt(o,{'control.autoclc',1});    % perform a CLC (clear command line)
      if (toplevel)
         clc;                          % clear command window
      end
   end
end