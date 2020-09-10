function o = engine(o)                 % Tick-Tock Engine              
%
% ENGINE   Tick-Tock Engine for Boost & Triac Control. Depending on 
%          option 'engine' one of the following tick-tock engines comes 
%          into action:
%
%          1) Loop Engine
%
%             opt(o,'engine',0);       % set 'engine' option to 0
%             engine(o);               % run engine as a 'Loop Engine'
%
%          2) Event Engine
%
%             opt(o,'engine',1);       % set 'engine' option to 1
%             engine(o);               % run engine as a 'Event Engine'
%
%          LoopEngine implements a tick-tock sequence in terms of a loop,
%          while EventEngine implements the tick-tock sequence by timer 
%          controlled events.
%
%          See also: BOOST, CONTROLLER, CORE
%
   mode = opt(o,{'engine',0});
   switch mode
      case 0                           % loop engine
         LoopEngine(o);
      case 1
         EventEngine(o)
   end
end

%==========================================================================
% Loop Engine
%==========================================================================

function LoopEngine(o)                 % Loop Based Tick-Tock Engine   
   function yes = Stop(o)              % Stop Request                  
      enable = ~(X.engine.stop);       % enabled if no stop request
      X.engine.enable = enable;

      t = X.timing.t;                  % current simulation time
      N = X.timing.N;                  % number of periodes to simulate
      f = X.observer.f;                % mains grid frequency

      X.engine.stop = (t >= N/f);      % store next time stop condition
      yes = ~enable;                   % yes to stop if engine not enabled
   end
   function Setup(o)                   % Setup Tick-Tock Engine        
      e = X.engine;                    % shorthand for engine variables

      core(o,'ClockInit');             % init clock
      core(o,'ClockEnable');           % enable clock for Tock() interrupt

      core(o,'MeasureInit');           % init measurement (Tick phase)
      core(o,'MeasureEnable');         % enable measurement interrupt

      core(o,'TimerInit',@Hello);      % init timer
      core(o,'TimerEnable');           % enable timer for Tick() interrupt

      e.log(o);                        % data logging at t = 0
      e.interval(o);                   % calculate sampling interval
      e.schedule(o);                   % schedule a Tick callback
   end
   function Tick(o)                    % Tick Phase                    
      e = X.engine;                    % shorthand for engine variables
      e.clear(o);                      % clear clock
      e.start(o);                      % start measurement
   end
   function Tock(o)                    % Tock Phase                    
      e = X.engine;                    % shorthand for engine functions

      e.process(o);                    % process transition
      e.observer(o);                   % observer transition
      e.log(o);                        % data logging
      e.control(o);                    % control booster and triac
      e.log(o);                        % data logging
      e.interval(o);                   % calculate next time interval

      if (~Stop(o))                    % Stop side effects X.engine.enable
         e.schedule(o);                % schedule Next Tick Callback
      end 
   end

   global X                            % our global variables
   Setup(o);                           % setup clock, measurement and timer
   while (X.engine.enable)             % tick-tock loop                
      Tick(o);                         % Tick phase of simulation loop
      Tock(o);                         % call timer callback
   end
end

%==========================================================================
% Event Engine
%=================================== =======================================

function EventEngine(o)                % Event based Tick-Tock engine  
   function yes = Stop(o)              % Stop Request                  
      enable = ~(X.engine.stop);       % enabled if no stop request
      X.engine.enable = enable;

      t = X.timing.t;                  % current simulation time
      N = X.timing.N;                  % number of periodes to simulate
      f = X.observer.f;                % mains grid frequency

      X.engine.stop = (t >= N/f);      % store next time stop condition
      yes = ~enable;                   % yes to stop if engine not enabled
   end
   function Setup(o)                   % Setup Tick-Tock Engine        
      e = X.engine;                    % shorthand for engine variables
      Event(o,'Init');                 % init event queue

      core(o,'ClockInit');             % init clock
      core(o,'ClockEnable');           % enable clock for Tock() interrupt

      core(o,'MeasureInit');           % init measurement (Tick phase)
      core(o,'MeasureEnable');         % enable measurement interrupt

      core(o,'TimerInit',@Hello);      % init timer
      core(o,'TimerEnable');           % enable timer for Tick() interrupt

      e.log(o);                        % data logging at t = 0
      e.interval(o);                   % calculate sampling interval
      e.schedule(o);                   % schedule a Tick callback
      Event(o,'Put',@Tick);            % init event queue
   end
   function Tick(o)                    % Tick Phase                    
      e = X.engine;                    % shorthand for engine variables
      e.clear(o);                      % clear clock
      e.start(o);                      % start measurement
      Event(o,'Put',@Tock);            % init event queue
   end
   function Tock(o)                    % Tock Phase                    
      e = X.engine;                    % shorthand for engine functions

      e.process(o);                    % process transition
      e.observer(o);                   % observer transition
      e.log(o);                        % data logging
      e.control(o);                    % control booster and triac
      e.log(o);                        % data logging
      e.interval(o);                   % calculate next time interval

      if (~Stop(o))                    % Stop side effects X.engine.enable
         e.schedule(o);                % schedule Next Tick Callback
         Event(o,'Put',@Tick);         % init event queue
      end
   end

   global X                            % our global variables
   Setup(o);                           % setup clock, measurement and timer
   while (1)                           % tick-tock loop                
      callback = Event(o,'Get');       % get next callback from event queue
      if isempty(callback)
         break                         % break if no more callbacks
      end
      callback(o);                     % execute callback
   end
end

%==========================================================================
% Event Emulation
%==========================================================================

function oo = Event(o,varargin)        % Event Queue Mgr. (Emulation)  
   function o = Init(o)                % Init Event Queue              
      list = {};
   end
   function o = Put(o)                 % Put Callback Into Event Queue 
      callback = arg(o,1);
      list{end+1} = callback;
   end
   function callback = Get(o)          % Get Next Callback From Queue  
      if isempty(list)
         callback = [];                % no more callbacks
      else
         callback = list{1};
         list(1) = [];                 % fetch 1st element of callback list
      end
   end
   function [gamma,o] = Dispatch(o,list)
      function [o,mode] = Initialize(o,list)
         mode = varargin{1};
         o = arg(o,list(2:end));
         if isempty(list)
            list = {};
         end
      end
      
      [o,mode] = Initialize(o,list);
      switch mode
         case 'Init'
            gamma = @Init;
         case 'Put'
            gamma = @Put;
         case 'Get'
            gamma = @Get;
         case 'Put'
            gamma = @Put;
      end
   end

   global list                         % callback list
   [gamma,oo] = Dispatch(o,varargin);  % dispatch local function
   oo = gamma(oo);                     % call local function
end

