function [arg1,out2,out3] = rpy(phi,theta,psi)
%
% RPY       Calculate Roll-Pitch-Yaw rotation matrix.
%
%              T = rpy(phi,theta,psi)     % angels in radians
%
%              [phi,theta,psi] = rpy(T)   % extract angles
%              phi_theta_psi = rpy(T)     % extract angles
%              rpy(T)                     % print angles
%
%           Basic rotations:
%
%              Roll(phi) = RotZ(phi)
%              Pitch(theta) = RotY(theta)
%              Yaw(psi) = RotX(psi)
%
%           RPY(phi,theta,psi) = RotZ(phi) * RotY(theta) * RotX(psi)
%
%           See also: ROBO, ROT, ROTX, ROTY, ROTZ
%
   if (nargin > 1)   % calculate rotation matrix
   
      if ( nargin ~= 3 ) error('3 input args expected!'); end
   
      arg1 = rotz(phi) * roty(theta) * rotx(psi);
      
   else % extract angles!
      
      T = phi;                   % first argument is rotation matrix
      
      theta = asin(-T(3,1));
      Ty1 = roty(theta);         % theta can be both pricipal value of asin()
      Ty2 = roty(pi-theta);      % or complement to pi!
      
      if any(abs(T(1:2,1)) > eps)
         
         phi = atan(T(2,1)/T(1,1));
         Tz1 = rotz(phi);        % phi can be both pricipal value of atan()
         Tz2 = rotz(phi+pi);     % or atan+pi!
         
            % calculate variants
            
         Tx11 = Ty1\(Tz1\T);
         Tx12 = Ty1\(Tz2\T);
         Tx21 = Ty2\(Tz1\T);
         Tx22 = Ty2\(Tz2\T);
            
            % we expect Txij to be  
            %                  [1  0  0]
            %    Txij = RotX = [0  a  b]
            %                  [0  c  d]
            %
            % what means Txij([1:4,7] = [1 0 0 0 0]
            
         idx = [1:4,7];  e = [1 0 0 0 0];  epsi = 1e-3;
            
         if ( norm(Tx11(idx)-e) < epsi )
            Tx = Tx11;  Ty = Ty1;  Tz = Tz1;
         elseif ( norm(Tx12(idx)-e) < epsi )
            Tx = Tx12;  Ty = Ty1;  Tz = Tz2;
         elseif ( norm(Tx21(idx)-e) < epsi )
            Tx = Tx21;  Ty = Ty2;  Tz = Tz1;
         elseif ( norm(Tx22(idx)-e) < epsi )
            Tx = Tx22;  Ty = Ty2;  Tz = Tz2;
         else
            error('calculation failed!')
         end
         
         psi   = angle(Tx(2,2)+Tx(3,2)*sqrt(-1));
         theta = angle(Ty(1,1)+Ty(1,3)*sqrt(-1));
         phi   = angle(Tz(1,1)+Tz(2,1)*sqrt(-1));
         
         err = norm(T - rpy(phi,theta,psi)); 
         if ( err > 1e-10 )
            fprintf('warning: rpy extraction unprecise (error = %g)!',err)
         end
      else  % theta = pi/2 or theta = -pi/2
         
         theta = -T(3,1)*pi/2;  % the real value of theta
         error('cannot proceed!')
      end
      
      if (nargout == 0)
         fprintf('\troll:  %g (%g m°)\n',phi,1000*phi*180/pi);
         fprintf('\tpitch: %g (%g m°)\n',theta,1000*theta*180/pi);
         fprintf('\tyaw:   %g (%g m°)\n',psi,1000*psi*180/pi);
      elseif nargout == 1
         arg1 = [phi theta psi];
      else
         arg1 = phi;  out2 = theta;  out3 = psi;
      end
   end
   
% eof   