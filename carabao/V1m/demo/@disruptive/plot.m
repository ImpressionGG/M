function oo = plot(o,varargin)         % DISRUPTIVE Plot Method
%
% PLOT   Cappuccino plot method
%
%           plot(o,'StreamX')          % stream plot X
%           plot(o,'StreamY')          % stream plot Y
%           plot(o,'Scatter')          % scatter plot
%           plot(o,'Show')             % show object
%           plot(o,'Animation')        % animation of object
%
   [gamma,oo] = manage(o,varargin,@Default,@Setup,@Plot,@Scatter);
   oo = gamma(oo);
end

function oo = Setup(o)                 % Setup Plot Menu               
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Basic');
   oooo = menu(ooo,'Plot');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Stream Plot',{@Plot,'Stream'});
   ooo = mitem(oo,'X/Y Plot',{@Plot,'Scatter'});
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
   oo = current(o);
   [idx,~] = config(oo,'x');           % is 'x' symbol supported?
   [idy,~] = config(oo,'y');           % is 'y' symbol supported?
   if isempty(idx) || isempty(idy)     % if 'x' or 'y' symbol not supported
      menu(oo,'About');
      return
   end
   
      % scatter plot
      
   [x,y] = data(oo,'x','y');
   color = get(oo,'color');
   plot(x,y,[color,'o']);
   set(gca,'dataaspect',[1 1 1]);
   
   R = 200;  
   set(gca,'xlim',1.25*[-R R],'ylim',1.25*[-R R]);
   phi = 0:pi/100:2*pi;

   hold on;
   plot(R*cos(phi),R*sin(phi),'k-.');
   
   text = get(oo,{'title',''});
   title(text);
   
   [Cpkx,Cpx,sigx,avgx] = capa(o,x,[-200 200]);
   [Cpky,Cpy,sigy,avgy] = capa(o,y,[-200 200]);
   
   str = sprintf('sigma: %g/%g [nm], avg: %g/%g [nm], Cp: %g/%g, Cpk: %g/%g',...
                 o.rd(sigx,0),o.rd(sigy,0),o.rd(avgx,0),o.rd(avgy,0),...
                 o.rd(Cpx,2),o.rd(Cpy,2),o.rd(Cpkx,2),o.rd(Cpky,2));
   xlabel(str);
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function oo = DoPlot(o,mode)           % actually do plotting
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
