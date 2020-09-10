function o = apo6(o,varargin)          % APO (Version #6)              
%
% APO6   Automatic Position Optimization (Version #6)
%
%           apo6                       % launch APO6 shell
%
%        Next steps:
%           - adopt CreateSample to generate a matrix stream
%           - create individual (stochastic) position offsets
%           - twin filter matrix based
%           - position optimization matrix based
%           - only n optimization runs
%           - can activate/deactivate twin mode 
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
   apo6(o,'Study');                    % add Study menu
   menu(o,'Info');                     % add Info menu
   menu(o,'End');                      % end shell setup
   
   o = trailer(o);                     % trailer supports standard func's
end

function o = Default(o)                % Provide Shell Defaults        
   o = provide(o,'title','APO6 Shell');
   o = provide(o,'comment',{'Auto Position Optimization','(Version #6)'});

   if (category(o,inf) == 0)
      o = category(o,1,[-3 3],[],'µ'); % category #1: spec, scale and unit
   end
   if ~config(o,inf) && property(o,'config?')
      o = config(o,'+');               % let shell define configuration
      o = config(o,'x',{1,'r',1});     % provide subplot#, color, category#
      o = config(o,'xf',{2,'d',1});    % provide subplot#, color, category#
      o = config(o,'xo',{3,'p',1});    % provide subplot#, color, category#
   end
   
   if isempty(opt(o,'style'))
      o = opt(o,'style.labels','statistics');
   end
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   call = @bazaar.call;
   default('twin.mode',1);             % default value for twin mode
   default('twin.T',0.5);              % default value for filter constant
   default('twin.K',1.5);              % default value for filter factor
   default('twin.N',5);                % default value for # optim. steps
   
   oo = mitem(o,'Study');              % create new menu
   ooo = mitem(oo,'Create Sample',call('Create'));
   ooo = mitem(oo,'Plot Sample',call('@Plot'));
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Twin Filter',call('@Twin'));
   ooo = mitem(oo,'Twin Parameters');
   oooo = mitem(ooo,'Twin Mode','','twin.mode');
   choice(oooo,{{'on',1},{'off',0}},'');
   oooo = mitem(ooo,'T: Filter Constant','','twin.T');
   choice(oooo,[0.1:0.1:0.4,0.5:0.5:2,3:6, 8, 10:5:30],'');
   oooo = mitem(ooo,'K: Filter Factor','','twin.K');
   choice(oooo,[1:0.1:2],'');
   oooo = mitem(ooo,'N: Optimization Steps','','twin.N');
   choice(oooo,[0:10,15:5:30,50,100,inf],'');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Position Optimization',call('@PosOpt'));
end

function oo = Create(o)                % Create a Trace Object         
   m = 4;  n = 5;  r = 100;            % rows (n), cols (n), repeats (r)
   t = 1:m*n*r;                        % crate a time vector
   x = 0.2*randn(size(t));             % create an 'x' data vector
   
      % reshape x to add a position offset
      
   x = reshape(x,m*n,r);               % make a matrix (m*n) x r
   off = 2+randn(m*n,1);               % generate random offsets
   x = x + off*ones(1,r);              % add offsets
   x = x(:)';                          % flatten x again
   
   oo = trace(t,'x',x);                % pack t and x into a trace object
   oo = set(oo,'sizes',[m,n,r]);       % set data sizes
   
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

function oo = Twin(o)                  % Twin Filtering of Data Stream 
%
% TWIN   Twin filtering of data stream x
%
   o = with(o,{'view','style'});       % use style options
   refresh(o,o);                       % come back here for refresh                      

   oo = current(o);                    % get current object
   if ~property(oo,'trace?')           % is current object a trace
      message(o,'Empty basket','Consider to create a sample trace!');
      return                           % cannot continue
   end
   
   t = cook(oo,0,'ensemble','absolute'); 
   x = cook(oo,'x','ensemble','absolute'); 

   xf = Filter(oo,t,x);                % calculate filtered x
   oo = data(oo,'xf',xf(:)');          % pack xf into object's data
   
   cls(o);                             % clear screen
   plot(oo);                           % plot object
end

function o = PosOpt(o)                 % Position Optimization         
%
% TWIN   Twin filtering of data stream x
%
   o = with(o,{'view','style'});       % use style options
   refresh(o,o);                       % come back here for refresh                      
   
   oo = current(o);                    % get current object
   if ~property(oo,'trace?')           % is current object a trace
      message(o,'Empty basket','Consider to create a sample trace!');
      return                           % cannot continue
   end
   
   t = cook(oo,0,'ensemble','absolute'); 
   x = cook(oo,'x','ensemble','absolute'); 

   xf = Filter(oo,t,x);                % calculate filtered x

   xo = x(:,1);                        % first value is not optimized
   for (k=2:length(t))
      xo(:,k) = x(:,k) - xf(:,k-1);    % optimized position x
   end
   
   oo = data(oo,'xf',xf(:)');          % pack xf into object's data
   oo = data(oo,'xo',xo(:)');          % pack xo into object's data

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
   [Iif] = util('iif');                % need some utils

   mode = opt(o,{'twin.mode'},1);      % twin mode
   T = opt(o,{'twin.T'},5);            % filter time constant
   K = opt(o,{'twin.K'},1);            % filter time increase factor
   N = opt(o,{'twin.N'},inf);          % number of optimization steps

   u = [u(:,1),u];  t = [-inf,t];      % extend u,t 
   v = 0*u(:,1); w = v; e = v; y = v;  % initialize v, w, e and y
   
   for (k=2:length(t))
      dt = t(k) - t(k-1);              % time difference
      a = Iif(k-1<=N,exp(-dt/T),1);    % filter eigenvalue
      
      v(:,k) = a*v(:,k-1) + (1-a)*u(:,k);    % intermediate signal v
      e(:,k) = u(:,k) - v(:,k);              % filter error
      w(:,k) = a*w(:,k-1) + (1-a)*e(:,k);    % intermediate signal w
      y(:,k) = v(:,k) + mode*w(:,k);         % filter output

      T = T*K;
   end
   
   y(:,1) = [];                        % delete "y(-1)"
end
