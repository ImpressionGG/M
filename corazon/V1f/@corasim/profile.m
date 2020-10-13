function [t,s,v,a,j] = profile(o,tmax,dt)
%
% PROFILE Get profile time series of a CORASIM motion object
%
%            oo = corasim('motion');
%            oo = data(oo,'smax,vmax,amax,tj',0.1,1,10000,0.02)
%
%            [t,s,v,a,j] = profile(oo,0:dt:tmax)
%
%            [t,s,v,a,j] = profile(oo,tmax,dt)   % t = 0:dt:tmax
%            [t,s,v,a,j] = profile(oo,tmax)      % t = 0:tmax/1000:tmax
%            [t,s,v,a,j] = profile(oo)
%
%            oo = profile(oo,0:dt:tmax)
%            oo = profile(oo,tmax,dt)
%            oo = profile(oo,tmax)
%            oo = profile(with(cuo,'simu'))
%            [t,s,v,a,j] = var(oo,'t,s,v,a,j');
%
%         Calculates time vector (t), stroke (s), velocity (v), accele-
%         ration (a) and jerk (j) of a motion profile.
%
%         If dt (input arg 3) is not specified but tmax (input arg 2) then
%         dt is calculated as dt = tmax/1000.
%
%         If neither tmax (arg2) nor dt (arg3) is provided then 
%            a) if opt 'tmax' is empty then tmax is determined by the 
%               length of the motion profile and dt by option 'dt' or 
%               (if empty) tmax/1000
%            b) otherwise opt 'tmax' determines tmax and dt is given by opt
%               'dt' or (if empty) tmax/1000
%
%         Options:
%
%            tmax            maximum time of profile (default: [])
%            dt              time increment (default: tmax/1000)
%
%         Example: Create a motion object in the CORASIM shell with
%         File>New>Corasim>200_mm_motion menu item
%
%            oo = with(cuo,'simu')     % get cuo with unwrapped simu opts
%            [t,s,v,a,j] = profile(oo)
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORASIM, MOTION
%
   if ~type(o,{'motion'})
      error('bad type, motion object expected');
   end
   
      % determine tmax and dt
      
   if (nargin < 2)
      tmax = opt(o,'tmax');
   end
   if (nargin < 3)
      dt = opt(o,{'dt',tmax/1000});
   end

      % brew motion and get profile signals
      
   oo = opt(o,'tmax,dt',tmax,dt);
   oo = motion(o,'Brew');   
   [t,s,v,a,j] = var(oo,'t,s,v,a,j');
   
   if (nargout <= 1)
      t = oo;                          % output arg
   end
end



