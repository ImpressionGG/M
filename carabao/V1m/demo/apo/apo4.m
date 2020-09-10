function o = apo4(o,varargin)          % APO (Version #4)              
%
% APO4   Automatic Position Optimization (Version #4)
%
%           apo4                       % launch APO4 shell
%
%        Next steps:
%           - extend dispatcher to deal with '@'
%           - call('@Plot'), call('@Twin')
%           - plot with style options
%           - TwinFilter menu item & callback added
%           - configure 'xf'
%           - add a menu item for filter time constant
%
%        See also: TRACE
%
   if (nargin == 0)                    % need to init object?
      o = trace(mfilename);            % create trace object
   end
   
   [cmd,o,func] = arguments(o,varargin,'Shell');
   [cmd,o,func] = arguments(o,func,which(func));    % find func here?
   o = eval(cmd);                      % dispatch to local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Default(o);
   
   menu(o,'Begin');                    % begin shell setup
   menu(o,'File');                     % add File menu
   menu(o,'Edit');                     % add Edit menu
   menu(o,'View');                     % add View menu
   menu(o,'Select');                   % add Select menu
   menu(o,'Plot');                     % add Plot menu
   apo4(o,'Study');                    % add Study menu
   menu(o,'Info');                     % add Info menu
   menu(o,'End');                      % end shell setup
   
   o = trailer(o);                     % trailer supports standard func's
end

function o = Default(o)                % Provide Shell Defaults        
   o = provide(o,'title','APO4 Shell');
   o = provide(o,'comment',{'Auto Position Optimization','(Version #4)'});

   if (category(o,inf) == 0)
      o = category(o,1,[-3 3],[],'µ'); % category #1: spec, scale and unit
   end
   if ~config(o,inf) && property(o,'config?')
      o = config(o,'+');               % let shell define configuration
      o = config(o,'x',{1,'r',1});     % provide subplot#, color, category#
      o = config(o,'xf',{2,'p',1});    % provide subplot#, color, category#
   end
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   call = @bazaar.call;
   default('twin.T',1);                % default value for filter constant
   
   oo = mitem(o,'Study');              % create new menu
   ooo = mitem(oo,'Create Sample',call('Create'));
   ooo = mitem(oo,'Plot Sample',call('@Plot'));
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Twin Filter',call('@Twin'));
   ooo = mitem(oo,'T: Filter Constant','','twin.T');
   choice(ooo,[0.5:0.5:2,3:6, 8, 10:5:30],'');
end

function oo = Create(o)                % Create a Trace Object         
   t = 1:100;                          % crate a time vector
   x = 2 + 0.2*randn(size(t));         % create an 'x' data vector
   oo = trace(t,'x',x);                % pack t and x into a trace object
   
      % provide title & comments for the trace object
      
   oo = set(oo,'title',[now(o),' Sample Data']);
   oo = set(oo,'comment','data with offset 2µ and 0.2µ sigma');
   
      % paste object into shell and display shell info on screen
      
   paste(oo);                          % paste new trace into shell
end

function oo = Plot(o)                  % Plot Trace Object             
   o = with(o,{'view','style'});       % use style options
   cls(o);                             % clear screen
   oo = plot(o);                       % plot object
end

function oo = Twin(o)                  % Twin Filter                   
%
% TWIN   Twin filtering of data stream x
%
   o = with(o,{'view','style'});       % use style options
   oo = current(o);                    % get current object
   
   [t,x] = data(oo,'time','x');        % fetch data
   xf = Filter(oo,t,x);                % calculate filtered x
   oo = data(oo,'xf',xf);              % pack xf into object's data
   
   cls(o);                             % clear screen
   plot(oo);                           % plot object
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function y = Filter(o,t,u)             % Twin Filter Algorithm        
%
%    For a given input signal u, filtered output signal y and filter
%    operator F(*) the twin filter algorithm works as follows:
%
%       v = F(v,u);                    % intermediate signal v
%       e = u - v;                     % filter error
%       w = F(w,e);                    % intermediate signal w
%       y = v + w;                     % twin filter output
%
%    The filter operator F can be any linear (time variant) stable operator
%    which maps a constant signal to the same constant as time approaches
%    infinity (means: gain factor V = 1).
%
%    Simplest algorithm: time variant order 1 filter
%
%       a = exp(-dt/Ts);               % eigenvalue of filter
%       y = a*yold + (1-a)*u           % means: V = 1
%
   T = opt(o,{'twin.T'},5);            % filter time constant

   u = [u(1),u];  t = [-inf,t];        % extend u,t 
   v = 0;  w = 0;  e = 0;  y = 0;      % initialize v, w, e and y
   
   for (k=2:length(t))
      dt = t(k) - t(k-1);              % time difference
      a = exp(-dt/T);                  % filter eigenvalue
      
      v(k) = a*v(k-1) + (1-a)*u(k);    % intermediate signal v
      e(k) = u(k) - v(k);              % filter error
      w(k) = a*w(k-1) + (1-a)*e(k);    % intermediate signal w
      y(k) = v(k) + w(k);              % filter output
   end
   
   y(1) = [];                          % delete "y(-1)"
end
