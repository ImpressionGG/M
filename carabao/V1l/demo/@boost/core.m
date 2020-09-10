function oo = core(o,varargin)         % Core Functions (HW Close)     
%
% CORE   Core method to access core level functions, which are close to
%        hardware layer
%
%           core(o,'ClockInit')        % init clock
%           core(o,'ClockEnable')      % enable clock
%           core(o,'ClockDisable')     % enable clock
%           core(o,'ClockClear')       % clear clock
%           t = core(o,'ClockTime')    % get current clock time [s]
%           t = core(o,'ClockInc',0.02)% increment clock time [s]
%
%           core(o,'MeasureInit')      % init measurement
%           core(o,'MeasureEnable')    % enable measurement interrupt
%           core(o,'MeasureDisable')   % disable measurement interrupt
%           core(o,'MeasureStart')     % start measurement
%           t = core(o,'MeasureGet')   % get measurement value
%
%           core(o,'TimerInit')        % init timer
%           core(o,'TimerEnable')      % enable timer interrupt
%           core(o,'TimerDisable')     % disable timer interrupt
%           core(o,'TimerStart',t)     % start measurement
%
   function oo = Dispatch(o,args)      % Dispatch Calling Syntax       
      oo = [];                            % empty return value by default
      mode = args{1};
      switch mode
         case 'ClockInit'
            oo = ClockClear(o);
         case 'ClockEnable'
            'ignore';
         case 'ClockDisable'
            'ignore';
         case 'ClockClear'
            oo = ClockClear(o);
         case 'ClockTime'
            oo = ClockTime(o);
         case 'ClockInc'
            oo = ClockInc(o,args{2});

         case 'MeasureInit'
            MeasureInit(o);
         case 'MeasureEnable'
            MeasureEnable(o);
         case 'MeasureDisable'
            MeasureDisable(o);
         case 'MeasureStart'
            MeasureStart(o,args{2});
         case 'MeasureGet'
            oo = MeasureGet(o);

         case 'TimerInit'
            Timer(o,args{2});
         case 'TimerEnable'
            TimerEnable(o);
         case 'TimerDisable'
            TimerDisable(o);
         case 'TimerStart'
            TimerStart(o,args{2});

         otherwise
            error('bad mode!');
      end
   end

   oo = Dispatch(o,varargin);          % dispatch & call local function
end

%==========================================================================
% Clock Functions
%==========================================================================

function t = Clock(o,dt)               % Central Clock Handler         
%
% CLOCK   Central clock handler
%
%            Clock(o)                  % clear clock
%            t = Clock(o)              % get clock time
%            t = Clock(o,dt)           % advance clock time by dt
%
   function Init(o)                    % Init Clock Handler            
      mode = opt(o,'study.timer');     % timer mode
      if isempty(clock)
         clock = 0;
      end
   end
   function ClockClear(o)              % Clear Clock                   
      clock = 0;
   end
   function ClockTime(o)               % Get Clock Time                
      sigt = opt(o,'study.sigt');      % sigma time jitter
      t = clock * (1+sigt*randn);
   end
   function ClockInc(o)                % Increment Clock Time          
      t = clock;
      clock = clock + dt;
   end

   persistent mode clock
   Init(o)

      % dispatch calling syntax
   
   if (nargout == 0 && nargin == 1)    % clear clock
      ClockClear(o)
   elseif (nargout == 1 && nargin == 1)
      ClockTime(o)
   elseif (nargin == 2)
      ClockInc(o)
   else
      error('bad syntax!');
   end
end
function o = ClockClear(o)             % Clear Clock                   
   Clock(o);                           % clear clock
   o = [];                             % return empty
end
function t = ClockTime(o)              % Clear Clock                   
   t = Clock(o);                       % get clock time
end
function t = ClockInc(o,dt)            % Increment Clock Time          
   t = Clock(o,dt);                    % increment clock time by dt
end

%==========================================================================
% Measurement Functions
%==========================================================================

function value = Measure(o,arg)        % Central Measurement Handler   
%
% MEASURE   Central measurement handler
%
%            Measure(o)                % init measurement
%            Measure(o,true)           % enable measurement
%            Measure(o,false)          % disable measurement
%            Measure(o,t)            % start measurement
%            value = MeasureGet(o,t)   % get measurement value
%
   function Init(o)
      mode = opt(o,'study.timer');     % timer mode
      if isempty(delay)
         delay = 0;
      end
      if isempty(enable)
         enable = false;
      end
      if isempty(measurement)
         measurement = 0;
      end
      if isempty(time)
         time = 0;
      end
   end
   function Perform(o,t)            % perform pseudo measurement
      f = opt(o,'study.f');         % frequency
      om = 2*pi*f;                  % circular frequency
      sigv = opt(o,'study.sigv');   % sigma measurement
      U = opt(o,'study.U');         % RMS voltage
      u = U*sqrt(2)*sin(om*t);      % current grid voltage
      y = u/100;                    % scaling factor for measurement
      measurement = y + sigv*randn; % add measurement noise
      time = t;
   end

   persistent mode delay enable measurement time
   Init(o);
   
      % dispatch calling syntax
      
   if (nargout == 0 && nargin == 1)    % init measurement: init delay
      delay = opt(o,{'study.delay',0.0003});
      enable = false;                  % initially measurement disabled
   elseif (nargout == 0 && nargin == 2)
      if isa(arg,'double')             % measurement start
         Clock(o,delay);
         t = arg;                      % current time
         Perform(o,t+delay);
      elseif isa(arg,'logical')        % enable/disable measurement
         enable = arg;                 % enable/disable
      else
         error('bad arg!');   
      end
   elseif (nargout == 1 && nargin == 1)% get measurement value
      if (enable)
         value = measurement;
      else
         value = 0;                    % measurement disabled
      end
   else
      error('bad syntax!');
   end
end
function MeasureInit(o)                % Init Measurement              
   Measure(o);                         % init measurement
end
function MeasureEnable(o)              % Enable Measurement Interrupt  
   Measure(o,true);                    % enable
end
function MeasureDisable(o)             % Disable Measurement Interrupt 
   Measure(o,false);                   % disable
end
function MeasureStart(o,t)             % Start Measurement             
   Measure(o,t);                     
end
function value = MeasureGet(o,t)       % Get Measurement Value         
   value = Measure(o);                 % get measurement Value
end

%==========================================================================
% Timer Functions
%==========================================================================

function value = Timer(o,arg)          % Central Timer Handler         
%
% TIMER   Central timer handler
%
%            Timer(o,@Callback)        % init timer
%            Timer(o,true)             % enable timer
%            Timer(o,false)            % disable timer
%            Timer(o,t)                % start timer
%
   function TimerInit(o)               % Init Timer                    
      clock = 0;                       % timer init
      callback = arg;                  % store callback
      enable = false;
   end
   function TimerEnable(o)             % Enable Timer                  
      enable = true;                   % store enable status
   end
   function TimerDisable(o)            % Disable Timer                 
      enable = false;                  % store enable status
   end
   function TimerStart(o)              % Start Timer                   
      function Callback(a,b)
         %callback;
      end
      if (enable)
         switch mode
            case 0                        % pure simulation
               clock = arg;
            case 1                        % hardware timer controlled
               sec = 1/(60^2*24);         % constat for conversion
               Tr = arg;                  % remaining time
               tim = timer;               % timer object
               tim.TimerFcn = @Callback;  % setup callback
               startat(tim,now+2*sec);    % start for single shoot
         end
      end
   end

   function Init(o)                    % Init Persistent variables     
      mode = opt(o,'study.timer');     % timer mode
      if isempty(clock)
         clock = 0;
      end
      if isempty(enable)
         enable = false;
      end
   end
   function gamma = Dispatch(o,nou,nin)% Dispatch Calling Syntax       
      Init(o);                         % init persistent variables
      obj = o;                         % store object for callback arg
      if (nou == 0 && nin == 2)        % enable/disable/start timer
         if isa(arg,'function_handle') % timer start
            gamma = @TimerInit;        % init timer
         elseif isa(arg,'double')      % timer start
            gamma = @TimerStart;
         elseif isa(arg,'logical')     % enable/disable timer
            if (arg)                   % enable timer ?
               gamma = @TimerEnable;
            else                       % disable timer
               gamma = @TimerDisable;
            end
         else
            error('bad arg type!');
         end
      else
         error('bad syntax!');
      end
   end

   persistent mode clock enable callback obj
   gamma = Dispatch(o,nargout,nargin);
   gamma(o);                           % call dispatched function
end
function TimerInit(o)                  % Init Timer                    
   Timer(o);                           % init timer
end
function TimerEnable(o)                % Enable Timer Interrupt        
   Timer(o,true);                      % enable
end
function TimerDisable(o)               % Disable Timer Interrupt       
   Timer(o,false);                     % disable
end
function TimerStart(o,t)               % Start Timer                   
   Timer(o,t);                     
end

