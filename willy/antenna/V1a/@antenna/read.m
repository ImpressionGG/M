function oo = read(o,varargin)         % Read ANTENNA Object From File
%
% READ   Read a ANTENNA object from file.
%
%             oo = read(o,'ReadLogLog',path) % .log data read driver
%
%          See also: ANTENNA, IMPORT
%
   [gamma,oo] = manage(o,varargin,@ReadAntDir);
   oo = gamma(oo);
end

%==========================================================================
% Read Driver for AntDir
%==========================================================================

function oo = OldReadAntDir(o)         % Read Driver for Antenna Dir   
   path = arg(o,1);
   [dir,file,ext] = fileparts(path);

      % ANTENNA Objekt erzeugen und mit Basisdaten versehen
      
   oo = antenna('ant');                % create 'ant' typed ANTENNA object
   oo.par.file = [file,ext];
   oo.par.dir = dir;
   oo.par.title = ['Antenna Data (',file,')'];
   
   gamma_all = [-90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90 ];
   nmax = length(gamma_all);   % nmax=19;
   
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

   for n=1:nmax
      fname=strcat(path,'/MX#',num2str(gamma_all(n)),'.dat');

      fid = fopen(fname,'r');          % Open text file
      s = textscan(fid,'%s','Delimiter','\n');
      
      a = s{1};
      c = 0;
      b = char(a(21));                 % ab zeile 22 Lesen
      n_az = strread(b,'%f');

      phi_meas_old = 0;
      for i=22:(22+n_az)
          c = c + 1;
          b = char(a(i));
          
          [phi_meas(c,n), rho_meas(c,n)] = strread(b,'%f,%f');
          if (phi_meas_old==phi_meas(c,n))
             phi_meas(c,n) = phi_meas(c,n)+0.1;
             phi_meas_old = phi_meas(c,n);
          end
          
          phi_meas_old = phi_meas(c,n);
          rho_meas(c,n) = rho_meas(c,n)+40;
          
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

         % damit die Interpolation beim ersten und letzten Element 
         % nicht davonläuft ...
         
      rho_i(1,n)=rho_meas(1,n);
      rho_i(jmax1,n)=rho_meas(n_az+1,n);
      rho_i(jmax1,n)=rho_meas(1,n);
      
      for j=1:jmax1
         gamma(j,n)=gamma_all(n);
      end % for j
   end % for n

      % brew X_meas, Y_meas, Z_meas, phi_eut, theta_eut, rho_eut, etc.
      
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

      %plot3(X_meas(:,n),Y_meas(:,n),Z_meas(:,n));
      %axis([-30 30 -30 30 -30 30]);
      %xlabel('X-ACHSE');
      %ylabel('Y-ACHSE');
      %zlabel('Z-ACHSE');
      %hold on;

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
   
      % Daten in das ANTENNA Objekt stopfen
      
   oo = data(oo,'X_meas,Y_meas,Z_meas',X_meas,Y_meas,Z_meas);
   oo = data(oo,'phi_meas,rho_meas',phi_meas,rho_meas);
   oo = data(oo,'phi_i,rho_i,gamma',phi_i,rho_i,gamma);
   oo = data(oo,'phi_eut,theta_eut,rho_eut',phi_eut,theta_eut,rho_eut);
   oo = data(oo,'n_theta,n_phi',nmax,n_az);
end
function oo = ReadAntDir(o)            % Read Driver for Antenna Dir   
   path = arg(o,1);
   [dir,file,ext] = fileparts(path);

      % ANTENNA Objekt erzeugen und mit Basisdaten versehen
      
   oo = antenna('ant');                % create 'ant' typed ANTENNA object
   oo.par.file = [file,ext];
   oo.par.dir = dir;
   oo.par.title = ['Antenna Data (',file,')'];
   
   gamma_all = [-90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90 ];
   nmax = length(gamma_all);   % nmax=19;
      
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

   for n=1:nmax
      fname=strcat(path,'/MX#',num2str(gamma_all(n)),'.dat');

      fid = fopen(fname,'r');          % Open text file
      s = textscan(fid,'%s','Delimiter','\n');
      
      a = s{1};
      c = 0;
      b = char(a(21));                 % ab zeile 22 Lesen
      n_az = strread(b,'%f');

      phi_meas_old = 0;
      for i=22:(22+n_az)
          c = c + 1;
          b = char(a(i));
          
          [phi_meas(c,n), rho_meas(c,n)] = strread(b,'%f,%f');
          if (phi_meas_old==phi_meas(c,n))
             phi_meas(c,n) = phi_meas(c,n)+0.1;
             phi_meas_old = phi_meas(c,n);
          end
          
          phi_meas_old = phi_meas(c,n);
          rho_meas(c,n) = rho_meas(c,n)+40;
          
          if rho_meas(c,n) < 0
              rho_meas(c,n) = 0.1; %bei 9 Probleme da  phi_eut zum Teil 0 !!  
          end %if rho
      end %for i

      fclose(fid);

   end % for n

   [m_phi,n_phi] = size(phi_meas);
   assert(m_phi==jmax);  assert(n_phi==nmax);

   [m_rho,n_rho] = size(rho_meas);
   assert(m_rho==jmax);  assert(n_rho==nmax);
   
   oo = data(oo,'phi,rho,gamma,n_az',phi_meas,rho_meas,gamma_all,n_az);
end
