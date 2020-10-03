function oo = bode(o,col)              % Corasim Bode Plot             
%
% BODE   Bode plot of a CORASIM object
%
%           bode(o)                    % plot bode diagram
%
%        Options:
%
%           fscale           frequency scaling factor => fqr(G,om*fscale)
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
%        See also: CORINTH, FQR, STEP
%
   oo = Inherit(o);
   oo = Bode(oo);
end

%==========================================================================
% Bode Plot
%==========================================================================

function o = Bode(o)                   % Bode Plot                     
   %o = with(o,'bode');                % unwrap Bode options
   held = ishold;

   o = Auto(o);                        % auto axis limits
   o = Axes(o);                        % plot axes
   if opt(o,{'magnitude.enable',true})
      Magnitude(o);
      
      if isempty(opt(o,'magnitude.low')) && isempty(opt(o,'magnitude.high'))
         set(gca,'Ylim',[-inf,inf]);
      end
   end
   if opt(o,{'phase.enable',true})
      Phase(o);
   end
   
   if (~held)
      hold off;
   end
   
   heading(o);
end

%==========================================================================
% Magnitude & Phase Plot
%==========================================================================

function o = Magnitude(o)              % Plot Magnitude                
   points = opt(o,{'omega.points',1000});   
   fscale = opt(o,{'fscale',1});       % frequency scaling factor
   
   xlim = get(gca,'Xlim');
   ylim = get(gca,'Ylim');
   zlim = get(gca,'Zlim');
   
   olim = log10(xlim);
   
   om = logspace(log10(xlim(1)), log10(xlim(2)), points);
   Gjw = fqr(o,om*fscale);
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
   points = opt(o,{'omega.points',1000});
   fscale = opt(o,{'fscale',1});       % frequency scaling factor
   
   xlim = get(gca,'Xlim');
   ylim = get(gca,'Ylim');
   zlim = get(gca,'Zlim');
   
   olim = log10(xlim);
   
   om = logspace(log10(xlim(1)), log10(xlim(2)), points);
   Gjw = fqr(o,om*fscale);
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
   col = opt(o,{'color','r--'});
   [col,lw,typ] = o.color(col);
   lw = [];
   
   set(hdl,'Color',col);
   if o.is(lw)
      set(hdl,'Linewidth',lw);
   end
end

%==========================================================================
% Helper
%==========================================================================

function o = Auto(o)                   % Automatic Axes Limits         
   if isempty(opt(o,'magnitude.low')) && isempty(opt(o,'magnitude.high')) 
      fscale = opt(o,{'fscale',1});
      
      [Gjw,om] = fqr(o);
      Gjw = fqr(o,om*fscale);
      
      high = Ceil(20*log10(max(abs(Gjw))));
      low = Floor(20*log10(min(abs(Gjw))));
      
      if isinf(low) || isinf(high)
         low = -80;  high = 80;
      end
      
      o = opt(o,'magnitude.low',low);
      o = opt(o,'magnitude.high',high);
   end
   
   function y = Ceil(x)
      offset = 10000;               % a big number
      y = ceil((x+offset)/20)*20 - offset;
   end
   function y = Floor(x)
      offset = 10000;               % a big number
      y = floor((x+offset)/20)*20 - offset;
   end
end
function [omega,magni,phase] = Lim(o)  % Get Limits                    

      % omega limits
      
   omega = shelf(o,gca,'omega');
   omega = o.either(omega,[1e-1,1e5]);
   
   omega(1) = opt(o,{'omega.low',omega(1)});
   omega(2) = opt(o,{'omega.high',omega(2)});

      % magnitude limits
      
   magni = shelf(o,gca,'magnitude');
   magni = o.either(magni,[-80,80]);

   magni(1) = opt(o,{'magnitude.low',magni(1)});
   magni(2) = opt(o,{'magnitude.high',magni(2)});

      % phase limits
      
   phase = shelf(o,gca,'phase');
   phase = o.either(phase,[-270,90]);

   phase(1) = opt(o,{'phase.low',phase(1)});
   phase(2) = opt(o,{'phase.high',phase(2)});
end
function o = Axes(o)                   % Plot Bode Axes                
   kind = shelf(o,gca,'owner');
   if ~isequal(kind,'bode')
      o = InitAxes(o);
   else
      hax = gca;
      
      [xlim,ylim,zlim] = Lim(o);
      set(hax,'xlim',xlim);
      set(hax,'ylim',ylim);
      set(hax,'zlim',zlim);
   end

   if opt(o,{'phase.enable',true})
      PhaseTicks(o);
   end
   
   subplot(o);                         % init axes done
   
   function o = InitAxes(o)            % Init Axes                           
      [omega,magni,phase] = Lim(o);
      
      col = o.iif(dark(o),'k.','w.');
      semilogx(omega,magni,col);
      hold on;
      grid(o);

      shelf(o,gca,'kind','owner');     % set axis ownership
   
      if diff(magni) < 150
         dy = 20;
      elseif diff(magni) < 320
         dy = 40;
      elseif diff(magni) < 400
         dy = 60;
      else
         dy = 100;
      end
      
      hax = gca;
      set(hax,'xlim',omega);
      set(hax,'ylim',magni);
      set(hax,'zlim',phase);
      set(hax,'ytick',magni(1):dy:magni(2)); 
      set(hax,'Xscale','log');
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
         label = sprintf('   %g',o.rd(z,1));
         hdl = text(xlim(2),y,label);
         
         o.color(hdl,o.iif(dark(o),'w','k'));
         shelf(o,hdl,'owner','bode');
      end
   end
end
function o = Inherit(o)                % inherit options from shell    
   if isempty(figure(o))
      so = pull(o);
      if ~isempty(so)
         o = inherit(o,so);
         o = with(o,'bode');
      end
   end
end
