function basics(obj)
%
% BASICS   Callbacks for demo menu 'basics'
%
%             Topics
%             - phase color and complex color
%             - color map visualization
%
   func = arg(obj);
   if isempty(func)
      mode = setting('basics.func');
   else
      setting('basics.func',func);
   end

   eval([func,'(obj);']);               % invoke callback
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
%eof   
   