function o = controller(o,osys)                                        
%
% CONTROLLER
%    Controller block
%
%       o = control(o)            % init
%       o = control(o,osys)       % loop
%
%    Second arg (osys) is the object representing the (PWM)
%    system block
%
%    Log data:
%
%       k:  run index
%       xm: observer state (x(1): period, x(2): ZV time stamps)
%       ym: observer output (zero cross time stamps)
%       yd: observer deviation (yd = ym-y)
%         
%
%  PWM System:
%
%   [ g' ]   [ 1   0   0 ]   [ g ]   [ 0 ]       [ 1 ]  
%   [    ]   [           ]   [   ]   [   ]       [   ]
%   [ h' ] = [ 0   1   0 ] * [ h ] + [ 1 ] * u + [ 0 ] * w  
%   [    ]   [           ]   [   ]   [   ]       [   ] 
%   [ q' ]   [ 1  -2   1 ]   [ q ]   [-1 ]       [ 0 ]  
%
%     y    = [ 0   0   1 ] * [ g h q ]' + v
%
%  Now consider a new equilibrium state xe to which we want to drive
%  the system. How do we have to do to achieve xe as a steady state?
%
%  Extended System: 
%
%     X := [x' f]' = [ g h q f ]'
%
%  Controller Implementatiom
%
%     x' = A*x + B*u
%     f' = 1*f + C*x + s*r
%     u = -K*x
%
%   [ g' ]   [ 1  0  0  0 ]   [ g ]   [ 0 ]       [ 1 ]       [ 0 ]  
%   [    ]   [            ]   [   ]   [   ]       [   ]       [   ]
%   [ h' ]   [ 0  1  0  0 ]   [ h ]   [ 1 ]       [ 0 ]       [ 0 ]
%   [    ] = [            ] * [   ] + [   ] * u + [   ] * w + [   ] * r 
%   [ q' ]   [ 1 -2  1  0 ]   [ q ]   [-1 ]       [ 0 ]       [ 0 ]
%   [    ]   [            ]   [   ]   [   ]       [   ]       [   ]
%   [ f' ]   [ 0  0  1  1 ]   [ f ]   [ 0 ]       [ 0 ]       [ s ]  
%
%       y  = [ 0  0  1  0 ]*[ g h q f ]' + v
%
%  Or in compact notation:
%
%     X = AA*X + BB*u + WW*w + S*r
%     y = CC*X + v
%     u = -K*X
%
%  For steady state consideration we let w = 0, v = 0 and claim
%  y = r:
%
%     X' = AA*X + BB*u + S*r
%     r = CC*X                    (since we want: r = y!)     
%     u = -K*X
%
%     X' = AA*X - BB*K*x + S*r = (AA-BB*K)*X + S*r
%
%  Note that for steady state we have
%
%     Xe = (AA-BB*K)*Xe + S*r
%     (I-AA+BB*K)*Xe = S*r
%     Xe = (I-AA+BB*K)\S*r
%
%  In particular we are not interested to achieve a given (entire) Xe
%  state but only to achieve y = CC*X = r:
%
%     r = CC*Xe = CC*inv(I-AA+BB*K)*S*r
%
%  Multiplying this equation by 1/r and identifying S with e4*s we get:
%
%     1 = CC*inv(I-AA+BB*K)*S
%     1 = CC*inv(I-AA+BB*K)*e4*s
%
%  This allows us to calculate the unknown s:
%
%     s = 1 / (CC*inv(I-AA+BB*K)*e4)
%
% LQR Design
%
%     AA := [A 0; C 1]
%     BB := [B; 0]
%     CC := [C 0]
%
%  while the controller implementation has to be:
%
%     u = -K*X = -K*[g h q f]'
%     f' = f + q + s*r = f + C*x + s*r 
%
%  As the pair [AA,BB] is not controllable we leave the first component 
%  of XX (namely g) uncontrolled and control the subsystem
%
%    [ h' ]   [ 1  0  0 ]   [ h ]   [ 1 ]       [ 0 ]
%    [    ]   [         ]   [   ]   [   ]       [   ] 
%    [ q' ] = [-2  1  0 ] * [ q ] + [-1 ] * u + [ 0 ] * r
%    [    ]   [         ]   [   ]   [   ]       [   ]
%    [ f' ]   [ 0  1  1 ]   [ f ]   [ 0 ]       [ s ]  
%
%  Setting
%
%     Xx := [ h  z  f ]' = XX(2:4)
%     Aa := AA(2:3,2:3)
%     Bb := Bb(2:3)
%
%  we get 
%
%     K = [ 0 Kk']'
%
%  while Kk is the solution of the discrete Ricati equation given
%  penalty matrices Q,R:
%
%   Kk = (R + Bb'*P'*Bb) \ Bb'*P*Aa;      
%   P = Aa'*P*Aa - Aa'*P*Bb * Kk + Q;
%
%    See also: PLL, SYSTEM, KALMAN
%
   if (nargin == 1)
      o = Init(o);
   else
      o = Loop(o,osys);
   end
end

%==========================================================================
% Helpers
%==========================================================================

function [K,P]=Dlqr(A,B,Q,R)           % Linear Quadratic Regulator    
%
% DLQR   Linear quadratic regulator design for discrete-time systems.
%
%	         [K,P] = Dlqr(A,B,Q,R)
%
%        calculates the optimal feedback gain matrix K such that the 
%        feedback law:
%
%		      u(k) = -K*x(k)
%
%	      minimizes the cost function:
%
%		      J = Sum {x(k)'*Q*x(k) + u(k)'*R*u(k)}
%
%	      subject to the constraint equation: 
%
%		      x(k+1) = A*x(k) + B*u(k) 
%                
%	      Also returned is S, the steady-state solution to the associated 
%	      algebraic Riccati equation:
%			
%           K = (R+B'*P'*B) \ B'*P*A;      
%           P = A'*P*A - A'*P*B * K + Q;
%
%        See TRF, LQR
%
   P = 0*Q;

   for (i=1:1000)
      K = (R+B'*P'*B) \ B'*P*A;
      P = A'*P*A - A'*P*B * K + Q;
   end
end
function [t0,period] = GridParameter(o)                                
   f = opt(o,{'grid.f',50});
   toff = opt(o,{'grid.offset',0});    % time offset

   period = 1/f;
   tmin = 0; tmax = period;
   t = [tmin-toff-period/2:period:tmax];
   
   idx = find(tmin <= t & t <= tmax);
   t0 = t(idx(1));
end

%==========================================================================
% Old Init & Loop
%==========================================================================

function o = OldInit(o)                % LQR Controller Setup          
   period = opt(o,'tim2.period')+1;

   k = 0;                              % init run index
   r = opt(o,'pwm.setpoint')*period;
   
   A = [ 
          1   0   0
          0   1   0
          1  -2   1
       ];
   B = [  0   1  -1 ]';
   C = [  0   0   1 ];
   
   AA = [A [0;0;0]; C 1];
   BB = [B;0];
   CC = [C 0]; 

   Aa = AA(2:4,2:4);
   Bb = BB(2:4);
   Cc = CC(2:4);
   
      % LQR Controller
      
   %Q = diag([1 5 10]);  R = 1;  P = 0*eye(3);
   Q = diag([10 5 10]);  R = 1;  P = 0*eye(3);
   %Q = diag([10 1 10]);  R = 0.1;  P = 0*eye(3);
   
   
   Kk = Dlqr(Aa,Bb,Q,R);               % linear quadratic regulator design
   K = [0 Kk];
      
      % overwrite K with 'pretty' values for mini model
      
   if (opt(o,{'simu.mini',0}) == 1)
      K = [0 1.2 -0.5 -0.2];
   end
   K = o.rd(K,4);                      % round to 4 digs for debuggability

   s = 1 / (Cc*inv(eye(3)-Aa+Bb*Kk)*[0 0 1]');
   
      % controller state and control signal init
      
   f = 0;  u = 0;

       % variable storage & data logging init
      
   o = var(o,'k',k, 'A',A, 'B', B, 'C',C, 'f',f, 'r',r, 's',s, 'K',K);
   o = var(o,'u',u, 'period',period);
   o = log(o,'k,t,x,r,y,e,f,q,u');
end
function o = OldLoop(o,osys)           % LQR Controller loop           
   [k,A,B,C,f,r,s,K] = var(o,'k','A','B','C','f','r','s','K');
   
      % run index and time
      
   t = k * 0.02;
   k = k+1;                            % update run index
   
      % get system state: we need system state(1:3) and extend by f
      
   x = var(osys,'x');                  % system state [g,t,h,q]'
   x = [x([1 3 4]);f];                 % extended LQR controller state
   
      % objective signal and control error
      
   y = [C 0]*x;                        % calc objective signal
   e = r - y;
   q = 0;
   u = -K*x;

      % data logging
      
   o = log(o,k,t,x,r,y,e,f,q,u);

      % controller transition
      
   f = [C 1]*x + s*r;
   
       % variable storage & data logging
      
   o = var(o,'k',k, 'f',f, 'u',u);
end

%==========================================================================
% Init & Loop
%==========================================================================

function o = Init(o)                   % LQR Controller Setup          
   period = opt(o,'tim2.period')+1;

   k = 0;                              % init run index
   r = opt(o,'pwm.setpoint')*period;
   
   A = [ 
          1   0   0
          0   1   0
          1  -2   1
       ];
   B = [  0   1  -1 ]';
   C = [  0   0   1 ];
   
   AA = [A [0;0;0]; C 1];
   BB = [B;0];
   CC = [C 0]; 

   Aa = AA(2:4,2:4);
   Bb = BB(2:4);
   Cc = CC(2:4);
   
      % LQR Controller
      
   %Q = diag([1 5 10]);  R = 1;  P = 0*eye(3);
   Q = diag([10 5 10]);  R = 1;  P = 0*eye(3);
   %Q = diag([10 1 10]);  R = 0.1;  P = 0*eye(3);
   
   
   Kk = Dlqr(Aa,Bb,Q,R);               % linear quadratic regulator design
   K = [0 Kk];
      
      % overwrite K with 'pretty' values for mini model
      
   if (opt(o,{'simu.mini',0}) == 1)
      K = [0 1.2 -0.5 -0.2];
   end
   K = o.rd(K,4);                      % round to 4 digs for debuggability

   s = 1 / (Cc*inv(eye(3)-Aa+Bb*Kk)*[0 0 1]');
   
      % controller state and control signal init
      
   f = 0;  u = 0;

       % variable storage & data logging init
      
   o = var(o,'k',k, 'A',A, 'B', B, 'C',C, 'f',f, 'r',r, 's',s, 'K',K);
   o = var(o,'u',u, 'period',period);
   o = log(o,'k,t,x,r,y,e,f,q,u');
end
function o = Loop(o,osys)              % LQR Controller loop           
   [k,A,B,C,f,r,s,K] = var(o,'k','A','B','C','f','r','s','K');
   
      % run index and time
      
   t = k * 0.02;
   k = k+1;                            % update run index
   
      % get system state: we need system state(1:3) and extend by f
      
   x = var(osys,'x');                  % system state [g,t,h,q]'
   x = [x([1 3 4]);f];                 % extended LQR controller state
   
      % objective signal and control error
      
   y = [C 0]*x;                        % calc objective signal
   e = r - y;
   q = 0;
   u = -K*x;

      % data logging
      
   o = log(o,k,t,x,r,y,e,f,q,u);

      % controller transition
      
   f = [C 1]*x + s*r;
   
       % variable storage & data logging
      
   o = var(o,'k',k, 'f',f, 'u',u);
end
