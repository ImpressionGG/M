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

%==========================================================================
% Scatter Plot
%==========================================================================

function o = Scatter(o)                % Scatter Plot
   cls(o);                             % clear screen
   if container(o)
      list = basket(o);
   else
      list = {o};
   end
   
   for (i=1:length(list))
      oo = list{i};
      
      X = cook(oo,'x','overlay','absolute');
      Y = cook(oo,'y','overlay','absolute');
      sizes = o.either(get(oo,'sizes'),[1 size(X)]);
      
      ooo = set(oo,'sizes',sizes([1 3 2]));
      ooo = data(ooo,'x',X(:)');
      ooo = data(ooo,'y',Y(:)');
      
      ooo = subplot(ooo,'layout',2);
      if (sizes(3) == 1)
         plot(ooo,'Stream');
         hold on;
         continue
      else
         plot(ooo,'Ensemble');
      end
      color = opt(o,'plot.color');
      if length(color) > 0 && any(color(1)=='rgbymck')
         oo.par.color = color;
      end

      subplot(1,2,2);
      ScatterPlot(oo);
      set(gca,'dataaspect',[1 1 1]);
      hold on;                         % hold drawings
   end
   if length(list) > 1
      title('Scatter Plot');
   end
   hold off
end
function ScatterPlot(o,x,y) % black scatter plot (v1a/scatterplot.m)
%
% SCATTERPLOT   Draw a black scatter plot: scatterplot(x,y,par)
%
   rd = @o.rd;                         % short hand
   
   X = cook(o,'x','overlay','absolute');
   Y = cook(o,'y','overlay','absolute');

   x = X(:,end);  y = Y(:,end);
     
      % get tolerances
      
   list = config(o,'x');  [specx,xlim] = category(o,list{3});
   list = config(o,'y');  [specy,ylim] = category(o,list{3});
   
   scatter(x,y,'k');    % black scatter plot
   hold on;

   hasspec = ~isempty(specx) && ~isempty(specy);
   hasspec = hasspec && (diff(specx) ~= 0) && (diff(specy) ~= 0);
   
   if hasspec
       plot(specx([1 2 2 1 1]),specy([1 1 2 2 1]),'b-.');
   end
   if ~isempty(xlim)
      set(gca,'xlim',xlim);
      plot(xlim,[0 0],'k');
   end
   if ~isempty(ylim)
      set(gca,'ylim',ylim);
      plot([0 0],ylim,'k');
   end
   
   sigx = std(x);  sigy = std(y);
   avgx = mean(x); avgy = mean(y);

   phi = 0:pi/100:2*pi;
   plot(avgx + 3*sigx*cos(phi),avgy + 3*sigy*sin(phi),'r');

   if hasspec
       [Cpk,Cp] = capa(o,[x,y]',[specx;specy]);
       xlabel(sprintf('Cpk = %g/%g @ x/y,  Cpk = %g/%g @ x/y',...
           rd(Cpk(1),2),rd(Cpk(2),2),rd(Cp(1),2),rd(Cp(2),2)));
   else
      xlabel('final x error [nm]');  
      ylabel('final y error [nm]');
   end
   
   set(gca,'box','on');
   title(sprintf('x/y error: %g/%g ± %g/%g nm @ 3s',...
         rd(avgx,1),rd(avgy,1),rd(3*sigx,0),rd(3*sigy,0)));
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
