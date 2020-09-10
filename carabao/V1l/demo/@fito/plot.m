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
   [gamma,oo] = manage(o,varargin,@Default,@StreamX,@StreamY,@Scatter);
   oo = gamma(oo);
end

function oo = Default(o)               % Default Plot Entry Point
   co = cast(o,'caramel');             % cast to CARAMEL
   oo = plot(co,'Default');            % delegate to caramel/plot
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
   [idx,~] = config(oo,'x');         % is 'x' symbol supported?
   [idy,~] = config(oo,'y');         % is 'y' symbol supported?
   if ~isempty(idx) && ~isempty(idy) % if both 'x' & 'y' symbol supported
      co = cast(o,'carabao');
      plot(co,mode);
   else
      menu(oo,'About');
   end
end
