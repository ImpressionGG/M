function out = rot(arg1)
%
% ROT       Rotation matrix for 2D rotation
%
%              T = rot(phi)
%              phi = rot(T)
%
%           Theory:
%                         [cos(phi) -sin(phi)]
%              Rot(phi) = [                  ]
%                         [sin(phi)  cos(phi)]
%
%           See also: ROBO, ROTX, ROTY, ROTZ, RPY
%
   if ( length(arg1) == 1 )
      
      phi = arg1;
      out = [  
               cos(phi) -sin(phi)
               sin(phi)  cos(phi)
            ];
          
    elseif all(size(arg1)==[2 2])
       
       T = arg1;
       if ( norm(T*T'-eye(2)) > 1e-10 )
          error('matrix is no pure rotation matrix - use RKS to decompose!')
       end
       
       phi = angle(T(1,1)+T(2,1)*sqrt(-1));
       out = phi;
    else
       error('arg1 must be scalar or quadratic matrix!')
    end
    
% eof