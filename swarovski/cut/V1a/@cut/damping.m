function oo = damping(o,D)
%
% DAMPING   Change stiffness parameters according to rotation angle
%
%             oo = damping(o,D)     % change Lehr©s damping measure 
%             oo = damping(o,0.002) % low damping
%             oo = damping(o,0.05)  % high damping
%
   if (nargin < 2)
      error("2 input args expected!")
   end
   
   oo = set(o,"modes.D",D);
   
   m = get(oo,"modes");           % rotation parameters
   c = 2*m.m*m.D*m.om0;           % [kg/s] D?mpfungsparameter
   oo = set(oo,"modes.c",c);

   oo = set(oo,"parameter.c1",c);
   oo = set(oo,"parameter.c2",c);
end
