function oo = step(o,sub)              % Step Respone                  
%
% STEP   Calculate or plot step response for linear transfer system
%
%           step(o)                    % plot step response
%           step(o,[2 2 1 2])          % plot step response
%
%           oo = step(o)               % calculate step response
%
%        Example 1:
%
%           
%
%        Options:
%
%           color:           line color (default: 'r')
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
      if (nargin == 1)
         Plot(o);
      else
         subplot(o,sub);
         Plot(o);
      end
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

   ooo = step(oo);
   
   if (nargout >= 1)
      bag = var(ooo);
      tags = fields(bag);
      for (i=1:length(tags))
         tag = tags{i};
         oo = var(oo,tag,bag.(tag));
      end
   end
end

%==========================================================================
% Plot Step Response
%==========================================================================

function oo = Plot(o)                  % Plot Step Response            
   if ~isequal(shelf(o,gca,'kind'),'step')
      %cls(o);
   end
         
   [t,y] = data(o,'t,y');
   col = opt(o,{'color','r'});
   xscale = opt(o,{'xscale',1});
   yscale = opt(o,{'yscale',1});

   plot(corazon(o),t*xscale,y*yscale,col);
   name = get(o,'name');
   if ~isempty(name)
      title([name,':  Step Response']);
   else
      title('Step Response');
   end
   xunit = opt(o,{'xunit','s'});
   xlabel(['time [',xunit,']']);

   yunit = opt(o,{'yunit','1'});
   ylabel(['y [',yunit,']']);
   
   shelf(o,gca,'kind','step');         % set gca kind: 'step'                
   hold on;                            % hold for next plot
   subplot(o);                         % subplot complete
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