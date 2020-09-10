function spinball(obj,phi,r,col,state)
%
% SPINBALL   Draw a 3D spinning ball at spinning angle phi and a spin
%            axes given by azel = [azimuth,elongation], radius r and color
%            col
%            
%               spinball(toy,phi,r,col,state);   % explicite spin state
%
%            If state is not provided explicitely then state is implicitely
%            fetched from option(obj,'spin.state').
%
%               spinball(toy,phi,r,col);         % implicite spin state
%
%            See also: TOY, BALL, GEM
%
   profiler('spinball',1);
   
   if (nargin < 5)
      az = either(option(obj,'spin.az'),0);
      el = either(option(obj,'spin.el'),0);
      azel = [az,el];   
   end
   
      % in case of random spin we will overwrite azimuth & elongation
      
   random = either(option(obj,'spin.random'),0);
   value = option(obj,'apparatus.value');
   if (random && value == 0)
      azel = [2*rand 1*rand] * pi;
   end
   
   Gem(obj,[0 0 0],r,phi,azel,'w');
   ball(obj,[0 0 0],r,'y',0.8,100);

   profiler('spinball',0);
   return
end

%==========================================================================
% Spinning Gem
%==========================================================================

function Gem(obj,offset,r,phi,azel,col,alfa)
%
% GEM  Draw a 3D Gem with offset, radius (r). The gem will rotate arround
%      the polarization axis defined by angle phi, while azel is a 2-vector
%      containing azimuth and elongation of the spin axis.
%
   if (nargin < 2)
      offset = [0 0 0];
   end
   if (nargin < 3)
      r = 1;
   end
   if (nargin < 4)
      phi = 0;
   end
   if (nargin < 5)
      col = 'r';
   end
   if (nargin < 6)
      alfa = 1;
   end
   
   %[X,Y,Z] = cylinder(sqrt(3)/2*[0 1 1 1 0],6);
   [X,Y,Z] = cylinder(sqrt(3)/2*[0 1 1 0],6);
   Z = Z*2-1;
   
   H = ones(size(X));
   C = cindex(obj,H,col);     % color indices

      % rotation transformations
      
   Ty = roty(obj,azel(2));    % elongation
   Tz = rotz(obj,azel(1));    % azimuth
   Ts = rotz(obj,phi);        % spin rotation
   
   T = r * Tz * Ty * Ts;
   
      % rotation according to phase

   Xp = T(1,1)*X + T(1,2)*Y + T(1,3)*Z + offset(1); 
   Yp = T(2,1)*X + T(2,2)*Y + T(2,3)*Z + offset(2); 
   Zp = T(3,1)*X + T(3,2)*Y + T(3,3)*Z + offset(3);
   
      % surf plot body

   hdl = surf(Xp,Yp,Zp,C,'EdgeColor','none');
   update(gao,hdl);
   return
end

