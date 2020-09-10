function schroedinger(obj)
%
% SCHROEDINGER Callbacks for demo menu 'Schroedinger', regarding the
%              Schroedinger Equation solutions
%
%              Topics
%              - infinite wave
%
   func = arg(obj);
   if isempty(func)
      mode = setting('schroedinger.func');
   else
      setting('schroedinger.func',func);
   end

   eval([func,'(obj);']);               % invoke callback
   return
   
%==========================================================================
% Infinte Wafes
%==========================================================================

function CbInfWaves1D(obj)
%
% INFWAVES1D  Demonstrate the solution of infinite waves under the condition
%           V(z,t) = V0 = const. We seek for solutions
%
%              Psi(z,t) = exp(i*(k*z-om*t))
%         
%           As the Schroedinger equation is
%
%              [-hbar^2/(2*m) d2/dz^2 + V(z,t)]*Psi = i*hbar d/dt Psi
%
%           Based on our asumption of the solution we get
%
%              [hbar^2/(2*m)*k^2 + V0] = hbar*om
%
%           Thus we get for any pair (p,V0)
%
%              om = 1/hbar * [hbar^2/(2*m)*k^2 + V0]
%
%           And for hbar = m = 1 we get the simple expression
%
%              om = k*k/2 + V0  (means: Etot = Ekin + Epot)
%
   lambda = pi/2;          % any lambda isa good!
   k = 2*pi/lambda;        % wave number (momentum)

   obj = option(obj,'global.nz',200);
   [t,z] = cspace(obj);

   V0 = 0:2:10;
   A0 = (V0(2) - V0(1))/2*0.9;;
   
   cls(obj);
   
   for (j = 1:length(V0))
      color(plot(z,0*z+V0(j)),'a');  hold on;
   end
   
   t = 0;  dt = 0.1;
   smo = timer(smart,dt);
   
   while (~stop(smo))
      smo = update(smo);
      for (j = 1:length(V0))
         om = k*k/2 + V0(j);
       
         iu = sqrt(-1);
         psi = exp(iu*(k*z - om*t));
         
         smo = update(smo,color(plot(z,V0(j)+A0*real(psi)),'b',3));
         smo = update(smo,color(plot(z,V0(j)+A0*imag(psi)),'r',1));
      end

      ylabel('Potential V0');
      xlabel('real part: blue,  imaginary part: red');
      title(sprintf('Wave function for constant k = %g and varying V0',k));
      t = t + dt;
      smo = wait(smo);
   end
   return

   
%==========================================================================

function CbInfWaves1P(obj)
%
% INFWAVES1P  Like INFWAVES1D but with phase color display
%
   lambda = pi/2;          % any lambda isa good!
   k = 2*pi/lambda;        % wave number (momentum)

   obj = option(obj,'global.nz',100);
   [t,z] = cspace(obj);

   V0 = 0:2:10;
   A0 = (V0(2) - V0(1))/2*0.9;;
   
   cls(obj);  hdl = [];
   
   for (j = 1:length(V0))
      color(plot(z,0*z+V0(j)),'a');  hold on;
   end
   
   [obj,map] = cmap(obj,'phase');
   
   t = 0;  dt = 0.1;
   smo = timer(smart,dt);
   
   delete(hdl);
   for (j = 1:length(V0))
      om = k*k/2 + V0(j);
       
      iu = sqrt(-1);
      psi = exp(iu*(k*z - om*t));
      
      for (l=1:length(z))
         hdl(j,l) = plot(z(l)*[1 1],V0(j)+2*A0*[0 1]);  hold on;
         color(hdl(j,l),'k',4);                        %set line width
      end

      ylabel('Potential V0');
      xlabel('real part: blue,  imaginary part: red');
      title(sprintf('Wave function for constant k = %g and varying V0',k));
   end

   while (~stop(smo))
      t = t + dt;
      for (j=1:length(V0))
         om = k*k/2 + V0(j);
         psi = exp(iu*(k*z - om*t));
         color(obj,hdl(j,:),psi);
      end
      smo = wait(smo);
   end
   return
   
%==========================================================================

%eof   
   