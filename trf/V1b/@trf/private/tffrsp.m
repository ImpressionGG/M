function y = tffrsp(G,u,t)
%
% TFFRSP  Simulation of a system response. 
%
%            y = tffrsp(Hz,u)
%            y = tffrsp(Gq,u)
%            y = tffrsp(Gs,u,t)
%
%         Calculates the system response of a discrete time linear 
%         described by a z-type transfer function Hz or a q-type
%         transfer function.
%
%         To calculate the response of a continuous time system (des-
%         cribed by an s-type transfer function Gs) an additional time
%         vector must be provided.
%

%	  (Control toolbox 1.0c - Copyright 1990/1991 by Hugo Pristauz)
%
   %if ( G(1,2) == 0  |  G(2,2) == 0 ) G = can(G); end
   %if ( G(1,2) == 0  &  G(2,2) == 0 ) G = can(G); end

   G = tfftrim(G);


   m = max(size(G));
   num = G(1,2:m);
   den = G(2,2:m);

   [class,typ] = ddmagic(G);	Ts = G(2);

   if ( typ == 1)
      y = lsim(num,den,u,t);
   elseif ( typ == 2 )
      y = dlsim(num,den,u);
   elseif ( typ == 3 )
      Hz = tffztf(G);
      m = max(size(Hz));
      num = Hz(1,2:m);
      den = Hz(2,2:m);

      y = dlsim(num,den,u);
   end

% eof
