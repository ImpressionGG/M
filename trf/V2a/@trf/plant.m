function oo = plant(o,varargin)        % Plant Method                  
%
% PLANT   Create a new plant pbject
%
%           plant(o,'IPT1')            % create I-PT1 plant model
%           plant(o,'AXIS')            % create simple axis model
%           plant(o,'GANTRY')          % create gantry model 
%
   [gamma,oo] = manage(o,varargin,@Plant,@IPT1,@AOB,@GOB);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Plant(o)                 % Plant Menu Setup              
   oo = mitem(o,'Plant');
   ooo = mitem(oo,'I-PT1 Plant',{@IPT1});
   ooo = mitem(oo,'Axis on Base',{@AOB});
   ooo = mitem(oo,'Gantry on Base',{@GOB});
end

%==========================================================================
% Actual Plant Model Creation
%==========================================================================
%
function oo = IPT1(o)                  % New I-PT1 Plant Model         
%
% IPT1   Create an I-PT1 plant model with transfer function 
%                         V    
%          G(s) = -----------------    % V = 1, T = 1
%                   s * (1 + s*T)
%
   [V,T] = get(o,{'V',1},{'T',5});
   oo = trf(V,[T 1 0]);               % transfer function

   oo = set(oo,'V',V,'T',T);
   oo = set(oo,'edit',{{'Gain V','V'},{'Time Constant T','T'}});
   
   head = 'IPT1(s) = V / [s * (s*T + 1)]';
   params = sprintf('V = %g, T = %g',V,T);
   oo = finish(o,oo,'IPT1 System',{head,params},'r');
end
function oo = AOB(o)                   % New Axis on Base Plant Model  
%
% AOB   Create a plant with transfer function for a linear driven axis
%       system with the axis mounted on an elastic base.
%
%                    x2 +-------+
%                   |-->|       |-----> F = K*u
%                       +-O---O-+
%        |   c   +---------------------+
%        |-/\/\/-|       x1            |   F      :                  .
%        |       |      |->o m         |<-----  m*x1 = -F - c*x1 - d*x1 
%        |--=|---|                     |
%        |   d   +--O--------------O---+        (M*s2 + d*s + c)*x1 = -K*u
%        +-------------------------------------
%        
%         x1(s) = - G(s) * F(s)
%
%                       K/m
%          G(s) = ----------------          % m = 600, c = 1e5, d = 1e5
%                   s2 + s*d + c
%
   [K,m,c,d] = get(o,{'K',1e10},{'m',600},{'c',1e5},{'d',1e3});
   oo = trf(K/m,[m d c]);              % transfer function

   oo = set(oo,'K',K,'m',m,'c',c,'d',d);
   oo = set(oo,'edit',{{'Gain K','K'},{'Mass of Base m','m'},...
               {'Spring Constant c','c'},{'Damping Constant d','d'}});
    
   head = 'AOB(s) = (K/m) / [s^2 * s*d + c)]';
   params = sprintf('K = %g, m = %g, c = %g, d = %g',K,m,c,d);
   oo = finish(o,oo,'Axis-on-Base (AOB) System',{head,params},'r');
end
function oo = GOB(o)                   % New Gantry on Base Plant Model
%
% GOB   Create Gantry-on-Base plant with transfer function 
%
%           x2 |-->|             x3 |-->|
%                  +-+ d2 +-------------+
%          Fd2 --->| |-=|-|<--- Fd2   m3|
%       F -------->| |    +-O-------+   |
%              |-->| +---------+ c2 |   |
%               x2 | m2 Fc2 -->|/\/\|   |<-- Fc2
%                  +-O-------O-+    +-O-+
%        |  c1   +------------------------+
%        |-/\/\/-|<-- Fc1   x1            |   F      :                  .
%        |       |         |->o m1        |<-----  M*x1 = -F - c*x1 - d*x1 
%        |--=|---|<-- Fd1                 |
%        |  d1   +--O-----------------O---+       (M*s2 + d*s + c)*x1 = -F
%        +-------------------------------------
%        
%                 :                                     .
%          (1) m1*x1 = -F - Fc1 - Fd1 = -F - c1*x1 - d1*x1
%                 :                                          .  .
%          (2) m2*x2 = F + Fc2 + Fd2  =  F + c2*(x3-x2) + d2*(x3-x2)
%                 :
%          (3) m3*x3 = -Fc2 - Fd2     = -c2*(x3-x2) - d2*(x3-x2)
%   
   [K,n,m1,m2,m3,c1,c2,d1,d2] = get(o,{'K',1e6},{'n',2},{'m1',600},{'m2',20},...
            {'m3',40},{'c1',2e6},{'c2',1e7},{'d1',1e3},{'d2',1e3});

   G1 = trf(-1,[m1 d1 c1]);
   G2 = trf([m3,d2,c2],[m2*m3, d2*(m2+m3), c2*(m2+m3)]);
   
   for (i=1:n)
      G2 = G2 * trf(1,[1 0]);
   end
         
   P = K*(G2 - G1);
   oo = trf(P);   

   oo = set(oo,'K',K,'n',n,'m1',m1,'m2',m2,'m3',m3,'c1',c1,'d1',d1,'c2',c2,'d2',d2);
   oo = set(oo,'edit',{{'Plant Gain K','K'},...
                       {'Number of Integrators','n'},...
                       {'Mass of Base m1','m1'},...
                       {'Mass of Gantry Part m2','m2'},... 
                       {'Mass of Gantry Part m3','m3'},... 
                       {'Spring Constant c1','c1'},...
                       {'Spring Constant c2','c2'},...
                       {'Damping Constant d1','d1'},...
                       {'Damping Constant d2','d2'}});
   G1 = trf(-1,[m1 d1 c1]);
   G2 = trf([m3,d2,c2],[m2*m3, d2*(m2+m3), c2*(m2+m3)]);
    
   head = 'GOB(s) = K*(1/s^2 * [m3*s^2 + d2*s +c1] / [m2*m3*s^2 + d2*(m2+m3)*s + c2*(m2+m3)] - 1/[m1*s^2 + d1*s + c1])';
   param1 = sprintf('K = %g, m1 = %g, m2 = %g, m3 = %g',K,m1,m2,m3);
   param2 = sprintf('c1 = %g, c2 = %g, d1 = %g, d2 = %g',c1,c2,d1,d2);
   oo = finish(o,oo,'Gantry-on-Base (GOB) System',{head,[param1,', ',param2]},'r');
end
