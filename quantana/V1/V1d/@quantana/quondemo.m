function quondemo(obj)
%
% QUONDEMO    Callbacks for demo menu 'Quons'
%
%             Topics
%             - distinguishable particles
%             - bosons
%             - fermions
%
   func = arg(obj);
   if isempty(func)
      mode = setting('quons.func');
   else
      setting('quons.func',func);
   end

   eval([func,'(obj);']);               % invoke callback
   return

%==========================================================================
% Particle in a Box
%==========================================================================

function CbPiBoxEigenFunctions(obj)
%
% CBPIBOXEIGENFUNCTIONS   Particle in a Box: display eigen functions
%
   profiler('PiBox',1);
   
   eob = envi(obj,'box','zspace',-5:0.2:5);
   qob = quon(eob);             % particle in a box
   z = get(qob,'zspace');       % get z-space
   
   sceene(obj,'psi',z); 
   camera('zoom',1.2);  Kw = 5;  Ke = 5;  Kp = 8;  Kt = 5;
  
   [t,dt] = timer(gao,0.1); 
   profiler('PiBox',1);
   while (control(gao))
      for (j=1:3)
         [psij,Ej] = eig(qob,j,Kt*t);
         wing(option(obj,'offset',[0 0 Ke*Ej]),z,Kw*psij,'r');
      end
      %camera('spin',1);
      [t,dt] = wait(gao);             % use dt > 0 for the rest of the loop
   end
   
   profiler('PiBox',0);
   return

%==========================================================================

function CbPiBoxGaussian(obj)
%
% CBPIBOXGAUSSIAN   Particle in a Box: Gaussian wave packet
%
   profiler('PiBox',1);
   center = option(obj,'quon.center');
   
   eob = envi(obj,'box','zspace',-5:0.1:5);
   qob = gauss(quon(eob),1,center);        % gaussian particle in a box
   z = get(qob,'zspace');                  % get z-space
   
   sceene(obj,'psi',z); 
   camera('zoom',1.5);  Kw = 5;  Ke = 5;  Kp = 12;  Kt = 2;
  
   hdl = well(obj,min(z),0.25,2);          % draw potential well
   hdl = well(obj,max(z),0.25,2);          % draw potential well
   
   [t,dt] = timer(gao,0.1); 
   
   profiler('PiBox',1);
   while (control(gao))
      psi = wave(qob,Kt*t);
      wing(obj,z,Kw*psi,'b');
      balley(obj,z,Kp*prob(psi),'b');
      camera('spin',0.5);
      [t,dt] = wait(gao);
   end
   profiler('PiBox',0);

   return

%==========================================================================
%eof   
   