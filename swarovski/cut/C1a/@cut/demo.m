function oo = demo(o,varargin)      % Uni Demo Shell  
% 
% DEMO  Open new figure for Uni demo simulations
%      
%           o = uni(cut,'demo')     % create a cut:demo object
%           demo(o)                 % open demo shell
%
%        See also: CUT, UNI, SHELL
%
   [func,o] = manage(o,varargin,@Shell);
   oo = func(o);
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
% 
   o = Init(o);                        % init object   

   o = menu(o,'Begin');                % begin menu setup
   oo = menu(o,'File');                % add File menu
   oo = Simulation(o);                 % add Simulation menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end

function o = Init(o)                   % Init Object                   
   if isempty(get(o,'title'))
      o = set(o,'title','Uni Demo Shell');
   end
   o = refresh(o,{@menu,'About'});  % provide refresh callback
end

%==========================================================================
% Simulation Menu
%==========================================================================

function oo = Simulation(o)            % Simulation Menu                     
   oo = mitem(o,'Simulation');         % add roll down header item
   
   ooo = mitem(oo,'Basic Example');
   oooo = mitem(ooo,'Stable (HEUN)',{@BasicExample,1});
   oooo = mitem(ooo,'Unstable (SODE)', {@BasicExample,2});
   oooo = mitem(ooo,'Velocity vx (SODE)', {@BasicExample,3});
   
   if isequal(type(o),'60mm')
      ElongationStudy(oo);
   end
   
   ooo = mitem(oo,'Friction Study');
   
   oooo = mitem(ooo,'Tape Velocity: v = 1m/s');
   ooooo = mitem(oooo,'Velocity vx (SODE)', {@FrictionStudy,1,'vx'});
   ooooo = mitem(oooo,'Elongation uy (SODE) - Abb. 3.3', {@FrictionStudy,1,'uy'});
   ooooo = mitem(oooo,'-');
   ooooo = mitem(oooo,'Velocity vx (HEUN)', {@FrictionStudy,2,'vx'});
   ooooo = mitem(oooo,'Elongation uy (HEUN)', {@FrictionStudy,2,'uy'});
   
   oooo = mitem(ooo,'Tape Velocity: v = 5m/s');
   ooooo = mitem(oooo,'Velocity vx (SODE)', {@FrictionStudy,3,'vx'});
   ooooo = mitem(oooo,'Elongation uy (SODE) - Abb. 3.7',...
                   {@FrictionStudy,4,'uy'});

   ooo = mitem(oo,'Eigenvalue');
   if (isequal(char(get(o,'model')),'@hoga1')) 
      oooo = mitem(ooo,'Stability Conditions - Abb.3.2', {@StabilityStudyCb});
   end
   if (isequal(char(get(o,'model')),'@hoga2')) 
      oooo = mitem(ooo,'Eigenvalue Analysis, beta = 45 - Abb.3.15',...
                       {@EigenvalueAnalysisCb,45,[0.01 0.05]});
      oooo = mitem(ooo,'Eigenvalue Analysis, beta = 75 - Abb.3.15',...
                       {@EigenvalueAnalysisCb,75,[0.01 0.05]});
   end
end




function o = BasicExample(o)           % Basic Example Callback        
   number = arg(o,1);                  % arg 1 is example number
   refresh(o,{'shell','BasicExample',number}); 

   oo = o;
   switch number
      case 1
         v = 1; mu = 0.7;
         oo.par.parameter.v = v;
         oo.par.parameter.mu = mu;
         oo = heun(oo);                % simulate
         cls(o); plot(oo);
      case 2
         v = 1; mu = 0.9;
         oo.par.parameter.v = v;
         oo.par.parameter.mu = mu;
         oo = sode(oo);                % simulate
         cls(o); plot(oo);
      case 3
         o = opt(o,'signal','vx');
         o = opt(o,'system',0.1);
         v = 1;  mu = 0.85;  
         if isequal(type(o),'demo')
            tmax = 0.1;
         else
            tmax = get(o,'simu.tmax');        
         end
         FrictionVariation(o,@sode,v,mu,tmax);
   end
end

function o = FrictionStudy(o)          % Basic Example Callback        
   number = arg(o,1);                  % arg 1 is example number
   signal = arg(o,2);
   refresh(o,{'shell','BasicExample',number}); 

   o = opt(o,'signal',signal);
   mu = [0.75, 0.8, 0.85];
   
   switch number
      case 1
         v = 1;  tmax = 5;
         FrictionVariation(o,@sode,v,mu,tmax);

      case 2
         v = 1;  tmax = 5;
         FrictionVariation(o,@heun,v,mu,tmax);

      case 3
         v = 5;  tmax = 10;
         FrictionVariation(o,@sode,v,mu,tmax);

      case 4
         v = 5;  tmax = 10;
         o = opt(o,'ylim',[-0.25 0.25]);
         FrictionVariation(o,@sode,v,mu,tmax);
   end
end

function o = StabilityStudyCb(o)         % Damping Study Callback        
   number = arg(o,1);                  % arg 1 is example number

   model = get(o,'model');
   cls(o);
   
   c = [0.5 1.0 2.0];                  % damping
   col = {'k','r','b'};
   
   for (i=1:length(c))
      StabilityConditions(o,c(i),col{i});
      hold on;
   end
   plot([0 2],[0 0],'r');
   grid;
   xlabel('friction coefficient');
   ylabel('Real{sigma}'); 
   legend(sprintf('Damping c1 = c2 = %g',c(1)),...
          sprintf('Damping c1 = c2 = %g',c(2)),...
          sprintf('Damping c1 = c2 = %g',c(3)));
end

function o = StabilityConditions(o,c,col)     % plot damping chart        
   model = get(o,'model');

   oo = o;
   oo.par.parameter.c1 = c;
   oo.par.parameter.c2 = c;
   
   mu = 0:0.01:2;
   for (i=1:length(mu))
      o.par.parameter.mu = mu(i);
      o.par.parameter.c1 = c;
      o.par.parameter.c2 = c;
      A1 = model(o);
      lambda = eig(A1);
      delta(i) = max(real(lambda));
   end   
   plot(mu,delta,col);
end

%==========================================================================
% friction variation
%==========================================================================

function FrictionVariation(o,simu,v,mu,tmax)
   col = {'k','r','b'};     
   signal = opt(o,{'signal','vx'});
   system = opt(o,{'system',0});

   cls(o);
   for (i=1:length(mu))
      oo = o;
      oo.par.parameter.v = v;
      oo.par.parameter.mu = mu(i);
      oo.par.simu.tmax = tmax;
      oo = simu(oo);                % simulate

      if (isequal(signal,'uy'))
         plot(oo.dat.t,oo.dat.x(2,:),col{i});
      else
         plot(oo.dat.t,oo.dat.x(3,:),col{i});
      end
      hold on
      
      if (system)                   % plot system indicator?
         plot(oo.dat.t,system*oo.dat.s,'k');
      end
      shg
   end
   set(gca,'xlim',[0 get(oo,'simu.tmax')]);
   if (length(opt(o,'ylim')) > 0)
      set(gca,'ylim',opt(o,'ylim'));
   end

   if (length(mu) >= 3)
      legend(sprintf('mu = %g',mu(1)),sprintf('mu = %g',mu(2)),...
             sprintf('mu = %g',mu(3)));
   end
   
   if (isequal(signal,'vx'))
      plot(oo.dat.t,0*oo.dat.t+v,'r');
      ylabel('Velocity vx [m/s]');
   elseif (isequal(signal,'uy'))
      ylabel('Elongation uy [mm]');
   end

   if (length(mu) >= 3)
      title(sprintf('Variation of Friction: v = %g m/s, mu = %g, %g, %g',...
                 v,mu(1),mu(2),mu(3)));
   end
   grid on;
end

%==========================================================================
% friction variation
%==========================================================================

function o = EigenvalueAnalysisCb(o)     % plot damping chart        
   number = arg(o,1);                  % arg 1 is example number

   model = get(o,'model');
   cls(o);
   
   beta = arg(o,1);                    % machining angle
   D = arg(o,2);                       % Lehr©s damping measure
   col = {'b','r','y','m','g','c','k'};
   
   k = 1; legends = {};
   for (i=1:length(beta))
      for (j=1:length(D))
         oo = rotate(o,beta(i));
         oo = damping(oo,D(j));
         EigenvalueConditions(oo,col{k});
         legends{1,k} = sprintf('beta = %g, D = %g',beta(i),D(j));
         k = 1+rem(k,length(col));
         hold on;
      end
   end
   
   title('Eigenvalue Analysis');
   xlabel('mu (friction coefficient)');
   ylabel('sigma (max real part of eigenvalues)');
   legend(legends);
end

function o = EigenvalueConditions(o,col)     % plot damping chart        
   model = get(o,'model');

   mu = -1.4:0.01:1;
   for (i=1:length(mu))
      o.par.parameter.mu = mu(i);
      lambda = eig(o);
      delta(i) = max(real(lambda(:)));
   end   
   plot(mu,delta,col);
end

%==========================================================================
% elongation study
%==========================================================================

function oo = ElongationStudy(o)
   oo = mitem(o,'Elongation Study');
   ooo = mitem(oo,'Initial Elongation uy = 0 mu',{@ElongationStudyCb,0});
   ooo = mitem(oo,'Initial Elongation uy = 10 mu',{@ElongationStudyCb,10});
   ooo = mitem(oo,'Initial Elongation uy = 20 mu',{@ElongationStudyCb,20});
   ooo = mitem(oo,'Initial Elongation uy = 30 mu',{@ElongationStudyCb,30});
   ooo = mitem(oo,'Initial Elongation uy = 30.7 mu',{@ElongationStudyCb,30.7});
   ooo = mitem(oo,'Initial Elongation uy = 30.8 mu',{@ElongationStudyCb,30.8});
end

function o = ElongationStudyCb(o)        
   uy_mu = arg(o,1);                  % arg 1 is example number
   refresh(o,{'shell','ElongationStudyCb',uy_mu}); 

   oo = o;
   oo = set(oo,'init.uy0',uy_mu*1e-6);
   oo = set(oo,'parameter.v',1);
   
   oo = sode(oo);                     % simulate
   oo.dat.s = oo.dat.s * 0.1;
   
   cls(o); plot(oo,'UxUyVxVy');
   %set(gca,'ylim',[-2 2]);
   title(sprintf('Initial Elongation: uy = %g mu',uy_mu))
end
