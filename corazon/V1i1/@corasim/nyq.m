function oo = nyq(o,col)               % NyquistPlot                   
%
% NYQ    Nyquist plot of a CORASIM object
%
%           nyq(o)                     % plot Nyquist diagram
%
%        Options:
%
%           oscale           omega scaling factor => fqr(G,om*oscale)
%           color            color propetty (default: 'r')
%           omega.low        omega range, low limit (default: 0.1)
%           omega.low        omega range, high limit (default: 100000)
%           magnitude.low    omega range, low limit (default: -80)
%           magnitude.high   magnitude range, high limit (default: 80)
%           phase.low        phase range, low limit (default: -270)
%           phase.high       phase range, high limit (default: 90)
%
%           magnitude.enable enable/disable magnitude plot (default: 1)
%           phase.enable     enable/disable phase plot (default: 1)
%           omega.points     number of points to be plotted (default: 1000)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, FQR, BODE, STEP
%
   oo = Inherit(o);
   held = ishold;

   if (nargin < 2)
      col = [];
   end
   
   oo = Axes(o);                       % plot axes   
   oo = Nyquist(oo,col);               % actual Nyquist plot
      
   if (~held)
      hold off;
   end
   
   heading(oo);
end

%==========================================================================
% Nyquist Plot
%==========================================================================

function o = Nyquist(o,col)            % Nyquist Plot                  
   points = opt(o,{'omega.points',10000});      
%  oscale = opt(o,{'oscale',1});       % omega scaling factor

   if type(o,{'fqr'})
      om = o.data.omega;
      Gjw = o.data.matrix{1,1};
   else
      [~,om] = fqr(o);                 % get omega vector
      Gjw = fqr(o,om);
   end
   
      % plot magnitude
      
   if opt(o,{'log',1})                 % logarithmic plot?
      phi = angle(Gjw);
      dB = 20*log10(abs(Gjw));
      r = Map(o,dB);
      
      hdl = plot(r.*cos(phi),r.*sin(phi));
   else   
      hdl = plot(real(Gjw),imag(Gjw));
   end
   
      % set attributes
      
   if isempty(col)
      col = opt(o,{'color','g'});
      col = get(o,{'color',col});
   end
   
   [col,lw,typ] = o.color(col);
   
   set(hdl,'Color',col);
   if o.is(lw) && lw >= 1
      set(hdl,'Linewidth',lw);
   elseif ~isempty(opt(o,'linewidth'))
      set(hdl,'Linewidth',opt(o,'linewidth'));
   end

      % do some decorative actions
      
   Limits(o);                          % set limits properly
  
   subplot(o);
   
   function Limits(o)                  % Set Limits Properly           
      xlim = shelf(o,gca,'xlim');
      if isempty(xlim);
         xlim = 1.1*get(gca,'xlim');
         set(gca,'xlim',xlim);
         shelf(o,gca,'xlim',xlim);        % store back to shelf
      end

      ylim = shelf(o,gca,'ylim');
      if isempty(ylim);
         ylim = 1.1*get(gca,'ylim');
         set(gca,'ylim',ylim);
         shelf(o,gca,'ylim',ylim);        % store back to shelf
      end
      
      set(gca,'xtick',[], 'ytick',[]);
   end
end

%==========================================================================
% Helper
%==========================================================================

function o = Axes(o)                   % Plot Bode Axes                
   hold on;
   grid(o);

   shelf(o,gca,'owner','nyq');         % set axis ownership
   set(gca,'Xlim',[-2 2]);
   set(gca,'Ylim',[-2 2]);
   set(gca,'DataAspectRatio',[1 1 1]);

   if opt(o,{'log',1})
      o = PolarGrid(o);
   end
   UnitCircle(o);
   
   subplot(o);                         % init axes done
   
   function o = UnitCircle(o)          % Plot Unit Circle              
      phi = 0:pi/100:2*pi;
      col = o.iif(dark(o),'w-.','k-.');
      plot(cos(phi),sin(phi),col);
   end
   function oo = PolarGrid(o)          % Plot Polar Grid               
      low = opt(o,{'magnitude.low',-300});
      high = opt(o,{'magnitude.high',100});
      delta = opt(o,{'magnitude.delta',20});
      
      col = [1 1 1]*o.iif(dark(o),0.3,0.7);
      
      low = min(low,-20);              % truncate to negative number
      high = max(high,20);             % truncate to positive number
      
      lab = 'grid: ';  sep = '';
      
      phi = 0:pi/100:2*pi;
      for (dB=high:-delta:0)
         r = Map(o,dB);
         %if (r > 0)
            hdl = plot(r*cos(phi),r*sin(phi));
            set(hdl,'Color',col);
         %end
         lab = [lab,sep,sprintf('%g',dB)];  sep = ', ';
         hold on;
      end
      
      k = 0;
      for (dB=-delta:-delta:low)
         r = Map(o,dB);
         hdl = plot(r*cos(phi),r*sin(phi));
         set(hdl,'Color',col);
         
         if (k <= 2)
            lab = [lab,sep,sprintf('%g',dB)];  sep = ', ';  k = k+1;
         end
      end

      rmax = Map(o,high);
      for (phi = pi/8:pi/8:pi)
         hdl = plot(rmax*cos(phi)*[-1 1],rmax*sin(phi)*[1 -1]);
         set(hdl,'Color',col);
      end
      
      hdl = plot([-2.2 2.2],[0 0]);
      set(hdl,'Color',0.5*[1 1 1]);
      hdl = plot([0 0],[-2.2 2.2]);
      set(hdl,'Color',0.5*[1 1 1]);
      
         % mark point "-1"
         
      col = o.iif(dark(o),'wp','kp');
      hdl = plot(-1,0,col);
      set(hdl,'Linewidth',2);
      plot(-1,0,'r.');
      
      lab = [lab,'... [dB]'];
      xlabel(lab);
      
      axis on;
      set(gca,'xtick',[],'ytick',[]);
      
      oo = opt(o,'view.grid',0);       % disable grid
   end
end
function o = Inherit(o)                % inherit options from shell    
   if isempty(figure(o))
      so = pull(o);
      if ~isempty(so)
         o = inherit(o,so);
         o = with(o,'nyq');
         o = opt(o,'oscale',oscale(o));
      end
   end
end
function r = Map(o,dB)                 % Map Magnitude                 
   mlow = opt(o,{'magnitude.low',-300});
   mhigh = opt(o,{'magnitude.high',100});
   mag = [mlow,mhigh];                 % change representation

   if (mag(1) >= 0 || mag(2) <= 0)
      error('bad magnitude boundaries');
   end

      % calculate order 2 mapping polynomial

   x = [mag(1),0.75*mag(1) 0, mag(2)];
   y = [0 0.1 1 2];
   
   map = polyfit(x,y,3);

      % map magnitude

   r = 0*dB;                          % default: init zeros
   idx = find(dB>=mag(1));
   if ~isempty(idx)
      r(idx) = polyval(map,dB(idx));
   end
   
   r = max(r,0);                      % truncate to positive numbers
end
