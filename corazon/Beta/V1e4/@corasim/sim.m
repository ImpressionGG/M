function o = sim(o,u,x0,t)
%
% SIM      Simulate response of a SIMU object to a given input function
%          and store x,y in data part.
%
%             o = sim(o,u,x0,t)            % store x,y as data 
%             o = sim(o,u,x0)              % store x,y,t as data 
%             o = sim(o,u)                 % x0: zero state 
%
%          Example 1: discrete system response
%
%             A = [-1 0;0 -2]; B = [1;1]; C = [1 1]; D = 0;
%             T = 0.1;          % sample time
%             o = set(type(o,'dss'),'system','A,B,C,D,T', A,B,C,D,T);
%
%             u = ones(1,20);
%             o = sim(o,u,x0);
%
%          See also: SIMU
%
   o.argcheck(2,4,nargin);
   [A,B,C,D] = get(o,'system','A,B,C,D');

   if (nargin < 3)
      x0 = [];
   end
   
   if isempty(x0)
      x0 = 0*A(:,1);
   end
   
      % continuous systems have to be converted to discrete systems
   
   if isequal(o.type,'css')
      if (nargin < 4)
         error('no time vector (arg 4) provided!');
      end
      dt = min(diff(t));
      t = t(1):dt:t(end);
      
      o = c2d(o,dt);
      [A,B,C,D] = get(o,'system','A,B,C,D');
   end
   
      % actual simulation and response calculation
      
   if (nargin <= 3)
      [y,x] = Dlsim(o,A,B,C,D,u,x0);
      o = data(o,'t,x,u,y',[],x,u,y);
   else
      [y,x] = Dlsim(o,A,B,C,D,u,x0);
      o = data(o,'t,x,u,y',t,x,u,y);
   end
end

%==========================================================================
% Helper Functions
%==========================================================================

function  [y,x] = Dlsim(o,A,B,C,D,u,x0)
%
% DLSIM	Simulation of discrete-time linear systems.
%      	Y = DLSIM(o,A,B,C,D,u)  calculates the time response of the system:
%		
%		      x[n+1] = Ax[n] + Bu[n]
%		      y[n]   = Cx[n] + Du[n]
%
%	      to input sequence U.  Matrix U must have as many rows as there
%        are inputs, u.  Each column of U corresponds to a new time point.
%        DLSIM returns a matrix Y with as many columns as there are outputs
%        y, and with LENGTH(U) rows.
%
%	      [Y,X] = DLSIM(o,A,B,C,D,u) also returns the state time history.
%	      DLSIM(o,A,B,C,D,U,x0) can be used if initial conditions exist.
%
%	      Y = DLSIM(o,NUM,DEN,U) calculates the time response from the
%        transfer function description  G(z) = NUM(z)/DEN(z)  where NUM
%        and DEN contain the polynomial coefficients in descending powers.
%
%	      DLSIM(NUM,DEN,u) is equivalent to FILTER(NUM,DEN,u).
%
   nargs = nargin;
   if (nargs == 4)		% transfer function description 
      u = C;
      [m,n] = size(a);
      if ((m == 1)|(nargout == 1))	% Use filter, it's more efficient
         y = filter(A,B,u);
         x = [];   % hux
         return
      else  			% Convert to state space
         A = [A zeros(m,length(B)-n)]
         [A,B,C,D] = tf2ss(A,B);
         nargs = 5;
      end
   end
   
   [ns,nx] = size(A);
   if (nargs == 6)
      x0 = zeros(1,ns);
   end
   
   o.argcheck(6,7,nargs);
   abcdcheck(o,A,B,C,D);
   
   x = ltitr(A,B,u',x0)';
   y = C*x + D*u;
end
