function o = sim(o,u,x0,t)             % System Simulation             
%
% SIM      Simulate response of a SIMU object to a given input function
%          and store x,y in data part.
%
%             o = sim(o,u,x0,t)            % store x,y as data 
%             o = sim(o,u,x0)              % store x,y,t as data 
%             o = sim(o,u)                 % x0: zero state 
%
%          Provide simulation settings menu
%
%             oo = sim(o,'Menu');
%
%          Example 1: discrete system response
%
%             A = [-1 0;0 -2]; B = [1;1]; C = [1 1]; D = 0;
%             T = 0.1;          % sample time
%             o = set(type(o,'dss'),'system','A,B,C,D,T', A,B,C,D,T);
%
%             u = ones(1,20);
%             oo = sim(o,u,x0);
%
%             [t,u,x,y] = var(oo,'t,x,u,y');
%
%          See also: SIMU
%
   if (nargin == 2 && ischar(u))
      switch u                         % u has the role of a mode arg
         case 'Menu'
            o = Menu(o);               % setup simulation parameter menu
         otherwise
            error('sim: bad mode (arg2)')
      end
      return
   end
   
      % otherwise simulate ...
      
   o.argcheck(2,4,nargin);
   [A,B,C,D] = system(o);

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
      dt = min(diff(t));               % get minimum dt
      t = t(1):dt:t(end);              % setup t-vector with minimum dt
      
      o = c2d(o,dt);
      [A,B,C,D] = system(o);
   end
   
      % actual simulation and response calculation
      
   if (nargin <= 3)
      [y,x] = Dlsim(o,A,B,C,D,u,x0);
      o = var(o,'t,x,u,y',[],x,u,y);
   else
      [y,x] = Dlsim(o,A,B,C,D,u,x0);
      o = var(o,'t,x,u,y',t,x,u,y);
   end
end

%==========================================================================
% Simu Menu
%==========================================================================

function oo = Menu(o)                  % Simulation Parameter Menu     
%
% SIMU   Add simulation parameter menu items
%
   setting(o,{'simu.tmax'},0.01);
   setting(o,{'simu.dt'},5e-6);
   setting(o,{'simu.plot'},100);       % number of points to plot

   oo = mitem(o,'Simulation');
   ooo = mitem(oo,'Max Time (tmax)',{},'simu.tmax');
          choice(ooo,[1000,2000,5000, 100,200,500,10,20,50, 1,2,5,...
                      0.1,0.2,0.5, 0.01,0.02,0.05, 0.001,0.002,0.005],{});
   ooo = mitem(oo,'Time Increment (dt)',{},'simu.dt');
          choice(ooo,[1e-6,2e-6,5e-6, 1e-5,2e-5,5e-5, 1e-4,2e-4,5e-4,...
                      1e-3,2e-3,5e-3, 1e-2,2e-2,5e-2, 1e-2,2e-2,5e-2],{});
   ooo = mitem(oo,'Number of Plot Intervals',{},'simu.plot');
          choice(ooo,{{'50',50},{'100',100},{'200',200},{'500',500},...
                      {'1000',1000},{},{'Maximum',inf}},{});
end

%==========================================================================
% Helper Functions
%==========================================================================

function  [y,x] = Dlsim(o,A,B,C,D,u,x0)% Simu Discret Time Lin. System 
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
