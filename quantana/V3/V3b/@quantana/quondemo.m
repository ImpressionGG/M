function quondemo(obj,varargin)
%
% QUONDEMO    Callbacks for demo menu 'Quons'
%
%             Topics
%             - Setup                 % setup menu
%             - PiBoxEigenFunctions   % particle in a box - eigen functions
%             - PiBoxGaussian         % Gaussian wave function in a box
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{{'@','invoke'}},'Setup');
   
   if ~propagate(obj,func,which(func)) 
      eval(cmd);
   end
   return
end

%==========================================================================
% Setup
%==========================================================================

function Setup(obj)
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);
   
   default('quon.center',0.0);    % center of gaussian wave packet
   default('quon.spin',0.2);      % Camera spin increment

   default('bohm.order',2);       % upper quantum number of wave function
   default('bohm.lower',1);       % lower quantum number of wave function
   default('bohm.number',3);      % number of particles for Bohmian motion
   default('bohm.white',0);       % show white spot of Bohmian motion
   default('bohm.gradient',0);    % show gradient of Bohmian motion
   default('bohm.velocity',0);    % show velocity of Bohmian motion
   default('bohm.ny',0);          % show ny-function of Bohmian motion
   default('bohm.trans',0.5);     % transparency value
   default('bohm.balley',1);      % probability balley
   default('bohm.record',0);      % position recording
   default('bohm.reference',0);   % reference recording
   default('bohm.dt',0.05);       % time interval
   default('bohm.periphery',0);   % display particle at periphery
%            
   men = mount(obj,'<main>',LB,'Quons');
   sub = uimenu(men,LB,'Particle in a Box');
         uimenu(sub,LB,'Eigen functions',CB,call,UD,'@PiBoxEigenFunctions');
         uimenu(sub,LB,'Bohmian Motion',CB,call,UD,'@BohmianMotion');
         uimenu(sub,LB,'_______________________',EN,'off');
         uimenu(sub,LB,'Bohmian Verification',CB,call,UD,'@BohmianVerification');
   
   sub = uimenu(men,LB,'Gaussian Wave Packet');
         uimenu(sub,LB,'Gaussian Wave Packet',CB,call,UD,'@PiBoxGaussian');
   
   sub = uimenu(men,LB,'_______________________',EN,'off');
         
   sub = uimenu(men,LB,'Gaussian Center',UD,'quon.center');
         choice(sub,[0:0.5:2.5],CHCR);   
   sub = uimenu(men,LB,'Camera Spin',UD,'quon.spin');
         choice(sub,[0:0.2:1],CHCR);   
         
   sub = uimenu(men,LB,'Bohmian Parameters');
   itm = uimenu(sub,LB,'Upper Quantum Number',UD,'bohm.order');
         choice(itm,[1:8],CHCR);   
   itm = uimenu(sub,LB,'Lower Quantum Number',UD,'bohm.lower');
         choice(itm,[1:8],CHCR);   
   itm = uimenu(sub,LB,'Number of Particles',UD,'bohm.number');
         choice(itm,[0:10],CHCR);   
   itm = uimenu(sub,LB,'White Spot',UD,'bohm.white');
         choice(itm,{{'Off',0},{'On',1}},CHCR);   
   itm = uimenu(sub,LB,'Gradient',UD,'bohm.gradient');
         choice(itm,{{'Off',0},{'On',1}},CHCR);   
   itm = uimenu(sub,LB,'Velocity',UD,'bohm.velocity');
         choice(itm,{{'Off',0},{'On',1}},CHCR);   
   itm = uimenu(sub,LB,'Ny-Function',UD,'bohm.ny');
         choice(itm,{{'Off',0},{'On',1}},CHCR);   
   itm = uimenu(sub,LB,'Transparency',UD,'bohm.trans');
         choice(itm,[0:0.1:1.0],CHCR);   
   itm = uimenu(sub,LB,'Probability Balley',UD,'bohm.balley');
         choice(itm,{{'Off',0},{'On',1}},CHCR);   
   itm = uimenu(sub,LB,'Position Recording',UD,'bohm.record');
         choice(itm,{{'Off',0},{'On',1}},CHCR);   
   itm = uimenu(sub,LB,'Reference Recording',UD,'bohm.reference');
         choice(itm,{{'Off',0},{'On',1}},CHCR);   
   itm = uimenu(sub,LB,'Time Interval',UD,'bohm.dt');
         choice(itm,[0.005 0.01 0.02 0.05 0.1 0.2],CHCR);   
   itm = uimenu(sub,LB,'Periphery Motion',UD,'bohm.periphery');
         choice(itm,{{'Off',0},{'On',1}},CHCR);   
   return
end

%==========================================================================
% Particle in a Box
%==========================================================================

function PiBoxEigenFunctions(obj)
%
% PI-BOX-EIGEN-FUNCTIONS   Particle in a Box: display eigen functions
%
   spin = option(obj,'quon.spin');
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
      camera('spin',spin);
      [t,dt] = wait(gao);             % use dt > 0 for the rest of the loop
   end
   
   profiler('PiBox',0);
   return
end

%==========================================================================
% Gaussian Wave Function in a Box
%==========================================================================

function PiBoxGaussian(obj)
%
% PI-BOX-GAUSSIAN   Particle in a Box: Gaussian wave packet
%
   profiler('PiBox',1);
   bohm = option(obj,'bohm');              % Bohmian motion options
   spin = option(obj,'quon.spin');         % camera spin speed
   center = option(obj,'quon.center');     % center of Gauss distribution
   
   eob = envi(obj,'box','zspace',-5:0.1:5);
   qob = gauss(quon(eob),1,center);        % gaussian particle in a box
   z = get(qob,'zspace');                  % get z-space
   
   sceene(obj,'psi',z); 
   camera('zoom',1.5);  Kw = 10;  Ke = 5;  Kp = 20;  Kt = 2;
  
   hdl = well(obj,min(z),0.25,2);          % draw potential well
   hdl = well(obj,max(z),0.25,2);          % draw potential well
   
   [time,dtime] = timer(gao,0.1); 
   zp = [];  zrec = [];  trec = [];
   
   profiler('PiBox',1);
   while (control(gao))
      t = Kt*time;  dt = Kt*dtime;
      psi = wave(qob,t);

      wall(obj,z,Kw*psi,'v');
      balley(obj,z,Kp*prob(psi),'v');

         % initialize position of particle and calculate velocity
         
      zp = position(qob,psi,bohm.number,zp);
      v = velocity(qob,psi,zp);

         % display the particle
         
      if (bohm.trans < 1)
         for (k = 1:length(zp))
            wp = interp1(z',psi,zp(k));
            wy = iif(bohm.periphery,-Kw*real(wp),0);
            wz = iif(bohm.periphery,Kw*imag(wp),0);
            ball(obj,[zp(k) wy wz],0.8,'y',1-bohm.trans);
         end
      end
      
         % further animations
         
      [zrec,trec] = FurtherAnimations(obj,qob,psi,zp,t,zrec,trec);
      
      if (bohm.number > 0)
         zp = zp + v*dt;
      end
      
         % finally spin the camera
         
      camera('spin',spin);
      [time,dtime] = wait(gao);
   end
   profiler('PiBox',0);

   return
end

%==========================================================================
% Bohmian Motion
%==========================================================================

function BohmianMotion(obj)
%
% BOHMIAN-MOTION   Animation of Bohmian motion
%
   profiler('PiBox',1);

   bohm = option(obj,'bohm');   % Bohmian motion options
   spin = option(obj,'quon.spin');

   eob = envi(obj,'box','zspace',-5:0.1:5);    % was -5:0.2:5
   qob = quon(eob);             % particle in a box
   z = get(qob,'zspace');       % get z-space
   
   sceene(obj,'psi',z); 
   camera('zoom',1.2);  Kw = 30;  Ke = 5;  Kp = 20;  Kt = 5;  

   hdl = well(obj,min(z),0.25,2);          % draw potential well
   hdl = well(obj,max(z),0.25,2);          % draw potential well
   
   [time,dtime] = timer(gao,bohm.dt); 
   zp = [];  zrec = [];  trec = [];
   
   while (control(gao))
      t = Kt*time;  dt = Kt*dtime;
      [psi,v,zp] = Bohm(qob,zp,t,bohm.order);
      
      wall(obj,z,Kw*psi,'r');
      if bohm.balley
         balley(obj,z,Kp*prob(psi),'r');
      end
      
      if (bohm.trans < 1)
         for (k = 1:length(zp))
            wp = interp1(z',psi,zp(k));
            wy = iif(bohm.periphery,-Kw*real(wp),0);
            wz = iif(bohm.periphery,Kw*imag(wp),0);
            ball(obj,[zp(k) wy wz],0.8,'y',1-bohm.trans);
         end
      end
      
      [zrec,trec] = FurtherAnimations(obj,qob,psi,zp,t,zrec,trec);
      
      zp = zp + v*dt;
      
         % finally spin the camera
         
      camera('spin',spin);
      [time,dtime] = wait(gao);   % use dtime > 0 for the rest of the loop
   end
   
   profiler('PiBox',0);
   return
end

%==========================================================================
% Bohmian Verification
%==========================================================================

function BohmianVerification(obj)
%
% BOHMIAN-VERIFICATION   Verification of the Bohm algorithms
%
   bohm = option(obj,'bohm');   % Bohmian motion options
   spin = option(obj,'quon.spin');
   
   eob = envi(obj,'box','zspace',-5:0.1:5);    % was -5:0.2:5
   qob = quon(eob);             % particle in a box
   z = get(qob,'zspace');       % get z-space

   hbar = data(qob,'hbar');  
   m = data(qob,'m');  
   L = max(z) - min(z);
   A1 = sqrt(0.2/L);  E1 = hbar^2/2/m*(1*pi/L)^2;
   A2 = sqrt(0.2/L);  E2 = hbar^2/2/m*(2*pi/L)^2;
   
   sceene(obj,'psi',z); 
   camera('zoom',1.2);  Kw = 10;  Ke = 5;  Kp = 8;  Kt = 5;  

   hdl = well(obj,min(z),0.25,2);          % draw potential well
   hdl = well(obj,max(z),0.25,2);          % draw potential well
   
   [time,dtime] = timer(gao,0.05); 
   zp = [];  zrec = [];  trec = [];  prec = [];
   
   while (control(gao))
      t = Kt*time;  dt = Kt*dtime;
      [psi,vp,zp] = Bohm(qob,zp,t,2);
      
      Psi1 = A1 * cos(1*pi*z(:)/L)*exp(-i*E1/hbar*t);  
      Psi2 = -A2 * sin(2*pi*z(:)/L)*exp(-i*E2/hbar*t);  
      Psi  = 1/sqrt(2)*[Psi1+Psi2];
      
      Grad1 = -A1 * 1*pi/L * sin(1*pi*z(:)/L)*exp(-i*E1/hbar*t);  
      Grad2 = -A2 * 2*pi/L * cos(2*pi*z(:)/L)*exp(-i*E2/hbar*t);  
      Grad = 1/sqrt(2)*[Grad1+Grad2];
      V = hbar/m * imag(Grad./Psi);     % Bohmian velocity
      
      [v,ny,grad] = velocity(qob,psi,z);
      
      err=norm(Psi-psi);
      if err > 1e-15
         fprintf('*** warning: err = norm(Psi - psi) = %g\n',err);
      end

      err = norm(V(3:end-2)-v(3:end-2));
      if err > 1e-1
         fprintf('*** warning: err = norm(V - v) = %g\n',err);
      end
      
      wing(obj,z,Kw*psi,'r');
      balley(obj,z,Kp*prob(psi),'r');

      for (k = 1:length(zp))
         ball(obj,[zp(k) 0 0],0.8,'y',1-bohm.trans);
      end

         % now particle specific
         
      Psi1p = A1 * cos(1*pi*zp(:)/L)*exp(-i*E1/hbar*t);  
      Psi2p = -A2 * sin(2*pi*zp(:)/L)*exp(-i*E2/hbar*t);  
      Psip  = 1/sqrt(2)*[Psi1p+Psi2p];
      
      Grad1p = -A1 * 1*pi/L * sin(1*pi*zp(:)/L)*exp(-i*E1/hbar*t);  
      Grad2p = -A2 * 2*pi/L * cos(2*pi*zp(:)/L)*exp(-i*E2/hbar*t);  
      Gradp  = 1/sqrt(2)*[Grad1p+Grad2p];
      Vp = hbar/m * imag(Gradp./Psip);     % Bohmian velocity
      
      zp = zp + Vp*dt;

      err = norm(Vp-vp);
      if err > 3e-3
         fprintf('*** warning: err = norm(Vp - vp) = %g\n',err);
      end
      
         % visualisation of velocity
      
      if (bohm.velocity)
         v(1) = 0;  v(end) = 0;
         wall(obj,z,i*v,'b',1.0);
      end
      
         % finally spin the camera
         
      camera('spin',spin);
      [time,dtime] = wait(gao);   % use dtime > 0 for the rest of the loop
   end
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [psi,v,zp] = Bohm(qob,zp,t,order)
%
% BOHM-FUNCTIONS   Get all functions for the calculation of 
%                  Bohmian motion
%
%                     [psi,v,zp] = Bohm(qob,zp,t,order)
%
   n  = option(qob,'bohm.number');
   n0 = min(order,option(qob,'bohm.lower'));
   
   psi = 0;
   for (j=n0:order)
      [psij,Ej] = eig(qob,j,t);
      psi = psi + psij;
   end
   
   psi = normalize(psi);
   zp = position(qob,psi,n,zp);
   
      % calculate velocity and update position

   if isempty(zp)
      v = [];
   else
      v = velocity(qob,psi,zp(:,end));
   end
   return
end

%==========================================================================


function [zlist,tlist] = FurtherAnimations(obj,qob,psi,zp,t,zlist,tlist,n)
%
% FURTHER-ANIMATIONS
%
   bohm = option(obj,'bohm');
   Kg = 20;
   
   z = zspace(qob);
   [v,ny,gradpsi] = velocity(qob,psi,z);

   if isempty(zlist)
      zlist = {[], []};  tlist = {[], []};
   end
   
   if (bohm.reference && bohm.number > 0)
      zrec = zlist{1};  trec = tlist{1};

      zr = position(qob,psi,bohm.number);
      zrec(:,end+1) = zr;     % record particle reference position
      trec(end+1) = t;
      
      one = ones(size(zrec(:,1)));
      hdl = color(plot3(zrec',-(0.5*one*trec(end:-1:1))',0*zrec'),0.5*[0 1 0]);      
      update(gao,hdl);
      zlist{1} = zrec;  tlist{1} = trec;
   end

   if (bohm.record && bohm.number > 0)
      zrec = zlist{2};  trec = tlist{2};
      zrec(:,end+1) = zp;     % record particle position
      trec(end+1) = t;
      
      one = ones(size(zrec(:,1)));
      hdl = color(plot3(zrec',-(0.5*one*trec(end:-1:1))',0*zrec'),0.5*[1 1 1]);      
      update(gao,hdl);
      zlist{2} = zrec;  tlist{2} = trec;
   end
   
   if (bohm.white)
      P = prob(psi);
      ball(obj,[z(:)'*P 0 0],0.8,'w');
   end

   if (bohm.gradient)
      wing(obj,z,Kg*gradpsi,'m');
   end

   if (bohm.velocity)
      v(1) = 0;  v(end) = 0;
      wall(obj,z,i*v,'b',1.0);
   end

   if (bohm.ny)
      ny(1) = 0; ny(end) = 0;
      wing(obj,z,ny,'g');
   end
   return
end
   
   