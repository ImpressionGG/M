function f = fvonp(p,z,v)
%
% FvonP  Berechnung des exponenten p durchj propieren, so dass f(p) = 0
%
%           f = fvonp(p,[z0,z1,z2][v0,v1,v2])
%
%        bzw.
%
%           f = fvonp(p,[0,-75,-95][314.159,180.535,96.0523]);
%
   z0 = z(1);  z1 = z(2);  z2 = z(3);
   v0 = v(1);  v1 = v(2);  v2 = v(3);
   
   f = (v0^p-v1^p)/(z0-z1) - (v1^p-v2^p)/(z1-z2);
end
