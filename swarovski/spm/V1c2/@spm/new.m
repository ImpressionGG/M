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
%           o = new(spm,'Schleif75')   % Schleifsaal Hypothese 75�
%
%           o = new(sho,'Motion')      % motion object
%
%       See also: SPM, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Mode3A,@Mode3B,@Mode3C,...
                       @Academic1,@Academic2,@Schleif,@Motion,@Menu);
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
   ooo = mitem(oo,'3-Mode Sample (A)',{@Create 'Mode3A'});
   ooo = mitem(oo,'3-Mode Sample (B)',{@Create 'Mode3B'});
   ooo = mitem(oo,'3-Mode Sample (C)',{@Create 'Mode3C'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Academic Sample #1',{@Create 'Academic1'});
   ooo = mitem(oo,'Academic Sample #2',{@Create 'Academic2'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Schleifsaal Hypothese 0�', {@Create 'Schleif' 0});
   ooo = mitem(oo,'Schleifsaal Hypothese 15�',{@Create 'Schleif' 15});
   ooo = mitem(oo,'Schleifsaal Hypothese 30�',{@Create 'Schleif' 30});
   ooo = mitem(oo,'Schleifsaal Hypothese 45�',{@Create 'Schleif' 45});
   ooo = mitem(oo,'Schleifsaal Hypothese 60�',{@Create 'Schleif' 60});
   ooo = mitem(oo,'Schleifsaal Hypothese 75�',{@Create 'Schleif' 75});
   ooo = mitem(oo,'Schleifsaal Hypothese 80�',{@Create 'Schleif' 80});
   ooo = mitem(oo,'Schleifsaal Hypothese 85�',{@Create 'Schleif' 85});
   ooo = mitem(oo,'Schleifsaal Hypothese 90�',{@Create 'Schleif' 90});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Motion Object',{@Create 'Motion'});
   
   ooo = mitem(oo,'-');
   ooo = Parameter(oo);


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
function oo = Parameter(o)
   setting(o,{'new.coupling'},0);
   
   oo = mitem(o,'Parameter');
   ooo = mitem(oo,'Coupling',{},'new.coupling');
   choice(ooo,[0 0.1 0.2 0.5 1 2 5 10]);
end

%==========================================================================
% SPM Objects
%==========================================================================

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
   C = [M' 0*M];
   D = 0*M;

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
   C = [M' 0*M];
   D = 0*M;

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
   C = [M' 0*M];
   D = 0*M;

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
% Academic Object Samples
%==========================================================================

function oo = Schleif(o)               % Schleifsaal Hypothese         
   theta = arg(o,1);                   % Lagewinkel
   
%  ka = 5e8;                           %  500 N/um (axial stiffness)
%  kt = 1.5e7;                         %   15 N/um (tangential stiffness)
   ka = 5e7;                           %   20 N/um (axial stiffness)
   kt = 2e7;                           %    2 N/um (tangential stiffness)

   ki = 5e6;                           %    5 N/um (crystal stiffness)  
   ci = 50;  ca = ci;  ct = ci;        %   50 Ns/m (viscous damping)
   m = 0.5;                            %  0.5 kg   (mass)
   
   Sin = sin(theta*pi/180);
   Cos = cos(theta*pi/180);
   
      % transformation matrix
      
   T = [Cos 0 -Sin; 0 1 0; Sin 0 Cos];
   Cd = T*diag([ca ct ct])*T' + diag([ci ci ci]);
   Kd = T*diag([ka kt kt])*T' + diag([ki ki ki]);
   cf = [0 0 ci]';  kf = [0 0 ki]'; 
  
      % coupling
      
   coupling = opt(o,{'new.coupling',0});
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
   oo.par.title = sprintf('Schleifsaal Hypothese %g�',theta);
   oo.par.comment = {sprintf('coupling: %g',coupling)}
   
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
