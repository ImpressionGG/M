% study1 - Kolbendaempfung

   m = 1;       % kg, Masse Kappl + Kristall
   M = 100;     % kg, Kolbenmasse

   k1 = 8e8;    % kg/s2, Steifigkeit 1
   k2 = 40e8;   % kg/s2, Steifigkeit

% Berechnung der Polstellen

   a = k2/(2*m) + k1/(2*M);
   om1om1 = a + sqrt(a*a-k1*k2/m/M);
   om2om2 = a - sqrt(a*a-k1*k2/m/M);
   
   om1 = sqrt(om1om1);
   om2 = sqrt(om2om2);
   
   f1 = om1/(2*pi);
   f2 = om2/(2*pi);
   
   fprintf('eigen frequencies: f1 = %g Hz, f2 = %g Hz\n',f1,f2);
   
% study poles of total system depemdent of c1

   c1 = [0,1e2,1e4,1e6,1e8];
   
   %clf;
   for (i=1:length(c1))
      a4 = m*M;
      a3 = c1(i)*m;
      a2 = (k1+k2)*m + k2*M;
      a1 = k2*c1(i);
      a0 = k2*(k1+k2) - k2*k2;
      delta = [a4 a3 a2 a1 a0];
      
      s = roots(delta);
      
      fprintf('Damping c1 = %g:\n',c1(i));
      s
   end
   
   
   c1 = 10.^(-10:0.01:10);
   
   clf;
   null = [0 sqrt(-k2/m), -sqrt(-k2/m)];
   plot(real(s)/1000,imag(s)/1000,'bo');
   hold on;
   
   minreal = 0;
   for (i=1:length(c1))
      a4 = m*M;
      a3 = c1(i)*m;
      a2 = (k1+k2)*m + k2*M;
      a1 = k2*c1(i);
      a0 = k2*(k1+k2) - k2*k2;
      delta = [a4 a3 a2 a1 a0];
      
      s = roots(delta);
      minreal = min(minreal,max(real(s)));
      
      plot(real(s)/1000,imag(s)/1000,'rx');
   end
   set(gca,'xlim',[-50 1]);
   fprintf('minimum real values of eigen values: %g:\n',minreal);
   
