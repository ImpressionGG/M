function oo = rotate(o,beta)
%
% ROTATE   Change stiffness parameters according to rotation angle
%
%             oo = rotate(o,degrees)   % change stiffness coefficients
%             oo = rotate(o,90)        % "Blattl-Lage"
%             oo = rotate(o,75)        % "75?-Lage"
%
   if (nargin < 2)
      error("2 input args expected!")
   end
   
   oo = set(o,"rotation.beta",beta);
   
   r = get(oo,"rotation");             % rotation parameters
   beta = r.beta * pi/180;             % angle in radians
   
   Kn = diag([r.ka,r.kt]);             % stiffness nominal matrix
   
   C = cos(beta);  S = sin(beta);
   T = [C, -S; S C];
   K = T'*Kn*T;

   oo = set(oo,"parameter.k11",K(1,1));
   oo = set(oo,"parameter.k12",K(1,2));
   oo = set(oo,"parameter.k21",K(2,1));
   oo = set(oo,"parameter.k22",K(2,2));
end
