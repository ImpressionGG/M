function oo = bode(o,col)              % Corasim Bode Plot             
%
% BODE   Bode plot of a CORASIM object
%
%           bode(o)                    % plot bode diagram
%           bode(o,'g')                % plot bode diagram in green color
%
%        Options:
%
%           oscale           omega scaling factor
%           frequency        plot frequency (f) instead of circular frequ.
%                            (default 0)
%           color            color propetty (default: 'r')
%           omega.low        omega range, low limit (default: 0.1)
%           omega.low        omega range, high limit (default: 100000)
%
%           magnitude.low    magnitude range, low limit (default: -80)
%           magnitude.high   magnitude range, high limit (default: 80)
%
%           phase.low        phase range, low limit (default: -270)
%           phase.high       phase range, high limit (default: 90)
%
%           magnitude.enable enable/disable magnitude plot (default: 1)
%           phase.enable     enable/disable phase plot (default: 1)
%           omega.points     number of points to be plotted (default: 1000)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, FQR, MAGNI, PHASE, NYQ, STEP
%
   oo = Inherit(o);
   if (nargin >= 2 && ischar(col))
      oo = opt(oo,'color',col);
   end

   oo = Bode(oo);
   dark(oo);                           % handle dark mode
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
         shelf(o,gca,'ylim',[-inf,inf]);
      end
   end
   if opt(o,{'phase.enable',true})
      Phase(o);
   end
      
   if (~held)
      hold off;
   end
   
         % set axis ownership
      
   shelf(o,gca,'owner','bode');        % set axis ownership
end

%==========================================================================
% Magnitude & Phase Plot
%==========================================================================

function o = Magnitude(o)              % Plot Magnitude                
   points = opt(o,{'omega.points',1000});   
%  oscale = opt(o,{'oscale',1});       % frequency scaling factor
   
   if opt(o,{'frequency',0})
      xlim = get(gca,'Xlim')*2*pi;
   else
      xlim = get(gca,'Xlim');
   end
   ylim = get(gca,'Ylim');
   zlim = get(gca,'Zlim');
   
   olim = log10(xlim);
   
   om = logspace(log10(xlim(1)), log10(xlim(2)), points);
%  Gjw = fqr(o,om*oscale);
   Gjw = fqr(o,om);
   dB = 20*log10(abs(Gjw));
   
      % plot magnitude
      
   col = Color(o);                     % retrieve object color   
   col = opt(o,{'color',col});
   [col,lw,typ] = o.color(col);
   
   if opt(o,{'frequency',0})
      hdl = semilogx(om/2/pi,dB,['r',typ]);
   else
      hdl = semilogx(om,dB,['r',typ]);
   end
   
   set(hdl,'Color',col);
   if o.is(lw)
      set(hdl,'Linewidth',lw);
   end
   
   Instabilities(o)                    % draw instabilities

   function col = Color(o)             % retrieve objectcolor
      col = get(o,'color','r1');
      digit = false;                   % init: contains no digit

      for (ii=1:length(col))
         c = col(ii);                  % i-th character
         if ('0' <= c && c <= '9')     % if isdigit(c)
            digit = true;              % mind: we hav already a digit
         end
      end
      if ~digit
         col(end+1) = '1';             % set line width 1        
      end
   end
   function Instabilities(o)
      if type(o,{'fqr'})
         return                        % ignore for frequency response type
      end
      
      oscale = opt(o,{'oscale',1});    % frequency scaling factor
      [z,p,k] = zpk(o);                % get pole zeros
      
      idx = find(real(p)>= 0);
      for (i=1:length(idx))
         k = idx(i);
         sk = p(k);
         
         if (imag(sk) ~= 0)            % complex pole
            om = sqrt(abs(sk))/oscale;
%           Gjw = fqr(o,om*oscale);
            Gjw = fqr(o,om);
            dB = 20*log10(abs(Gjw));
   
               % plot magnitude
      
            if opt(o,{'frequency',0})
               hdl = semilogx(om/2/pi,dB,'rp');
               hdl = semilogx(om/2/pi,dB,'w.');
            else
               hdl = semilogx(om,dB,'rp');
               hdl = semilogx(om,dB,'w.');
            end
         end
      end
      
   end
end
function o = Phase(o)                  % Plot Phase                    
   points = opt(o,{'omega.points',1000});
%  oscale = opt(o,{'oscale',1});       % frequency scaling factor
   
   xlim = get(gca,'Xlim');
   ylim = get(gca,'Ylim');
   zlim = get(gca,'Zlim');
   
   olim = log10(xlim);
   
   om = logspace(log10(xlim(1)), log10(xlim(2)), points);
%  Gjw = fqr(o,om*oscale);
   Gjw = fqr(o,om);
   phase = atan2(imag(Gjw),real(Gjw)) * 180/pi;
   
      % map positive phases into negative
      
   idx = find(phase >= 0);
   if ~isempty(idx)
      phase(idx) = phase(idx)-360;
   end
   
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
      
%  hdl = semilogx(om,p,'r--');
   if opt(o,{'frequency',0})
      hdl = semilogx(om/2/pi,p,'r');
   else
      hdl = semilogx(om,p,'r');
   end
   col = opt(o,{'color','r--'});
   [col,lw,typ] = o.color(col);
   %lw = [];
   
   set(hdl,'Color',col);
   if o.is(lw)
      set(hdl,'Linewidth',lw);
   end
end

%==========================================================================
% Helper
%==========================================================================

function o = Auto(o)                   % Automatic Axes Limits         
%
% AUTO   Autoscaling of magnitude plot if no magnitude limits are provided.
%        No action if either option magnitude.low or magnitude.high is
%        provided
%
   if isempty(opt(o,'magnitude.low')) && isempty(opt(o,'magnitude.high')) 
      [~,om] = fqr(o);
      Gjw = fqr(o,om);
      
      high = Ceil(20*log10(max(abs(Gjw))));
      low = Floor(20*log10(min(abs(Gjw))));
      
      ylim = get(gca,'ylim');
      if all(ylim==[0 1])              % do we have default y-limits?
          ylim = [];                   % set ylim quasi undefined
      end
      
      if ~isempty(ylim)
         low = min(low,ylim(1)); 
         high = max(high,ylim(2)); 
      end
      
      if (abs(high-low) < 1)
         high = o.rd(low,-1)+20;
         low  = o.rd(low,-1)-20;
      end
      
      if isinf(low)
         low = -300;
      end
      if isinf(high)
         high = 120;
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
      
      if opt(o,{'frequency',0})
         xlim = xlim/2/pi;
      end
      
      set(hax,'xlim',xlim);
      set(hax,'ylim',ylim);
      set(hax,'zlim',zlim);
   end
   
      % phase ticks to plot ?

   if opt(o,{'phase.enable',true})
      PhaseTicks(o);
   end
   
   subplot(o);                         % init axes done
   
   function o = InitAxes(o)            % Init Axes                           
      [omega,magni,phase] = Lim(o);
      
      col = o.iif(dark(o),'k.','w.');
      if opt(o,{'frequency',0})
         semilogx(omega/2/pi,magni,col);
      else
         semilogx(omega,magni,col);
      end
      hold on;
      axis on;
      grid(o);

%     shelf(o,gca,'owner','bode');     % set axis ownership
   
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
      if opt(o,{'frequency',0})
         set(hax,'xlim',omega/2/pi);
      else
         set(hax,'xlim',omega);
      end
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

      if (opt(o,{'magnitude.enable',1}) && opt(o,{'phase.enable',1})) 
         for (i=1:length(ytick))
            y = ytick(i);
            z = z0 + (y-y0) * dz/dy;
            label = sprintf('   %g',o.rd(z,1));
            hdl = text(xlim(2),y,label);

            o.color(hdl,o.iif(dark(o),'w','k'));
            shelf(o,hdl,'owner','bode');
         end
      elseif (~opt(o,{'magnitude.enable',1}) && opt(o,{'phase.enable',1}))
         set(gca,'ylim',zlim);
         ytick = [];
         for (k=-4500:45:4500)
            if (k >= zlim(1) && k <= zlim(2))
               ytick(end+1) = k;
            end
         end
         set(gca,'ytick',ytick);
      end
   end
end

function o = Inherit(o)                % inherit options from shell    
   so = [];
   if isempty(figure(o))
      so = pull(o);
   end
      
      % save all options that have been explicitely provided

   color = opt(o,'color');
   oscale = opt(o,'oscale');
   omega = opt(o,'omega');
   magnitude = opt(o,'magnitude');
   phase = opt(o,'phase');

      % if there is a shell object from which we can inherit

   if ~isempty(so)
      o = inherit(o,so);
      o = with(o,'bode');
%     o = opt(o,'oscale',opt(o,{'brew.T0',1}));
   end
   
      % expand bode options if not yet provided
      
   if isempty(opt(o,'oscale'))
      o = opt(o,'oscale',opt(o,'bode.oscale'));
   end
   if isempty(opt(o,'omega'))
      o = opt(o,'omega',opt(o,'bode.omega'));
   end
   if isempty(opt(o,'magnitude'))
      o = opt(o,'magnitude',opt(o,'bode.magnitude'));
   end
   if isempty(opt(o,'phase'))
      o = opt(o,'phase',opt(o,'bode.phase'));
   end
      
      % restore all options that have previously been provided
         
   if ~isempty(color)
      o = opt(o,'color',color);
   end
   if ~isempty(oscale)
      o = opt(o,'oscale',oscale);
   end
   if ~isempty(omega)
      o = opt(o,'omega',omega);
   end
   if ~isempty(magnitude)
      o = opt(o,'magnitude',magnitude);
   end
   if ~isempty(phase)
      o = opt(o,'phase',phase);
   end
end
