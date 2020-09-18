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
%           xscale:          x-scaling factor (default: 1)
%           yscale:          y-scaling factor (default: 1)
%           xunit:           x-axis unit (default: 's')
%           yunit:           y-axis unit (default: 's')
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
      
   [t,y] = var(o,'t,y');

      % reduce plot vectors if plot delta is larger than simulation
      % delta
      
   [t,y] = Subset(o,t,y);
         
   col = opt(o,{'color','r'});

   plot(corazon(o),t,y,col);
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

function varargout = Subset(o,varargin)
%
% SUBSET  returns index of subset vectors to be plotted
%
%            idx = Subset(o,t)
%            [t,y] = Subset(o,t,y);
%
   if ~((nargin==2 && nargout <= 1) || (nargin == 1+nargout))
      error('bad number of input/output args');
   end
   
   idx = [];                           % default: empty
   t = varargin{1};
   
   dt = opt(o,'simu.dt');
   plot = opt(o,'simu.plot');
      
   if ~isempty(dt) && ~isempty(plot) && (dt < max(t)/plot)
      n = length(t);
      delta = floor(n/plot);
      if (~isempty(delta) && delta >= 1)
         idx = 1:delta:n;
         if (length(idx) > 0 && idx(end) ~= n)
            idx(end+1) = n;
         end
      end
   end
   
      % set output args
      
   if (nargout <= 1)
      varargout{1} = idx;              % return idx
   elseif isempty(idx)
      for (i=1:length(varargin))
         varargout{i} = varargin{i};
      end
   else
      for (i=1:length(varargin))
         d = varargin{i};              % data stream
         varargout{i} = d(idx);        % replace by subset
      end
   end
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