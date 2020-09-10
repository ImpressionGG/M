function biondemo(obj,varargin)
%
% BIONDEMO    Callbacks for demo menu 'Bions'
%
%             Topics
%             - distinguishable particles
%             - bosons
%             - fermions
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{},'setup');
   
   if ~propagate(obj,func,which(func)) 
      eval(cmd);
   end
   return

%==========================================================================
% Bion Eigen Functions
%==========================================================================

function CbBionEigen(obj)
%
% CBBIONEIGEN   Bion Eigen Functions
%
   type = option(obj,'bion.type');
   modes = option(obj,'bion.modes');
   
   eob = envi(obj,'box');       % particle in a box environment
   z = get(eob,'zspace');       % get z-space
   
   qob = quon(eob);             % single particle in specified modes
   bob = bion(qob,qob,modes(:,1),modes(:,2),type);
   
   sceene(obj,'bion',z);  camera('zoom',1.2);
  
   [t,dt] = timer(gao,0.1);  fac = 10;  facp = 8;  fact = 30; 
   while (control(gao))
      [psi,eco] = wave(bob,t);
      
      eco1 = sum(eco')';
      eco2 = conj(sum(eco))';
      
      phase1 = eig(qob,1:length(eco1))*eco1;
      phase2 = eig(qob,1:length(eco2))*eco2;
      
      pxy = conj(psi').*psi;
      p1 = normalize(sum(pxy')',z);
      p2 = normalize(conj(sum(pxy))',z);
      
      psi1 = sqrt(p1) .* phase1;
      psi2 = sqrt(p2) .* phase2;
      
      wing(option(obj,'offset',[0 0 4]),z,psi1,'r');
      wing(option(obj,'offset',[0 0 -4]),z,psi2,'y');
      
      [X,Y] = meshgrid(z,z);

      C = rem(angle(psi)+pi,pi);      % a bit tricky
      update(gao,surf(X,Y,fac*real(psi),C,'edgecolor','none'));
      caxis([-1 1]);
      %camera('spin',1);
      [t,dt] = wait(gao);             % use dt > 0 for the rest of the loop
   end
   return

%==========================================================================
% Distinguishable Particles
%==========================================================================

function CbDistinguish(obj)
%
% CBDISTINGUISH   Wing demonstration of 2 distinguishable particles
%
   eob = envi(obj,'box');  % particle in a box environment
   eob = set(eob,'zspace',-10:0.1:10);
   z = get(eob,'zspace');  % get z-space
   
   qob1 = quon(eob,[1 2]); % single particle in ground state 1
   qob2 = quon(eob,[2 3]); % single particle in excited state 2

   qob1 = option(qob1,'offset',[0 -3 0]);
   qob2 = option(qob2,'offset',[0 +3 0]);

   sceene(obj,'psi',z);  camera('zoom',1.2);

   
   [t,dt] = timer(smart,0.1);  fac = 5;  facp = 8;  fact = 15; 
   dt = 0;                                   % set 0 for the 1st time
   N = length(z);
   while (control(gao))
      dt = dt*10;
         % calculate new wave function after time interval dt
         % asw well as constituents in energy eigen function base

      psi11 = eig(qob1,1) * conj(eig(qob2),1)';
      psi12 = wave(qob1,1) * conj(qob2,2)';
      psi12 = wave(qob1,1) * conj(qob2,2)';
         
      [psi1,Psi1t] = wave(qob1,t*fact);
      [psi2,Psi2t] = wave(qob2,t*fact);
      
      Psixy = psi1*conj(psi2)';
      %Psixy = psi1*conj(psi2)' + psi2*conj(psi1)';
      
      %phs1 = sum(Psixy)/N;         phs1 = exp(i*angle(phs1)); 
      %phs2 = sum(conj(Psixy)')/N;  phs2 = exp(i*angle(phs2)); 
      
      Pxy = conj(Psixy).*Psixy;
      
      psi1 = normalize(sqrt(sum(Pxy)),z); 
      psi2 = normalize(sqrt(sum(Pxy')),z); 

      wing(qob1,z,fac*psi1,'r');
      balley(qob1,z,facp*prob(psi1,z),'r',1.0); 

      wing(qob2,z,fac*psi2,'y');
      balley(qob2,z,facp*prob(psi2,z),'y',1.0); 
      
      camera('spin',0.1);
      [t,dt] = wait(gao);             % use dt > 0 for the rest of the loop
   end
   return

%==========================================================================
%eof   
   