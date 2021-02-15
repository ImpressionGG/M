function rlocus(o,L0,mu)
%
% RLOCUS   Root locus plot of a SISO or MIMO state space representation
%          in terms of negative damping versus frequency.
%
%             L0 = cook(cuo,'Sys0');
%
%             rlocus(o,L0)             % take mu from 'process.mu' option
%             rlocus(o,L0,mu)
%
%          Theory:
%             1) calculate eigenvalues of closed loop system  
%
%                           +------------+   +-------------+
%                           |            |   |             |
%                      o--->|    K*mu    |-->|    L0(s)    |---*--->
%                      ^ -  |            |   |             |   |
%                      |    +------------+   +-------------+   |
%                      |                                       |
%                      +---------------------------------------+
%
%                according to the closed loop dynamic matrix
%
%                   [A0,B0,C0,D0] = system(L0)
%                   Kmu = K*mu
%                   A = A0 - B0*inv(eye(size(D0))+Kmu*D0)*Kmu*C0
%                   s = eig(A)
%
%             2) Plot negative damping versus frequency
%
%                   om = abs(s), f = om/2/pi
%                   zeta = -real(s)/om * 100%
%
%          Options
%             process.mu               % nominal friction coefficient
%             gain.low                 % lower gain
%             gain.high                % upper gain
%             points                   % number of points
%
%          Copyright(c): Bluenetics 2021
%
%          See also: SPM, COOK
%
   if ~type(L0,{'css','dss'})
      error('state space representation of L0 (arg2) expecgted');
   end
   [A0,B0,C0,D0] = system(L0);
   mu = opt(o,{'process.mu',0.1}); 
   
   [K0,K180] = cook(o,'K0,K180');
   
   PlotRoots(A0,B0,C0,D0,0,'w','p');
   hold on;
   subplot(o);
   
   PlotRoots(A0,B0,C0,D0,K0,'r','p');
   %PlotRoots(A0,B0,C0,D0,-K0,'b','p');
   
   subplot(o);                         % subplot done
   
   function PlotRoots(A0,B0,C0,D0,Kmu,col,marker)
      if (nargin < 7)
         marker = '*';
      end
      
      [s,f,zeta] = Roots(A0,B0,C0,D0,Kmu);
      
      hdl = plot(f,zeta,['w',marker]);
      if ischar(col)
         col = o.color(col);
      end
      
      set(hdl,'color',col);
   end
   function [s,f,zeta] = Roots(A0,B0,C0,D0,K)   % closed loop roots
      I = eye(size(D0));
      A = A0 - B0*inv(I+K*D0)*K*C0;
      
      s = eig(A);
      om = abs(s);  f = om/2/pi;
      zeta = real(s)/om;
   end
end