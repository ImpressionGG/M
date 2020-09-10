function oo = basics(o,varargin)
%
% BASICS   Callbacks for demo menu 'basics'
%
%             Topics
%             - phase color and complex color
%             - color map visualization
%
   [gamma,oo] = manage(o,varargin,@EnergyLevels,@EigenFuncs,@EigenOscis);
   oo = gamma(oo);
end

%==========================================================================
% Harmonic Oscillators
%==========================================================================

function o = EnergyLevels(o)           % Plot Energy Levels of H.O.    
%
% ENERGYLEVELS  Plot energy levels of harmonic oscillator
%
   color = @carabull.color;    % short hand
   cls(o);

   om = 1;  z = -5:0.1:5;      % omega and z-space definition
   osc = harmonic(om,z);       % create harmonic oscillator

   [psi,E] = eig(osc,0:7);     % eigen functions and eigen values

   V = potential(osc);         % potential curve

   color(plot([min(z) max(z)],E*[1 1]),'a');  % energy levels
   hold on;

   for (j=1:length(E))
      n = j-1;  En = E(j);
      text(4.2,En+0.2,sprintf('E%g',n));
   end

   plot(z,V,'b');   % potential curve
   
   ylabel('Energy Levels En, Potential V');
   title(sprintf('Energy Levels of Harmonic Oscillator (omega = %g)',om));
   set(gca,'xlim',[-5 5],'ylim',[0 8]);
   shg
end
function o = EigenFuncs(o)             % Plot Eigen Functions of H.O.  
%
% EIGENFUNCS  Plot eigen functions of harmonic oscillator
%
   color = @carabull.color;    % short hand
   cls(o);

   om = 1;  z = -5:0.1:5;      % omega and z-space definition
   osc = harmonic(om,z);       % create harmonic oscillator

   [psi,E] = eig(osc,0:7);     % eigen functions and eigen values

   V = potential(osc);         % potential curve

   color(plot([min(z) max(z)],E*[1 1]),'a');  % energy levels
   hold on;

   for (j=1:length(E))
      n = j-1;  En = E(j);
      text(4.2,En+0.2,sprintf('E%g',n));
      color(plot(z,En+0.5*real(psi(:,j))),'r',3);
   end

   plot(z,V,'b');   % potential curve
   
   ylabel('Energy Levels En, Potential V');
   title(sprintf('Energy Levels of Harmonic Oscillator (omega = %g)',om));
   set(gca,'xlim',[-5 5],'ylim',[0 8]);
   shg

end
function o = EigenOscis(o)
%
% EIGENOSCIS  Plot eigen functions of harmonic oscillator
%
   color = @carabull.color;    % short hand
   prob = @quantana.prob;      % short hand
   
   cls(o);

   om = 1;  z = -5:0.1:5;      % omega and z-space definition
   osc = harmonic(om,z);       % create harmonic oscillator

   index = 0:7;
   [psi,E] = eig(osc,index);   % eigen functions and eigen values

   V = potential(osc);         % potential curve

   color(plot([min(z) max(z)],E*[1 1]),'a');  % energy levels
   hold on;

   for (j=1:length(E))
      n = j-1;  En = E(j);
      text(4.2,En+0.2,sprintf('E%g',n));
   end

   plot(z,V,'b');   % potential curve

   ylabel('Energy Levels En, Potential V');
   title(sprintf('Energy Levels of Harmonic Oscillator (omega = %g)',om));
   set(gca,'xlim',[-5 5],'ylim',[0 8]);
   shg

   [t,dt] = timer(o,0.1);

   while (~stop(o))
      o = update(o);                 % sync call to update
      [Psi,E] = eig(osc,index,z,t);

      for (j=1:length(E))
         n = j-1;  En = E(j);
         hdl(1) = color(plot(z,En+real(Psi(:,j))),'r',2);
         hdl(2) = color(plot(z,En+20*prob(Psi(:,j))),'g',2);
         o = update(o,hdl);          % tracking call to update
      end

      t = wait(o);
   end
end
   
%==========================================================================

function CbSuper1(obj)
%
% CBSuper1   3D wing animation of 0th and 1st eigen oscillation
%            including superposition
%
%
   mp = option(obj,'pale.m');   % number of segments along pale (mp = 10)
   np = option(obj,'pale.n');   % number of segments around pale (np = 10)
   tp = option(obj,'pale.t');   % transparency (tp = 0.8)

   tp = 1;
   mp = 20;  np = 4;   
   fac = 1;                     % virtual amplification for visualisation
   
      % Define coordinate space and psi functioon

   omega = 1;
   z = -5:0.1:5;                             % our coordinate space
   osc = setup(harmonic(omega,z),25);        % harmonic oscillator
   k = 0 * 2*pi / 10; om = 2*pi*0.2;         % wave number & frequency

      % setup sceene
      
   sceene(obj,'psi',z);
   camera('zoom',1.5);
   
   [t,dt] = timer(smart,0.1);
   while (control(smart))

      psi0 = eig(osc,0,z,t);
      psi1 = eig(osc,1,z,t);
      psi = psi0 + psi1;
      P = prob(psi,z);
      
      wing(obj,z,fac*psi0,'r',tp,np); 
      wing(obj,z,fac*psi1,'y',tp,np); 
      wing(obj,z,fac*psi,'b',tp,np); 
      balley(obj,z,fac/2*P,'g',1.0); 

      [t,dt] = wait(smart);
   end
end
   
%==========================================================================

function CbSuper2(obj)
%
% CBSUPER2   3D wing animation of 0th, 1st and 2nd eigen oscillation
%            including superposition
%
%
   mp = option(obj,'pale.m');   % number of segments along pale (mp = 10)
   np = option(obj,'pale.n');   % number of segments around pale (np = 10)
   tp = option(obj,'pale.t');   % transparency (tp = 0.8)

   tp = 1;
   mp = 20;  np = 4;   
   
      % Define coordinate space and psi functioon

   omega = 1;
   z = -5:0.1:5;                             % our coordinate space
   osc = setup(harmonic(omega,z),25);        % harmonic oscillator
   k = 0 * 2*pi / 10; om = 2*pi*0.2;         % wave number & frequency
   fac = 1;                     % virtual amplification for visualisation

      % setup sceene
      
   sceene(obj,'psi',z);
   camera('zoom',2);
   
   [t,dt] = timer(gao,0.1);
   while (control(gao))
      
      psi0 = eig(osc,0,z,t);
      psi1 = eig(osc,1,z,t);
      psi2 = eig(osc,2,z,t);
      psi = psi0 + psi1 + psi2;
      P = prob(psi,z);
      
      wing(obj,z,fac*psi0,'r',tp,np); 
      wing(obj,z,fac*psi1,'y',tp,np); 
      wing(obj,z,fac*psi2,'m',tp,np); 
      wing(obj,z,fac*psi,'d',tp,np); 
      balley(obj,z,fac/2*P,'g',1.0); 

      [t,dt] = wait(gao);
   end
end

%==========================================================================

function CbCoherent(obj)
%
% CBCOHERENT 3D wing animation of 0th, 1st and 2nd eigen oscillation
%            including superposition
%
%
   speed = option(obj,'harmonic.speed');
   N = option(obj,'harmonic.N');              % coherence number
   switch either(option(obj,'harmonic.coloring'),'multi')
      case 'uni'
         colw = 'r';  colb = 'r';  trsp = 1;
      otherwise
         colw = 'r';  colb = 'g';  trsp = 1;
   end
   
   mp = option(obj,'pale.m');   % number of segments along pale (mp = 10)
   np = option(obj,'pale.n');   % number of segments around pale (np = 10)
   tp = option(obj,'pale.t');   % transparency (tp = 0.8)

   tp = 1;
   mp = 20;  np = 12;   
   fac = 3;                     % virtual amplification for visualisation
   
      % Define coordinate space and psi functioon

   omega = 1;
   z = -12:0.05:12;                          % our coordinate space
   osc = setup(harmonic(omega,z),100);       % harmonic oscillator
   k = 0 * 2*pi / 10; om = 2*pi*0.2;         % wave number & frequency

      % setup sceene
      
   sceene(obj,'psi',z);
   camera('zoom',2.0);
      
   %idx = 0:50;                               % idices of eigenstates

   [t,dt] = timer(smart,0.1);
   while (control(smart))
      M = max(25,3*N);
      Psit = eig(osc,0:M,z,t);               % all eigenstates
      cN = coherent(osc,N,M);
      psiN = Psit * cN;                      % coherent state
      P = prob(psiN,z);                      % probability function
      
      wing(obj,z,fac*psiN,colw,tp,np,np,0.1); 
      balley(obj,z,fac/2*P,colb,trsp); 

      [t,dt] = wait(smart);
   end
end
