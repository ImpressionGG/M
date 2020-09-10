% nreg.m - Drehzahlregelung fuer Glasformprozess

   d0 = 4.7;  % mm - Eintrittsdurchmesser in Schneidwerkzeug
   d1 = 6.2;  % mm - Durchmesser an Mess-Stelle 1
   d2 = 8.5;  % mm - Durchmesser an Mess-Stelle 2
   
   A0 = d0^2*pi/4;
   A1 = d1^2*pi/4;
   A2 = d2^2*pi/4;
   
   N  = 60;             % (1) - Anzahl der Schneidkammern
   n  = 1;              % m/s - Drehzahl des Schneidrades
   R  = 50;             % mm  - Radius Schneidrad
   V  = 45.8;           % mm3 - Volumen des Artikel
   
   T  = 2*pi*R/N;       % Umfangsteilung
   vu = R*2*pi*n;       % Umfangsgeschwindigkeit Schneidrad
   Vp0 = N*V*n;         % Volumensnutzenstrom
   rho = vu*A0/Vp0-1;   % Faktor für Zusatzmaterial
   Vextra = V*rho;      % Extravolumen per Artikel
   Vp = N*V*n*(1+rho); 

% z-Koordinaten

   z0 = 0;              % mm - z-Koordinate Eintritt Schneidrad
   z1 = -75;            % mm - z-Koordinate Mess-Stelle 1
   z2 = -75-20;         % mm - z-Koordinate Mess-Stelle 2

% Geschwindigkeiten

   v0 = Vp/A0;          % mittlere Strang-Geschwindigkeit am Schneidrad
   v1 = Vp/A1;          % mittlere Strang-Geschwindigkeit am Schneidrad
   v2 = Vp/A2;          % mittlere Strang-Geschwindigkeit am Schneidrad
   
% approximation of v(z)
%
% Ansatz: [v(z)]^a = k*z + d
% 
% Setze:   v0^p - v1^p = k*(z0-z1)
%          v1^p - v2^p = k*(z1-z2)
%
% somit:   (v0^p-v1^p)/(z0-z1) = (v1^p-v2^p)/(z1-z2)
%
% oder     f(p) = (v0^p-v1^p)/(z0-z1) - (v1^p-v2^p)/(z1-z2) = 0

   zz = [z0 z1 z2];
   vv = [v0 v1 v2];
   p = 2.4890222;        % durch Probieren ermittelt
   ok = fvonp(p,zz,vv);
   
   d = v0^p;
   k = (v0^p-v1^p)/(z0-z1);
   
% Totzeit

   Tapprox = (1/v0+1/v1)/2 * (z0-z1);   % Näherung
   Ttot = integral(@(z)(1./vvonz(z)),z1,z0);
   
% Verlauf v(z)

   figure;               % new figure
   plot([z2:z0],vvonz([z2:z0]),'b');
   hold on
   plot([z2 z1 z0],[v2 v1 v0],'ro');
   title(sprintf('v(z) = (k*z + d)^(1/p) fuer p = %g',p));
   xlabel('z - Position entlang des Glasstranges');
   ylabel('v - mittlere Stranggeschwindigkeit (mm/s)');

% Verlauf 1/v(z) (fuer Integration benoetigt)

   figure;               % new figure
   plot([z2:z0],1./vvonz([z2:z0]),'b');
   hold on
   plot([z2 z1 z0],1./[v2 v1 v0],'ro');
   title(sprintf('v(z) = (k*z + d)^(1/p) fuer p = %g (Laufzeit(1->0) = %g s)',...
                 p,Ttot));
   xlabel('z - Position entlang des Glasstranges');
   ylabel('1/v - Kehrwert der mittleren Stranggeschwindigkeit (s/mm)');

% zeige dass v(z)^p = k*z + d

   figure;               % new figure
   plot([z2:z0],vvonz([z2:z0]).^p,'b');
   hold on
   plot([z2 z1 z0],[v2^p v1^p v0^p],'ro');
   title(sprintf('v(z)^p = k*z + d fuer p = %g',p));
   xlabel('z - Position entlang des Glasstranges');
   ylabel('v^p - mittlere Stranggeschwindigkeit hoch p');

% print results

   fprintf('d0 = %g mm   Eintrittsdurchmesser in Schneidwerkzeug\n',d0);
   fprintf('d1 = %g mm   Durchmesser an Mess-Stelle 1\n',d1);
   fprintf('d2 = %g mm   Durchmesser an Mess-Stelle 2\n',d2);
   fprintf('\n');
   fprintf('A0 = %g mm2   Querschnitt Eintritt Schneidrad\n',A0);
   fprintf('A1 = %g mm2   Querschnitt an Mess-Stelle 1\n',A1);
   fprintf('A2 = %g mm2   Querschnitt an Mess-Stelle 2\n',A2);
   fprintf('\n');
   fprintf('N  = %g       Anzahl der Schneidkammern\n',N);
   fprintf('n  = %g m/s   Drehzahl des Schneidrades\n',n);
   fprintf('R  = %g mm    Radius Schneidrad\n',R);
   fprintf('\n');
   fprintf('V  = %g mm3   Volumen des Artikels\n',V);
   fprintf('\n');
   fprintf('T  = %g mm    Umfangsteilung\n',T);
   fprintf('vu = %g mm/s  Umfangsgeschwindigkeit Schneidrad\n',vu);
   fprintf('Vp0 = %g mm3/s Volumensnutzenstrom\n',Vp0);
   fprintf('rho = %g      Faktor für Zusatzmaterial\n',rho);
   fprintf('Vextra = %g mm    Extravolumen per Artikel\n',Vextra);
   fprintf('Vp = %g mm3/s Volumensstrom\n',Vp);
   fprintf('\n');   
   fprintf('z0 = %g mm z-Koordinate Eintritt Schneidrad\n',z0);
   fprintf('z1 = %g mm z-Koordinate Mess-Stelle 1\n',z1);
   fprintf('z2 = %g mm z-Koordinate Mess-Stelle 2\n',z2);
   fprintf('\n');
   fprintf('v0 = %g mm/s Geschwindigkeit Eintritt Schneidrad\n',v0);
   fprintf('v1 = %g mm/s Geschwindigkeit an Mess-Stelle 1\n',v1);
   fprintf('v2 = %g mm/s Geschwindigkeit an Mess-Stelle 2\n',v2);
   fprintf('\n');
   fprintf('p = %g    Exponent fuer v(z)^p = k*z+d\n');
   fprintf('f(p,[z0 z1 z2],[v0 v1 v2] = %g  Kontrolle\n',fvonp(p,zz,vv));
   fprintf('k = %g    Steigung der Funktion v^p\n',k);
   fprintf('d = %g    Ordinatenabschnitt der Funktion v^p\n',d);
   fprintf('\n');
   fprintf('Ttot = %g s     Totzeit von z1 nach z2\n',Ttot);
   fprintf('Ttot°= %g s     Totzeit von z1 nach z2 (approx.)\n',Tapprox);
