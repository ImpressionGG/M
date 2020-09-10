% mapdemo

echo on

C = camera([0.2 0.2 0],[80 40],[30 30 30]*deg);
V = vchip;
F = photo(C,V);

figure   % new figure
vplt(F);  title('Originalobjekt')
dark; shg; aspect;
pause

C0 = map(V,F,0);
F0 = map(C0,V);
hold on; vplt(F0,'go'); shg
title('Lineare Approximation')
pause

C1 = map(V,F,1);
F1 = map(C1,V);
hold on; vplt(F1,'ro'); shg
title('Affine Approximation')
pause

fac = 20;
V = vchip * fac;
F = photo(C,V);

figure;    % new figure
vplt(F,'g'); aspect; dark; shg
title(sprintf('%g * so grosses Objekt!',fac))
pause

C1 = map(V,F,1);
F1 = map(C1,V);
hold on; vplt(F1,'ro'); shg
title('Affine Approximation')
pause

C2 = map(V,F,2);
F2 = map(C2,V);
hold on; vplt(F2,'co'); shg
title('Nichtlineare Approximation 2. Ordnung')
echo off