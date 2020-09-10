function [arg1,K,R,V] = hskr(Th)
%
% HSKR      SKR factorizaton of a homogeneous 3H or 4H transformation matrix.
%
%              [S,K,R,V] = hskr(M)     % SKR factorization: M = S*K*R*V
%
%              hskr(M)             % display SKR parameters in text form
%              par = hskr(M)       % SKR parameters
%
%           SKR parameters of a 3H matrix:
%
%              par(1): phi         % rotation angle
%              par(2): kx          % scale x
%              par(3): ky          % scale y
%              par(4): s           % shear
%              par(5): vx          % translation x
%              par(6): vy          % translation y
%
%           SKR parameters of a 4H matrix:
%
%              par(1): phi         % roll angle
%              par(2): theta       % pitch angle
%              par(3): psi         % yaw angle
%              par(4): kx          % scale x
%              par(5): ky          % scale y
%              par(6): kz          % scale z
%              par(7): sxy         % shear xy
%              par(8): sxz         % shear xz
%              par(9): syz         % shear yz
%              par(10): vx         % translation x
%              par(11): vy         % translation y
%              par(12): vz         % translation z
%
%           To a given matrix T calculate the decomposed matrices R,K,S,V and
%
%                T = S*K*R*V
%           and
%                S ... shear matrix (upper triangular with all diagonal elements =1)
%                K ... scale matrix (K = diag(ki))
%                R ... rotation matrix (orthonormal: R'*R = R*R' = E)
%                V ... translation matrix
%
%           See also: ROBO, RKS, SKR, HRKS, HROT, SCALE, SHEAR, HTRAN
%
   [m,n] = size(Th);

   if ( m ~= n ) error('arg1 must be a quadratic matrix'); end
   
   if ( m == 3 )
      if  any(abs(Th(3,:)-[0 0 1])>1000*eps)
         error('last row of 3H matrix expected to be [0 0 1]!');
      end
      [M,v] = ihom(Th);
      [S,K,R] = skr(M);
      
      phi = rot(R);  kx = K(1,1);  ky = K(2,2);  s = S(1,2);
      if ( nargout == 0 )
         fprintf('\trotation:      %g (%g m°)\n',phi,1000*phi/deg);
         fprintf('\tscale x:       %g (%g µm/dm)\n',kx,(kx-1)*1e5);
         fprintf('\tscale y:       %g (%g µm/dm)\n',ky,(ky-1)*1e5);
         fprintf('\tshear:         %g (%g µm/dm)\n',s,s*1e5);
         if ( any(v~=0) )
            fprintf('\ttranslation x: %g\n',v(1));
            fprintf('\ttranslation y: %g\n',v(2));
         end
      elseif ( nargout == 1 )
         arg1 = [phi kx ky s v(1) v(2)];
      else
         arg1 = h2m(S,0);  K = h2m(K,0);  R = h2m(R,0);  V = h2m(eye(2),v);
      end
         
   elseif ( m == 4 )
      if  any(abs(Th(4,:)-[0 0 0 1])>1000*eps)
         error('last row of 4H matrix expected to be [0 0 0 1]!');
      end
      [M,v] = ihom(Th);
      [S,K,R] = skr(M);
      
      [phi,theta,psi] = rpy(R);  
      if ( nargout == 0 )
         kx = K(1,1);  ky = K(2,2);  kz = K(3,3);
         sxy = S(1,2); sxz = S(1,3);  syz = S(2,3);
         fprintf('\troll:          %g (%g m°)\n',phi,1000*phi/deg);
         fprintf('\tpitch:         %g (%g m°)\n',theta,1000*theta/deg);
         fprintf('\tyaw:           %g (%g°)\n',psi,psi/deg);
         fprintf('\tscale x:       %g (%g µm/dm)\n',kx,(kx-1)*1e5);
         fprintf('\tscale y:       %g (%g µm/dm)\n',ky,(ky-1)*1e5);
         fprintf('\tscale z:       %g (%g µm/dm)\n',kz,(kz-1)*1e5);
         fprintf('\tshear xy:      %g (%g µm/dm)\n',sxy,sxy*1e5);
         fprintf('\tshear xz:      %g (%g µm/dm)\n',sxz,sxz*1e5);
         fprintf('\tshear yz:      %g (%g µm/dm)\n',syz,syz*1e5);
         if ( any(v~=0) )
            fprintf('\ttranslation x: %g\n',v(1));
            fprintf('\ttranslation y: %g\n',v(2));
            fprintf('\ttranslation z: %g\n',v(3));
         end
      elseif ( nargout == 1 )
         arg1 = [phi theta psi kx ky kz sxy sxz syz v(1) v(2) v(3)];
      else
         arg1 = hom(S,0);  K = hom(K,0);  R = hom(R,0);  V = hom(eye(3),v);
      end
   else
      error('3H or 4H matrix expected')
   end
   
% eof   