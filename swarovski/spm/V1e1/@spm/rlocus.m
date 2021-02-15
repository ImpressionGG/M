function rlocus(o,L0,mu,glim)
%
% RLOCUS   Root locus plot of a SISO or MIMO state space representation
%          in terms of negative damping versus frequency.
%
%             L0 = cook(cuo,'Sys0');
%
%             rlocus(o,L0)             % take mu from 'process.mu' option
%             rlocus(o,L0,mu,glim)     % provide mu and gain limits
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
   scale = oscale(o);
   
   if (nargin < 3)
      mu = opt(o,{'process.mu',0.1}); 
   end
   if (nargin < 4)
      glim = [-inf +inf];
   end
   
      % setup coloring
      
   Ktab = [0.001 0.01  0.1  0.2  0.5   1    2    5    10   20  100  1000];
   Ctab = { 'w','wwm','wm', 'm', 'mr' 'r','yr','yyr','yyyr','g','gb', 'gkb'};
      
      % get critical gains
   
   [K0,K180] = cook(o,'K0,K180');
   col = o.iif(dark(o),'w','k');
   
   PlotRoots(A0,B0,C0,D0,0,'w','p');
   hold on;
   
   PlotRoots(A0,B0,C0,D0,K0,'r','p');
   %PlotRoots(A0,B0,C0,D0,-K0,'b','p');
   
   points = opt(o,{'points',25});
   
   for (i=2:length(Ktab))
      low = max(Ktab(i-1),glim(1));
      high = min(Ktab(i),glim(2));
      
      if (low <= high)
         K = logspace(log10(low),log10(high),points);
         col = o.color(Ctab{i});
         PlotRoots(A0,B0,C0,D0,K*mu,col,'.');
         PlotRoots(A0,B0,C0,D0,Ktab(i)*mu,col,'p');
      end
   end
   
   ylim = get(gca,'ylim');
   set(gca,'ylim',[ylim(1),2]);
   subplot(o);                         % subplot done
   
   function PlotRoots(A0,B0,C0,D0,Kmu,col,marker)
      if (nargin < 7)
         marker = '*';
      end
      if ischar(col)
         col = o.color(col);
      end
      
      for (k=1:length(Kmu))
         [s,f,zeta] = Roots(A0,B0,C0,D0,Kmu(k));
         hdl = semilogx(f,zeta*100,['w',marker]);   
         set(hdl,'color',col);
      end
   end
   function [s,f,zeta] = Roots(A0,B0,C0,D0,K)   % closed loop roots
      I = eye(size(D0));
      A = A0 - B0*inv(I+K*D0)*K*C0;
      
      s = eig(A);
      s = s/scale;
      om = abs(s);  f = om/2/pi;
      zeta = -real(s)./om;
   end
end