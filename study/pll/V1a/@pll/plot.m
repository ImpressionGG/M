function oo = plot(o,varargin)         % PLL Plot Method               
%
% PLOT   PLL plot method
%
%           plot(type(o,'kmf'),os,ok)  % Kalman Filter Plot
%
%        Single Plots:
%
%           plot(o,'PlotE')            % error signal
%
%        See also: PLL
%
   [gamma,oo] = manage(o,varargin,@Plot,@PlotE,@PlotY,@PlotU,@PlotPwm,...
                       @PlotQ,@PlotNoise,@PlotD,@PlotPeriod);
   oo = gamma(oo);
end

%==========================================================================
% Plot Menu
%==========================================================================

function o = Plot(o)                   % Plotting                      
   switch type(o)
      case 'kalman'                    % Kalman filter plot
         KalmanPlot(o);
      case 'pll'                       % PLL Plot
         PllPlot(o);
      case 'con'                       % Control
         ControlPlot(o);
      otherwise
         error('type not supported');
   end
end

%==========================================================================
% Helper
%==========================================================================

function [y,idx] = Steady(x)           % Steady value of 2nd Half      
   idx = max(1,ceil(length(x)/2));
   idx = idx:length(x);
   y = mean(x(idx));
end
function t = Timing(o,tmin,tmax)                                       
%
% TIMING return counter value(s) to given time value(s)
%
%            t = Timing(with(o,'tim6'),tmin,tmax)
%
%         See also: Counter
%
   if (nargin < 2)
      tmin = var(o,'tmin');
      if isempty(tmin)
         tmin = 0;
      end
      tmax = var(o,'tmax');
      if isempty(tmax)
         f = opt(o,{'grid.f',50});
         periods = opt(o,{'simu.periods',1});
         tmax = 1/f*periods;
      end
   end
   
   f0 = opt(o,{'clock.f0',32e6});
   kappa = opt(o,{'clock.kappa',1});

   offset = opt(o,{'offset',0});
   %period = opt(o,{'period',40000-1});
   K = opt(o,{'prescale',32});
   delta = K/f0*kappa;

   t = [tmin, tmin+rem(offset,0.001):delta:tmax];
   t = round(t*1e6)/1e6;
end
function [cnt,delta,t0] = Pwm(o,t,p,t0)% Return PWM counter            
%
% PWM     Return PWM counter value(s) to given time value(s) and
%         sequence of PWM periods p (note that actual timer periods
%         are period(k) = p(k)-1.
%
%            cnt = Counter(o,t,delta,period,offset)
%            cnt = Counter(with(o,'tim6'),t,p)
%
%         Get PWM key parameters
%
%            [period,delta,t0] = Pwm(o)
%
%         See also: Timing
%
   oo = with(o,'tim2');    % PWM timer   
   
   if (nargin < 3)
      p = opt(oo,{'period',40000});
   end
   if (nargin < 4)
      t0 = opt(oo,{'offset',0});
   end
   
   f0 = opt(oo,{'clock.f0',32e6});
   kappa = opt(oo,{'clock.kappa',1});
   K = opt(oo,{'prescale',32});
   delta = K/f0*kappa;

   if (nargin == 1)                    % return PWM key parameters
      cnt = opt(oo,'period')+1;        % nominal period
      return
   end
   
      % convert time to timer increments
      
   z = round(t/delta);
   z0 = round(t0/delta);
   
   cnt = 0*z;                          % init counter values
   zmax = max(z);
   zk = z0;
   
   k = 1;                              % index through p(k)
   while (zk <= zmax) 
      period = p(k);
      modulus = period;                % not period+1 !
      
         % get indices of next counter tooth
         
      idx = find(z >= zk & z < zk+modulus); 

         % calculate counter values of current tooth
        
      if ~isempty(idx)
         zidx = (z(idx)-zk);
         tooth = rem(zidx,modulus);
         cnt(idx) = tooth;
      end
      
         % progress to next tooth
         
      zk = zk + modulus;
      k = min(k+1,length(p));          % increment k, unless end of p
   end
end
function Subplot(o)                    % Select Subplot                
   sub = opt(o,'sub');
   if ~isempty(sub)
      subplot(sub);
   end
end
function oo = Options(o)               % Set Options by Args           
%
% OPTIONS  Push args into options
%
   args = arg(o);
   oo = o;                         
   while ~isempty(args)
      if (length(args) < 2)
         error('arg list must be pair of option tag and value');
      end
      tag = args{1};
      val = args{2};
      if ~ischar(tag)
         error('option tag must be character')
      end
      oo = opt(oo,tag,val);
      args(1:2) = [];
   end
end
function Grid(o)                       % Grid On/Off                   
   onoff = opt(o,'grid');
   if ~isempty(onoff)
      if (onoff)
         grid on;
      else
         grid off;
      end
   end
end

%==========================================================================
% Subplots
%==========================================================================

function hdl = Step(t,y,col)           % Step Plot                     
   t = [t;t(2:end) t(end)];
   y = [y;y];
   
   hdl = plot(t(:),y(:));
   if (nargin >= 3)
      corazito.color(hdl,col);
   end
end
function PwmPlot(o,t,q,tz,qz)          % Plot PWM Timer Signals        
   tmin = min(t);
   tmax = max(t);
   fac = 1/1000;
   
   hdlpwm = Step(t*1000,q*fac,'rk');
   [stqz,idx] = Steady(qz);
   sigqz = std(qz(idx));
   title(sprintf('PWM Phase (-> %g +- %g @3s)',o.rd(stqz,0),...
                                               o.rd(3*sigqz,0)));
   set(gca,'xlim',[tmin tmax]*1000);
   ylabel('PWM counter [k#]');
   
   if (opt(o,{'simu.mini',0}) == 1)
      set(gca,'Xtick',0:2:200);
      set(gca,'Ytick',1:12);
      set(gca,'Ylim',[0 12]);
      set(hdlpwm,'Linewidth',2);
      grid on;
   end
   
      % add zero crossing to PWM plot
      
   if (nargin >= 4)
      ylim = get(gca,'Ylim');
      for (i=1:length(tz))
         hdl = plot(tz(i)*[1 1]*1000,ylim,'b-.');
         if (opt(o,{'simu.mini',0})==1)
            set(hdl,'LineWidth',2);
         end
      end  
      hdl = plot(tz*1000,qz*fac,'ro', tz*1000,qz*fac,'r');
      set(hdl,'LineWidth',1.5);
   end
end

function o = PlotPwm(o)                % Plot PWM Signals              
   [t,p] = data(o,'t','p');
   t0 = data(o,{'t0',0});
   pwm = var(o,'pwm');
   Dt = var(o,{'Dt',1});

   o = Options(o);
   Subplot(o);

   tz = (t0+t)*Dt;
   t = Timing(with(o,'tim2'));
   period = Pwm(o);
   q = Pwm(o,t,pwm);
   PwmPlot(o,t/1000,q,tz/1000,p);
   Grid(o);
end
function o = PlotE(o)                  % Plot Error Signal             
%
% PLOTE   Plot a controller's error signal
%
%            t = 0:0.02:2;
%            oo = log(o,'t',t,'e',2000*sin(10*pi*t).*exp(-t/0.2)); 
%            plot(oo,'PlotE','sub',311,'color','m','grid',1);
%
   [t,e] = data(o,'t','e');
   fac = 1000;
   
   o = Options(o);
   Subplot(o);
   
   col = opt(o,{'color','k'});
   plot(t,e/fac,col, t,e/fac,[col,'.']);

   [einf,idx] = Steady(e);
   sig = std(e(idx));
   
   title(sprintf('Error (-> %g ms +- %g us @ 3s)',...
                 o.rd(einf/fac), o.rd(3*sig,0)));
   ylabel('e [ms]');
   Grid(o);
end
function o = PlotY(o)                  % Plot Objective Signal         
%
% PLOTY   Plot objective signal
%
%            t = 0:0.02:2;
%            oo = log(o,'t',t,'y',2000-2000*cos(10*pi*t).*exp(-t/0.2)); 
%            plot(oo,'PlotY','sub',312,'color','r','grid',1);
%
   [k,y,yo] = data(o,'k','y','o');
   t = k*0.02;
   fac = 1000;
   
   o = Options(o);
   Subplot(o);
   
   col = opt(o,{'color','r'});
   plot(t,y/fac,col, t,y/fac,[col,'.']);
   
   if ~isempty(yo)
      hold on
      plot(t,yo/fac,'k');
   end   

   [yinf,idx] = Steady(y);
   sigy = std(y(idx));

   if (~isempty(yo))
      sigo = std(yo(idx));
      title(sprintf('Objective (-> %g ms +- %g/%g us @ 3s)',...
                 o.rd(yinf/fac), o.rd(3*sigy,0),o.rd(3*sigo,0)));
      ylabel('r:y, k:o [ms]');
   else
      title(sprintf('Objective (-> %g ms +- %g us @ 3s)',...
                 o.rd(yinf/fac), o.rd(3*sigy,0)));
      ylabel('y [ms]');
   end
   Grid(o);
end
function o = PlotQ(o)                  % Plot Objective Signal         
%
% PLOTQ   Plot target signal
%
%            t = 0:0.02:2;
%            oo = log(o,'t',t,'y',2000-2000*cos(10*pi*t).*exp(-t/0.2)); 
%            plot(oo,'PlotY','sub',312,'color','r','grid',1);
%
   [k,x,yo] = data(o,'k','x','yo');
   
   t = k*0.02;
   fac = 1000;
   q = x(4,:);
   
   o = Options(o);
   Subplot(o);
   
   col = opt(o,{'color','m'});
   plot(t,q/fac,col, t,q/fac,[col,'.']);
   if ~isempty(yo)
      hold on
      plot(t,yo/fac,'k', t,yo/fac,'k.');
   end
   
   [qinf,idx] = Steady(q);
   sig = std(q(idx));
   
   if ~isempty(yo)
      sigo = std(yo(idx));
      title(sprintf('Target/Objective (-> %g ms +- %g/%g us @ 3s)',...
                 o.rd(qinf/fac), o.rd(3*sig,0),o.rd(3*sigo,0)));
      ylabel('m:q, k:o [ms]');
   else
      title(sprintf('Target (-> %g ms +- %g us @ 3s)',...
                 o.rd(qinf/fac), o.rd(3*sig,0)));
      ylabel('q [ms]');
   end
   
   avg = round(qinf/fac);
   set(gca,'ylim',[0.95*avg 1.05*avg]);
   
   Grid(o);
end
function o = PlotU(o)                  % Plot Control Signal           
%
% PLOTU   Plot control signal
%
%            t = 0:0.02:2;
%            oo = log(o,'t',t,'u',1000*cos(10*pi*t).*exp(-t/0.2)); 
%            plot(oo,'PlotU','sub',313,'color','b','grid',1);
%
   [k,u] = data(o,'k','u');
   t = k*0.02;
   fac = 1;
   
   o = Options(o);
   Subplot(o);
   
   col = opt(o,{'color','b'});
   plot(t,u/fac,col, t,u/fac,[col,'.']);

   [uinf,idx] = Steady(u);
   sig = std(u(idx));
   
   title(sprintf('Control Signal (-> %g ms +- %g us @ 3s)',...
                 o.rd(uinf/fac), o.rd(3*sig,0)));
   ylabel('u [us]');
   Grid(o);
end

function o = PlotNoise(o)              % Plot Noise Signals            
%
% PLOTNOISE  
%    Plot noise signals
%
%    t = 0:0.02:2;
%    oo = log(o,'t',t,'u',rand(size(t))); 
%    plot(oo,'PlotNoise','sub',313,'grid',1);
%
   [t,t0,u,v,w,z] = data(o,'t','t0','u','v','w','z');
   Dt = var(o,'Dt');
   tt = (t+t0)*Dt;
   fac = 1000;
   
   o = Options(o);
   Subplot(o);
   
   plot(tt,v,'b', tt,v,'bo');
   hold on

   plot(tt,w,'g', tt,w,'g.');
   plot(tt,z-t,'r', tt,z-t,'r.');

   sigw = std(w);  sigv = std(v);
   title(sprintf('Grid Variation: %g us @ 3s, Jitter: %g us @ 3s',...
                 o.rd(3*sigw,0),o.rd(3*sigv,0)));   
   ylabel('jitter [us]');

   Grid(o)
end
function o = PlotD(o)                  % Plot Deviation & Error        
%
% PLOTD  Plot deviation and error signal
%
%    t = 0:0.02:2;  y = 10000*rand(2,length(t)); 
%    os = log(o,'t',t, 'q',y(1,:)); 
%    ok = log(o,'t',t, 'd',rand(size(t)), 'q',y(2,:)); 
%    o = var(o, 'os'os, 'ok',ok);
%    plot(o,'PlotD','sub',323,'grid',1);
%
   os = var(o,'os');
   ok = var(o,'ok');

   [t,t0] = data(os,'t','t0');
   [xm,d,q] = data(ok,'x','d','q');
   Dt = var(os,{'Dt',1});
   tt = (t+t0)*Dt;
   
   o = Options(o);
   Subplot(o);
   
   switch size(xm,1)                   % depending on system order
      case 2   
         e = t - q;
      case 3
         e = [];
      case 4
%        e = q(2,:) - t;
         e = t - q(1,:);
   end
         
   %subplot(312);
   plot(tt,0*tt,'k');
   hold on;
   
   if (size(d,1) >= 2)
      plot(tt,d(1,:),'r',  tt,d(1,:),'r.');
      sigd1 = std(d(1,round(end*0.3):end));

      plot(tt,d(2,:),'c',  tt,d(2,:),'c.');
      sigd2 = std(d(2,round(end*0.3):end));
   else
      plot(tt,d,'r',  tt,d,'r.');
      sigd = std(d(1,round(end*0.3):end));
   end
   
   if (isempty(e) && size(d,1) == 1)
      title(sprintf('Deviation d=y-z (%d us @ 3s)',o.rd(3*sigd,0)));
      ylabel('d');
      set(gca,'ylim',3*(sigd)*[-1 1]);
   elseif (isempty(e) && size(d,1) > 1)
      title(sprintf('Deviation d=y-z (%d/%d us @ 3s)',...
                    o.rd(3*sigd1,0),o.rd(3*sigd2,0)));
      ylabel('r:d1, c:d2 [us]');
      set(gca,'ylim',3*(max([sigd1,sigd2]))*[-1 1]);
   elseif (~isempty(e) && size(d,1) == 1)
      plot(tt,e,'b',  tt,e,'b.');
      sige = std(e(round(end*0.3):end));
      title(sprintf('Deviation d=y-z (%d us @ 3s) & Error e=qm-tz (%d us @ 3s)',...
                    o.rd(3*sigd,0),o.rd(3*sige,0)));
      ylabel('r:d, b:e [us]');
      set(gca,'ylim',3*(sigd+sige)*[-1 1]);
   elseif (~isempty(e) && size(d,1) > 1)
      plot(tt,e,'b',  tt,e,'b.');
      sige = std(e(round(end*0.3):end));
      title(sprintf('Deviation d=y-z (%d/%d us @ 3s) & Error e=qm-tz (%d us @ 3s)',...
                    o.rd(3*sigd1,0),o.rd(3*sigd2,0),o.rd(3*sige,0)));
      ylabel('r:d1, c:d2, b:e [us]');
      set(gca,'ylim',3*(max([sigd1,sigd2])+sige)*[-1 1]);
   end
   
   Grid(o);
end
function o = PlotPeriod(o)             % Plot Estimated Period         
   os = var(o,'os');
   ok = var(o,'ok');

   [t,t0,g] = data(os,'t','t0','g');
   [x] = data(ok,'x');
   
   Dt = var(os,'Dt');
   tt = (t+t0)*Dt;
   gm = x(1,:);                        % model state 1 (grid period)
   fac =  1000;
   
   o = Options(o);

   if (size(x,1) ~= 3)
      Subplot(o);
      %xe = gm - g;      % period observation error
      plot(tt,g/fac,'r', tt,g/fac,'r.');
      hold on;

      plot(tt(3:end),gm(3:end)/fac,'b', tt(3:end),gm(3:end)/fac,'b.');

      sigt = std(g(round(end*0.3):end));
      sigm = std(gm(round(end*0.3):end));
      title(sprintf('System Period (%d ms @ 3s) & Observed (%d us @3s)',...
                    o.rd(3*sigt,0),o.rd(3*sigm,0)));   
      ylabel('period [ms] (r:sys, b:obs)');

      Grid(o);
   else
      subplot(615);

      plot(tt,g/fac,'r', tt,g/fac,'r.');
      sig = std(g(round(end*0.3):end));
      title(sprintf('System Period (%d ms @ 3s)',o.rd(3*sig,0)));   
      ylabel('period [ms]');
      Grid(o);

      subplot(616);

      plot(tt(3:end),gm(3:end)/fac,'b', tt(3:end),gm(3:end)/fac,'b.');
      sig = std(gm(round(end*0.3):end));
      title(sprintf('Observed Period (%d ms @ 3s)',o.rd(3*sig,0)));   
      ylabel('period [ms]');
      Grid(o);
   end   
end

%==========================================================================
% Kalman Filter Plot
%==========================================================================

function o = KalmanPlot(o)            % Full Kalman Filter Plot        
   os = arg(o,1);                      % system object
   ok = arg(o,2);                      % data object
   o = var(o,'os',os,'ok',ok);

   sub = opt(o,{'sub',[311,312,313]});

      % First Plot
  
   plot(os,'PlotNoise','sub',sub(1),'grid',1);
      
      % Second Plot
      
   plot(o,'PlotD','sub',sub(2),'grid',1);
   
      % Third Plot
   
   plot(o,'PlotPeriod','sub',sub(3),'grid',1);
end

%==========================================================================
% Control Plot
%==========================================================================

function o = ControlPlot(o)            % Plot Controller Signals       
   oc = arg(o,1);
   os = arg(o,2);

   [k,r,y,e,u] = data(oc,'k','r','y','e','u');
   [x,g] = data(os,'x','g');
   fac = 1000;
   
   time = k*0.02;
   kmax = length(time);
   
   if isempty(data(os,'pwm'))
      sub = [221,222,223,224];
   else
      sub = [321,322,323,324];
   end
   
      % 1st plot   

   plot(oc,'PlotY','sub',sub(1),'grid',1);
   
      % 2nd plot
     
   os = data(os,'yo',data(oc,'o'));
   plot(os,'PlotQ','sub',sub(2),'grid',1);
   
      % 3rd plot
      
   subplot(sub(3));

   h = x(3,:);
   plot(time,g/fac,'g', time,g/fac,'go');
   hold on
   plot(time,2*h/fac,'m', time,2*h/fac,'m.');
   [avg,idx] = Steady(g);
   sigg = std(g(idx));
   
   title(sprintf('Grid (Period -> %g ms +- %g us @3s)',...
      o.rd(avg/fac,1),o.rd(3*sigg,0)));
   ylabel('g:h [ms], m:2*h [ms]');
   set(gca,'ylim',o.rd(avg,0)*[0.9 1.1]/fac);
   xlabel('time [s]');
   grid on

      % 4th plot
      
   plot(oc,'PlotU','sub',sub(4),'grid',1);
   
      % 5th plot
      
   if ~isempty(data(os,'pwm'))
      plot(os,'PlotPwm','sub',313,'grid',1);
   end
end

%==========================================================================
% PLL Plot
%==========================================================================

function o = PllPlot(o)                % Plot All Signals              
   os = arg(o,1);
   ok = arg(o,2);
   oc = arg(o,3);
   
   os = data(os,'yo',data(oc,'y'));
   if opt(o,{'pwm.pwmplot',1})
      oo = opt(o,'sub',[421,423,425]);
      oo = arg(oo,{os,ok});
      KalmanPlot(oo);

      plot(oc,'PlotQ','sub',422,'grid',1);
      plot(oc,'PlotY','sub',424,'grid',1);
      plot(oc,'PlotU','sub',426,'grid',1);
      plot(os,'PlotPwm','sub',414,'grid',1);
   else
      oo = opt(o,'sub',[321,323,325]);
      oo = arg(oo,{os,ok});
      KalmanPlot(oo);

      plot(os,'PlotQ','sub',322,'grid',1);
      plot(oc,'PlotY','sub',324,'grid',1);
      plot(oc,'PlotU','sub',326,'grid',1);
   end
end
