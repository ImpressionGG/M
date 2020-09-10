function oo = brew(o)
%
% BREW    Brew up raw data
%
%            oo = brew(o)
%
%         See also: ANTENNA, READ
%
   [phi,rho,gamma_all,n_az] = data(o,'phi,rho,gamma,n_az');

      % we use conistently m as the row size and n as the column size
      % of our data matrices, while i is row index and j is column index
      
   [m,n] = size(phi);
   
      % brew X_meas, Y_meas, Z_meas, phi_eut, theta_eut, rho_eut, etc.

   for j=1:n                           % iterate through all columns

         % Interpolation auf 10° Schritte
         
      x=phi(1:n_az+1,j);
      y=rho(1:n_az+1,j);
      phi_i(:,j) = 0:10:360;
      jmax1=size((phi_i),1);
      rho_i(:,j) =interp1(x,y,phi_i(:,j),'nearest'); 

         % damit die Interpolation beim ersten und letzten Element 
         % nicht davonläuft ...
         
      rho_i(1,j)=rho(1,j);
      rho_i(jmax1,j)=rho(n_az+1,j);
      rho_i(jmax1,j)=rho(1,j);
      
      for i=1:jmax1
         gamma(i,j)=gamma_all(j);
      end % for i

      %  polar(phi(j,:).*pi./180.+pi,rho(j,:));
      for i=1:jmax1
         X_meas(i,j) = cos(phi_i(i,j)*pi/180).*cos(gamma(i,j)*pi/180).*rho_i(i,j);
         Y_meas(i,j) = sin(phi_i(i,j)*pi/180).*cos(gamma(i,j)*pi/180).*rho_i(i,j);
         Z_meas(i,j) = sin(gamma(i,j)*pi/180).*cos(phi_i(i,j)*pi/180).*rho_i(i,j);    

         phi1= atan2(Y_meas(i,j),X_meas(i,j))*180/pi;

         if (phi1 < 0) 
            phi_eut(i,j)= 360 + phi1;
         else
            phi_eut(i,j)= phi1;    
         end %if     

         %phi_eut(i,j)= atan2(Y_meas(i,j),X_meas(i,j))*180/pi;
         theta_eut(i,j)=asin(Z_meas(i,j)/rho_i(i,j))*180/pi;
         rho_eut(i,j)=rho_i(i,j);
      end % for i 

      %plot3(X_meas(:,j),Y_meas(:,j),Z_meas(:,j));
      %axis([-30 30 -30 30 -30 30]);
      %xlabel('X-ACHSE');
      %ylabel('Y-ACHSE');
      %zlabel('Z-ACHSE');
      %hold on;

      %      Schnitt = [X_meas(:,j) Y_meas(:,j) Z_meas(:,j)];
      % Aktuelle Drehmatix berechnen
      %T(1,1)= cos(pi/180*gamma(j,1));
      %T(1,3)= sin(pi/180*gamma(j,1));
      %T(3,1)= -sin(pi/180*gamma(j,1));
      %T(3,3)= cos(pi/180*gamma(j,1));
      %T(2,2)= 1;
      %T_inv = inv(T);
      %Schnitt_eut = Schnitt*T_inv
   end %for j
   
      % Daten in das ANTENNA Objekt stopfen
      
   oo = o;
   oo = var(oo,'X_meas,Y_meas,Z_meas',X_meas,Y_meas,Z_meas);
   oo = var(oo,'phi_i,rho_i,gamma',phi_i,rho_i,gamma);
   oo = var(oo,'phi_eut,theta_eut,rho_eut',phi_eut,theta_eut,rho_eut);
   oo = var(oo,'n_theta,n_phi',n,n_az);
end
