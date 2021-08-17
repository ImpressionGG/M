function oo = new(o,varargin)          % SPM New Method                
%
% NEW   New SPM object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(spm,'Mode3A')      % 3-mode sample, version A
%           o = new(spm,'Mode3B')      % 3-mode sample, version B
%           o = new(spm,'Mode3C')      % 3-mode sample, version C
%
%           o = new(spm,'Academic1')   % academic sample 1
%           o = new(spm,'Academic2')   % academic sample 2
%
%           o = new(spm,'Schleif75')   % Schleifsaal Hypothese 75°
%
%           o = new(spm,'Challenge')   % 2x2 @ 3-mode challenging sample
%
%           o = new(sho,'Motion')      % motion object
%
%       See also: SPM, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Mode2,@Mode3A,@Mode3B,@Mode3C,...
                       @Academic1,@Academic2,@Schleif,@Order,@Challenge,...
                       @Motion,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Callback(o)                                              
   mode = arg(o,1);
   oo = new(o,mode);
   paste(o,oo);                        % paste object into shell
end

function oo = Menu(o)                  % New Menu                      
%
% Menu   Setup New menu items
%
   oo = mitem(o,'-');
   oo = o;  %                          oo = mhead(o,'Spm');
   ooo = mitem(oo,'2-Mode Sample',{@Create 'Mode2'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'3-Mode Sample (A)',{@Create 'Mode3A'});
   ooo = mitem(oo,'3-Mode Sample (B)',{@Create 'Mode3B'});
   ooo = mitem(oo,'3-Mode Sample (C)',{@Create 'Mode3C'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Academic Sample #1',{@Create 'Academic1'});
   ooo = mitem(oo,'Academic Sample #2',{@Create 'Academic2'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'High Order Sample');
   oooo = mitem(ooo,'Order 2',{@Create 'Order',2});
   oooo = mitem(ooo,'Order 3',{@Create 'Order',3});
   oooo = mitem(ooo,'Order 5',{@Create 'Order',5});
   oooo = mitem(ooo,'Order 10',{@Create 'Order',10});
   oooo = mitem(ooo,'Order 20',{@Create 'Order',20});
   oooo = mitem(ooo,'Order 30',{@Create 'Order',30});
   oooo = mitem(ooo,'Order 40',{@Create 'Order',40});
   oooo = mitem(ooo,'Order 50',{@Create 'Order',50});
   oooo = mitem(ooo,'Order 60',{@Create 'Order',60});
   oooo = mitem(ooo,'Order 70',{@Create 'Order',70});
   oooo = mitem(ooo,'Order 80',{@Create 'Order',80});
   oooo = mitem(ooo,'Order 90',{@Create 'Order',90});
   oooo = mitem(ooo,'Order 100',{@Create 'Order',100});
   oooo = mitem(oo,'-');

   ooo = mitem(oo,'Schleifsaal Hypothese');
   %oooo = mitem(ooo,'80° @ Coupling 0.5 ',{@Create 'Schleif', 80,0.5});
   %oooo = mitem(ooo,'-');
   oooo = mitem(ooo,'0°', {@Create 'Schleif', 0,[]});
   oooo = mitem(ooo,'15°',{@Create 'Schleif', 15,[]});
   oooo = mitem(ooo,'30°',{@Create 'Schleif', 30,[]});
   oooo = mitem(ooo,'45°',{@Create 'Schleif', 45,[]});
   oooo = mitem(ooo,'60°',{@Create 'Schleif', 60,[]});
   oooo = mitem(ooo,'75°',{@Create 'Schleif', 75,[]});
   oooo = mitem(ooo,'80°',{@Create 'Schleif', 80,[]});
   oooo = mitem(ooo,'85°',{@Create 'Schleif', 85,[]});
   oooo = mitem(ooo,'88°',{@Create 'Schleif', 88,[]});
   oooo = mitem(ooo,'89°',{@Create 'Schleif', 89,[]});
   oooo = mitem(ooo,'90°',{@Create 'Schleif', 90,[]});
   oooo = mitem(ooo,'-');
   oooo = Coupling(ooo);   
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Challenge',{@Create 'Challenge'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Motion Object',{@Create 'Motion'});
 
   function o = Create(o)
      gamma = eval(['@',arg(o,1)]);
      
         % remove first arg
         
      args = arg(o);
      args(1) = [];
      o = arg(o,args);
      
      oo = gamma(o);                   % create specific object
      paste(oo);                       % paste into shell
   end
end
function oo = Coupling(o)              % Coupling Menu                 
   setting(o,{'new.coupling'},0.5);
   
   oo = mitem(o,'Coupling',{},'new.coupling');
   choice(oo,[0 0.1 0.2 0.3 0.4 0.5 1 2 5 10]);
end

%==========================================================================
% SPM Objects
%==========================================================================

function oo = Mode2(o)                 % 2-Mode Sample                 
%
% MODE2 setup a 2-mode system according to the simulated 3-mode sample
%              exported from ANSYS.
%
   zeta = [0.01 0.01]';                % damping coefficients
%  f = [444 1091 2387]';               % eigen frequencies
   omega = [3000 7000]';               % circular eigen frequencies

   a0 = omega.*omega;                  % a0 = [7.8e6 47e6]';  
   a1 = 2*zeta.*omega;                 % a1 = [56 137]
   
   M = [-5e-10 -7.0 -2.0e-8; 7.0 -5e-10 2.0e-8];
  
  
      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M'];
   D = 0*C*B;

   oo = spm('spm');                    % new spm typed object
   oo.par.title = '2-Mode Sample';
   oo.par.comment = {'omega = [3000 1/s, 7000 1/s]','zeta = [0.01  0.01]'};
    
      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end
function oo = Mode3A(o)                % 3-Mode Sample, Version A      
%
% MODE3SAMPLEA setup an 3-mode system according to the simulated sample
%              exported from ANSYS. Version A is as close to the ANSYS
%              model
%
   a0 = [7.8e6 47e6 225e6]';           % circular eigen frequencies
   a1 = [56 137 300]';                 % damping terms
   
   M = [-5e-10 -7.2 -2.3e-8; 7.1 -5e-10 1.8e-8; 4.2e-8 -7e-8 0];
  
      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M'];
   D = 0*C*B;

   oo = spm('spm');                    % new spm typed object
   oo.par.title = '3-Mode Sample A';
    
      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end
function oo = Mode3B(o)                % 3-Mode Sample, Version B      
%
% MODE3SAMPLEB setup an 3-mode system according to the simulated sample
%              exported from ANSYS. Version B is as close to the ANSYS
%              model, and is derived from eigenfrequencies & dampings
%
   zeta = [0.01 0.01 0.01]';           % damping coefficients
   f = [444 1091 2387]';               % eigen frequencies
   omega = 2*pi*f;                     % circular eigen frequencies

   a0 = omega.*omega;                  % a0 = [7.8e6 47e6 225e6]';  
   a1 = 2*zeta.*omega;                 % a1 = [56 137 300]
   
   M = [-5e-10 -7.2 -2.3e-8; 7.1 -5e-10 1.8e-8; 4.2e-8 -7e-8 0];
  
      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M'];
   D = 0*C*B;

   oo = spm('spm');                    % new spm typed object
   oo.par.title = '3-Mode Sample B';
    
      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end
function oo = Mode3C(o)                % 3-Mode Sample, Version C      
%
% MODE3SAMPLEC setup an 3-mode system according to the simulated sample
%              exported from ANSYS. Version C is as close to the ANSYS
%              model, is derived from eigenfrequencies & dampings, and
%              has rounded values
%
   zeta = [0.01 0.01 0.01]';           % damping coefficients
%  f = [444 1091 2387]';               % eigen frequencies
   omega = [3000 7000 15000]';         % circular eigen frequencies

   a0 = omega.*omega;                  % a0 = [7.8e6 47e6 225e6]';  
   a1 = 2*zeta.*omega;                 % a1 = [56 137 300]
   
%  M = [-5e-10 -7.2 -2.3e-8; 7.1 -5e-10 1.8e-8; 4.2e-8 -7e-8 0];
   M = [-5e-10 -7.0 -2.0e-8; 7.0 -5e-10 2.0e-8; 4.0e-8 -7e-8 0];
  
      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M'];
   D = 0*C*B;

   oo = spm('spm');                    % new spm typed object
   oo.par.title = '3-Mode Sample C';
    
      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end

%==========================================================================
% Academic Object Samples
%==========================================================================

function oo = Academic1(o)             % Academic Sample #1            
%
% ACADEMIC setup an 3-mode system according to the simulated sample
%          exported from ANSYS. Version C is as close to the ANSYS
%          model, is derived from eigenfrequencies & dampings, and
%          has rounded values
%
   zeta = [0.01 0.01 0.01]';           % damping coefficients
%  f = [444 1091 2387]';               % eigen frequencies
   omega = [3 7 15]'*1;                % circular eigen frequencies

   a0 = omega.*omega;                  % a0 = [7.8e6 47e6 225e6]';  
   a1 = 2*zeta.*omega;                 % a1 = [56 137 300]
   
%  M = [-5e-10 -7.2 -2.3e-8; 7.1 -5e-10 1.8e-8; 4.2e-8 -7e-8 0];
   M = 1e-3*[-5e-10 -7.0 -2.0e-8; 7.0 -5e-10 2.0e-8; 4.0e-8 -7e-8 0];
  
      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M];
   D = 0*M;

   oo = spm('spm');                    % new spm typed object
   oo.par.title = 'Academic Sample #1';
   oo.par.comment = {'omega = [3 7 15],  zeta = 0.01',...
                     'Set simulation time: 10s'};
    
      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end
function oo = Academic2(o)             % Academic Sample #2            
%
% ACADEMIC setup an 3-mode system according to the simulated sample
%          exported from ANSYS. Version C is as close to the ANSYS
%          model, is derived from eigenfrequencies & dampings, and
%          has rounded values
%
   zeta = [0.01 0.01 0.01]';           % damping coefficients
%  omega = [3 7 15]';                  % circular eigen frequencies
   omega = [2 8 16]';                  % circular eigen frequencies

   a0 = omega.*omega;                  % a0 = [7.8e6 47e6 225e6]';  
   a1 = 2*zeta.*omega;                 % a1 = [56 137 300]
   
%  M = [-5e-10 -7.2 -2.3e-8; 7.1 -5e-10 1.8e-8; 4.2e-8 -7e-8 0];
%  M = 1e-3*[0 -7.0 -2.0e-8*0; 7.0 0 2.0e-8*0; 4.0e-8*0 -7e-8*0 0];
%  M = [0 -7.0 -2.0e-8*0; 7.0 0 2.0e-8*0; 4.0e-8*0 -7e-8*0 0];
%  M = [0 -5 -1;  7 0 1;  4 -5 0];
   M = [0 -2 -1;  
        2  0  1;  
        1 -1  0];
  
      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M];
   D = 0*M;

   oo = spm('spm');                    % new spm typed object
   oo.par.title = 'Academic Sample #2';
   oo.par.comment = {sprintf('omega = [%g %g %g],  zeta = %g',...
                              omega(1),omega(2),omega(3),zeta(1)),...
                     'Set simulation time: 10s',...
                     'M = [0 -2 -1;  2 0 1;  1 -1 0]'};
                  
      % store some parameters as info
      
   oo.par.omega = omega;
   oo.par.zeta = zeta;
   oo.par.M = M;
    
      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end

%==========================================================================
% High Order Samples
%==========================================================================

function oo = Order(o)                 % HIgh Order Sample      
%
% ORDER setup an n-mode system
%
   n = arg(o,1);
   
   zeta = 0.1*ones(n,1);               % damping coefficients
   if (n == 2)
      omega = [3000 7000]';            % circular eigen frequencies
   elseif (n == 3)
      omega = [3000 7000 15000]';      % circular eigen frequencies
   else
      omega = (1:n)'*15000/n;          % circular eigen frequencies
   end

   a0 = omega.*omega;                  % a0 = [7.8e6 47e6 225e6]';  
   a1 = 2*zeta.*omega;                 % a1 = [56 137 300]
   
%  M = [-5e-10 -7.2 -2.3e-8; 7.1 -5e-10 1.8e-8; 4.2e-8 -7e-8 0];
   M = (1:n)'*[-5e-10 -7.0 -2.0e-8];
  
      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M'];
   D = 0*C*B;

   oo = spm('spm');                    % new spm typed object
   oo.par.title = sprintf('%g-Mode Sample',n);
    
      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end

%==========================================================================
% Schleifsaal Hypothese
%==========================================================================

function oo = Schleif(o)               % Schleifsaal Hypothese         
   theta = arg(o,1);                   % Lagewinkel
   coupling = arg(o,2);
   coupling = o.either(coupling,opt(o,{'new.coupling',0}));
   
      % ka wa<s nominal ka = 5e8, but we take 10x the value
      % to have an effective demonstration of the instability
      
   k0 = 40;
   ka = 500e6*k0;                      % 500 N/um (nominal axial stiffness)
   kt = 15e6;                          %  15 N/um (nominal tang. stiffness)
 
   ki = 5e6;%*k0;                        %   5 N/um (crystal stiffness)  
   ci = 50;  ca = ci;  ct = ci;        %  50 Ns/m (viscous damping)
   m = 0.5;                            % 0.5 kg   (mass)
   
   Sin = sin(theta*pi/180);
   Cos = cos(theta*pi/180);
   
      % transformation matrix
      
   T = [Cos 0 -Sin; 0 1 0; Sin 0 Cos];
   Cd = T*diag([ca ct ct])*T' + diag([ci ci ci]);
   Kd = T*diag([ka kt kt])*T' + diag([ki ki ki]);
   cf = [0 0 ci]';  kf = [0 0 ki]'; 
  
      % coupling
      
   ck = coupling*ci;    kk = coupling*ki;
   Cd(1,2) = ck;   Kd(1,2) = kk;
   Cd(2,1) = ck;   Kd(2,1) = kk
   Cd(2,3) = ck;   Kd(2,3) = kk
   Cd(3,2) = ck;   Kd(3,2) = kk
   
   n = length(T);  Z = zeros(n);  I = eye(n);
   
   A = [Z I; -Kd/m, -Cd/m];
   B = [Z; I/sqrt(m)];
   C = [I/sqrt(m) Z];
   D = Z;
   
   oo = spm('spm');                    % new spm typed object
   oo.par.title = sprintf('Schleifsaal Hypothese Pivot %g° @ Coupling %g',...
                          theta,coupling);

      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end

%==========================================================================
% Challenging Sample
%==========================================================================

function oo = Challenge(o)             % A Challenging Sample          
%
% CHALLENGE setup an 2x2 @ 3-mode system which comes with numerical
%           challenges in case of FQR calculation
%
   zeta = [0.01 0.01 0.01]';           % damping coefficients
   f = [100 11000 10000]';             % eigen frequencies
   omega = 2*pi*f;                     % circular eigen frequencies

   a0 = omega.*omega;                  % a0 = [7.8e6 47e6 225e6]';  
   a1 = 2*zeta.*omega;                 % a1 = [56 137 300]
   
%  M = 1e-3*[-5e-10 -7.0 -2.0e-8; 7.0 -5e-10 2.0e-8; 4.0e-8 -7e-8 0];
%  M = 1e0 *[1  -10   1;    10  -1   1;   1   -1   1];
   M = 1e0 *[-1 0 1,  1 -1 1, 1 0 -2
              0 2 1,  -1 2 0,  1 2 -1
              1 1 -1,  -1 1 1,  0 -1 1];
   M = [
          1  -10   1
          10  -1   1
          1   -1   1
       ];

   M = [
           0   0   1
          10   0   1
           0   0   1
       ];

   M = [
           0   0   1
           0   0   1
           10   0   1
       ];

      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M'];
   D = 0*C*B;

   oo = spm('spm');                    % new spm typed object
   oo.par.title = 'Challenge #1';
   oo.par.comment = {'f = [100 1000 100000],  zeta = 0.01'};
    
      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end

%==========================================================================
% Motion Objects
%==========================================================================

function oo = Motion(o)                % Motion Object                 
   oo = inherit(type(corasim,'motion'),o);
   
      % copy data from motion options
      
   oo = data(oo,opt(o,'motion'));
   oo.par.title = sprintf('Motion Object (%s)',datestr(now));
end
