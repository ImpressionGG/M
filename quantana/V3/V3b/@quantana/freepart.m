function freepart(obj,varargin)
%
% FREEPART    Callbacks for demo menu 'Free Particle'
%
%             Topics
%             - eigen functions
%             - wave packet
%             - Fourier transform
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{},'setup');
   
   if ~propagate(obj,func,which(func)) 
      eval(cmd);
   end
   return
   
%==========================================================================
% Harmonic Oscillators
%==========================================================================

function CbEigenFuncs(obj)
%
% EIGENFUNCTS  Plot eigen functions of free particle
%
   z = -5:0.1:5;
   fob = free(z);          % free particle with sigma = 2
   
   sceene(obj,'3D');       % prepare 3D sceene
   k = kspace(fob);

   wing(obj,z,eig(fob,k(1)),'r');
   wing(obj,z,eig(fob,k(2)),'g');
   wing(obj,z,eig(fob,k(3)),'b');
   wing(obj,z,eig(fob,k(4)),'y');
   camera('zoom',2,'spinning');

   return
   
%==========================================================================

function CbFourier(obj)
%
% CBFOURIER  Discrete Fourier Transformation demo
%
   z = 0:3;
   
   fob = free(z);          % free particle with sigma = 2
   psi = eig(fob,3*pi/2);
   
   N = length(psi);
   phi = 0*psi;
   for (k=0:N-1)
      for (j=0:N-1)
         phi(k+1) = phi(k+1) + psi(j+1)*exp(-2*pi/N*i*j*k);
      end
   end

   sceene(obj,'3D');       % prepare 3D sceene
   pale(obj,z,psi,'r');
   plot([min(z)-1,max(z)+1],[0 0],'r');
   camera('zoom',2,'spinning');

   return
   
%==========================================================================

function CbFreeFwdStudy(obj)
%
   FreeStudy(obj,+1);
   return
   
function CbFreeBckStudy(obj)
%
   FreeStudy(obj,-1);
   return

function FreeStudy(obj,kappa)
%
% FREESTUDY   Free particle movement; kappa is either +1 (forward move)
%             or -1 (backward move)
%
   z = -5:0.2:5;
   
   lambda = z(end)-z(1);  hbar = 1;  m = 1;
   k = 2*pi/lambda * kappa;
   om = hbar*k*k/(2*m);
   
   fob = free(z,kappa);      % free particle with lambda = 10
   psi = wave(fob);          % wave function at time t=0
   
   sceene(obj,'3D');         % prepare 3D sceene
   
   pale(obj,z,psi,'r');
   
   t = pi/2/om;
   psi = wave(fob,t);        % wave function at time t=0
   pale(obj,z,psi,'y');
   
   t = pi/2/om * 2;
   psi = wave(fob,t);        % wave function at time t=0
   pale(obj,z,psi,'g');
   
   t = pi/2/om * 3;
   psi = wave(fob,t);        % wave function at time t=0
   pale(obj,z,psi,'b');
   
   camera('zoom',2,'spinning');

   return
   
%==========================================================================

function CbPacketStudyPale(obj)
%
   z = -5:0.025:5;
   gob = gauss(free(z,-15),1,0);   % k = -15, sigma = 1, center = 0
   sceene(obj);
   pale(obj,z,wave(gob,0),'r');
   camera('zoom',2,'spinning');
   return

function CbPacketStudyWing(obj)
%
   z = -5:0.025:5;
   gob = gauss(free(z,-15),1,0);   % k = -14, sigma = 1
   sceene(obj);
   psi = wave(gob,0);
   wing(obj,z,psi,'r');
   balley(obj,z,conj(psi).*psi/2,'r',1.0); 
   camera('zoom',4,'spinning');
   return

function CbPacketMovePale(obj)
%
   z = -5:0.025:5;
   gob = gauss(free(z,15),1,-2);   % k = -15, sigma = 1, center = -2

   az = -30;  tmax = 5;            % azimuth & max time
   sceene(obj,'psi');
   camera('zoom',2,'spin',az); camlight;

   terminate(gao,0);
   while(~stop(gao))
      [t,dt] = timer(gao,0.1);    % setup timer
      while (control(gao) & t < tmax)
         psi = wave(gob,t/tmax);
         P = conj(psi).*psi;

         pale(obj,z,psi,'r');
         %balley(obj,z,0.5*P,'r',1.0); 
      
         camera('spin',0.1);
         [t,dt] = wait(gao);
      end
      if (~stop(gao)) 
         update(gao,inf);                  % cleanup: delete all waves
      end
      az = az + 20;
   end
   return
   
function CbPacketMoveWing(obj)
%
   z = -5:0.025:5;
   gob = gauss(free(z,15),1,-2);   % k = -15, sigma = 1, center = -2

   az = -30;  tmax = 10;           % azimuth & max time
   sceene(obj,'psi');
   camera('zoom',2,'spin',az); camlight;

   terminate(gao,0);
   while(~stop(gao))
      [t,dt] = timer(gao,0.15);    % setup timer
      while (control(gao) & t < tmax)
         psi = wave(gob,t/tmax);
         P = conj(psi).*psi;

         wing(obj,z,psi,'r');
         balley(obj,z,0.5*P,'r',1.0); 
      
         camera('spin',0.1);
         [t,dt] = wait(gao);
      end
      if (~stop(gao)) 
         update(gao,inf);                  % cleanup: delete all waves
      end
      az = az + 20;
   end
   return
   
%==========================================================================

function CbFreeMove(obj)
%
% CBFREEMOVE   Free particle movement
%
   fob = free(-5:0.1:5,4);    % free particle, double nominal k

   sceene(obj,'3D');          % prepare 3D sceene
   hdl = wing(obj,zspace(fob),wave(fob),'r');
   camera('zoom',2,'pin');  camlight;
   delete(hdl);

   [t,dt] = timer(gao,0.1);  % setup timer
   while (control(gao))
      psi = wave(fob,t);
      wing(obj,zspace(fob),psi,'r');
      camera('spin',0.1);
      [t,dt] = wait(gao);
   end
   
   return
   
%==========================================================================

function CbWavePacket(obj)
%
% CBFREEMOVE   Free particle movement
%
   fob = free(-15:0.1:15,20);    % free particle, double nominal k
   z = zspace(fob);  sigma = 2;
   gob = gauss(fob,sigma,min(z)+3*sigma); 

   %fob = free(-15:0.05:15,2);    % free particle, double nominal k
   %z = zspace(fob);  sigma = 2;
   %gob = gauss(fob,sigma,max(z)-3*sigma); 
   
   sceene(obj,'3D');          % prepare 3D sceene
   hdl = wing(obj,zspace(gob),wave(gob),'r');
   camera('zoom',1.5,'pin');  
   delete(hdl);

   fac = 10;
   
   [t,dt] = timer(gao,0.1);  % setup timer
   while (control(gao))
      psi = wave(gob,t);
      P = conj(psi).*psi;

      wing(obj,zspace(gob),fac*psi,'r');
      balley(obj,z,fac*P,'g',1.0); 
      
      camera('spin',0.1);
      [t,dt] = wait(gao);
   end
   
   return

%==========================================================================
% Scattering
%==========================================================================

function CbTotalReflection(obj)
%
% CBTOTALREFLECTION   Total reflexion of wave packet
%
   z = (-10:0.05:10)';
   sigma = 1;  kappa = 15;   % std deviation and rel. wave number of packet
   
   gob1 = gauss(free(z,kappa),sigma,-3*sigma); 
   gob2 = gauss(free(z,-kappa),sigma,+3*sigma); 
   
   sceene(obj,'psi');        % prepare 3D sceene
   camera('spin',-50,'zoom',1);  

   well(obj,0,0.25,5);       % draw potential well
   fac = 5;
   
   [t,dt] = timer(gao,0.02); % setup timer
   while (control(gao))
      psi1 = wave(gob1,t);
      psi2 = wave(gob2,t);
      
      R = 1.0;
      psil = (psi1 + R*psi2) .* (z < 0);   % left side 
      psir = ([1-R] * psi1) .* (z >= 0);   % right side
      psi = psil + psir;
      P = conj(psi).*psi;

      wing(obj,z,fac*psi,'r');
      balley(obj,z,fac*P/3,'r',1.0); 
      
      camera('spin',0.1);
      [t,dt] = wait(gao);
   end
   
   return

%==========================================================================

function CbDeltaScattering(obj)
%
% CBDELTASCATTERING   Delta Scattering Demo
%
   colors = {'c','b','g','y','m','r'};
   nc = length(colors);
   
   z = (-15:0.015*5:15)';
   sigma = 1;  kappa = 15;   % std deviation and rel. wave number of packet

   fac = 3;  az = -40;  tmax = 5;       % azimuth & max time
   daz = 1;                             % delta azimuth
   alfa = 1/1.5;                        % weight of delta function
   
   sceene(obj,'psi');
   camera('zoom',1.5,'spin',az); camlight;

   terminate(gao,0);
   while(~stop(gao))
      gob = gauss(free(z,kappa),sigma,-1*sigma);    % -5*sigma
      idx = 1 + floor(nc*rand); 
      col = colors{idx};
      alfa = 45^(idx/nc)/3;
      
      [fob,bob,R] = scatter(gob,'delta',alfa); 
      
      
      [t,dt] = timer(gao,0.02,-tmax); % setup timer
      while (control(gao) & (t<=tmax))
         hdl = well(obj,0,0.25,alfa/3); % draw potential well
         update(gao,hdl);
         
         gpsi = wave(gob,t).*(z <0 ); % original wave function
         fpsi = wave(fob,t);          % forward scattered wave function
         bpsi = wave(bob,t);          % back scattered wave function
      
         psi = (gpsi + bpsi) .* (z < 0) + fpsi .* (z >= 0);  % resulting psi
         P = conj(psi).*psi;

         %wing(obj,z,fac*gpsi,'m');
         %wing(obj,z,fac*bpsi,'y');
         %wing(obj,z,fac*fpsi,'b');
         wing(obj,z,fac*psi,col);
         balley(obj,z,fac*P/3,col,1.0); 
      
         camera('spin',daz);
         [t,dt] = wait(gao);
         if (abs(t) > tmax/8)
            [t,dt] = wait(gao);
            if (abs(t) > tmax/6)
               [t,dt] = wait(gao);  [t,dt] = wait(gao);
               if (abs(t) > tmax/3)
                  [t,dt] = wait(gao); [t,dt] = wait(gao); [t,dt] = wait(gao);
               end
            end
         end
      end
      if (~stop(gao)) 
         update(gao,inf);                  % cleanup: delete all waves
      end
   end
   return

%==========================================================================
   
%eof   
   