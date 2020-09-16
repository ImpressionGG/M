function oo = step(o)                  % Step Respone                  
%
% STEP   Calculate or plot step response for linear transfer system
%
%           step(o)                    % plot step response
%           oo = step(o)               % calculate step response
%
%        Example 1:
%
%           
%
%        Options:
%
%           subplot:         subplot identifier (default: [1 1 1])
%           tmax:            max simulation time
%           dt:              simulation time increment
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, PLOT, RAMP
%  
   if (nargout == 0)
      o = Step(o);
      Plot(o);
   else
      oo = Step(o);
   end
end

%==========================================================================
% Calculate Step Response
%==========================================================================

function oo = Step(o)                  % Calculate Step Response       
   [num,den] = peek(o);
   oo = Timing(o);
   
   oo = corasim(oo);                   % cast to corasim object
   oo = system(oo,{num,den});          % set system parameters

   oo = step(oo);
end

%==========================================================================
% Plot Step Response
%==========================================================================

function oo = Plot(o)                  % Plot Step Response            
   plot(o);
   dark(o);
end

%==========================================================================
% Helper
%==========================================================================

function oo = Timing(o)
%
% TIMING   Set timing options
%
%             oo = Timing(o)
%             [tmax,dt] = opt(o,'tmax,dt')
%
   poles = roots(den(o));
   zeros = roots(num(o));
   
   [mag,idx] = sort(abs(poles));
   T = 1/min(mag);
   tmax = 5*T;
   dt = tmax / 1000;
   
   oo = opt(o,{'tmax'},tmax);
   oo = opt(oo,{'dt'},dt);
end