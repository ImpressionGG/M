function [out1,out2,out3,out4] = spin(obj,arg2,arg3)
%
% SPIN   Setup a spin state
%
%    1) Create a spin space
%
%       H = spin(toy)
%
%    2) With first argument being a spin space the general spin operator
%    (Sn), the spin polarization vector (n) as well as azimuth (az) and
%    elongation (el) angle will be returned.
%
%       [Sn,n] = spin(H,pi/4,pi/2);           % az = pi/4, el = pi/2
%       [Sn,n,az,el] = spin(H,pi/4,pi/2);     % az = pi/4, el = pi/2
%
%    The main spin operators Sx, Sy and Sz are created as follows:
%
%       [Sz,nz] = spin(H,0,0);                % az = 0, el = 0
%       [Sx,nx] = spin(H,0,pi/2);             % az = 0, el = pi/2
%       [Sy,ny] = spin(H,pi/2,pi/2);          % az = pi/2, el = pi/2
%
%    First argument can also be a generic TOY object, which would cause an
%    implicite creation of a spin space with a call H = spin(toy).
%
%       [Sn,n,az,el] = spin(toy,pi/4,pi/2);   % quick way
%       H = space(Sn);                        % extract Hilbert space
%
%       [Sz,nz] = spin(toy,0,0);              % az = 0, el = 0
%       [Sx,nx] = spin(toy,0,pi/2);           % az = 0, el = pi/2
%       [Sy,ny] = spin(toy,pi/2,pi/2);        % az = pi/2, el = pi/2
%
%    3) With first argument (and only input argument) being a spin state
%    (ket vector) the general spin operator (Sn), the spin polarization
%    vector (n) as well as azimuth (az) and elongation (el) angle are
%    returned. 
%
%       [Sn,pol,az,el] = spin(s);      % s is a spin vector
%
%       spin(u)                        % display az,el and pol
%       spin(d)                        % display az,el and pol
%       spin(unit(r+l))                % display az,el and pol
%
%    4) With first argument being a spin operator the two eigenvectors
%    of the spin operator according to the eigen values +1 and -1 are
%    returned.
%       
%       Sz = spin(H,0,0);               % spin operator Sz
%       [su,sd] = spin(Sz);             % spin states |u>, |d> (up,down)
%
%       Sx = spin(H,pi/2,0);            % spin operator Sx
%       [sr,sl] = spin(Sx);             % spin states |l>, |r> (left,right)
%
%       Sy = spin(H,pi/2,pi/2);         % spin operator Sy
%       [si,so] = spin(Sy);             % spin states |i>, |o> (in,out)
%
%    5) With first argument being a Hilbert space (or generic TOY) and
%    second argument being a spin polarization 3-vector the according
%    quantities general spin operator Sn, spin polarization vector n, 
%    azimuth (az) and elongation (el) will be returned.
%
%       [Sn,n,az,el] = spin(H,[nx ny nz]);    % by spin polarization vector
%       [Sn,n,az,el] = spin(toy,[nx ny nz]);  % by spin polarization vector
%
%       [Sz,nz] = spin(toy,[0 0 1]);          % nz = [0 0 1]
%       [Sx,nx] = spin(toy,[1 0 0]);          % nx = [1 0 0]
%       [Sy,ny] = spin(toy,[0 1 0]);          % ny = [0 1 0]
%
%   Here's how the main spin vectors may be created:
%
%       su = spin(spin(toy,[0 0 1]));         % su = |u> (up)
%       sd = spin(spin(toy,[0 0 -1]));        % sd = |d> (down)
%
%       sr = spin(spin(toy,[1 0 0]));         % sr = |r> (right)
%       sl = spin(spin(toy,[-1 0 0]));        % sl = |l> (left)
%
%       si = spin(spin(toy,[0 1 0]));         % si = |i> (in)
%       so = spin(spin(toy,[0 -1 0]));        % so = |o> (out)
%
%    Theory: for given azimuth (az) and elongation (el) angle the spin
%    polarization vector is
%
%               [ nx ]     [ sin(el)*cos(az) ]
%       pol  =  [ ny ]  =  [ sin(el)*sin(az) ]
%               [ nz ]     [     cos(el)     ]
%
%    This leads to the general spin operator
%
%       Sn  =  Sx*nx + Sy*ny + Sz*nz
%
%              [ nz    nx-i*ny  ]
%       Sn  =  [                ]
%              [ nx+i*ny   -nz  ]
%
%    From here we can read out the components of the spin polarization
%    vector
%
%       nz = Sn(1,1);   nx = real(Sn(1,2));  ny = imag(Sn(1,2))
%
%    See also: TOY, SPACE, OPERATOR
%
   profiler('spin',1);

   if strcmp(type(obj),'#GENERIC')
      obj = toy('spin');
      if (nargin == 1)
         out1 = obj;
         profiler('spin',0);
         return
      end
   end
   
% Next step is to check whether arg1 (obj) is of type vector. In this case
% we have to calculate spin operator Sn, spin polarization vector n, 
% azimuth az and elongation el.

   if property(obj,'vector?')
      profiler('spinvector',1);
      if (nargin ~= 1)
         error('Only 1 input arg (vector) expected for vector type!');
      end
      
      s = unit(obj);      % spin state
      M = matrix(s)+0;    % M = [m1;m2]

      if (norm(M) < 30*eps)
         error('vector must not be null vector!');
      end
      
         % calculate normal matrix according to [n1 n2]*[m1; m2] = 0,
         % or m1*n1 + m2*n2 = 0 => n2 = -m1/m2 * n1
         
      if (M(2) == 0)
         N = [0; 1];
      else
         N = [1, -M(1)/M(2)]';
         N = N / norm(N);
      end
      
      Mn = 1*M*M' - 1*N*N';
      Sn = operator(space(s),Mn);
      
%       sn = vector(obj,N);       % normal vector
%       Sn = 1*s*s' - 1*sn*sn'; 
%       Mn = matrix(Sn)+0;

      nz = Mn(1,1);   nx = real(Mn(1,2));  ny = imag(Mn(2,1));
      
      assert(abs(Mn(2,2)+nz) < 30*eps);         % Mn(2,2) == -nz;
      assert(abs(real(Mn(2,1))-nx) < 30*eps);   % real(Mn(2,1) == nx
      assert(abs(imag(Mn(1,2))+ny) < 30*eps);   % imag(Mn(1,2) == -ny

      n = [nx ny nz]' / norm([nx ny nz]);
      
      el = acos(nz);
      if (n(1) == 0 && n(2) == 0)
         az = 0;
      else
         az = atan2(n(2),n(1));
      end
      
      azel = [az el];
      for (i=1:length(azel))
         if abs(azel(i)-pi/4) < 30*eps
            txt{i} = 'pi/4';
         elseif abs(azel(i)+pi/4) < 30*eps
            txt{i} = '-pi/4';
         elseif abs(azel(i)-pi/2) < 30*eps
            txt{i} = 'pi/2';
         elseif abs(azel(i)+pi/2) < 30*eps
            txt{i} = '-pi/2';
         elseif abs(azel(i)-pi) < 30*eps
            txt{i} = 'pi';
         elseif abs(azel(i)+pi) < 30*eps
            txt{i} = '-pi';
         else
            txt{i} = sprintf('%g',azel(i));
         end
      end
      
      if (nargout == 0)
         fprintf('   az = %s, el = %s, pol = [%g; %g; %g]\n',...
                  txt{1},txt{2},n(1),n(2),n(3));
      else
         out1 = Sn;
         out2 = n;
         out3 = az;
         out4 = el;
      end
      profiler('spinvector',0);
      profiler('spin',0);
      return
   end
   
% Next step is to check whether arg1 is of type space. In this case
% we have to calculate spin operator Sn, spin polarization vector n, 
% azimuth az and elongation el.
   
   if property(obj,'space?')
      profiler('spinspace',1);
      if (nargin == 2)
         n = arg2(:);           % spin polarization vector

         if (norm(n) < 30*eps)
            error('spin polarization vector (arg2) must not be null vector!');
         end

         n = n/norm(n);
         el = acos(n(3));
         if (n(1)*n(2) == 0)
            az = 0;
         else
            az = atan2(n(2),n(1));
         end
      elseif (nargin == 3)
         az = arg2;             % azimuth angle
         el = arg3;             % elongation angle
         
         %n = [sin(el)*cos(az); sin(el)*sin(az); cos(el)];

         Ty = roty(obj,el);     % elongation
         Tz = rotz(obj,az);     % azimuth
         T = Tz * Ty;

         n = T*[0 0 1]';
      else
         error('2 or 3 input args expectzed for space type object!');
      end
      
         % calculate general spin operator

      [Sx,Sy,Sz] = operator(obj,'Sx','Sy','Sz');
      Sn = Sx*n(1) + Sy*n(2) + Sz*n(3);
      
      out1 = Sn;
      out2 = n;
      out3 = az;
      out4 = el;
      profiler('spinspace',0);
      profiler('spin',0);
      return
   end
   
% With one input argument being a spin operator we return the two eigen
% vectors according to eigen values +1 and -1.
   
   if property(obj,'operator?') || property(obj,'projector?')
      profiler('spinoperator',1);
      if (dim(obj) ~= 2)
         error('dimension of spin operator (arg1) must be 2!');
      end
      
      Sn = obj;
      H = space(Sn);
      M = matrix(Sn)+0;
      [V,D] = eig(M);

         % apply phasor to 1st component
         
      i = sqrt(-1);
      ph1 = exp(i*angle(V(1,1)));        % phasor V(1,1)
      V(:,1) = V(:,1)/ph1;

      ph2 = exp(i*angle(V(1,2)));        % phasor V(1,2)
      V(:,2) = V(:,2)/ph2;

         % trim V
         
      for (i=1:length(V(:)))
         if (abs(real(V(i))) < 30*eps)
            V(i) = sqrt(-1)*imag(V(i));
         elseif (abs(imag(V(i))) < 30*eps)
            V(i) = real(V(i));
         end
      end
      
         % construct ket vectors
         
      if (abs(D(1,1)-1) < 30*eps)        % check if D(1,1) == 1
         V1 = ket(H,V(:,1));
         V2 = ket(H,V(:,2));
      elseif (abs(D(2,2)-1) < 30*eps)    % check if D(2,2) == 1
         V1 = ket(H,V(:,2));
         V2 = ket(H,V(:,1));
      else
         error('unexpected eigenvalues!')
      end
      out1 = V1;  out2 = V2;
      profiler('spinoperator',0);
      profiler('spin',0);
      return
   end
   
   error('cannot process argument syntax!');
   profiler('spin',0);
   return
end
