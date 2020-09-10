function harmosc(obj,varargin)
%
% HARMOSC     Callbacks for demo menu 'harmonic', regarding the
%             Harmonic Oscillator
%
%             Topics
%             - eigen functions
%             - eigen oscillations
%             - coherent state
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{},'setup');
   
   if ~propagate(obj,func,which(func)) 
      eval(cmd);
   end
   return


%    func = arg(obj);
%    if isempty(func)
%       mode = setting('harmonic.func');
%    else
%       setting('harmonic.func',func);
%    end
% 
%    eval([func,'(obj);']);               % invoke callback
%    return

%==========================================================================
% Basics
%==========================================================================

function CbEnergyLevels(obj)
%
% ENERGYLEVELS  Plot energy levels of harmonic oscillator
%
   cls(obj);
   q = either(option(obj,'harmonic.pseudo'),1.0);

   om = 1;  z = -5:0.1:5;      % omega and z-space definition
   osc = harmonic(om,z);       % create harmonic oscillator
   osc = pseudo(osc,q);        % potentially transform to pseudo osc.
   
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
   type = iif(q==1,'Harmonic','Pseudo');
   title(sprintf(['Energy Levels of ',type,' Oscillator (omega = %g)'],om));
   set(gca,'xlim',[-5 5],'ylim',[0 8]);
   shg

   return
   
%==========================================================================

function CbEigenFuncs(obj)
%
% EIGENFUNCS  Plot eigen functions of harmonic oscillator
%
   cls(obj);
   q = either(option(obj,'harmonic.pseudo'),1.0);

   om = 1;  z = -5:0.1:5;      % omega and z-space definition
   osc = harmonic(om,z);       % create harmonic oscillator
   osc = pseudo(osc,q);        % potentially transform to pseudo osc.

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
   type = iif(q==1,'Harmonic','Pseudo');
   title(sprintf(['Energy Levels of ',type,' Oscillator (omega = %g)'],om));
   set(gca,'xlim',[-5 5],'ylim',[0 8]);
   shg

   return
   
%==========================================================================

function CbEigenOscis(obj)
%
% EIGENOSCIS  Plot eigen functions of harmonic oscillator
%
   cls(obj);
   q = either(option(obj,'harmonic.pseudo'),1.0);

   om = 1;  z = -5:0.1:5;      % omega and z-space definition
   osc = harmonic(om,z);       % create harmonic oscillator
   osc = pseudo(osc,q);        % potentially transform to pseudo osc.

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
   type = iif(q==1,'Harmonic','Pseudo');
   title(sprintf(['Energy Levels of ',type,' Oscillator (omega = %g)'],om));
   set(gca,'xlim',[-5 5],'ylim',[0 8]);
   shg

   t = 0;  dt = 0.1;
   smo = timer(smart,dt);

   while (~stop(smo))
      smo = update(smo);             % sync call to update

      [Psi,E] = eig(osc,index,z,t);

      for (j=1:length(E))
         n = j-1;  En = E(j);
         hdl(1) = color(plot(z,En+real(Psi(:,j))),'r',1);
         hdl(2) = color(plot(z,En+20*prob(Psi(:,j))),'g',2);
         smo = update(smo,hdl);      % tracking call to update
      end

      smo = wait(smo);
      t = t + dt;
   end

   return
   
%==========================================================================
% Superposition
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
   camera('zoom',2.0);
   
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
   return
   
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
   return


function CbCoherent(obj)
%
% CBCOHERENT coherent state oscillation
%
%
   [speed,N,colw,colb] = harmopts(obj);
   fac = 3;                     % virtual amplification for visualisation
   
      % Define coordinate space and psi functioon

   omega = 1;
   z = -12:0.05:12;                          % our coordinate space
   osc = setup(harmonic(omega,z),100);       % harmonic oscillator
   k = 0 * 2*pi / 10; om = 2*pi*0.2;         % wave number & frequency

      % setup sceene
      
   sceene(obj,'psi',z);
   camera('zoom',4.0);
      
   [t,dt] = timer(smart,0.1);
   while (control(smart))
      M = max(25,3*N);
      Psit = eig(osc,0:M,z,t);               % all eigenstates
      cN = coherent(osc,N,M);
      psiN = Psit * cN;                      % coherent state
      P = prob(psiN,z);                      % probability function
      
      wing(obj,z,fac*psiN,colw); 
      balley(obj,z,fac/2*P,colb); 

      [t,dt] = wait(smart);
   end
   return
   
%==========================================================================
   
function CbCoherentSpeedup(obj)
%
% CBCOHERENTSPEEDUP   coherent state oscillation
%
%
   [speed,N,colw,colb] = harmopts(obj);
   fac = 3;                     % virtual amplification for visualisation
   colb = 'v';  colw = colb;
   
      % Define coordinate space and psi functioon

   omega = 1;
   z = -12:0.1:12;                          % our coordinate space
   osc = setup(harmonic(omega,z),100);       % harmonic oscillator
   k = 0 * 2*pi / 10; om = 2*pi*0.2;         % wave number & frequency

      % setup sceene
      
   sceene(obj,'psi',z);
      
   [t,dt] = timer(smart,0.1);
   while (control(smart))
      N = N*1.005;
      camera('zoom',10/sqrt(N));
      M = max(25,3*N);
      Psit = eig(osc,0:M,z,t);               % all eigenstates
      cN = coherent(osc,N,M);
      psiN = Psit * cN;                      % coherent state
      P = prob(psiN,z);                      % probability function
      
      wing(obj,z,fac*psiN,colw); 
      balley(obj,z,fac/2*P,colb); 

      [t,dt] = wait(smart);
   end
   return
   
%==========================================================================
% Harmonic Oscillators
%==========================================================================

function CbEnergyLevels(obj)
%
% ENERGYLEVELS  Plot energy levels of harmonic oscillator
%
   cls(obj);

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

   return
   
%==========================================================================

function CbEigenFuncs(obj)
%
% EIGENFUNCS  Plot eigen functions of harmonic oscillator
%
   cls(obj);

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

   return
   
%==========================================================================

function CbEigenOscis(obj)
%
% EIGENOSCIS  Plot eigen functions of harmonic oscillator
%
   cls(obj);

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

   t = 0;  dt = 0.1;
   smo = timer(smart,dt);

   while (~stop(smo))
      smo = update(smo);             % sync call to update

      [Psi,E] = eig(osc,index,z,t);

      for (j=1:length(E))
         n = j-1;  En = E(j);
         hdl(1) = color(plot(z,En+real(Psi(:,j))),'r',1);
         hdl(2) = color(plot(z,En+20*prob(Psi(:,j))),'g',2);
         smo = update(smo,hdl);      % tracking call to update
      end

      smo = wait(smo);
      t = t + dt;
   end

   return

%==========================================================================
% Eigen Oscillations
%==========================================================================
   
function Cb3DEigenOscis(obj)
%
% EIGENOSCIS  Plot eigen functions of harmonic oscillator
%
   cls(obj);

   om = 1;  z = -5:0.1:5;      % omega and z-space definition
   osc = harmonic(om,z);       % create harmonic oscillator

   index = 0:7;
   [psi,E] = eig(osc,index);   % eigen functions and eigen values

   [V,coeff] = potential(osc);         % potential curve
   
      % setup sceene and draw potential
      
   sceene(obj);
   potential(option(obj,'potential.color',0.5*[0 0 1]),'poly',z,coeff);
   obj = option(obj,'potential.width',0.1);

   camera('target',[0 0 4],'zoom',3);
   fac = 1;  facp = fac*0.4;
   
      % now plot the oscillating eigen functions
   
   [t,dt] = timer(gao,0.05); % setup timer
   
   
   while (control(gao))
      [Psi,E] = eig(osc,index,z,t);

      for (j=1:length(E))
         psi = Psi(:,j);
         obj = option(obj,'offset',[0 0 E(j)]);
         
         wing(obj,z,fac*psi,'r');
         balley(obj,z,facp*prob(psi,z),'r',1.0); 
      end
      
      camera('spin',0.5);
      [t,dt] = wait(gao);
   end
   return

   
%==========================================================================
% Superposition
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
   return
   
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
   return

%==========================================================================
% Coherent State
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
   return

%==========================================================================

function [osc,om,z,V0,F0,E,t0,Tp,coeff] = oscsetup(obj)
%
% OSCSETUP     Oscillator Setup:
%              - clear screen
%              - setup an oscillator with omega = 2, z = -5:dz:5
%              - setup a wave function with selected modes
%              - calculate potential V & coefficients w/o external field
%              - setup an external field F
%              - initialize plot with n+1 values En for energy E
%
   cls(obj);

   om = 1;  z = -5:0.1:5;           % omega and z-space definition
   F0 = either(option(obj,'harmonic.field'),0.5);   % external field force

   modes = either(option(obj,'harmonic.modes'),[0 0]);
   q = either(option(obj,'harmonic.pseudo'),1.0);
   Tp = either(option(obj,'harmonic.pulse'),inf);
   t0 = 5;
   
   osc = harmonic(om,z);            % create harmonic oscillator
   Psi = eig(osc,modes);            % wave fcts. according to selected modes
   psi = normalize(sum(Psi')');     % sum up selected eigenfcts. & norm.
   [V0,coeff] = potential(osc);     % oscillator's potential curve 
   
      % As we have now a wave function we re-initialize the oscillator
      
   F = 0*F0;
   osc = harmonic([om,F],z,psi);    % create harmonic osc. @ psi & F
   osc = pseudo(osc,q);             % potentially transform to pseudo

   index = 0:5;
   [psi,E] = eig(osc,index);        % eigen functions and eigen values

   color(plot([min(z) max(z)],[0;E]*[1 1]),'a');  % energy levels
   hold on;

   for (j=1:length(E))
      n = j-1;  En = E(j);
      text(3.5,En+0.2,sprintf('E%g = %g',n,round(100*En)/100));
   end

      % initialize plot and add labels and title
      
   ylabel('Energy Levels En, Potential V');
   type = iif(q~=1,'Pseudo','Harmonic')
   title(sprintf(['Energy Levels of ',type,' Oscillator (omega = %g)'],om));
   set(gca,'xlim',[-5 5],'ylim',[-1 max(index)]);
   shg
   return
   
%==========================================================================
% Pulse Field
%==========================================================================

function CbPulseField(obj)
%
% CBPULSEFIELD   Plot eigen functions of harmonic oscillator
%                under sudden influence of an electric field.
%                The initial state is defined by the 'harmonic.modes'
%                option.
%
   [osc,om0,z,V0,F0,E,t0,Tp] = oscsetup(obj);
   xlabel(sprintf('Puls width: Tp = %g',Tp));

   index = 0:length(E)-1;
   
   [t,dt] = timer(smart,0.1);  fac = 5;  
   dt = 0;                                   % set 0 for the 1st time
   while (control(gao))
      F = F0 * (t > t0 & t <= t0+Tp);        % pulse width
      V = potential(osc);                    % potential curve @ external F
      update(gao,plot(z,V0,'b', z,V,'y'));   % draw potentials

         % calculate new wave function after time interval dt
         % asw well as constituents in energy eigen function base
         
      [Psi,E] = eig(osc,index,z,t);          % need E values
      [psi,Psit] = wave(osc,dt);
      
      hdl(1) = color(plot(z,real(fac*psi)),'r',3);
      for (j=1:length(E))
         hdl(1+j) = color(plot(z,E(j)+real(fac*Psit(:,j))),'r',1);
      end
      
      update(gao,hdl);             % tracking call to update

         % now update the harmonic oscillatior with the new external 
         % field value and the current wave function
         
      osc = harmonic(osc,psi,F);   % update psi & F

      [t,dt] = wait(gao);          % use dt > 0 for the rest of the loop
   end
   return

%==========================================================================
   
function CbPulseAnalysis(obj)
%
% CBFIELDANALYSIS Plot eigen functions of harmonic oscillator
%                 under sudden influence of an electric field.
%                 Initially there is only the ground state
%
   cls(obj);
   [osc,om0,z,V0,F0,E,t0,Tp,coeff0] = oscsetup(obj);
   xlabel(sprintf('Puls width: Tp = %g',Tp));

   modes = either(option(obj,'harmonic.modes'),[0 0]);
   q = either(option(obj,'harmonic.pseudo'),1.0);
  
   psi = wave(osc);
   osc0 = harmonic(osc,psi,0);           % clone with external field F = 0 
   osc1 = harmonic(osc,psi,0*F0*(Tp>0));   % clone with external field F = F0 

   index = 0:length(E)-1;

   [t,dt] = timer(smart,0.1);  fac = 5;  dt = 0;
   while (control(gao))
      F = F0 * (t > t0 & t <= t0+Tp);       % pulse width
      V = potential(osc);                   % potential curve @ external F
      update(gao,plot(z,V0,'b', z,V,'y'));  % draw potentials

      [Psi0,E0] = eig(osc0,index,z,t);
      [Psi1,E1] = eig(osc1,index,z,t);
      [Psi,E]   = eig(osc,index,z,t);

      [psi0,Psi0t] = wave(osc0,t);
      [psi1,Psi1t] = wave(osc1,t);
      [psi,Psit]   = wave(osc,dt);
      
      update(gao,color(plot(z,real(fac*psi0)),'r',3));
      update(gao,color(plot(z,real(fac*psi1)),'y',3));
      update(gao,color(plot(z,real(fac*psi)),'b',3));
      
      for (j=1:length(E))
         hdl(1) = color(plot(z,E0(j)+real(fac*Psi0t(:,j))),'r',1);
         hdl(2) = color(plot(z,E1(j)+real(fac*Psi1t(:,j))),'y',3);
         hdl(3) = color(plot(z,E(j)+real(fac*Psit(:,j))),'b',1);
         update(gao,hdl);      % tracking call to update
      end

         % now update the harm. oscillatior with the new external 
         % field value %
         
      osc = harmonic(osc,psi,F);      % update psi & F

      [t,dt] = wait(gao);
   end

   return
   
%==========================================================================
% Harmonic Field
%==========================================================================

function CbHarmonicField(obj)
%
% CBHARMONICFIELD3D   3D Plot of harmonic oscillator behavior under
%                     influence of an oscillating electric field.
%                     The initial state is defined by the 
%                     'harmonic.modes' option.
%
   stop = option(obj,'harmonic.stop');
   showwave = option(obj,'harmonic.wave');

   [osc,om0,z,V0,F0,E,t0,Tp,coeff0] = oscsetup(obj);
   omega = either(option(obj,'harmonic.omega'),1.0);  % frequency of F(t) 
   %wobble = either(option(obj,'harmonic.wobble'),1.01);
   static = either(option(obj,'harmonic.static'),0);
   
      % setup sceene and draw potential
      
   sceene(obj,'psi',z);  camera('zoom',2);
   obj = option(obj,'potential.width',4,'offset',[0 0 0]);

%    potential(option(obj,'potential.color',0.5*[0 0 1]),'poly',z,coeff);
   obj = option(obj,'potential.width',0.1);
   
   [t,dt] = timer(smart,0.1);  fac = 5;  facp = 1; 
   dt = 0;                                   % set 0 for the 1st time
   F = 0;
   while (control(gao))
      if (showwave)
         [V,coeff] = potential(osc);            % potential curve @ F(t)
         [phdl,obj] = potential(option(obj,'potential.color','y'),'wave',z,F);
         update(gao,phdl);
      end
      
         % calculate new wave function after time interval dt
         % asw well as constituents in energy eigen function base

      if (static)
         dt = 0;    % no changes in case of static
      end
      [psi,Psit] = wave(osc,dt);

      wing(obj,z,fac*psi,'r');
      balley(obj,z,facp*prob(psi,z),'r',1.0); 

      if (stop && t >= t0)
         [obj,Tp] = OptimalStop(obj,Psit,Tp,omega); 
      end   
      
         % now update the harmonic oscillatior with the new external 
         % field value and the current wave function
         
      F = F0*sin(omega*(t-t0)) * (t>=t0 & t <= t0+Tp);
      %omega = omega * wobble;
      osc = harmonic(osc,psi,F);      % update psi & F

      camera('spin',0.1);
      [t,dt] = wait(gao);             % use dt > 0 for the rest of the loop
   end
   return

%==========================================================================

function CbHarmonicAnalysis(obj)
%
% CBHARMONICFIELD   Plot eigen functions of harmonic oscillator
%                   under influence of an oscillating electric
%                   electric field. The initial state is defined by
%                   the 'harmonic.modes' option.
%
   stop = option(obj,'harmonic.stop');
   
   [osc,om0,z,V0,F0,E,t0,Tp] = oscsetup(obj);
   omega = either(option(obj,'harmonic.omega'),1.0);  % frequency of F(t) 
   %wobble = either(option(obj,'harmonic.wobble'),0.00);
   xlabel(sprintf('External field frequency: om = %g (E1-E0 = %g)',omega,E(2)-E(1)));
   %omega = E(2)-E(1)
   static = either(option(obj,'harmonic.static'),0);
   
   [t,dt] = timer(smart,0.1);  fac = 5;  
   dt = 0;                                   % set 0 for the 1st time
   
   while (control(gao))
      V = potential(osc);                    % potential curve @ external F
      update(gao,plot(z,V0,'b', z,V,'y'));   % draw potentials

         % calculate new wave function after time interval dt
         % asw well as constituents in energy eigen function base
         
      if (static)
         dt = 0;    % no changes in case of static
      end
      [psi,Psit] = wave(osc,dt);
      
      hdl(1) = color(plot(z,real(fac*psi)),'r',3);
      for (j=1:length(E))
         hdl(1+j) = color(plot(z,E(j)+real(fac*Psit(:,j))),'r',1);
      end
      
      update(gao,hdl);      % tracking call to update

      if (stop && t >= t0)
         [obj,Tp] = OptimalStop(obj,Psit,Tp,omega); 
      end   
      
         % now update the harmonic oscillatior with the new external 
         % field value and the current wave function
         
      F = F0*sin(omega*(t-t0)) * (t>=t0 & t <= t0+Tp);
      %omega = omega + wobble;
      osc = harmonic(osc,psi,F);      % update psi & F

      [t,dt] = wait(gao);             % use dt > 0 for the rest of the loop
   end
   return

   
function [obj,Tp] = OptimalStop(obj,Psit,Tp,omega)
%
% OPTIMAL-STOP  Return stop condition
%
   Maxi = either(option(obj,'Maxi'),-1e-99);
   
   maxi = max(abs(Psit(:,1)));
   xlabel(sprintf('External field frequency: om = %g (a0 = %g)',...
          omega,rd(maxi,2)));

   if (Maxi < 0)
      if (maxi >= abs(Maxi))
         Maxi = -maxi;
      else
         Maxi = maxi;
      end
   else % now Maxi > 0 and we are in a declining phase
      if (maxi > Maxi+1e-3)
         Tp = 0;
      end
      Maxi = min(Maxi,maxi);
   end
   
   obj = option(obj,'Maxi',Maxi);
   return

%==========================================================================
% Harmonic Excitation
%==========================================================================
   
function HarmonicExcitation(obj)
%
% HARMONIC-EXCITATION
%
   choice('harmonic.pseudo',2.0);   % Pseudo harmonic oscillator
   choice('harmonic.omega',2.0);    % Field frequency
   check('harmonic.stop',1);        % Optimal stop
   choice('harmonic.pulse',1e99);   % infinite pulse width
   choice('harmonic.field',0.06);   % infinite pulse width
   
   obj = gfo;                       % get new settings
   refresh(obj,'demo(obj);',{'CbExecute'  'CbHarmonicField'});
   CbHarmonicField(obj);
   
   return

%==========================================================================
% Parameters and Options
%==========================================================================

function [speed,N,colw,colb] = harmopts(obj)
%
% HARMOPTS    Harmonic options
%
   speed = option(obj,'harmonic.speed');
   N = option(obj,'harmonic.N');              % coherence number
   switch either(option(obj,'harmonic.coloring'),'multi')
      case 'uni'
         colw = 'r';  colb = 'r';
      otherwise
         colw = 'r';  colb = 'g';
   end
   return
   
   
%eof   
   