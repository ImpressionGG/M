function [K0,f0,K180,f180,L0] = critical(o,cdx,sub,crit)               
%
%  CRITICAL   Calculate or plot critical stability parameters K0 (critical
%             open loop gain) and f0 (critical frequency)
%
%                critical(o)      % plot critical stability charts
%                critical(o,cdx)  % plot for specific contact indices
%
%             Plotting specific diagrams. Argument crit specifies whether
%             principal spectrum lambda0|lambda180 is used for analysis
%             or critical spectrum gamma0|gamma180, where 
%
%                gamma0 := K0*lambda0
%                gamma180 := K180*lambda180
%
%             Diagram Plotting
%
%                critical(o,'Overview',[sub1,sub2,sub3],crit);
%                critical(o,'Damping',[sub0,sub180],crit);
%                critical(o,'Bode',[sub1,sub2],crit);
%                critical(o,'Magni',sub,crit);
%                critical(o,'Phase',sub,crit);
%                critical(o,'Nichols',sub,crit);
%
%             Calculate principal system and critical qantities 
%
%                [K0,f0,K180,f180,L0] = critical(o)
%                [K0,f0,K180,f180,L0] = critical(o,cdx)  % contact index
%
%             Calculate lower boundary of K0
%
%                K0min = critical(o,'K0min');
%
%             Options:
%                gain.low         % minimum gain (default: 1e-3)
%                gain.high        % maximum gain (default: 1e+3)
%                gain.points      % number of gain points
%
%                search           % number of search points (default 50)
%                eps              % termination epsilon (default 1e-10)
%                iter             % max iterations (default 50)
%                check            % check crit. quantities (0: off, 1: weak
%                                 % 2: strong - default 1)
%                algo             % algorithm to calculate critical
%                                 % quantities (default: 'fqr')
%                                 % 'fqr': frequency response
%                                 % 'eig': eigenvalue based
%                mu               % alternative plots if provided
%                stop             % stops on user request (default: false)
%
%             Copyright(c): Bluenetics 2021
%
%             See also: SPM, CONTACT, PRINCIPAL
%
   if type(o,{'spm'})
      %o = cache(o,o,'multi');          % refresh multi segment
   else
      error('SPM object expected');
   end
   
   if (nargin < 4)
      crit = 0;
   end
   
      % lower boundary for critical gain
      
   if (nargin == 2 && isequal(cdx,'K0min'))
      K0 = LowerBoundary(o);
      return
   end
   
      % calculate contact related system (oo) and principal system (L0)
      
   if (nargout == 0 || nargin == 1)
      oo = system(o);
   elseif (nargout > 0)
      oo = system(o,cdx);
   end
   L0 = principal(o,oo);               % calc L0 from oo

      % handle plot modes
      
   if (nargout == 0)
      if (nargin < 2)
         mode = 'Overview';
      else
         mode = cdx;
      end
      
      if (nargout < 3 && nargin < 3)
         sub = [];
      end
      
      switch mode
         case 'Overview'
            if (length(sub) < 3)
               sub = [311,312,313, 0,0,0];
            end
            if (sub(1) || sub(2))
               Bode(o,oo,L0,sub(1:2),+1,crit);    % plot critical parameter overview
               Damping(o,oo,L0,sub(3));
            end
            if (length(sub) >= 4 && (sub(4) || sub(5)))
               L180 = Negate(L0);
               Bode(o,oo,L180,[sub(4:5),0],-1,crit); % plot critical parameter overview
               Damping(o,oo,L0,[0 sub(6)]);
            end
         case 'Bode'
            if (length(sub) < 2)
               sub = [211,212,0,0];
            elseif (length(sub) < 4)
               sub(6) = 0;
            end
            
            if (sub(1) || sub(2))
               Bode(o,oo,L0,sub(1:2),+1,crit); % plot critical parameter overview
            end
            if (sub(3) || sub(4))
               L180 = Negate(L0);
               Bode(o,oo,L180,sub([3 4]),-1,crit); % plot critical parameter overview
            end
         case 'Magni'
            if (length(sub) < 1)
               sub = [111];
            end
            if (length(sub) < 2)
               sub = [sub 0];
            end
            
            if sub(1)
               Bode(o,oo,L0,[sub(1) 0],+1,crit);   % plot magnitude (forward)
            end
            if sub(2)
               L180 = Negate(L0);
               Bode(o,oo,L180,[sub(2) 0],-1,crit); % plot magnitude (revers)
            end
         case 'Phase'
            if (length(sub) < 1)
               sub = [111];
            end
            if (length(sub) < 2)
               sub = [sub 0];
            end
            
            if sub(1)
               Bode(o,oo,L0,[0 sub(1)],+1,crit);   % plot magnitude (forward)
            end
            if sub(2)
               L180 = Negate(L0);
               Bode(o,oo,L180,[0 sub(2)],-1,crit); % plot magnitude (revers)
            end
         case 'Damping'
            if (length(sub) == 1)
               sub = [111,0];
            end
            Damping(o,oo,L0,sub);      % plot critical parameter overview
         case 'K0min'
            K0 = LowerBoundary(o);
         case 'Nichols'
            if (length(sub) < 1)
               sub = [111];
            end
            if (length(sub) < 2)
               sub = [sub 0];
            end
            
            if sub(1)
               Nichols(o,oo,L0,[sub(1) 0],+1,crit); % Nichols plot (fwd)
            end
            if sub(2)
               L180 = Negate(L0);
               Nichols(o,oo,L180,[sub(2) 0],-1,crit); % Nichols plot (rev)
            end
     end
   elseif (nargout <= 2)
      [K0,f0] = Calc(o,oo,L0);         % calculate some critical parameters
   else
      [K0,f0,K180,f180]=Calc(o,oo,L0); % calculate all critical parameters
   end
end

%==========================================================================
% Calculate
%==========================================================================

function [K0,f0,K180,f180] = Calc(o,oo,L0)       % Calculate Crit.Val's
   algo = opt(o,{'algo','fqr'});
   
   switch algo
      case 'fqr'
         if (nargout <= 2)
            [K0,f0] = CalcFqr(o,oo,L0);
         else
            [K0,f0,K180,f180] = CalcFqr(o,oo,L0);
         end
         
      case 'eig'
         if (nargout <= 2)
            [K0,f0] = CalcEig(o,oo,L0);
         else
            [K0,f0,K180,f180] = CalcEig(o,oo,L0);
         end
         
      otherwise
         fprintf('*** bad algo => using EIG algorithm\n');
         if (nargout <= 2)
            [K0,f0] = CalcEig(o,oo,L0);
         else
            [K0,f0,K180,f180] = CalcEig(o,oo,L0);
         end
   end
end
function [K0,f0,K180,f180] = CalcFqr(o,oo,L0)    % Frequency Based     
   [K0,f0,K180,f180,err] = Critical(o,oo);
   
   check = opt(o,{'check',2});
   if (check >= 1 )
      if (check == 2)
         [K0_,f0_] = Stable(o,L0);
      else
         [K0_,f0_] = Stable(o,L0,K0);
      end
      
      err = norm([K0-K0_,f0-f0_]);
      if (err > 1e-6)
         fprintf('*** numerical struggles during K0,f0 calculation: err = %g\n',err);
      end
      
      if (nargout > 2)
         L180 = Negate(L0); 
         if (check == 2)
            [K180_,f180_] = Stable(o,L180);
         else
            [K180_,f180_] = Stable(o,L180,K180);
         end

         err = norm([K180-K180_,f180-f180_]);
         if (err > 1e-6)
            fprintf('*** numerical struggles during K180,f180 calculation: err = %g\n',err);
         end
      end
   end
end
function [K0,f0,K180,f180] = CalcEig(o,oo,L0)    % Eigenvalue Based    
   [K0,f0] = Stable(o,L0);
    
   if (nargout > 2 && ~stop(o,o))
      L180 = Negate(L0); 
      [K180,f180] = Stable(o,L180);
   end
   
      % pay attention to a user stop request, which means that all 
      % intermediate results have to be invalidated with immediate return
      
   if stop(o,o)                        % stop option controlled
      K0 = [];  f0 = [];  K180 = [];  f180 = [];
      return
   end
   
      % otherwise continue processing ...
      
   check = opt(o,{'check',2});
   if (check >= 1 )
      tol = opt(o,{'critical.eps',1e-12});
      iter = opt(o,{'critical.iter',100});

      [A,B_1,B_3,C_3,T0] = var(oo,'A,B_1,B_3,C_3,T0');
      PsiW31 = psion(o,A,B_1,C_3);     % to calculate G31(jw)
      PsiW33 = psion(o,A,B_3,C_3);     % to calculate G33(jw)
      
      [K,Omega,err] = Pass(o,PsiW31,PsiW33,2*pi*f0*T0*[0.990,1.001],1,tol,iter);
      K0_ = K;  f0_ = Omega/(2*pi*T0);

      err = norm([K0-K0_,f0-f0_]);
      if (err > 1e-6)
         fprintf('*** numerical struggles during K0,f0 calculation: err = %g\n',err);
      end
      
      if (nargout > 2)
         [K,Omega,err] = Pass(o,PsiW31,PsiW33,2*pi*f180*T0*[0.990,1.001],-1,tol,iter);
         K180_ = K;  f180_ = Omega/(2*pi*T0);

         err = norm([K180-K180_,f180-f180_]);
         if (err > 1e-6)
            fprintf('*** numerical struggles during K180,f180 calculation: err = %g\n',err);
         end
      end
   end
 
   function L = Negate(L)
      L.data.B = -L.data.B;
      L.data.D = -L.data.D;
   end
end

%==========================================================================
% Plot Overview
%==========================================================================

function o = Damping(o,oo,L0,sub)           % Damping Plot             
   if isempty(sub)
      sub = [211,212];
   end
   if (length(sub) == 1)
      sub = [sub 0];
   end
   
   mu = opt(o,'mu');                   % get friction coefficient
   gain = abs(o.either(mu,1));
   
   if (sub(1) ~= 0)
      L = Gain(L0,gain);
      [K0,f0] = PlotStability(o,L,sub(1),'0',mu);
   end
   if (sub(2) ~= 0)
      L = Gain(L0,-gain);
      [K180,f180] = PlotStability(o,L,sub(2),'180',-mu);
   end
   
   function L = Gain(L,gain)
      L.data.B = gain * L.data.B;
      L.data.D = gain * L.data.D;
   end
end
function Bode(o,oo,L0,sub,cutting,crit)     % Bode Plot                
   if (length(sub) < 2)
      sub = [211,212,0,0];
   end

   [A,B_1,B_3,C_3,T0] = var(oo,'A,B_1,B_3,C_3,T0');

   if (cutting > 0)
      [K0,f0] = cook(o,'K0,f0');
      tag = '0';
   elseif (cutting < 0)
      [K0,f0] = cook(o,'K180,f180');
      tag = '180';
   end
   
   m = size(C_3,1);
   multi = (m > 1);                 % multi contact
   
   if isequal(K0,inf)
      set(gca,'ylim',[-5 5]);
      subplot(o,312);
      message(o,'No instabilities - skip frequency analysis!');
      return
   end
      
   olo = opt(o,{'omega.low',100});
   ohi = opt(o,{'omega.high',1e5});
   points = opt(o,{'omega.points',2000});

   om = logspace(log10(olo),log10(ohi),points);
   Om = om*T0;                      % time normalized omega
   f = om/2/pi;                     % frequency range
   
   L0jw = zeros(m,length(om));  G31jw = L0jw;  G33jw = L0jw; 

      % calculate G31(jw), G33(jw) and L0(jw)

   i123 = (1:m)';
   kmax = length(om);
      
%L0jW = cook(o,'lambda0jw');    

   L0jw = lambda(o,A,B_1,B_3,C_3,Om);
   
      % calculate phases phi31,phi33 and phi=phi31-phi33

   kf0 = min(find(f>=f0));   
   phi = angle(o,L0jw,kf0);
         
      % calculate critical frequency response
      
   [L0jw0,G31jw0,G33jw0] = Lambda(o,A,B_1,B_3,C_3,2*pi*f0*T0);
   phi0 = mod(angle(L0jw0),2*pi) - 2*pi;
   
      % search characteristic frequency response with best matching
      % |N(jw)| = |1+K0*L0[k](jw0) = 1
      
   M = abs(1 + K0*L0jw0);              % magnitude of Nyquist FQR
   nyqerr = min(M);                    % Nyquist error
   
      % now find index k0 that approximates 1 + K0*L0jw =~= 0
      
   idx = min(find(f>=f0));
   M = abs(1 + K0*L0jw(:,idx));
   aprerr = min(M);                    % approximate Nyquist error
   k0 = min(find(M==aprerr));          % indexing critical characteristics
   
      % get critical characteristics
   
   %if (sub(1) ~= 0 && sub(2) ~= 0)
      lk0jw = L0jw(k0,:);                 % critical characteristics 
      phil0 = angle(o,lk0jw,kf0);
      l0jw = lambda(o,L0jw);

      BodePlot(o,l0jw,sub(1),sub(2),crit);% plot intermediate results

      M31 = abs(G31jw0(k0));              % coupling gain
      phi31 = angle(G31jw0(k0));          % coupling phase      

      M33 = abs(G33jw0(k0));              % direct gain
      phi33 = angle(G33jw0(k0));          % direkt phase      

      ML0 = abs(L0jw0(k0));               % critical gain
      phi0 = angle(L0jw0(k0));            % critical phase      

      [K0_,f0_] = Stable(o,L0,K0); 
      Results(o,sub(1),sub(2));           % display results
   %end
   
   
   heading(o);
         
   function BodePlot(o,l0jw,sub1,sub2,crit)
      if dark(o)
         colors = {'rk','gk','b','ck','mk'};
      else
         colors = {'rwww','gwww','bwww','cwww','mwww'};
      end
      
      if (sub1)
         subplot(o,sub1,'semilogx');
         set(gca,'visible','on');
      
            % magnitude plot  
      
         K = o.iif(crit,K0,1);
         
         for (ii=1:size(L0jw,1))
            col = colors{1+rem(ii-1,length(colors))};
            plot(o,om,20*log10(abs(K*L0jw(ii,:))),col);
         end
         
         col = o.iif(crit,'r2','ryyy2');
         plot(o,om,20*log10(abs(K*l0jw)),col);         
         plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'K1-.');
         plot(o,2*pi*f0,-20*log10(K0/K),'K1o');

         name = o.iif(crit,'C0(s)=K0*G31(s)/G33(s)','L0(s)=G31(s)/G33(s)');
         title(sprintf('%s: Magnitude Plots (K0: %g @ %g Hz)',name,K0,f0));
         xlabel('Omega [1/s]');
         ylabel('|L0[k](jw)| [dB]');
         subplot(o);
      end
      
         % phase plot
         
      if (sub2)
         subplot(o,sub2,'semilogx');
         set(gca,'visible','on');

         plot(o,om,0*f-180,'K');
         for (ii=1:size(L0jw,1))
            col = colors{1+rem(ii-1,length(colors))};
            plot(o,om,phi(ii,:)*180/pi,col);
         end

         plot(o,om,phil0*180/pi,o.iif(crit,'r2','yyyr2'));

         plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'K1-.');
         plot(o,2*pi*f0,-180,'K1o');

         subplot(o);  idle(o);  % give time to refresh graphics
         xlabel('Omega [1/s]');
         ylabel('L0[k](jw): Phase [deg]');
      end
   end
   function Results(o,sub1,sub2)
      s0 = CritEig(o,L0,K0);
      err = norm([K0-K0_,f0-f0_,real(s0)]);
      
      if (crit)
         name = o.iif(cutting>0,'gamma0(jw)','gamma180(jw)');
      else
         name = o.iif(cutting>0,'lambda0(jw)','lambda180(jw)');
      end
      
      if (sub1)
         subplot(o,sub1);
         title(sprintf(['%s: Magnitude Plot - K%s: ',...
                        '%g @ %g Hz (EV error: %g)'],name,tag,K0_,f0_,err));

         txt = sprintf('G31(jw0): %g nm/N @ %g deg, G33(jw0): %g nm/N @ %g deg',...
               Rd(M31*1e9),Rd(phi31*180/pi),...
               Rd(M33*1e9),Rd(phi33*180/pi));
         xlabel(txt);
         K = o.iif(crit,K0,1);
         limits(o,'Magni',K);
         subplot(o);
      end
      
      if (sub2)
         subplot(o,sub2);
         title(sprintf('%s: Phase Plot (Nyquist error: %g)',name,nyqerr));
         plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'r1-.');
         plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'K1-.');
         xlabel(sprintf('omega [1/s]      (G31(jw0)/G33(jw0): %g @ %g deg)',...
                o.rd(M31/M33,2),Rd((phi31-phi33)*180/pi)));
         subplot(o);
      end
   end

   function y = Rd(x)                  % round to 1 decimal
      ooo = corazon;
      y = ooo.rd(x,1);
   end
end
function Nichols(o,oo,L0,sub,cutting,crit)  % Nichols Plot             
   if (length(sub) < 2)
      sub = [211,212,0,0];
   end

   [A,B_1,B_3,C_3,T0] = var(oo,'A,B_1,B_3,C_3,T0');

   if (cutting > 0)
      [K0,f0] = cook(o,'K0,f0');
      tag = '0';
   elseif (cutting < 0)
      [K0,f0] = cook(o,'K180,f180');
      tag = '180';
      B_1 = -B_1;  B_3 = -B_3;
   end
   
   m = size(C_3,1);
   multi = (m > 1);                 % multi contact
   
   if isequal(K0,inf)
      set(gca,'ylim',[-5 5]);
      subplot(o,312);
      message(o,'No instabilities - skip frequency analysis!');
      return
   end
      
   olo = opt(o,{'omega.low',100});
   ohi = opt(o,{'omega.high',1e5});
   points = opt(o,{'omega.points',2000});

   om = logspace(log10(olo),log10(ohi),points);
   Om = om*T0;                      % time normalized omega
   f = om/2/pi;                     % frequency range
   
   L0jw = zeros(m,length(om));  G31jw = L0jw;  G33jw = L0jw; 

      % calculate G31(jw), G33(jw) and L0(jw)

   i123 = (1:m)';
   kmax = length(om);
      
%L0jW = cook(o,'lambda0jw');    

   L0jw = lambda(o,A,B_1,B_3,C_3,Om);
    
      % calculate phases phi31,phi33 and phi=phi31-phi33

   kf0 = min(find(f>=f0));   
   phi = angle(o,L0jw,kf0);
         
      % calculate critical frequency response
      
   [L0jw0,G31jw0,G33jw0] = Lambda(o,A,B_1,B_3,C_3,2*pi*f0*T0);
   phi0 = mod(angle(L0jw0),2*pi) - 2*pi;
   
      % search characteristic frequency response with best matching
      % |N(jw)| = |1+K0*L0[k](jw0) = 1
      
   M = abs(1 + K0*L0jw0);              % magnitude of Nyquist FQR
   nyqerr = min(M);                    % Nyquist error
   
      % now find index k0 that approximates 1 + K0*L0jw =~= 0
      
   idx = min(find(f>=f0));
   M = abs(1 + K0*L0jw(:,idx));
   aprerr = min(M);                    % approximate Nyquist error
   k0 = min(find(M==aprerr));          % indexing critical characteristics
   
      % get critical characteristics
   
   %if (sub(1) ~= 0 && sub(2) ~= 0)
      lk0jw = L0jw(k0,:);                 % critical characteristics 
      phil0 = angle(o,lk0jw,kf0);
      l0jw = lambda(o,L0jw);

      NicholsPlot(o,l0jw,K0,sub(1),sub(2),crit);% plot intermediate results

      M31 = abs(G31jw0(k0));              % coupling gain
      phi31 = angle(G31jw0(k0));          % coupling phase      

      M33 = abs(G33jw0(k0));              % direct gain
      phi33 = angle(G33jw0(k0));          % direkt phase      

      ML0 = abs(L0jw0(k0));               % critical gain
      phi0 = angle(L0jw0(k0));            % critical phase      

      [K0_,f0_] = Stable(o,L0,K0); 
      Results(o,sub(1),sub(2));           % display results
   %end
   
   
   heading(o);
         
   function NicholsPlot(o,l0jw,K0,sub1,sub2,crit)                      
      if dark(o)
         colors = {'rk','gk','b','ck','mk'};
      else
         colors = {'rwww','gwww','bwww','cwww','mwww'};
      end
      
      K = o.iif(crit,K0,1);
      tag = o.iif(cutting>0,'0','180');
      name = o.iif(crit,'gamma','lambda');
      
      if (sub1)
         subplot(o,sub1);
         set(gca,'visible','on');
      
            % magnitude plot  
      
         for (ii=1:size(L0jw,1))
            col = [colors{1+rem(ii-1,length(colors))},'1'];
            plot(o,phi(ii,:)*180/pi,20*log10(abs(K*L0jw(ii,:))),col);
         end
         if 0
            plot(o,phil0*180/pi,20*log10(abs(K*l0jw)),'ryyy2');
         end
%        plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'K1-.');
%        plot(o,2*pi*f0,-20*log10(K0),'K1o');

         title(sprintf('%s%s(jw): Nichols Plots (K0: %g @ %g Hz)',...
                       name,tag,K0,f0));
         xlabel('phase [deg]');
         ylabel('|L0[k](jw)| [dB]');
         
            % limit calculation seems complicated, but xlim has 
            %  irelevant values when graphics is zoomed in
            
         plim = [min(phi(:)),max(phi(:))]*180/pi;
         xlim = get(gca,'xlim');
         xlim = [min(xlim(1),plim(1)), max(xlim(2),plim(2))];
         
            % draw critical points

         phi0 = -180;
         while (phi0 >= xlim(1))
            phi0 = phi0 - 360;
         end
         for (phi = phi0+360:360:100*180)
            hdl = plot(phi,0,'p');
            if (phi==-180)
               set(hdl,'color','r', 'linewidth',1);
               plot(phi,0,'y.');
            else
               set(hdl,'color',o.iif(dark(o),'w','k'), 'linewidth',1);
            end
            if (phi+360>xlim(2))
               break;
            end
         end
         
         subplot(o);
      end
   end
   function Results(o,sub1,sub2)
      s0 = CritEig(o,L0,K0);
      err = norm([K0-K0_,f0-f0_,real(s0)]);
      
      if (crit)
         name = o.iif(cutting>0,'gamma0(jw)','gamma180(jw)');
      else
         name = o.iif(cutting>0,'lambda0(jw)','lambda180(jw)');
      end
      
      if (sub1)
         subplot(o,sub1);
         title(sprintf(['%s: Nichols Plot - K%s: ',...
                   '%g @ %g Hz (EV error: %g)'],name,tag,K0_,f0_,err));

         txt = sprintf('G31(jw0): %g nm/N @ %g deg, G33(jw0): %g nm/N @ %g deg',...
               Rd(M31*1e9),Rd(phi31*180/pi),...
               Rd(M33*1e9),Rd(phi33*180/pi));
         xlabel(txt);
         
         K = o.iif(crit,K0,1);
         limits(o,'Magni',K);
         subplot(o);
      end
      
      if (sub2)
         subplot(o,sub2);
         title(sprintf('%s: Phase Plot (Nyquist error: %g)',name,nyqerr));
         plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'r1-.');
         plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'K1-.');
         xlabel(sprintf('omega [1/s]      (G31(jw0)/G33(jw0): %g @ %g deg)',...
                o.rd(M31/M33,2),Rd((phi31-phi33)*180/pi)));
         subplot(o);
      end
   end

   function y = Rd(x)                  % round to 1 decimal
      ooo = corazon;
      y = ooo.rd(x,1);
   end
end

%==========================================================================
% Frequency Response
%==========================================================================

function [L0jw,G31jw,G33jw] = Lambda(o,A,B_1,B_3,C_3,om) % Lambda FQR's

   n = length(om);
   for (k=1:n)
      jw = 1i*om(k);
      I=eye(size(A));                     % unit matrix
      Phi = inv(jw*I-A);
      G31jw = C_3*Phi*B_1;
      G33jw = C_3*Phi*B_3;
      L0jw = G33jw\G31jw;

         % in multi contact case replace:
         % - G31jw by 'largest' eigenvalue of G31jw
         % - G33jw by 'smallest' eigenvalue of G33jw
         % - L0jw  by 'largest' eigenvalue  of L0jw

      m = length(L0jw);                        % number of contacts
      if (m > 1)                               % multi contact
         s31 = eig(G31jw);                     % eigenvalues (EV) of G31(jwk)
         [~,idx] = sort(abs(s31),'descend');   % get sorting indices
         G31jw = s31(idx);                     % pick 'largest' eigenvalues

         s33 = eig(G33jw);                     % eigenvalues (EV) of G33(jwk)
         [~,idx] = sort(abs(s33),'ascend');    % get sorting indices
         G33jw = s33(idx);                     % pick 'smallest' eigenvalues

         s0 = eig(L0jw);                       % eigenvalues of L0(jwk) 
         [~ ,idx] = sort(abs(s0),'descend');   % sort EV's by magnitude
         L0jw = s0(idx);                       % pick 'largest' eigenvalues
      end
   end
   
   if (n > 1)
      L0jw = Rearrange(L0jw);
   end
end
function L = Rearrange(L)              % Rearrange FQR (obsolete)      
%
% REARRANGE   Rearrange characteristic frequency responses in order to
%             obtain smooth graphs.
%
   [m,n] = size(L);
   if (n <= 1)
      return                           % nothing to re-arrange
   end
   
   one = ones(m,1);
   void = one*inf;
   
   for (k=2:n)
      x = L(:,k-1);  y = L(:,k);
      M = abs(y*one' - one*x.');       % magnitude change matrix

      px = angle(x);  py = angle(y);
      P = py*one' - one*px.';          % phase difference matrix
      P = abs(mod(P+pi,2*pi) - pi);    % phase change matrix, maps to [0,pi]

      % D matrix (deviations) is be a mix of magnitude changes M and
      % phase changes P
      
      D = M/norm(M) + P/norm(P);       % mix them together
      
      idx = void;
      for (l=1:m)
         row = min(D);
         j = min(find(row==min(row))); % target index
         col = D(:,j);
         i = min(find(col==min(col))); % source index
         
            % note: i-th element moves to j-th position
            
         idx(j) = i;                   % ith index equals j
         D(i,:) = void';               % ith row out of game
         D(:,j) = void;                % jth column out of game
         
       end
       L(:,k) = L(idx,k);
   end
end
function [L,idx] = TailSort(L,om)      % Sort Tail of FQR              
%
% TAILSORT    Rearrange characteristic frequency responses in order to
%             obtain smooth graphs.
%
   [m,n] = size(L);
   if (n <= 1)
      idx = (1:m)';
      return                        % nothing to sort
   end
   
   one = ones(m,1);
   void = one*inf;
   
   x = L(:,end-1);  y = L(:,end);
   M = abs(y*one' - one*x.');       % magnitude change matrix
   
   px = angle(x);  py = angle(y);
   P = py*one' - one*px.';          % phase difference matrix
   P = abs(mod(P+pi,2*pi) - pi);    % phase change matrix, maps to [0,pi]
   
      % D matrix (deviations) is be a mix of magnitude changes M and
      % phase changes P
      
   D = M/norm(M) + P/norm(P);       % mix them together
   
   idx = void;
   for (l=1:m)
      row = min(D);
      j = min(find(row==min(row))); % target index
      col = D(:,j);
      i = min(find(col==min(col))); % source index

         % note: i-th element moves to j-th position

      idx(j) = i;                   % ith index equals j
      D(i,:) = void';               % ith row out of game
      D(:,j) = void;                % jth column out of game
    end
    L(:,end) = L(idx,end);
end

%==========================================================================
% Stability Plot
%==========================================================================

function [K0,f0] = PlotStability(o,L0,sub,tag,mu)  % Stability Chart   
   if (nargin < 4)
      tag = '0';
   end
   if (nargin < 5)
      mu = [];
   end
   
   cutting = o.iif(isequal(tag,'0'),+1,-1);   % cutting direction
   
   K0 = nan;  f0 = nan;
   subplot(o,sub,'semilogx');
   set(gca,'visible','on');

   low  = opt(o,{'gain.low',1e-3});
   high = opt(o,{'gain.high',1e3});
   points = opt(o,{'gain.points',200});
   
   closeup = opt(o,{'stability.closeup',0});
   if (closeup)
      K0 = cook(o,['K',tag]);
      low = K0/(1+closeup);
      high = K0*(1+closeup);
   end
   
   K = logspace(log10(low),log10(high),points);
   [o,s] = Cache(o,K,cutting);         % get cached eigenvalues 
   
      % get L0 system matrices

   rng(1);                             % reset random seed (repeatable)
   [~,ridx] = sort(randn(1,length(K)));
   
   %s = 0*K;
   stop(o,'Enable');
   steps = 10;
   for (i=1:steps)
      kdx = i:steps:length(K);
      jdx = ridx(kdx);
      Ki = K(jdx);
      si = s(jdx);
      
      if any(isnan(si))
         si = CritEig(o,L0,Ki);
         s(jdx) = si;
         o = Cache(o,K,cutting,s);     % hard refresh of cache
      end
      
         % plot K for stable EV in green and unstable in red

      idx = find(real(si)<0);
      if ~isempty(idx)
         plot(Ki(idx),-real(si(idx))*100,'g.');
      end
      idx = find(real(si)>=0);
      if ~isempty(idx)
         plot(Ki(idx),-real(si(idx))*100,'r.');
      end
      idle(o);                         % give time for graphics refresh
      if stop(o,o)                     % stop option controlled
         K0 = [];  f0 = [];
         return;
      end
   end
   stop(o,'Disable');
      
%  [K0,f0] = Stable(o,L0);
   if (cutting > 0)
      [K0,f0] = cook(o,'K0,f0');
   else
      [K0,f0] = cook(o,'K180,f180');
   end
   
      % plot limits
      
   limits(o,'Gain');
   lim = o.either(limits(o),[1 1]);
   
   if ~isequal(K0,inf)
      if (K0 < 1/lim(1))
         col = 'r';
      elseif (K0 > 1/lim(2))
         col = 'g';
      else
         col = 'yyyr';
      end
      plot(o,[K0 K0],get(gca,'ylim'),[col,'1-.']);
   end
   
   %xlim = get(gca,'xlim');             % save x-limits
   %plot(o,[1 1],get(gca,'ylim'),'K1-.');
   %set(gca,'xlim',xlim);               % restore x-limits
   
   ylim = get(gca,'ylim');
   if (diff(ylim) < 1)
      set(gca,'ylim',[min(ylim(1),-5),max(ylim(2),+5)]);
   end
   
   if isempty(mu)
      title(sprintf('Critical Gain (K%s: %g @ f%s: %g Hz)',tag,K0,tag,f0));
   else
      error('using this plot as stability margin is obsoleted');
      title(sprintf('Stability Margin: %g (%g dB) @ f: %g Hz, omega: %g/s (mu: %g)',...
           o.rd(K0,2),o.rd(20*log10(K0),1), o.rd(f0,1),o.rd(2*pi*f0,1),mu));
   end
   xlabel('closed loop gain K');
   ylabel('worst damping [%]');
   
   function [o,s] = Cache(o,K,cutting,s)    % get cached eigenvalues
   %
   % CHACHE  Retrieve/Update cached eigenvalues vor damping plot
   %
   %            [o,s] = CachedEig(o,K);     % retrieve eigenvalues
   %            o = CachedEig(o,K,s)        % store cached eigenvalues
   %
      o = cache(o,o,'critical');            % hard refresh cache
      
      if (nargin == 4)
         if (cutting >= 0)                  % forward cutting
            o = cache(o,'critical.plot_K0',K);
            o = cache(o,'critical.plot_s0',s);
         else                               % reverse cutting
            o = cache(o,'critical.plot_K180',K);
            o = cache(o,'critical.plot_s180',s);
         end
         cache(o,o);                        % hard refresh cache
      elseif (nargin == 3)
         if (cutting >= 0)                  % if forward cutting
            K_ = cache(o,'critical.plot_K0');
            if isequal(K,K_)
               s = cache(o,'critical.plot_s0');
            else
               s = K*NaN;
               o = cache(o,'critical.plot_K0',[]);  % invalidate plot data
               o = cache(o,'critical.plot_s0',[]);  % invalidate plot data
               cache(o,o);                     % hard refresh cache
            end
         else                                  % else reverse cutting
            K_ = cache(o,'critical.plot_K180');
            if isequal(K,K_)
               s = cache(o,'critical.plot_s180');
            else
               s = K*NaN;
               o = cache(o,'critical.plot_K180',[]);  % invalidate plot data
               o = cache(o,'critical.plot_s180',[]);  % invalidate plot data
               cache(o,o);                     % hard refresh cache
            end
         end
      end
   end
end

%==========================================================================
% Helper
%==========================================================================

function [K0,f0] = Stable(o,L0,K,s)    % Calc Stability Margin         
%
% STABLE  Calculate critical K0 and frequency f0 for open loop system L0
%         by interval search. K and s are auxillary data for quick
%         estimation of an initial interval.
%
%            [K0,f0] = Stable(o,L0,K,s)
%            [K0,f0] = Stable(o,L0,K)
%            [K0,f0] = Stable(o,L0)
%
   if (nargin < 3)
      low  = opt(o,'gain.low');
      high = opt(o,'gain.high');
      search = opt(o,{'search',200});
      
      if isempty(low)
         low = LowerBoundary(o)/2;     % factor 2 safety margin
      end
      if isempty(high)
         high = low*1000;
      end
      K = logspace(log10(low),log10(high),search);
   end
   iter = opt(o,{'iter',50});
   epsi = opt(o,{'eps',1e-10});
   
   if (length(K) == 1)
      K = K*[0.99,1.01];               % convert to interval
   end
   
   if (nargin < 4)
      s = CritEig(o,L0,K);
      if stop(o,o)                     % stop option controlled
         K0 = [];  f0 = [];
         return
      end
   end
   
   Klim = Initial(o,L0,K,s);
   if isequal(Klim,inf)
      K0 = inf;  f0 = 0;
      return
   end
   
   s = CritEig(o,L0,Klim);
   
      % pay attention to the case that user requested a termination
      % in this case return empty values for K0 and f0
      
   if stop(o,o)
      K0 = [];  f0 = [];
      return
   end
   
   if (real(s(1))>= 0 || real(s(2)) < 0)
      error('bad initial data, cannot proceed');
   end
   
   if isequal(Klim,inf)
      K0 = inf;  f0 = 0;
      return
   elseif isequal(Klim,0)
      K0 = 0;  f0 = 0;
      return
   end

      % interval search

   [A0,B0,C0,D0,scale] = data(L0,'A,B,C,D,scale');

   %kmax = length(K);
   I = eye(size(D0));
   for (k=1:iter)
      if (rem(k-1,10)==0)
         progress(o,'critical K interval search',k);
      end
      
      K0 = mean(Klim);

         % calculate closed loop dynamic matrix

      Ak = A0 - B0*K0 * inv(I+D0*K0) * C0;  % closed loop dynamic matrix

         % find eigenvalue with largest real part

      sk = eig(Ak);
      re = real(sk);
      idx = find(re==max(re));
      s = sk(idx(1));
      f0 = imag(s)/(2*pi)/scale;
      
         % terminate?
         
      err = abs(real(s));
      if (err < epsi)
         break;
      end
      
         % closeup
         
      if (real(s) > 0)
         Klim(2) = K0;
      elseif (real(s) < 0)
         Klim(1) = K0;
      else
         break;
      end
      
         % eventually stop
         
      if stop(o,o)
         K0 = inf;  f0 = 0;
         progress(o);               % done   
         return
      end
   end
   progress(o);                     % done   
      
   function Klim = Initial(o,L0,K,s)
      idx = find(real(s)>=0);
      if isempty(idx)
         Klim = inf;
      elseif (idx(1) == 1)
         Klim = 0;
      else
         Klim = [K(idx(1)-1), K(idx(1))];
      end
   end
end
function s = CritEig(o,L0,K)           % Find critical Eigenvalues     
   [A0,B0,C0,D0] = data(L0,'A,B,C,D');
   
   kmax = length(K);
   for (k=1:kmax)
      if (kmax > 10 && rem(k-1,10) == 0)
         progress(o,sprintf('%g of %g: critical eigenvalues',k,kmax),k/kmax*100);
      end

      Kk = K(k);

         % calculate closed loop dynamic matrix

      Ak = A0 - B0*inv(eye(size(D0))+Kk*D0)*Kk*C0;  % closed loop A

         % find eigenvalue with largest real part

      sk = eig(Ak);
      re = real(sk);
      idx = find(re==max(re));
      s(k) = sk(idx(1));
      
      if stop(o,o)                     % stop option controlled
         break;
      end
   end
   
   if (kmax > 10)
      progress(o);                  % done
   end
end
function [K0,f0,K180,f180,err] = Critical(o,oo)  % Critical Quantities 
%
% algorithm: for quadrants 1..4 assign quadrant IDs as follows
%
%    quadrant 1: ID = 1
%    quadrant 2: ID = 2
%    quadrant 3: ID = -2
%    quadrant 4: ID = -1
%
% thus q (holding quadrant IDs could look as follows)
%
%     q = [-1 -1 -2 -2 2  2  1  1 -1 -1]
%    dq = [ 0 -1  0  4 0 -1  0 -2  0]
%
%      0° passes are characterized by abs(diff(q)) = 2
%    180° passes are characterized by abs(diff(q)) = 4
%
   olo = opt(o,{'omega.low',100});
   ohi = opt(o,{'omega.high',1e5});
   points = opt(o,{'omega.points',2000});

      % get system matrices
      
   [A,B_1,B_3,C_3,T0] = var(oo,'A,B_1,B_3,C_3,T0');
   PsiW31 = psion(o,A,B_1,C_3);        % to calculate G31(jw)
   PsiW33 = psion(o,A,B_3,C_3);        % to calculate G33(jw)
   
      % omega/frequency range
      
   om = logspace(log10(olo),log10(ohi),points);
   Om = om*T0;                         % time normalized omega
   f = om/2/pi;                        % frequency range
   
      % calculate spectrum

   l0jw = lambda(o,A,B_1,B_3,C_3,Om);
   phi = angle(o,l0jw,'Positive') * 180/pi;
   [m,n] = size(phi);
   
      % find quadrant changes
 
   for (i=1:m)
      q = Quadrant(phi(i,:));      
      Dq(i,:) = diff(q);               % find quadrant changes
   end
   dq = max(abs(Dq));
   
   jdx = find(dq>=2);
   K0 = inf;  K180 = inf;  f0 = 0;  f180 = 0;
   
   for (k=1:length(jdx))
      j = jdx(k);  dqj = Dq(:,j);
      if (j == n)
         break;                        % no passing
      end
      
      for (i=1:m)
         switch dqj(i)
            case {-2,2}                % 0° passing
               [K,Omega,err] = Pass(o,PsiW31,PsiW33,[Om(j),Om(j+1)],-1);
               if (K < K180)
                  K180 = K;  f180 = Omega/(2*pi*T0);
               end
            case {-4,4}                % 180° passing
               [K,Omega,err] = Pass(o,PsiW31,PsiW33,[Om(j),Om(j+1)],1);
               if (K < K0)
                  K0 = K;  f0 = Omega/(2*pi*T0);
               end
         end
      end
   end
   
       % second run for exact calculation
       
   tol = opt(o,{'critical.eps',1e-12});
   iter = opt(o,{'critical.iter',100});
   
   try
      [K,Omega,err] = Pass(o,PsiW31,PsiW33,2*pi*f0*T0*[0.990,1.001],1,tol,iter);
      K0 = K;  f0 = Omega/(2*pi*T0);
   catch
      fprintf('*** exception catched during final FQR calculation of K0,f0\n');
   end

   try
      [K,Omega,err] = Pass(o,PsiW31,PsiW33,2*pi*f180*T0*[0.990,1.001],-1,tol,iter);
      K180 = K;  f180 = Omega/(2*pi*T0);
   catch
      fprintf('*** exception catched during final FQR calculation\n');
   end
end
function q = Quadrant(phi)             % Classify Quadrants            
   while (phi(1) >= 360)
      phi = phi - 360;
   end
   while (phi(1) < 0)
      phi = phi + 360;
   end
   assert(0 <= phi(1) && phi(1) < 360);

   q = nan*phi;

   idx = find(0<=phi & phi<90);
   q(idx) = 0*idx + 1;              % ID=1 for 1st quadrant

   idx = find(90<=phi & phi<180);
   q(idx) = 0*idx + 2;              % ID=2 for 2nd quadrant

   idx = find(180<=phi & phi<270);
   q(idx) = 0*idx - 2;              % ID=-2 for 3rd quadrant

   idx = find(270<=phi & phi<360);
   q(idx) = 0*idx - 1;              % ID=-1 for 4th quadrant

   assert(any(any(isnan(q)))==0);
end
function [K,Omega,err] = Pass(o,PsiW31,PsiW33,Olim,sgn,tol,iter)       
   if (nargin < 8)
      tol = 1e-5;
   end
   if (nargin < 9)
      iter = 5;
   end

   l0jw = lambda(o,PsiW31,PsiW33,Olim);
   Gjw = 1 + sgn*l0jw;

   idx = find(imag(Gjw(:,1)) .* imag(Gjw(:,2)) <= 0);
   Mi = max(mean(abs(Gjw(idx,:))'));

   ilim = imag(Gjw(idx,:));
   ilim = [min(ilim(:)), max(ilim(:))];

   K = min(1./mean(abs(l0jw(idx,:))));

   for (ii=1:iter)
      Omega = mean(Olim);
      l0jw = lambda(o,PsiW31,PsiW33,Omega);
      Gjw = 1 + K*sgn*l0jw;

      absGjw = abs(Gjw);
      idx = min(find(absGjw==min(absGjw)));
      K = min(1./abs(l0jw(idx)));
      err = imag(Gjw(idx));

      if (abs(err) < tol)
         return;                    % terminate
      end

      if (sign(diff(ilim)) * sign(err) > 0)
         ilim(2) = err;
         Olim(2) = Omega;
      else
         ilim(1) = err;
         Olim(1) = Omega;
      end
   end
end
function K0min = LowerBoundary(o)      % Calc Lower Boundary           
%
% K0MIN   Calculate lower boundary of K0:
%         Let l0jw = [l01(jw),l02(jw),...,l0n(jw)], then we know that for
%         for critical gain we have
%
%             K0*l0i(jw0) = -1         % for some 1 <= i <= n
%
%         This implies that K0*|l0i(jw)|= 1 and K0 = 1/|l0i(jw)|. Given now
%         a boundary condition
%
%             |l0i(jw)| <= A           % for all 1 <= i <= n and all w
%
%         we can conclude that
%
%            K0 >= 1/A
%
%         Thus we can calculate K0min as a lower boundary of K0 as
%
%            K0 = 1 / max{|l0i(jw)|}  % over i=1..n and all w
%
   o = with(o,'spectrum');             % need for omega calculation

      % calculate omega range
      
   olo = opt(o,{'omega.low',100});
   ohi = opt(o,{'omega.high',1e5});
   points = opt(o,{'omega.points',2000});

   om = logspace(log10(olo),log10(ohi),points);

      % quickest way of spectrum calculation
      
   sys = system(o);
   [A,B_1,B_3,C_3,T0] = var(sys,'A,B_1,B_3,C_3,T0');
 
   PsiW31 = psion(o,A,B_1,C_3);            % to calculate G31(jw)
   PsiW33 = psion(o,A,B_3,C_3);            % to calculate G33(jw)
   lambda0jw = lambda(o,PsiW31,PsiW33,T0*om);

      % calculate upper boundary A
      
   A = max(max(abs(lambda0jw)));
   K0min = 1/A;
end
function L = Negate(L)
   L.data.B = -L.data.B;
   L.data.D = -L.data.D;
end