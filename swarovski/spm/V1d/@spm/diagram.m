function oo = diagram(o,varargin)                                       
%
% DIAGRAM   Plot diagram
%
%              diagram(o,'Force','F1',t,F1,sub)       % force 1
%              diagram(o,'Elongation','x2',t,x2,sub)  % elongation 2
%              diagram(o,'Acceleration','a1',t,a1,sub)% acceleration 1
%              diagram(o,'Mode','x4',t,x4,sub)        % mode plot (mode 4)
%              diagram(o,'Orbit','y2(y1)',y1,y2,sub)  % orbit plot
%
%              diagram(o,'Trf','G11',G11,sub)         % transfer function
%              diagram(o,'Weight','G12',w12,sub)      % weight vector
%              diagram(o,'Step','G11',G11,sub)        % elon. step response
%              diagram(o,'Vstep','L11',L11,sub)       % velocity step rsp.
%              diagram(o,'Astep','Ta1',Ta1,sub)       % accel. step rsp.
%              diagram(o,'FStep','L51',L51,sub)       % force step response
%              diagram(o,'Rloc','G11',G11,sub)        % root locus
%              diagram(o,'Stability','L1',L1,sub)     % stability analysis
%              diagram(o,'Bode','G11',G11,sub)        % bode diagram
%              diagram(o,'Nyq','G11',G11,sub)         % Nyquist diagram
%              diagram(o,'Numeric','G11',G11,sub)     % numeric quality
%              diagram(o,'Calc','L1',L1,sub)          % calculation diagram
%
%           Options:
%              critical:     plot critical frequency in bode plot
%
%           Copyright(c): Bluenetics 2020
%
%           See also: SPM, PLOT
%
   [gamma,oo] = manage(o,varargin,@Force,@Elongation,@Acceleration,...
                       @Mode,@Orbit,@Trf,@Weight,@Numeric,@Stability,...
                       @Step,@Vstep,@Astep,@Fstep,@Bode,@Nyq,@Rloc,@Calc);
   oo = gamma(oo);
end

%==========================================================================
% Force
%==========================================================================

function o = Force(o)                  % Force Diagram                 
   o = with(o,'scale');                % unwrap scale options
   o = opt(o,'yscale',1,'yunit','N');
 
   sym = arg(o,1);
   t = arg(o,2);
   F = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,t,F,'yyr');
   
   Epilog(o,['Force ',sym],sym);
end

%==========================================================================
% Elongation, Velocity, Acceleration
%==========================================================================

function o = Elongation(o)             % Elongation Diagram            
   o = with(o,'scale');                % unwrap scale options
   
   sym = arg(o,1);
   t = arg(o,2);
   y = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,t,y,'g');
   
   Epilog(o,['Elongation ',sym],sym);
end
function o = Acceleration(o)           % Acceleration Diagram          
   o = with(o,'scale');                % unwrap scale options
   o = opt(o,'yscale',opt(o,'ascale'));
   o = opt(o,'yunit',opt(o,'aunit'));
   
   sym = arg(o,1);
   t = arg(o,2);
   y = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   col = opt(o,{'color','r'});
   plot(o,t,y,col);
   
   Epilog(o,['Acceleration ',sym],sym);
end

%==========================================================================
% Mode
%==========================================================================

function o = Mode(o)                   % Mode Diagram                  
   o = with(o,'scale');                % unwrap scale options
 
   colors = {'r','y','bc','m','gc','rw','yw','bcw','mw','gcw',...
             'rk','yk','bck','mk','gck'};
   
       % consult 'some magic' to generate unique color index
       
   sym = arg(o,1);
   idx = 1 + rem(sum(sym)-sum('x1')+10*length(colors),length(colors));
   col = colors{idx};
   
   t = arg(o,2);
   x = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   if (size(x,1) == 1)
      plot(o,t,x,col);
   else
      plot(t,x);
   end
   
   Epilog(o,['Mode ',sym],sym);
end

%==========================================================================
% Orbit Diagram
%==========================================================================

function o = Orbit(o)                  % Orbit Diagram                 
   o = with(o,'scale');                % unwrap scale options
   o = opt(o,'xscale',opt(o,'yscale'));% copy y-scaling factor
   o = opt(o,'xunit',opt(o,'yunit'));  % copy y-unit
   
   sym = arg(o,1);
   ya = arg(o,2);
   yb = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,ya,yb,'g');
   
   try
      sym1 = sym(4:5);
      sym2 = sym(1:2);
   catch
      sym1 = 'ya';  sym2 = 'yb';
   end
  
   Epilog(o,['Orbit ',sym2,' (',sym1,')'],sym1,sym2);
end

%==========================================================================
% Transfer & Weight Function Diagram
%==========================================================================

function o = Trf(o)                    % Transfer Function Diagram     
   sub = o.either(arg(o,3),[1 1 1]);
   G = arg(o,2);
   sym = o.either(arg(o,1),Sym(G));

   tit = [sym,': Transfer Function'];  % default title
   tit = o.either(arg(o,4),tit);       % title
   
   if isequal(sub,111) || isequal(sub,1111)
      o = opt(o,'subplot',sub,'pitch',0.4);
      G = opt(G,'maxlen',250,'braces',1);
   elseif isequal(sub,311) || isequal(sub,3111) 
      o = opt(o,'subplot',sub,'pitch',2);
      G = opt(G,'maxlen',250,'braces',1);
   else
      o = opt(o,'subplot',sub,'pitch',2,'braces',1);
   end
   
   comment = [{' '},display(G)];
   message(o,tit,comment);
   axis off;
end
function o = Weight(o)                 % Weight Function Diagram       
   weightdb = opt(o,{'weight.db',1});  % show weight in dB
   w0 = opt(o,'weight.nominal');       % nominal weight
   
   sym = arg(o,1);
   w = arg(o,2);
   dB = 20*log10(abs(w));              % weight in decibels
   
   sub = o.either(arg(o,3),[1 1 1]);
   
   o = opt(o,'subplot',sub);
   
   small = opt(o,{'weight.small',1e-3});
   small = small*max(abs(w));
   idx = find(abs(w)<small);
   
   n = 1:length(w);
   if ~isempty(idx)
      ww = w(idx);  nn = n(idx);  db = dB(idx);
      if weightdb
         plot(o,nn,db,'|K', nn,db,'Ko');
      else
         plot(o,nn,ww,'|K', nn,ww,'Ko');
      end
      hold on;
   end
   
   idx = find(abs(w)>=small);
   if ~isempty(idx)
      ww = w(idx);  nn = n(idx);  db = dB(idx);
      if weightdb
         plot(o,nn,db,'|r', nn,db,'ro');
      else
         plot(o,nn,ww,'|r', nn,ww,'ro');
      end
      hold on;
   end
   
   Xtick(o);                           % set pretty xticks
   
   title('Modal Weights');
   xlabel('Mode Number');
   if weightdb && isempty(w0)
      ylabel([sym,'  [dB]']);
   elseif weightdb && ~isempty(w0)
      ylabel(sprintf([sym,'/%g  [dB]'],o.rd(w0,.2)));
   else
      ylabel(sym);
   end
   
   function Xtick(o)                   % Set Pretty Xticks             
      nw = length(w);
      if (nw < 20)
         set(gca,'Xtick',1:nw);
      elseif (nw < 40)
         set(gca,'Xtick',2:2:nw);
      else
         delta = round(nw/20);
         switch delta
            case {3,4}
               delta = 5;
            case {6,7,8,9}
               delta = 10;
            case {11,12,13,14}
               delta = 15;
            otherwise
               delta = ceil(delta/5)*5;
         end

         set(gca,'Xtick',delta:delta:nw);
      end
   end
end

%==========================================================================
% Elongation/Velocity Step Response Diagram
%==========================================================================

function o = Step(o)                   % Elongation Step Response      
   o = Scaling(o);                     % manage scaling factors
   
   sub = o.either(arg(o,3),[1 1 1]);
   G = arg(o,2);
   sym = o.either(arg(o,1),Sym(G));
   
   G = inherit(G,o);
   G = Color(G);
   
   if length(num(G)) > length(den(G))
      G = system(G,{0,1});
   end
   
   subplot(o,sub);
   step(G);
   
   title(sprintf('%s - Step Response',sym));
   ylabel(['y  [',opt(o,{'yunit','1'}),']']);

   subplot(o);                         % subplot done!
end
function o = Vstep(o)                  % Velocity Step Response        
   o = Scaling(o);                     % manage scaling factors
   o = opt(o,'yscale',opt(o,'vscale'));
   o = opt(o,'yunit',opt(o,'vunit'));
   
   sub = o.either(arg(o,3),[1 1 1]);
   G = arg(o,2);
   sym = o.either(arg(o,1),Sym(G));
   
   G = inherit(G,o);
   G = Color(G);

   subplot(o,sub);
   step(G);
   
   ylabel(['dy/dt [',opt(o,{'yunit','1'}),']']);
   subplot(o);                         % subplot done!
end
function o = Astep(o)                  % Acceleration Step Response    
   o = Scaling(o);                     % manage scaling factors
   o = opt(o,'yscale',opt(o,'ascale'));
   o = opt(o,'yunit',opt(o,'aunit'));
   
   sub = o.either(arg(o,3),[1 1 1]);
   G = arg(o,2);
   sym = o.either(arg(o,1),Sym(G));
   
   G = inherit(G,o);
   G = Color(G);
   
   subplot(o,sub);
   step(G);
   
   ylabel(['dy2/dt2 [',opt(o,{'yunit','1'}),']']);
   subplot(o);                         % subplot done!
end
function o = Fstep(o)                  % Force Step Response           
   o = Scaling(o);                     % manage scaling factors
   o = opt(o,'yscale',opt(o,'fscale'));
   o = opt(o,'yunit',opt(o,'funit'));
   
   sub = o.either(arg(o,3),[1 1 1]);
   G = arg(o,2);
   sym = o.either(arg(o,1),Sym(G));
   
   G = inherit(G,o);
   G = Color(G);

   subplot(o,sub);
   step(G);
   
   ylabel(['F [',opt(o,{'yunit','1'}),']']);
   subplot(o);                         % subplot done!
end

%==========================================================================
% Bode & Nyquist Diagram
%==========================================================================

function o = Bode(o)                   % Bode Diagram                  
   if isequal(opt(o,{'trf.type','??'}),'strf')
      o = GoodBode(o);
   else
      o = NewBode(o);
   end
   hold on;
end
function o = GoodBode(o)               % Bode Diagram                  
   o = Scaling(o);                     % manage scaling factors
   
   sub = o.either(arg(o,3),[1 1 1]);
   G = arg(o,2);
   sym = o.either(arg(o,1),Sym(G));

   [num,den] = peek(G);
   oo = system(inherit(corasim,o),{num,den});   
   oo = set(oo,'name',sym); 
   oo = Color(oo);
   
   subplot(o,sub);
   
   bode(oo);
   title([sym,': Bode Diagram']);

   subplot(o);                         % subplot done!
end
function o = NewBode(o)                % Bode Diagram                  
   o = Scaling(o);                     % manage scaling factors
   critical = opt(o,{'critical',0});   % plot critical frequency ?
   
   sub = o.either(arg(o,3),[1 1 1]);
   G = arg(o,2);
   sym = o.either(arg(o,1),Sym(G));

   G = inherit(G,o);                   % inherit options
   G = set(G,'name',sym);              % set name of transfer function
   G = Color(G);
   
   subplot(o,sub);  
   bode(G);
   
   if (critical)
      f0 = cook(o,'f0');
      ylim = get(gca,'ylim');
      hold on;
      hdl = semilogx(2*pi*f0*[1 1],ylim,'r-.');
      set(hdl,'linewidth',1);
   end
   
   title([sym,': Bode Diagram']);
   subplot(o);                         % subplot done!
end

function o = Nyq(o)                    % Nyquist Diagram               
   o = Scaling(o);                     % manage scaling factors
   o = with(o,'nyq');                  % override some Scaling opts
   
   sub = o.either(arg(o,3),[1 1 1]);
   G = arg(o,2);
   sym = o.either(arg(o,1),Sym(G));

   G = inherit(G,o);                   % inherit options
   G = set(G,'name',sym);              % set name of transfer function
   G = Color(G);
   
   if isempty(opt(G,'color'))
      G = opt(G,'color','r');
   end
   
   subplot(o,sub);
   
   o = nyq(G);
   title([sym,': Nyquist Diagram']);

   subplot(o);                         % subplot done!
end
function o = Stability(o)              % Stability Analysis            
   o = Scaling(o);                     % manage scaling factors
   o = with(o,'nyq');                  % override some Scaling opts
   
   sym = arg(o,1);
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);

   G = inherit(G,o);                   % inherit options
   G = set(G,'name',sym);              % set name of transfer function
   
   if isempty(opt(G,'color'))
      G = opt(G,'color','r');
   end
   
   subplot(o,sub);
   
   stable(o,G);
   %title([sym,': Stability Analysis']);

   subplot(o);                         % subplot done!
   
   function o = OldStable(o)
      low = opt(o,{'magnitude.low',-300});
      high = opt(o,{'magnitude.high',100});
      delta = opt(o,{'magnitude.delta',20});
      
      mag = logspace(low/20,high/20,5000);
      
      [num,den] = peek(o);
      
      for (i=1:length(mag))
         K = mag(i);
         poly = add(o,K*num,den);
         r = roots(poly);
         
         re(i) = max(real(r));
      end
      
      dB = 0*re;
      
      idx = find(re>0);
      if ~isempty(idx)
         dB(idx) = 20*log(1+re(idx));
      end

      idx = find(re<0);
      if ~isempty(idx)
         dB(idx) = 20*log(-re(idx));
      end
      
      hdl = semilogx(mag,dB);
      hold on;
      
      lw = opt(o,{'linewidth',1});
      set(hdl,'LineWidth',lw,'Color',0.5*[1 1 1]);
      
      idx = find(re>0);
      margin = inf;
      
      if ~isempty(idx)
         semilogx(mag(idx),dB(idx),'r.');
         margin = mag(min(idx));
      end
      
      idx = find(re<0);
      if ~isempty(idx)
         semilogx(mag(idx),dB(idx),'g.');
      end
      
         % plot axes
         
      col = o.iif(dark(o),'w-.','k-.');
      plot(get(gca,'xlim'),[0 0],col);
      plot([1 1],get(gca,'ylim'),col);
      subplot(o);
      
      xlabel('K-factor');
      mu = opt(o,'process.mu');
      if isempty(mu)
         ylabel(sprintf('Stability Margin: %g',o.rd(margin,2)));
      else
         ylabel(sprintf('Stability Margin: %g  (mu = %g)',...
                o.rd(margin,2),mu));
      end         
   end
end

%==========================================================================
% Numeric Quality
%==========================================================================

function o = Numeric(o)                % Numeric Quality               
%
% Compare frequency response calculations for usual transfer function
% representations against modal representations. Convert error to dB
% and show in terms of logarithmic error
%
   o = Scaling(o);                     % manage scaling factors
   
   psi_W = arg(o,1);                   % modal representation of TRF
   psi = psi_W{1};
   wij = psi_W{2};
   
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);

   G = inherit(G,o);                   % inherit options
%  G = set(G,'name',sym);              % set name of transfer function
   name = get(G,{'name',''});
   
   if isempty(opt(G,'color'))
      G = opt(G,'color','r');
   end
   
   subplot(o,sub);
   
   Show(G);
   title([name,': Frequency Response Error']);
   ylabel('Relative Error [dB]');

   subplot(o);                         % subplot done!
   
   function Show(o)                    % Show Numeric Quality 
      o = Auto(o);                     % auto axis limits
      o = Axes(o);                     % plot axes

      points = opt(o,{'omega.points',1000});   
      oscale = opt(o,{'oscale',1});       % frequency scaling factor
   
      xlim = get(gca,'Xlim');
      ylim = get(gca,'Ylim');
      zlim = get(gca,'Zlim');
   
      olim = log10(xlim);

         % convert modal reoresentation (o) to strf (o1)
         
      o1 = trf(o);
      om = logspace(log10(xlim(1)), log10(xlim(2)), points);
   
         % first plot strf in yellow
         
%     Gjw1 = fqr(o1,om*oscale);
      [Gjw1,~,dB1] = fqr(o1,om);
      mag1 = abs(Gjw1);
      hdl = semilogx(om,dB1);
      set(hdl,'Color','y')
      hold on;
      
         % then plot modal form in red
         
%     Gjw0 = fqr(o,om*oscale);
      [Gjw0,~,dB0] = fqr(o,om);
      mag0 = abs(Gjw0);
      hdl = semilogx(om,dB0);
      set(hdl,'Color','r')
      
         % finally plot psion FQR in green

      [Gjw2,dB2] = psion(o,psi,om,wij);
      mag2 = abs(Gjw2);
      hdl = semilogx(om,dB2);
      set(hdl,'Color','g')
         
         % finally plot error in magenta
         
      err = (mag1-mag0) ./ mag0;
      dBerr = 20*log10(abs(err));
      if all(err==0)
         hdl = semilogx(om,-399+0*err); 
      else
         hdl = semilogx(om,dBerr); 
      end
      set(hdl,'Color',o.color('m'),'LineWidth',1)
      
         % same with psion error
         
      err = (mag2-mag0) ./ mag0;
      dBerr = 20*log10(abs(err));
      if all(err==0)
         hdl = semilogx(om,-399+0*err); 
      else
         hdl = semilogx(om,dBerr); 
      end
      set(hdl,'Color',o.color('rm'),'LineWidth',1)
      
      
      set(gca,'Ylim',[-inf inf]);
      
   end
   function o = Auto(o)                % Automatic Axes Limits         
      if isempty(opt(o,'magnitude.low')) && isempty(opt(o,'magnitude.high')) 
         oscale = opt(o,{'oscale',1});

         [Gjw,om] = fqr(o);
         Gjw = fqr(o,om*oscale);

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
   function o = Axes(o)                % Plot Bode Axes                
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
         %PhaseTicks(o);
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
         %set(hax,'ylim',magni);
         %set(hax,'zlim',phase);
         %set(hax,'ytick',magni(1):dy:magni(2)); 
         set(hax,'Xscale','log');
      end
   end
   function o = Inherit(o)             % inherit options from shell    
      if isempty(figure(o))
         so = pull(o);
         if ~isempty(so)
            o = inherit(o,so);
            o = with(o,'bode');
            o = opt(o,'oscale',oscale(o));
         end
      end
   end
end

%==========================================================================
% Root Locus Diagram
%==========================================================================

function o = Rloc(o)                   % Root Locus Diagram            
   sub = o.either(arg(o,3),[1 1 1]);
   G = arg(o,2);
   sym = o.either(arg(o,1),Sym(G));
   
   G = inherit(G,o);                   % inherit options
   G = set(G,'name',sym);              % set name of transfer function
   G = Color(G);

   o = opt(o,'subplot',sub);
   subplot(o,sub);

   [z,p,K] = zpk(G);                   % zeros , poles, K
   
   col = o.iif(dark(o),'y','g');
   hdl = plot(corazon(o),real(p),imag(p),'x');
   set(hdl,'color',col);
   hold on;

   oo = corazon(o);
   hdl = plot(oo,real(z),imag(z),'o');
   set(hdl,'color',col);
   hold on;
   
   center = sum(real([p(:);z(:)]))/(length(p)+length(z));
   pmax = o.either(max(real(p)),-inf);
   zmax = o.either(max(real(z)),-inf);
   
   title(sprintf('%s: Poles/ Zeros',sym));
   xlabel(sprintf('Re(z) <= %g,  Re(p) <= %g',zmax,pmax));
   
   t = 0:1/10:100;
   K = 10.^t - 1;
      
   for (i=1:length(p))
      plot([center real(p(i))],[0 imag(p(i))],'r');
      hold on
      
         % for instable poles we also draw a line from the mirrored
         % center in the right complex half plane to alert attention
         
      if (real(p(i)) >= 0)
         plot([abs(center) real(p(i))],[0 imag(p(i))],'r');
      end
   end
   
   col = o.color('cb');
   for (i=1:length(z))
      hdl = plot([center real(z(i))],[0 imag(z(i))],'b');
      set(hdl,'color',col);
      hold on

         % for 'instable zeros' we also draw a line from the mirrored
         % center in the right complex half plane to alert attention
         
      if (real(z(i)) >= 0)
         hdl = plot([abs(center) real(z(i))],[0 imag(z(i))],'c');
         set(hdl,'color',col);
      end
   end
   
   SetLimits(o);   
   plot(o,[0 0],get(gca,'ylim'),'K1-.');
   subplot(o);                         % subplot done!
   
   function SetLimits(o)
      o = with(o,'rloc');
      zoom = opt(o,{'zoom',1});
      
      xlim = get(gca,'xlim');
      xlim = [xlim(1) max(xlim(2),abs(xlim(1)))];
      set(gca,'xlim',zoom*xlim);

      ylim = get(gca,'ylim');
      set(gca,'ylim',zoom*ylim);
      
         % option dependent settings
         
      xlim = opt(o,{'xlim',[]});
      ylim = opt(o,{'ylim',[]});
      
      if ~isempty(xlim)
         set(gca,'xlim',zoom*xlim);
      end
      if ~isempty(ylim)
         set(gca,'ylim',zoom*ylim);
      end
   end
end

%==========================================================================
% Calculation Diagram
%==========================================================================

function o = Calc(o)                   % Calculation Diagram           
   sym = arg(o,1);
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);

   switch sym
      case {'L(s)','L1(s)','L2(s)'}
         comment = ...
            {'L(s)  =  [ L1(s), L2(s) ]  =  HD(s)  =  [ H31(s), H32(s) ]',...
             ' ','L1(s)  =  H31(s)  =  -G31(s) / G33(s)',...
             'L2(s)  =  H32(s)  =  -G32(s) / G33(s)'};
      otherwise
         comment = {};
   end
   
   message(opt(o,'subplot',sub,'fontsize.comment',12,'pitch',2),...
       sprintf('Calculation of %s',sym),comment);
    
   axis off;
end

%==========================================================================
% Helper
%==========================================================================

function o = Epilog(o,tit,sym1,sym2)   % Epilog Tasks for Diagrams     
   title(tit);
   
   if (nargin == 3)
      xlabel(['time [',opt(o,{'xunit','?'}),']']);
      ylabel([sym1,' [',opt(o,{'yunit','?'}),']']);
   elseif (nargin == 4)
      xlabel([sym1,' [',opt(o,{'xunit','?'}),']']);
      ylabel([sym2,' [',opt(o,{'yunit','?'}),']']);
   end
   
   grid(o);
   heading(o);
end
function o = Scaling(o)                % Manage Scaling Factors        
%
% SCALING  Manage scaling factors with respect to time normalizing. Also
%          unwrap simu options, scale options and Bode options
%
   T0 = opt(o,{'brew.T0',1});
   
      % unwrap style options
      
   o = with(o,'style');
   
      % modify simu options
      
   o = with(o,'simu');
   [tmax,dt] = opt(o,'tmax,dt');
   tmax = tmax/T0;  dt = dt/T0;        % reduce simulation timing
   o = opt(o,'tmax,dt',tmax,dt);
   
         % modify scale options
      
   o = with(o,'scale');
   xscale = opt(o,{'xscale',1});
   xscale = xscale*T0;                 % blow-up displayed time
   o = opt(o,'xscale',xscale);
 
   o = with(o,'bode');
   oscale = opt(o,{'oscale',1});       % omega scale factor
   oscale = oscale*T0;
   o = opt(o,'oscale',oscale);
end
function sym = Sym(o)                  % Build Symbiol from Name       
   sym = [get(o,{'name','?'}),''];
end
function o = Color(o)                  % Set Color Default             
   sym = get(o,{'name','?'});
   if isempty(opt(o,'color')) 
      switch sym(1)
         case 'F'
            col = 'gb';
         case 'G'
            col = 'g';
         case 'H'
            col = 'm';
         case 'L'
            col = 'bcc';
         case 'P'
            col = 'bbw';
         case 'Q'
            col = 'mmmb';
         case 'S'
            col = o.iif(dark(o),'wwk','kkw');
         case 'T'
            col = 'rrrb';
         case '?'
            col = 'rk';
         otherwise
            col = 'r.';
      end
      
      if length(sym) >= 2 && isequal(sym(1:2),'L0')
         col = 'yyyyyr';
      end
      o = opt(o,'color',col);
   end
   
      % we also clear args
      
   o = arg(o,{});                      % clear args
end

