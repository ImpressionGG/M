function rv = control(obj,clear)
%
%  use t and u as global input variables from work space
%
   if (nargin < 2)
      clear = 1;
   end
   
   mode = arg(obj);
   if isempty(mode)
      mode = setting('control.mode');
   else
      setting('control.mode',mode);
   end

   if (clear)
      cls;     % clear screen
   end
   
   switch mode
      case 'SLOW-RECOVERY'
         recovery(obj,1,'Slow');
         return
 
      case 'FAST-RECOVERY'
         kboost = get(obj,'control.kboost'); 
         recovery(obj,kboost,'Fast');
         return

      case 'WELL-LOADED'
         title = 'Well-loaded Thermalization';
         Tpl = 160; % pre-load temperature
         thermalization(obj,0,Tpl,title);
         thermalization(obj,1,Tpl,title);
         thermalization(obj,2,Tpl,title);
         return

      case 'UNDER-LOADED'
         title = 'Well-loaded Thermalization';
         Tpl = 155; % pre-load temperature
         thermalization(obj,0,Tpl,title);
         thermalization(obj,1,Tpl,title);
         thermalization(obj,2,Tpl,title);
         return

      case 'OVER-LOADED'
         title = 'Over-loaded Thermalization';
         Tpl = 170; % pre-load temperature
         thermalization(obj,0,Tpl,title);
         thermalization(obj,1,Tpl,title);
         thermalization(obj,2,Tpl,title);
         return

      case 'GOLDEN-PROFILE'
         title = 'Golden TIM-Temperature Profile';
         Tpl = 160; % pre-load temperature
         obj = set(obj,'model.kRC',0.8);
         goldenprofile(obj);
         return

      case 'PID-CONTROL'
         title = 'Closed Loop Thermalization Control';
         Tpl = 160; % pre-load temperature
         pidcontrol(obj,0,Tpl,title);
         return
         
   end
   return

%==========================================================================
   
function recovery(obj,kboost,speed)
%
   Ts = setting('model.Ts');                    % model sampling time
   Tmax = setting('control.Tmax');              % max simulation time

   par = setting('model.parameter');
   [A0,B0,C0,D0] = statemodel(obj,par.p,0,Ts);  % non touching thermodes
   [A1,B1,C1,D1] = statemodel(obj,par.p,1,Ts);  % touching thermodes
   
   t = (0:Ts:Tmax);
   one = ones(size(t));        % heating power 

   ttouch = 1.0;               % touch down time
   idx1 = find(t < ttouch);
   idx2 = find(t >= ttouch);

   T0 = 20;                    % ambient temperature
   T1 = get(obj,'control.setpoint');    % working temperature 
   
   target = get(obj,'control.target');  % control on Ttim or on Tt?
   relax = get(obj,'control.relax');    % relaxation threshold
   Tr = get(obj,'control.Tr');          % fading time constant
   
   [p_0,Tt0,Ttim0] = steady(target,A0,B0,C0,D0,T1,T1,T0);  
   [p_1,Tt1,Ttim1] = steady(target,A1,B1,C1,D1,T1,T1,T0);
   
   p0 = p_0;                   % initial power to hold working temp
   p1 = p_1;                   % steady power after touch down
   
   p(idx1) = p0 * one(idx1);   % initial heating power before touch down
   p(idx2) = p1 * one(idx2);   % steady power after touch down
                               % later 1403 W heating after touch down
   
   Tp(idx1) = 20 * one(idx1);  % ambient temperature before touch down
   Tp(idx2) = T1 * one(idx2);  % no pedestal temperature before touch down
                               % 50K over ambient (20°C) temperature (70°C) 

   Ta = T0 * one;              % 20°C ambient temperature
   
   u = [p; Tp; Ta];            % input signal vector
   x0 = [Tt1-T0; T0-T0];
   
   x = x0;          % initialize plant state
   Tmin = Tt1;      % init
   
   for (k = 1:length(t))
      uk = u(:,k);
      if (t(k) < ttouch)
         x = A0*x + B0*uk;
         y = C0*x + D0*uk;
      else
         x = A1*x + B1*uk;
         y = C1*x + D1*uk;
      end
      
      Tt(k) = y(1);  Ttim(k) = y(2);
      Tmin = min(Tmin,y(1));
      Tthresh = Tmin + (Tt1-Tmin)*relax;
      
      if (t(k) < ttouch)
         done = 0;    % not yet recovered
      elseif ((t(k) >= ttouch) && (Tt(k) < Tthresh) && k < length(t) && ~done)
         u(1,k+1) = max(p1,kboost*p0);
      elseif (k < length(t))
         done = 1;
         u(1,k+1) = p1 + [u(1,k)-p1] * exp(-Ts/Tr);
      end
   end

   kP = 1;  % p0/25;
   kRC = get(obj,'model.variation.kRC');
   
   cls;
   subplot(121);
   golden = goldenprofile(obj);
   color(plot(golden(1,:),golden(2,:)),'y',3);
   hold on;
   hdl = plot(t,T1*one,'k:', t,u(1,:)/kP,'r');
   hdl = plot(t,Tt,'m',  t,Ttim,'b');
   set(hdl,'linewidth',3)

   if (strcmp(target,'Tt'))
      Tend = Tt(end);  err = (Tend - Tt1)/Tt1;
   else
      Tend = Ttim(end);  err = (Tend - Ttim1)/Ttim1;
   end
   ovr = (max(Ttim) - Ttim(end)) / Ttim(end);  % overshoot error
   dTt_dt = diff(Tt)./ diff(t);
   slope = max(dTt_dt);
   islope = find(slope==dTt_dt);  islope = islope(1);
   tslope = t(islope); 
   
   title(sprintf([speed,' Recovery @ %g %% Contact area'],100*kRC));
   xlabel(sprintf('Boost factor: %g',kboost));
   set(gca,'ylim',[0 250]);
   
   subplot(122);   
   color(plot(golden(1,:),golden(2,:)),'y',3);
   hold on;
   hdl = plot(t,T1*one,'k:', t,u(1,:)/kP,'r');
   hdl = plot(t,Tt,'m',  t,Ttim,'b');
   plot(tslope,Tt(islope),'ro');
   N = round(1/Ts);
   plot([t(max(1,islope-N)),t(islope+N)],Tt(islope)+slope*[-N*Ts,N*Ts],'k');
   set(hdl,'linewidth',3)
   set(gca,'ylim',[T1-20,T1+10])
   title(sprintf(['Steady Err: %2.1g %%, Overshoot: %2.1g %%'],err*100,ovr*100));
   xlabel(sprintf('Max recovery slope: %g °C/s',round(slope*10)/10));
   shg

   return

%==========================================================================
   
function profile = goldenprofile(obj)
%
   obj = set(obj,'model.variation.kRC',0.8);              % 80% contact resistance
   
   Ts = get(obj,'model.Ts');                    % model sampling time
   Tmax = get(obj,'control.Tmax');              % max simulation time

   par = get(obj,'model.parameter');
   [A0,B0,C0,D0] = statemodel(obj,par.p,0,Ts);  % non touching thermodes
   [A1,B1,C1,D1] = statemodel(obj,par.p,1,Ts);  % touching thermodes
   
   t = (0:Ts:Tmax);
   one = ones(size(t));        % heating power 

   ttouch = 1.0;               % touch down time
   idx1 = find(t < ttouch);
   idx2 = find(t >= ttouch);

   T0 = 20;                    % ambient temperature
   T1 = get(obj,'control.setpoint');    % working temperature 
   
   target = get(obj,'control.target');  % control on Ttim or on Tt?
   
   [p_0,Tt0,Ttim0] = steady(target,A0,B0,C0,D0,T1,T1,T0);  
   [p_1,Tt1,Ttim1] = steady(target,A1,B1,C1,D1,T1,T1,T0);
   
   p0 = p_0;                   % initial power to hold working temp
   p1 = p_1;                   % steady power after touch down
   
   p(idx1) = p0 * one(idx1);   % initial heating power before touch down
   p(idx2) = p1 * one(idx2);   % steady power after touch down
                               % later 1403 W heating after touch down
   
   Tp(idx1) = 20 * one(idx1);  % ambient temperature before touch down
   Tp(idx2) = T1 * one(idx2);  % no pedestal temperature before touch down
                               % 50K over ambient (20°C) temperature (70°C) 

   Ta = T0 * one;              % 20°C ambient temperature
   
   u = [p; Tp; Ta];            % input signal vector
   x0 = [Tt1-T0; T0-T0];
   
   x = x0;          % initialize plant state
   
   for (k = 1:length(t))
      uk = u(:,k);
      if (t(k) < ttouch)
         x = A0*x + B0*uk;
         x(1) = T1 - T0;
         y = C0*x + D0*uk;
      else
         x = A1*x + B1*uk;
         x(1) = T1 - T0;
         y = C1*x + D1*uk;
      end
      
      Tt(k) = y(1);  Ttim(k) = y(2); 
      u(:,k) = uk;
   end

   kP = 1;  % p0/25;
   
   if (nargout == 0)
      cls;
      subplot(121);
      hdl = plot(t,T1*one,'k:');
      hold on;
      color(plot(t,Tt),'m',3);
      color(plot(t,Ttim),'y',3);

      if (strcmp(target,'Tt'))
         Tend = Tt(end);  err = (Tend - Tt1)/Tt1;
      else
         Tend = Ttim(end);  err = (Tend - Ttim1)/Ttim1;
      end
      ovr = (max(Ttim) - Ttim(end)) / Ttim(end);  % overshoot error
   
      kRC = get(obj,'model.variation.kRC');
      
      title(sprintf(['Golden Profile @ %g %% Contact Area'],100*kRC));
      set(gca,'ylim',[0 250]);
   
      subplot(122);   
      hdl = plot(t,T1*one,'k:');
      hold on;
      color(plot(t,Ttim),'y',3);

      set(gca,'ylim',[T1-20,T1+10])
      title(sprintf(['Steady Err: %2.1g %%, Overshoot: %2.1g %%'],err*100,ovr*100));
      shg
   end
   
   profile = [t;Ttim];
   return

%=========================================================================
% Open Loop Thermalization Control
%=========================================================================

function thermalization(obj,mode,Tpl,titletext)
%
   Ts = setting('model.Ts');                    % model sampling time
   Tmax = setting('control.Tmax');              % max simulation time


   par = setting('model.parameter');
   [A0,B0,C0,D0] = statemodel(obj,par.p,0,Ts);  % non touching thermodes
   [A1,B1,C1,D1] = statemodel(obj,par.p,1,Ts);  % touching thermodes
   
   t = (0:Ts:Tmax);
   one = ones(size(t));        % heating power 

   ttouch = 1.0;               % touch down time
   idx1 = find(t < ttouch);
   idx2 = find(t >= ttouch);

   %RH = par.p(1);              % thermode ambient resistance
   kPL = get(obj,'control.kPL');
   
   T0 = 20;                    % ambient temperature
   T1 = 150;                   % working temperature 
   T2 = Tpl*kPL;               % preload temperature
   
   target = setting('control.target');  % control on Ttim or on Tt?
   
   [p_0,Tt0,Ttim0] = steady(target,A0,B0,C0,D0,T2,T1,T0);  
   [p_1,Tt1,Ttim1] = steady(target,A1,B1,C1,D1,T1,T1,T0);
   
   p0 = p_0;                   % initial power to hold working temp
   if (mode == 0)
      p1 = 0;  % p_1;          % steady power after touch down
   elseif (mode == 1)
      p1 = p_1;                % steady power after touch down
   else
      p1 = 2*p_1;              % steady power after touch down
   end
          
   p(idx1) = p0 * one(idx1);   % initial heating power before touch down
   p(idx2) = p1 * one(idx2);   % steady power after touch down
                               % later 1403 W heating after touch down
   
   Tp(idx1) = 20 * one(idx1);  % ambient temperature before touch down
   Tp(idx2) = T1 * one(idx2);  % no pedestal temperature before touch down
                               % 50K over ambient (20°C) temperature (70°C) 

   Ta = T0 * one;              % 20°C ambient temperature
   
   u = [p; Tp; Ta];            % input signal vector
                  
   
   %x0 = par.x0;
   x0 = [T2-T0; T0-T0];
   
   x = x0;          % initialize plant state
   
   for (k = 1:length(t))
      if (t(k) < ttouch)
         y = C0*x + D0*u(:,k);
         x = A0*x + B0*u(:,k);
      else
         y = C1*x + D1*u(:,k);
         x = A1*x + B1*u(:,k);
      end
      
      Tt(k) = y(1);  Ttim(k) = y(2);
      
      if (t(k) < ttouch)
         done = 0;    % not yet recovered
      elseif ((t(k) >= ttouch) && (Tt(k) < Tt1) && k < length(t) && ~done)
         u(1,k+1) = 5*p0;
      elseif (k < length(t))
         done = 1;
         u(1,k+1) = p1 + [u(1,k)-p1] * exp(-Ts/0.3);
      end
      
   end

   kP = p0/25;
   
   if (mode == 0) cls; end
   
   subplot(121)
   hdl = plot(t,T1*one,'k:', t,u(1,:)/kP,'r');
   hold on;
   hdl = plot(t,Tt,'m',  t,Ttim,'b');
   set(hdl,'linewidth',3)
   title(titletext);

   subplot(122)
   hdl = plot(t,T1*one,'k:', t,u(1,:)/kP,'r');
   hold on;
   hdl = plot(t,Tt,'m',  t,Ttim,'b');
   set(hdl,'linewidth',3)

   Ttarget = iif(strcmp(target,'Tt'),Tt,Ttim);
   Tend = Ttarget(end);
   err = (Tend - T1)/T1;
   ovr = (max(Ttim) - Ttim(end)) / Ttim(end);  % overshoot error
   title(sprintf('Steady Err: %2.1g %%, Overshoot: %2.1g %%',...
                 err*100,ovr*100));

   set(gca,'ylim',[140 160]);
   shg

   return

%=========================================================================
% Closed Loop Thermalization Control
%=========================================================================

function pidcontrol(obj,mode,Tpl,tit)
%
   Ts = get(obj,'model.Ts');                    % model sampling time
   Tf = get(obj,'control.Tf');                  % fade sampling time
   Tmax = get(obj,'control.Tmax');              % max simulation time

   par = setting('model.parameter');
   [A0,B0,C0,D0] = statemodel(obj,par.p,0,Ts);  % non touching thermodes
   [A1,B1,C1,D1] = statemodel(obj,par.p,1,Ts);  % touching thermodes
   
   t = (0:Ts:Tmax);
   one = ones(size(t));        % heating power 

   ttouch = 1.0;               % touch down time
   idx1 = find(t < ttouch);
   idx2 = find(t >= ttouch);

   kPL = get(obj,'control.kPL');
   delay = get(obj,'control.delay');
   
   T0 = 20;                    % ambient temperature
   T1 = setting('control.setpoint');  % was 150; working temperature 
   Tpl = Tpl + T1-150;
   T2 = Tpl*kPL;               % preload temperature
   
   target = 'Tt';              % control on Tt!
   
   [p_0,Tt0,Ttim0] = steady(target,A0,B0,C0,D0,T2,T1,T0);  
   [p_1,Tt1,Ttim1] = steady(target,A1,B1,C1,D1,T1,T1,T0);

   Tp(idx1) = 20 * one(idx1);  % ambient temperature before touch down
   Tp(idx2) = T1 * one(idx2);  % no pedestal temperature before touch down
                               % 50K over ambient (20°C) temperature (70°C) 

   x0 = [T2-T0; T0-T0];
   
   x = x0;                     % initialize plant state
   
         % controller parameters
      
   DT = get(obj,'control.DT'); % off switch temperature difference
   Tr = get(obj,'control.Tr'); % reference time constant
   Ti = get(obj,'control.Ti'); % integration time constant
   Kp = get(obj,'control.Kp'); % controller proportional constant
   I0 = get(obj,'control.I0'); % integrator pre-set
   
   Aw = exp(-Tf/Tr);          % eigen value for reference generation

   setpoint = T2;

   umin = get(obj,'control.umin');
   umax = get(obj,'control.umax');

      % Simulation Loop
      
   u = [p_0; Tp(1); T0];           % init
   y = C0*x + D0*u;                % init
   ik = u(1);                      % init integral part 
   uk = ik;
   
   for (k = 1:length(t))
      yk = y(1);  tk = t(k);

      if (tk < ttouch+delay)
         setpoint = Tt1;              % prepare new setpoint
         wk = T2 - setpoint;          % initial value of fade signal
         tfade = 0;
      else
         if (tfade < ttouch+delay)
            tfade = tk - 100*eps;     % avoid rounding effects
         end
         if (tk >= tfade)
            wk = Aw * wk;             % decline fade signal
            tfade = tk + Tf - 100*eps;% fading sampling timing
         end
      end
      
         % controller 

      rk = setpoint + wk;             % setpoint + wk;
      ek = rk - yk;

      ik = ik + Ts/Ti * ek;           % R(s) = Kp + 1/sTi     
      ik = max(umin,min(ik,umax));    % anti wind-up
      %uk = Kp * (ek + ik);           % R1(s) = Kp * (1 + 1/sTi)
      uk = ik + Kp * ek;
      uk = max(umin,min(uk,umax));    % constraints for control signal
      
      u(:,k) = [uk; Tp(k); T0];
      
         % plant transition
       
      if (t(k) < ttouch)
         y = C0*x + D0*u(:,k);
         x = A0*x + B0*u(:,k);
      else
         y = C1*x + D1*u(:,k);
         x = A1*x + B1*u(:,k);
      end
      
      Tt(k) = y(1);  Ttim(k) = y(2); Tw(k) = wk;
      yy(k) = yk;  e(k) = ek;  i(k) = ik;  r(k) = rk;
   end

   global Log Legend;
   Log = [t; yy; r; e; i; u(1,:)];
   Legend = '[t; y; r; e; i; u]';
   
   kP = 1;   % p0/25;
   
   
   %if (mode == 0) cls; end
   
   subplot(121)
   golden = goldenprofile(obj);
   color(plot(golden(1,:),golden(2,:)),'y',3);
   hold on
   plot(golden(1,:),golden(2,:),'r:');
   hdl = plot(t,Tt,'m',  t,Ttim,'b');
   set(hdl,'linewidth',1)
   hdl = plot(t,T1*one,'k:', t,u(1,:)/kP,'r', t,Tw,'g',t,Tw+setpoint,'g');
   plot(ttouch*[1 1],[T0 T2],'k:');
   plot((ttouch+delay)*[1 1],[T1 T2],'k:');
   title(tit);  ylabel('Tref: green, TT: magenta, TTIM: blue')
   set(gca,'ylim',[0 180+T1-150]);

   subplot(122)
   color(plot(golden(1,:),golden(2,:)),'y',3);
   hold on;
   plot(golden(1,:),golden(2,:),'r:');
   hdl = plot(t,T1*one,'k:', t,u(1,:)/kP,'r', t,Tw,'g',t,Tw+setpoint,'g');
   hdl = plot(t,Tt,'m',  t,Ttim,'b');
   set(hdl,'linewidth',1)
   plot(ttouch*[1 1],[T0 T2],'k:');
   plot((ttouch+delay)*[1 1],[T1 T2],'k:');
   set(gca,'ylim',[140 160]);

   Tend = Tt(end);
   err = (Tend - T1)/T1;
   ovr = (max(Ttim) - Ttim(end)) / Ttim(end);  % overshoot error
   devi = (Tt(end) - Ttim(end)) / Tt(end);     % steady deviation Tt - Ttim
   title(sprintf('Steady Err: %2.1g %%, Overshoot: %2.1g %%',...
                 err*100,ovr*100));
   set(gca,'ylim',[140 T1+20]);
   xlabel(sprintf('Deviation (Tt-Ttim): %2.1g %%',devi*100));
   
   subplot(121);  % switch back to 1st subplot to enable xlabels
   kRC = get(obj,'model.variation.kRC');
   xlabel(sprintf('%g %% Contact area',100*kRC));
   shg
   
   return

%eof   
   