% Antennendiagramm 
% Rev 5
% 
%
% EUT Koordinatensystem 
% X_eut= ( e_x_eut,e_y_eut,e_Z_eut)
% x_eut  Richtung Antenne auf Tischebene  (phi =0°) 
% y_eut  Richtung Türe auf Tischebene  (phi = 90°) 
% z_eut  zur Decke 
% Kippachse für 3D Elevation liegt auf der y_eut Achse
% durch Drehmatrix M_kipp gegeben. 
% Kippwinkel gamma=0°  EUT in Antennenebene
% Kippwinkel gamma=90° EUT schaut nach oben (Decke)  
% Kippwinkel gamma=0°  EUT schaut nach unten (Boden)
% Drehung des EUT durch Drehung der Ebene (x_eut x y_eut) um die Achse z_eut
% Gemessen wird damit die gekippten EUT Koordinaten 
%  x_eut_gekippt  
%  y_eut_gekippt
%  z_eut_gekippt
%  X_eut= ( e_x_eut_gekippt,e_y_eut_gekippt,e_z_eut_gekippt)

%  X_eut_gekippt = X_eut * M_kipp
%  Rücktransformation der Messwerte in EUT Koordinaten 
%  X_eut_gekippt * inv(M_kipp) = X_eut
% 
% Antennen Koordinatensystem 

clear all;
mapping =1;
%using predefined mesh
% ===================================================
%gamma_all = [-50 -40 -30 -20 -10 0 10 20 30 40 50 ];
%nmax=11;
gamma_all = [-90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90 ];
nmax=19;
%gamma_all = [-90 -75 -60 -45 -30 -15  0 15 30 45 60 75 90 ];
%nmax=13;
jmax=160;

% Drehmatrix erzeugen
M_kipp =[1 0 1
        0 1 0
       -1 0 1];
% =====================

phi_meas =  zeros(jmax,nmax);
rho_meas =  zeros(jmax,nmax);
phi_i(:,nmax) = 0:10:360;
jmax1=size((phi_i),1);
phi_i=zeros(jmax1,nmax);
rho_i=ones(jmax1,nmax);

X_meas =  zeros(jmax1,nmax);
Y_meas =  zeros(jmax1,nmax);
Z_meas =  zeros(jmax1,nmax);
X =  zeros(jmax1,nmax);
Y =  zeros(jmax1,nmax);
Z =  zeros(jmax1,nmax);

%###
caption = 'Dateien einlesen';
[files, dir] = fselect(corazon,'d','',caption);
subdir = 'AD_Horizontal';


for n=1:nmax
   %fname=strcat('D:\__2017\Berichte\2017-10\2017-10-08_NUKI_Antennendiagramm\AD_Horizontal\MX#',num2str(gamma_all(n)),'.dat');
   fname=strcat(dir,'/',subdir,'/MX#',num2str(gamma_all(n)),'.dat');

   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M6_SN9870\#',num2str(gamma_all(n)),'#H.dat');
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M6_SN9870\#',num2str(gamma_all(n)),'#V.dat');
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M5_SN2B72\#',num2str(gamma_all(n)),'#H.dat');
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M5_SN2B72\#',num2str(gamma_all(n)),'#V.dat');
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M4_SN2D20\#',num2str(gamma_all(n)),'#H.dat');
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M4_SN2D20\#',num2str(gamma_all(n)),'#V.dat');
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M3_SN9A07\#',num2str(gamma_all(n)),'#H.dat')
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M3_SN9A07\#',num2str(gamma_all(n)),'#V.dat')
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M2_SN37D7\#',num2str(gamma_all(n)),'#H.dat')
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M2_SN37D7\#',num2str(gamma_all(n)),'#V.dat');
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M1_SN9298\#',num2str(gamma_all(n)),'#V.dat');
   %fname=strcat('D:\__2013\Berichte\2013-07\2013-07-05-MICROTRONICS-Q_Gate\M1_SN9298\#',num2str(gamma_all(n)),'#H.dat');

   fid = fopen(fname,'r');             % Open text file% 
   s = textscan(fid,'%s','Delimiter','\n')
   a=s{1}
   c = 0
   b=char(a(21));                      % ab zeile 22 Lesen
   n_az=strread(b,'%f')

   phi_meas_old=0
   for i=22:(22+n_az)
       c = c + 1;
       b=char(a(i));
       [phi_meas(c,n) rho_meas(c,n)]=strread(b,'%f,%f');
       if (phi_meas_old==phi_meas(c,n))
       phi_meas(c,n)= phi_meas(c,n)+0.1;
       phi_meas_old=phi_meas(c,n);
       end
       phi_meas_old=phi_meas(c,n);
       rho_meas(c,n)=rho_meas(c,n)+40;
       if rho_meas(c,n) < 0
           rho_meas(c,n) = 0.1; %bei 9 Probleme da  phi_eut zum Teil 0 !!  
       end %if rho
   end %for i
   fclose(fid);

   % Interpolation auf 10° Schritte 
   x=phi_meas(1:n_az+1,n);
   y=rho_meas(1:n_az+1,n);
   phi_i(:,n) = 0:10:360;
   jmax1=size((phi_i),1);
   rho_i(:,n) =interp1(x,y,phi_i(:,n),'nearest'); 

   % damit die Interpolation beim ersten und letzten Element nicht davonläuft 
   rho_i(1,n)=rho_meas(1,n);
   rho_i(jmax1,n)=rho_meas(n_az+1,n);
   rho_i(jmax1,n)=rho_meas(1,n);
   for j=1:jmax1
      gamma(j,n)=gamma_all(n);
   end % for j
end % for n

% Rohdaten der einzelnen Ebenenschnitte 
hold off 
for n=1:nmax
   %  polar(phi_meas(n,:).*pi./180.+pi,rho_meas(n,:));
    for j=1:jmax1
    X_meas(j,n) = cos(phi_i(j,n)*pi/180).*cos(gamma(j,n)*pi/180).*rho_i(j,n);
    Y_meas(j,n) = sin(phi_i(j,n)*pi/180).*cos(gamma(j,n)*pi/180).*rho_i(j,n);
    Z_meas(j,n) = sin(gamma(j,n)*pi/180).*cos(phi_i(j,n)*pi/180).*rho_i(j,n);    

    phi1= atan2(Y_meas(j,n),X_meas(j,n))*180/pi;
    if (phi1 < 0) 
        phi_eut(j,n)= 360 + phi1;
    else
        phi_eut(j,n)= phi1;    
    end %if     
    %phi_eut(j,n)= atan2(Y_meas(j,n),X_meas(j,n))*180/pi;
    theta_eut(j,n)=asin(Z_meas(j,n)/rho_i(j,n))*180/pi;
    rho_eut(j,n)=rho_i(j,n);
    end % for j 
    plot3(X_meas(:,n),Y_meas(:,n),Z_meas(:,n));
    axis([-30 30 -30 30 -30 30]);
    xlabel('X-ACHSE');
    ylabel('Y-ACHSE');
    zlabel('Z-ACHSE');
    hold on;
   %      Schnitt = [X_meas(:,n) Y_meas(:,n) Z_meas(:,n)];
   % Aktuelle Drehmatix berechnen
   %T(1,1)= cos(pi/180*gamma(n,1));
   %T(1,3)= sin(pi/180*gamma(n,1));
   %T(3,1)= -sin(pi/180*gamma(n,1));
   %T(3,3)= cos(pi/180*gamma(n,1));
   %T(2,2)= 1;
   %T_inv = inv(T);
   %Schnitt_eut = Schnitt*T_inv
end %for n

n_theta = nmax; % Samples on Elevation
n_phi = n_az;
if(mapping > 0)
    az= phi_eut.*pi/180;
    el= (theta_eut.*pi/180);
    azs = 0*pi/180;
    azi = 10*pi/180;
    aze = 360*pi/180;
    els = -90*pi/180;
    eli = 10*pi/180;
    ele = 90*pi/180;
    [Az_m El_m] = meshgrid(azs:azi:aze,els:eli:ele);
    %Interpolate the nonuniform gain data onto the uniform grid
    Zi = griddata(az,el,rho_eut,Az_m,El_m,'cubic');
    %Generate the cartesian coordinates
    [x y z] = sph2cart(Az_m,El_m,Zi);
    %Plot surface and colour according to Zi
    surf(x,y,z,Zi,'FaceColor','interp',...
   'EdgeColor','none',...
   'FaceLighting','phong');
   %  surf(X,Y,Z); % wireframe)
else  
   %X_meas = cos(phi_meas.*pi/180).*cos(gamma.*pi/180).*rho_meas;
   % = sin(phi_meas.*pi/180).*cos(gamma.*pi/180).*rho_meas;
   %Z_meax = sin(gamma.*pi/180).*rho_meas;
   %[X Y Z] = [X_meas;Y_meas;Z_meas];
   X=X_meas;
   Y=Y_meas;
   Z=Z_meas;
   %surf(X,Y,Z,'FaceColor','interp',...
   %   'EdgeColor','none',...
   %   'FaceLighting','phong');
   surf(X,Y,Z,rho_meas,'FaceColor','interp',...
      'EdgeColor','none',...
      'FaceLighting','phong');
   sur2stl('testsurf1.stl', X , Y , Z,'ascii');
   %  surf(X,Y,Z); % wireframe
   %daspect([5 5 5]);
   %%mesh(X,Y,Z);
end %if 

camlight right
axis vis3d;
%rotate3D on;
ax=gca;
%fig2u3d(ax);
figure2xhtml;


