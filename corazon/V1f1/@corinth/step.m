function oo = step(o)
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
   oo = o;
end

%==========================================================================
% Plot Step Response
%==========================================================================

function oo = Plot(o)                  % Plot Step Response            
   oo = o;
end
