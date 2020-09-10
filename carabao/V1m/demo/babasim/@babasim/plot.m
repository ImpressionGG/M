function oo = plot(o,varargin)         % Capuchino Plot Method
%
% PLOT   Cappuccino plot method
%
%           plot(o,'StreamX')          % stream plot X
%           plot(o,'StreamY')          % stream plot Y
%           plot(o,'Scatter')          % scatter plot
%           plot(o,'Show')             % show object
%           plot(o,'Animation')        % animation of object
%
   [gamma,oo] = manage(o,varargin,@StreamX,@StreamY,@Scatter);
   oo = gamma(oo);
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function oo = StreamX(o)               % Stream Plot X                 
   oo = Plot(o,'StreamX');
end
function oo = StreamY(o)               % Stream Plot Y                 
   oo = Plot(o,'StreamY');
end
function o = Scatter(o)                % Scatter Plot
   oo = Plot(o,'Scatter');
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function oo = Plot(o,mode)
   oo = current(o);
   switch oo.type
      case {'pln','smp'}
         co = cast(o,'carabao');
         plot(co,mode);
      otherwise
         menu(oo,'About');
   end
end
