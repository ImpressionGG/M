function o = system(o,oo)              % system block                  
%
% SYSTEM  
%    PWM System block (PWM system)
%
%       o = system(o)                  % init
%       o = system(o,[])               % measure
%       o = system(o,oo)               % loop
%
%    Example
%
%       os = system(o);                % init system
%       oc = type(o,'control');        % (pseudo) controller object
%       for (k=0:Kmax(o))
%          oc = var(oc,'u',randn);     % 'run' controller loop
%          os = system(os,oc);         % run system loop
%       end
%
%    Second arg (ocon) is the object representing the controller block
%
%    Log data:
%
%       k:  run index
%         
%    Mathematical Description of Basic PWM System:
%
%        [ g' ]   [ 1   0   0   0 ]   [ g ]   [ 0 ]       [ 1 ]  
%        [    ]   [               ]   [   ]   [   ]       [   ]
%        [ t' ]   [ 1   1   0   0 ]   [ t ]   [ 0 ]       [ 0 ]
%    x = [    ] = [               ] * [   ] + [   ] * u + [   ] * w 
%        [ h' ]   [ 0   0   1   0 ]   [ h ]   [ 1 ]       [ 0 ]  
%        [    ]   [               ]   [   ]   [   ]       [   ] 
%        [ q' ]   [ 1   0  -2   1 ]   [ q ]   [-1 ]       [ 0 ]  
%
%                                     [ g ]   
%                                     [   ]
%        [ z  ]   [ 0   1   0   0 ]   [ t ]   [ 1 ]
%    Y = [    ] = [               ] * [   ] + [   ] * v 
%        [ y  ]   [ 0   0   0   1 ]   [ h ]   [ 1 ]
%                                     [   ]
%                                     [ q ]   
%
%    We define 
%                                     [ g ]   
%                                     [   ]
%        [ t  ]   [ 0   1   0   0 ]   [ t ]             [ 1 ]
%    Z = [    ] = [               ] * [   ] ,   Y = Z + [   ] * v
%        [ q  ]   [ 0   0   0   1 ]   [ h ]             [ 1 ]
%                                     [   ]
%                                     [ q ]   
%    In matrix notation we have:
%
%       x := [g t h q]',  Y = [ z y]'
%
%       x' = A*x + B*u + W*w
%       Y  = C*x + V*v
%       Z  = C*x  =>  Y = Y + V*v
%
%    See also: PLL, CONTROL, KALMAN
%
   if (nargin <= 1)
      o = Init(o);
   elseif ~isobject(oo)
      o = Measure(o);
   else
      o = Loop(o,oo);
   end
end

%==========================================================================
% Helpers
%==========================================================================

function [t0,period] = GridParameter(o)                                
   f = opt(o,{'grid.f',50});
   toff = opt(o,{'grid.offset',0});    % time offset

   period = 1/f;
   tmin = 0; tmax = period;
   t = [tmin-toff-period/2:period:tmax];
   
   idx = find(tmin <= t & t <= tmax);
   t0 = t(idx(1));
end
function [Tt0,Tt,Dt] = PwmParameter(o)                                 
   f0 = opt(o,'clock.f0');
   kappa = opt(o,'clock.kappa');

   Kt = opt(o,'tim2.prescale');
   Dt = Kt/f0*kappa;
   
   period = opt(o,'tim2.period')+1;
   Tt = period*Dt;
   
   offset = opt(o,'tim2.offset');
   Tt0 = offset;
end
function [Tt0,Tt,Dt] = TimerParameter(o)                               
   f0 = opt(o,'clock.f0');
   kappa = opt(o,'clock.kappa');

   Kt = opt(o,'tim6.prescale');
   Dt = Kt/f0*kappa;
   
   period = opt(o,'tim6.period')+1;
   Tt = period*Dt;
   
   offset = opt(o,'tim6.offset');
   Tt0 = offset;
end
function [sigw,sigv] = Noise(o)        % Get Noise Sigma Values        
   if opt(o,{'simu.noise',1})
      [Tt0,Tt,Dt] = TimerParameter(o);
      sigw = opt(o,{'grid.vario',10e-6}) / 3 / Dt;
      sigv = opt(o,{'grid.jitter',60e-6}) / 3 / Dt;
   else
      sigw = 0;
      sigv = 0;
   end
end
function kmax = Kmax(o)                % Maximum Simulation Index      
   kmax = opt(o,'simu.periods');
end
function [w,v] = Randn(o)              % Random Row Vector             
   kmax = Kmax(o);
   [sigw,sigv] = Noise(o);
   
   if (nargout <= 1)
      w = sigw*randn(1,kmax+1);
   else
      for (j=1:kmax+1)
         w(:,j) = round([sigw*randn;0;0;0]);
         v(1,j) = round(sigv*randn);
      end
   end
end
function u = Constrain(o,u,h)          % Constrain PWM Height          
   hlim = opt(o,{'pwm.hlim',[0.8 1.2]});
   period = var(o,'period');
   hmin = period * hlim(1);
   hmax = period * hlim(2);
   
   if (h+u > hmax)
      u = hmax - h;                    % to cause h(k+1) = hmax
   elseif (h+u < hmin)
      u = hmin-h;                      % to cause h(k+1) = hmin
   end
end
function y = Quantize(x)               % Quantizing Measurements       
   y = round(x);
end

%==========================================================================
% Init & Loop
%==========================================================================

function o = Init(o)                   % Init                          
%
%  Model #1 (runs away ...)
%
%
%     g(k+1) = g(k) + w(k)             % grid period (w(k) dynamic noise)
%     t(k+1) = t(k) + g(k)             % zero cross time stamps
%     h(k+1) = h(k) + u(k)             % PWM period (controlled by u(k))
%     b(k+1) = b(k) +2*h(k) + u(k)     % PWM base time stamps
%     ----------------------------
%      y(k)  = t(k) - b(k) + v(k)      % PWM counter values @ ZC timestamps
%
%  Note: y(k) is the (counter valued) phase of the PWM signal, and is our
%  control signal!
%
%   [ g(k+1) ]   [ 1   0   0   0 ]   [ g(k) ]   [ 0 ]          [ 1 ]  
%   [        ]   [               ]   [      ]   [   ]          [   ]
%   [ h(k+1) ]   [ 0   1   0   0 ]   [ h(k) ]   [ 1 ]          [ 0 ]  
%   [        ] = [               ] * [      ] + [   ] * u(k) + [   ] * w(k)
%   [ t(k+1) ]   [ 1   0   1   0 ]   [ t(k) ]   [ 0 ]          [ 0 ]  
%   [        ]   [               ]   [      ]   [   ]          [   ]
%   [ b(k+1) ]   [ 0   2   0   1 ]   [ b(k) ]   [ 1 ]          [ 0 ]  
%
%       y(k)   = [ 0   0   1  -1 ] *   x(k) + v(k)
%
%  This model is not completely observable, as it can be seen by the follo-
%  wing regular state transformation.
%
%  Define: 
%
%      z(k) := t(k) - b(k)             % true PWM phase
%
%  which leaves us with
%
%      y(k) = z(k) + v(k)              % PWM phase with measurement noise
%
%  Now investigate:
%
%      z(k+1) = t(k+1) - b(k+1) =
%             = t(k) + g(k) - b(k) - 2*h(k) - u(k) = 
%             = [t(k) - b(k)] + g(k) - 2*h(k) - u(k) = 
%             = [z(k)] + g(k) - 2*h(k) - u(k)
%
%      z(k+1) = g(k) - 2*h(k) + z(k) - u(k)
%
%  So we can reformulate the transformed system:
%
%     g(k+1) = g(k) +w(k)              % grid period (w(k) dynamic noise)
%     h(k+1) = h(k) +u(k)              % PWM period (controlled by u(k))
%     z(k+1) = g(k) -2*h(k) +z(k) -u(k)% true PWM phase
%     t(k+1) = t(k) +g(k)              % zero cross time stamps
%     --------------------------------
%      y(k)  = z(k) + v(k)             % measured PWM phase
%      b(k)  = t(k) - z(k)             % PWM base timestamps
%
%  The signals g(k), h(k) and y(k) are not running away (when controlled).
%  On the other hand t(k) and b(k) are running away. If we are not
%  interested in t(k) and b(k) we can drop them from the model and we get:
%
%     g(k+1) = g(k) + w(k)             % grid period (w(k) dynamic noise)
%     h(k+1) = h(k) + u(k)             % PWM period (controlled by u(k))
%     z(k+1) = g(k) -2*h(k) +z(k) -u(k)% PWM phase
%     --------------------------------
%      y(k)  = z(k) + v(k)             % measured PWM phase
%
%  Or in matrix represetation
%
%   [ g(k+1) ]   [ 1   0   0 ]   [ g(k) ]   [ 0 ]          [ 1 ]  
%   [        ]   [           ]   [      ]   [   ]          [   ]
%   [ h(k+1) ] = [ 0   1   0 ] * [ h(k) ] + [ 1 ] * u(k) + [ 0 ] * w(k)  
%   [        ]   [           ]   [      ]   [   ]          [   ] 
%   [ q(k+1) ]   [ 1  -2   1 ]   [ q(k) ]   [-1 ]          [ 0 ]  
%
%       y(k)   = [ 0   0   1 ] *   x(k) + v(k)
%
   o = type(o,'pwm');
   [Tg0,Tg] = GridParameter(o);
   [Tt0,Tt,Dt] = PwmParameter(o);

   k = 0;                              % init run index
   period = Tt/Dt; 

   [sigw,sigv] = Noise(o);             % noise parameters
   [w,v] = Randn(o);                   % setup noise signals
   
      % initial values for model state
      
   g = Tg/Dt;                          % init system period [#]
   t = Tg0/Dt;                         % time [#]
   h = Tt/Dt;                          % PWM period [#]
   q = (Tg-Tg0-Tt0)/Dt;                % PWM phase [#]
  
   z = t + v(1);                       % jittered zero crossing time
   y = q + v(1);
   b = t - y;                          % PWM base time stamps
   
   x = [g; h; q; t];                   % init system state

      % model system matrices
      
   A = [1  0  0  0;                    % model dynamic matrix
        1  1  0  0; 
        0  0  1  0;
        1  0 -2  1];                 
   B = [0  0  1 -1]';                  % model input matrix
   C = [0 1 0 0; 0 0 0 1];             % model output matrix
   
   Z = z*Dt;                           % zero cross time stamp [s]
   u = 0;                              % control signal
   t0 = 0;                             % moving time offset
   
   pwm = [h];
   p = rem(round(y)+100*h,h);          % PWM phase (counter): mod h
   
       % variable storage
      
   o = var(o,'k',k,'sigw',sigw,'sigv',sigv,'Dt',Dt,'period',period,'t',t);
   o = var(o,'A',A, 'B',B, 'C',C, 'x',x, 'w',w, 'v',v, 'u',u, 'y',y,'q',q);
   o = var(o,'p',p, 'z',z, 'Z',Z, 'pwm',pwm, 't',t, 't0',t0);
   
      % log init      
   
   o = log(o,'k,x,u,y,p,q,v,w,g,h,z,Z,t,t0');
end
function o = Measure(o)                % Measurement                   
   [k,x,C,v,Dt] = var(o,'k','x','C','v','Dt');

   k = k+1;

      % output signals
      % jittered zero cross time modulo period
      
   z = Quantize(C(1,:)*x + v(k));      % jittered zero cross time [#]
   y = Quantize(C(2,:)*x + v(k));      % phase plus measurement noise

      % modulo function caused by tmer counters
      
   h = x(3);                           % PWM height (period)
   Z = z*Dt;                           % zero cross time stamp [s]
   p = round(rem(y+10*h,h));           % PWM phase (counter): mod h
   
   o = var(o,'z',z, 'y',y, 'Z',Z, 'p',p);
end
function o = Loop(o,oo)                % Loop                          
   [k,A,B,C,x,w,v,pwm,Dt,t0] = var(o,'k','A','B','C','x','w','v','pwm','Dt','t0');
   k = k+1;                            % update run index

   u = var(oo,'u');                    % get control signal from oo object
   
   g = x(1);                           % grid period (in TIM2 increments)
   t = x(2);                           % let t extra run
   h = x(3);                           % PWM height (period)
   q = x(4);                           % phase without measurement noise

      % input signal
      % constraining the control input u such that hmin <= h <= hmax
      
   u = Constrain(o,u,h);   
   
      % output signals
      % jittered zero cross time modulo period
      
   z = Quantize(C(1,:)*x + v(k));      % jittered zero cross time [#]
   y = Quantize(C(2,:)*x + v(k));      % phase plus measurement noise

      % modulo function caused by tmer counters
      
   Z = z*Dt;                           % zero cross time stamp [s]
   p = round(rem(y+10*h,h));           % PWM phase (counter): mod h
   
      % data logging

   o = log(o,k,x,u,y,p,q,v(k),w(1,k),g,h,z,Z,t,t0);

      % transition
      
   x = A*x + B*u + w(:,k);
   while (x(2) >= 40000)
      x(2) = x(2) - 40000;             % handle modulo character of time
      t0 = t0 + 40000;
   end

   pwm = [pwm, h+u, h+u];              % for PWM plot
   
      % variable storage & data logging
      
   o = var(o,'k',k, 'u',u, 'x',x, 't',t, 't0',t0, 'z',z, 'y',y, 'p',p);
   o = var(o,'pwm',pwm, 'Z',Z);
end
