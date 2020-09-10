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
   [gamma,oo] = manage(o,varargin,@Default,@Setup,@Plot,...
                                  @StreamX,@StreamY,@Scatter);
   oo = gamma(oo);
end

function oo = Setup(o)                 % Setup Plot Menu
   setting(o,{'study.zoom'},false);

   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Basic');
   oooo = menu(ooo,'Plot');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stream Plot',{@Plot,'Stream'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Zoom',{},'study.zoom');
   check(ooo,{});
end
function oo = Plot(o)                  % Plot Callback                 
   args = arg(o,0);                    % get arg list
   oo = arg(o,[{'Plot'},args]);        % add 'Plot' header to arg list
   oo = cast(oo,'caramel');            % cast to caramel object
   oo = plot(oo);                      % call plot(oo,'Plot')
end
function oo = Default(o)               % Default Plot Entry Point
   co = cast(o,'caramel');             % cast to CARAMEL
   oo = plot(co,'Default');            % delegate to caramel/plot
end

%==========================================================================
% Local Plot Functions
%==========================================================================

function oo = StreamX(o)               % Stream Plot X                 
   oo = DoPlot(o,'StreamX');
end
function oo = StreamY(o)               % Stream Plot Y                 
   oo = DoPlot(o,'StreamY');
end
function o = Scatter(o)                % Scatter Plot
   oo = DoPlot(o,'Scatter');
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function oo = DoPlot(o,mode)
   oo = current(o);
   [idx,~] = config(oo,'x');           % is 'x' symbol supported?
   [idy,~] = config(oo,'y');           % is 'y' symbol supported?
   if ~isempty(idx) && ~isempty(idy)   % if both 'x' & 'y' symbol supported
      co = cast(o,'carabao');
      plot(co,mode);
   else
      menu(oo,'About');
   end
end
