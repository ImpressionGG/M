function oo = bode(o,col)
%
% BODE   Bode plot of a CORASIM object
%
%           bode(o)                    % plot bode diagram
%
%        Options:
%
%           color            color propetty (default: 'r')
%           omega.low        omega range, low limit (default: 0.1)
%           omega.low        omega range, high limit (default: 100000)
%           magnitude.low    omega range, low limit (default: -80)
%           magnitude.high   magnitude range, high limit (default: 80)
%           phase.low        phase range, low limit (default: -270)
%           phase.high       phase range, high limit (default: 90)
%
   held = ishold;

   Axes(o);                            % plot axes
   Magnitude(o);
   Phase(o);
   
   if (~held)
      hold off;
   end
   
   heading(o);
end


%==========================================================================
% Magnitude & Phase Plot
%==========================================================================

function o = Magnitude(o)              % Plot Magnitude                
   oo = with(o,'scale');
   points = opt(oo,{'omega.points',1000});
   
   xlim = get(gca,'Xlim');
   ylim = get(gca,'Ylim');
   zlim = get(gca,'Zlim');
   
   olim = log10(xlim);
   
   om = logspace(log10(xlim(1)), log10(xlim(2)), points);
   Gjw = fqr(o,om);
   dB = 20*log10(abs(Gjw));
   
      % plot magnitude
      
   hdl = semilogx(om,dB);
   col = opt(o,{'color','r1'});
   [col,lw,typ] = o.color(col);
   
   set(hdl,'Color',col);
   if o.is(lw)
      set(hdl,'Linewidth',lw);
   end
end
function o = Phase(o)                  % Plot Phase                    
   oo = with(o,'scale');
   points = opt(oo,{'omega.points',1000});
   
   xlim = get(gca,'Xlim');
   ylim = get(gca,'Ylim');
   zlim = get(gca,'Zlim');
   
   olim = log10(xlim);
   
   om = logspace(log10(xlim(1)), log10(xlim(2)), points);
   Gjw = fqr(o,om);
   phase = atan2(imag(Gjw),real(Gjw)) * 180/pi;
   
      % prepare phase
      
   p = ylim(1) + diff(ylim)/diff(zlim) * (phase-zlim(1));

   idx = find(p<zlim(1));
   while o.is(idx)
      p(idx) = p(idx) + 360;
      idx = find(p<zlim(1));
   end
   
   idx = find(p>zlim(2));
   while o.is(idx)
      p(idx) = p(idx) - 360;
      idx = find(p>zlim(2));
   end
   
      % plot phase
      
   hdl = semilogx(om,p,'r--');
   col = opt(o,{'color','r1--'});
   [col,lw,typ] = o.color(col);
   
   set(hdl,'Color',col);
   if o.is(lw)
      set(hdl,'Linewidth',lw);
   end
end

%==========================================================================
% Helper
%==========================================================================

function [omega,magni,phase] = Lim(o)  % Get Limits                    

      % omega limits
      
   omega = shelf(o,gca,'omega');
   omega = o.either(omega,[1e-1,1e5]);
   
   omega(1) = opt(o,{'omega.low',omega(1)});
   omega(2) = opt(o,{'omega.high',omega(2)});

      % magnitude limits
      
   magni = shelf(o,gca,'magnitude');
   magni = o.either(magni,[-80,80]);

   magni(1) = opt(o,{'omega.low',magni(1)});
   magni(2) = opt(o,{'omega.high',magni(2)});

      % phase limits
      
   phase = shelf(o,gca,'phase');
   phase = o.either(phase,[-270,90]);

   phase(1) = opt(o,{'phase.low',phase(1)});
   phase(2) = opt(o,{'phase.high',phase(2)});
end
function o = Axes(o)
   kind = shelf(o,gca,'owner');
   if ~isequal(kind,'bode')
      InitAxes(o);
   else
      hax = gca;
      
      [xlim,ylim,zlim] = Lim(o);
      set(hax,'xlim',xlim);
      set(hax,'ylim',ylim);
      set(hax,'zlim',zlim);
   end

   PhaseTicks(o);
   subplot(o);                         % init axes done
   
   function InitAxes(o)                % Init Axes                     
      if isempty(figure(o))
         o = inherit(o,sho);
      end
      
      [omega,magni,phase] = Lim(o);
      
      col = o.iif(dark(o),'k.','w.');
      semilogx(omega,magni,col);
      hold on;
      grid(o);

      shelf(o,gca,'kind','owner');     % set axis ownership
   
      hax = gca;
      set(hax,'xlim',omega);
      set(hax,'ylim',magni);
      set(hax,'zlim',phase);
      set(hax,'ytick',magni(1):20:magni(2)); 
      set(hax,'Xscale','log');
      
      %set(hax,'Color',[0.3 0.3 0]);
      %set(hax,'userdata','Bode Axes');
      %set(hax,'ButtonDownFcn','timeaxcb(1)');
      %set(hax,'nextplot','replace');
%hold on
%      grid on;
%     set(gca,'GridColor','w');
%     set(gca,'GridAlpha',0.3);
%     set(gca,'MinorGridColor','w');
%     set(gca,'MinorGridAlpha',0.3);
      %tffmencb(0);   % setup menu
   end
   function PhaseTicks(o)              % Refresh Phase Ticks           
      hax = gca;
      
      xlim = get(hax,'Xlim');
      ylim = get(hax,'Ylim');
      zlim = get(hax,'Zlim');
      
         % remove current phase ticks

      kids = get(hax,'children');
      for (i=1:length(kids))
         kid = kids(i);
         if isequal(shelf(o,kid,'owner'),'bode')
            delete(kid);
         end
      end

         % update phase ticks

      ytick = get(hax,'ytick');

      dy = ylim(2)-ylim(1);  y0 = ylim(1);
      dz = zlim(2)-zlim(1);  z0 = zlim(1);

      for (i=1:length(ytick))
         y = ytick(i);
         z = z0 + (y-y0) * dz/dy;
         label = sprintf('   %g',z);
         hdl = text(xlim(2),y,label);
         
         o.color(hdl,o.iif(dark(o),'w','k'));
         shelf(o,hdl,'owner','bode');
      end
   end
end
