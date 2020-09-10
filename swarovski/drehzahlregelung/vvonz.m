function v = vvonz(z)
%
% VvonZ  Berechne
%
%           v = vvonz(z)
%
   v0 = pi*100;
   v1 = 180.535;
   z0 = 0;
   z1 = -75;
   
   p = 2.4890222;        % durch Probieren ermittelt
   d = v0^p;
   k = (v0^p-v1^p)/(z0-z1);

   v = (k*z+d).^(1/p);
end
