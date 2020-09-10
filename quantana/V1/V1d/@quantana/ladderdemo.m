function ladderdemo(obj)
%
% LADDERDEMO   Callbacks for demo menu 'Ladder'
%
%             Topics
%             - how ladder operators work
%
   func = arg(obj);
   if isempty(func)
      mode = setting('ladder.func');
   else
      setting('ladder.func',func);
   end

   eval([func,'(obj);']);               % invoke callback
   return

%==========================================================================
% Particle Creation
%==========================================================================

function CbCreation(obj)
%
% CBCREATION   Particle in a Box: display eigen functions
%
   [eob,qob,lob,z,nmin,nmax,vis] = setup(obj,1);  % setup environment

   sceene(obj,'psi',z); 
   camera('zoom',1.5);  Kw = 4;  Kb = 15;  Kt = 1;
   colormap(hsv);
   
   [t,dt] = timer(gao,0.1);  n = nmin;  t0 = 0;
   while (control(gao))
      [nt,col] = progress(lob,n,t-t0);  % progress of creation operator      
      if (nt == n+1 && n < nmax)
         n = n+1;  t0 = t;
      end
      
      [psi,E] = eig(qob,nt+1,Kt*t);

      wing(obj,z,Kw*psi,col);
      balley(obj,z,Kb*prob(psi),col);

      if (vis)
         plot(lob,nt,t-t0);
      end
  
      camera('spin',Kt*1);
      [t,dt] = wait(gao);
   end
   return

%==========================================================================
% Particle Anihilation
%==========================================================================

function CbAnihilation(obj)
%
% CBANIHILATION   Particle in a Box: display eigen functions
%
   [eob,qob,lob,z,nmin,nmax,vis] = setup(obj,-1); % setup environment
   
   sceene(obj,'psi',z); 
   camera('zoom',1.5);  Kw = 4;  Kb = 15;  Kt = 1;
   colormap(hsv);
   
   [t,dt] = timer(gao,0.1);  n = nmax;  t0 = 0;
   while (control(gao))
      [nt,col] = progress(lob,n,t-t0);  % progress of creation operator      
      if (nt == n-1 && n > nmin+1)
         n = n-1;  t0 = t;
      end
      
      [psi,E] = eig(qob,nt,Kt*t);

      Kb = min(Kb,max(abs(psi)*20));
      
      wing(obj,z,Kw*psi,col);
      balley(obj,z,Kb*prob(psi),col);
      
      if (vis)
         plot(lob,nt,t-t0);
      end
      
      camera('spin',Kt*1);
      [t,dt] = wait(gao);
   end
   return

%==========================================================================
% Particle Creation & Anihilation
%==========================================================================

function CbCreationAnihilation(obj)
%
   [eob,qob,lob,z,nmin,nmax,vis] = setup(obj,0);  % setup environment
   cre = ladder(eob,+1);
   ani = ladder(eob,-1);
   
   sceene(obj,'psi',z); 
   camera('zoom',1.5);  Kw = 4;  Kb = 15;  Kt = 1;
   colormap(hsv);
   
   n = nmin;  lob = cre;                % start with creation from n = nmin 
   [t,dt] = timer(gao,0.1);  t0 = 0;
   while (control(gao))
      [nt,col] = progress(lob,n,t-t0);  % progress of creation operator
      [lob,n,t0] = transition(lob,cre,ani,t,t0,n,nt,nmin,nmax);
      
      [psi,E] = eig(qob,nt+1,Kt*t);

      wing(obj,z,Kw*psi,col);
      balley(obj,z,Kb*prob(psi),col);

      if (vis)
         plot(lob,nt,t-t0);
      end
      
      camera('spin',Kt*1);
      [t,dt] = wait(gao);
   end
   return

function [lob,n,t0] = transition(lob,cre,ani,t,t0,n,nt,nmin,nmax)   
%
% TRANSITION    Make transition to next number
%
   if (data(lob,'mode') > 0)            % creation
      lob = cre;
      if (nt == n+1)
         n = n+1;  t0 = t;
         if (n >= nmax)
            lob = ani;
         end
      end
   else                                 % anihilation
      [nt,col] = progress(ani,n,t-t0);  % progress of creation operator
      lob = ani;
      if (nt == n-1)
         n = n-1;  t0 = t;
         if (n <= nmin)
            lob = cre;
         end
      end
   end
   return
    
%==========================================================================
% Auxillary functions
%==========================================================================

function [eob,qob,lob,z,nmin,nmax,vis] = setup(obj,mode)
%
% SETUP     Setup environment
%
   nmax  = either(option(obj,'ladder.nmax'),3);
   nmin  = either(option(obj,'ladder.nmin'),0);
   trans = either(option(obj,'ladder.trans'),8);
   dwell = either(option(obj,'ladder.dwell'),4);
   omega = either(option(obj,'ladder.omega'),1);
   vis   = either(option(obj,'ladder.operator'),1);

   eob = envi(obj,'harmonic','zspace',-5:0.1:5,'omega',omega);
   eob = set(eob,'nmax',nmax,'nmin',nmin);
   eob = set(eob,'trans',trans,'dwell',dwell);

   qob = quon(eob);                   % harmonic oscillator
   lob = ladder(eob,mode);            % creation & anihilation operator
   z = get(qob,'zspace');             % get z-space
   return

%==========================================================================

function y = sat(x,xmin,xmax)
%
% SAT     Saturation function
%
   if (nargin == 1)
      xmin = -1;  xmax  = 1;
   end
   
   if (nargin == 2)
      xmax = abs(xmin);  xmin = -xmax;
   end
   
   y = min(xmax,max(xmin,x));
   return

%==========================================================================

function ball(obj,x0,phi,r)
%
% BALL   Draw a ball
%
   if (nargin < 2) x0 = 0; end
   if (nargin < 3) phi = x0; end
   if (nargin < 4) r = 1; end
   
   [X0,Y0,Z] = sphere(150);
 
   smo = smart(imread('image/opcreation.jpg'));
   
   x = cos(phi)*X0 - sin(phi)*Y0 + x0;
   y = sin(phi)*X0 + cos(phi)*Y0;
   hdl = surf(r*x,r*y,r*Z,'edgecolor','none');
   alpha(hdl,0.5);
   update(gao,hdl);
   texture(smo,hdl);
   return

%eof   
   