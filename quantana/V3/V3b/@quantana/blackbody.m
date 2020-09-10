function blackbody(obj)
%
% BLACKBODY   Callbacks for demo menu 'blackbody'
%
%             Topics
%             - Planck Ball
%             - Boltzmann distribution simulation
%
   func = args(obj,1);
   if isempty(func)
      mode = setting('blackbody.func');
   else
      setting('blackbody.func',func);
   end

   eval([func,'(obj);']);               % invoke callback
   return

%==========================================================================   
% Planck Ball
%==========================================================================   

function CbPlanckBall(obj)
%
% CBPLanckBall   Display a ball with Planck's image
%
   r = 2;
   sceene(quantana,'sphere',r);
   %camera('lift',-30);
   %camera('zoom',1.0,'pin');
   
   [x0,y0,z] = sphere(150);

   dir = upath(smart,which('quantana'));
   dir(min(findstr(dir,'/@quantana')):end) = '';
   smo = smart(imread([dir,'/image/planck.jpg']));
   
   fps = 20;
   frames = 100;
   M = moviein(frames);
  
   [t,dt] = timer(gao,0.02);            % setup timer
   phi = 0; dphi = 0.02;
   i = 1;
   while (i <= frames && ~stop(gao))                   % still continue 
      update(gao);
      phi = phi + dphi;
      x = cos(phi)*x0 - sin(phi)*y0;
      y = sin(phi)*x0 + cos(phi)*y0;
      hdl = surf(r*x,r*y,r*z,'edgecolor','none');
      update(gao,hdl);
      texture(smo,hdl);
      camera('home');
      M(:,i) = getframe;

      %camera('spin',0.8);
      %camera('zoom',1+sin(t)/2);
      [t,dt] = wait(gao);               % wait for timer tick
      i = i+1;
   end
   
   %movie(M,3,fps)
   %movie2avi(M,'PlanckBall','fps',fps,'Compression', 'none');

   return
   
   %eof   
   