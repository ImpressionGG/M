function [td,acont,du] = duty(o,smax,vmax,amax,tj,unit,infotext)
%
% EDUTY  Calculate ETEL style duty time, continuous acceleration and duty cycle of a motion profile
%
%           [tduty,ac,du] = duty(o,smax,vmax,amax,tj,unit)     % return continuous acceleration
%           duty(o,smax,vmax,amax,tj,unit)                     % plot acceleration profile and cont. acceleration
%           duty(o,NaN,vmax,amax,tj,unit)                      % plot duty map
%
%        Theory:
%           Assume a trapezoidal acceleration profile with the following phases
%           1) ramp up from    0 .. am  over time Ta
%           2) constant phase am        over time Tp
%           3) ramp down from  am .. 0  over time Ta
%           4) beeing zero              over time Tz
%           5) ramp down from  0 .. -am over time Ta
%           6) constant phase  -am      over time Tp
%           7) ramp up from    -am .. 0 over time Ta
%
%        Note that the total time equals T = 4*Ta + 2*Tp + Tz !
%        
%        Then:
%			Duty time is 	tduty = (4/3*Ta + 2*Tp)*(am/amax)^2
%			continuous acceleration equals   ac = am * sqrt([4/3*Tp + 2*Tc]/T)
%        Duty cycle is defined by  du = ac/am
%
%        See also: CARASIM, MOTION
%
   algo = opt(o,{'algo',1});           % ETEL algorithm by default
   epsi = 1e6*eps;

   if (nargin < 2) 
      smax = opt(o,{'smax',100});
   end
   if (length(smax) > 1) 
      if (min(size(smax)) ~= 1)
         error('arg1 must be a scalar or vector!');
      end
      si = smax;
      smax = max(si(:));
   end
      
   if (nargin < 3)
      vmax = opt(o,{'vmax',1000});
   end
   if (nargin < 4) 
      amax = opt(o,{'amax',10000});
   end
   if (nargin < 5) 
      tj = opt(o,{'tj',0});
   end
   if (length(tj) > 1)
      algo = tj(2); tj = tj(1);
   end
   
   if (nargin < 6)
      unit = opt(o,{'unit','mm'});;
   end
   if (nargin < 7)
      infotext = sprintf('Motion profile (Algo %g)',algo); 
      infotext = opt(o,{'info',infotext});
   end
   
   if (isempty(smax) || iscell(smax))
      fprintf('*** motion(o,[],...) or motion(o,{},...) no more supported!');
      fprintf('*** use motion(o,NaN,...) instead!');
      smax = NaN;
   end
   if isnan(smax)
      %if (iscell(smax)) smax = smax{1}; end
      DutyMap(o,smax,vmax,amax,tj,algo,unit,infotext);
      return;
   end
   
   [ti,tsvaj,tref] = motion(o,smax,vmax,amax,[tj algo],unit);
   
   t = tsvaj(:,1);
   v = tsvaj(:,3);
   a = tsvaj(:,4);
   j = tsvaj(:,5);
   d = tsvaj(:,6);
   
   tmax = max(t);
   tj = t(2);  j0 = j(2);
   Tmax = tmax; tadd = tmax-tref;
   vm = max(v);
   
   % continuous acceleration must be based on amax, not on the maximum 
   % acceleration reached during the movement! (MILO 30.1.02)
   
   am = max(abs(a));
   
   %ta = t(2) - t(1);
   %tv = t(3) - t(2);
   %tz = t(5) - t(4);
   
   %Tduty = [4/3*ta + 2*tv]*(am/amax)^2;  % old formula of calculating duty time
   
   tduty = 0;
   for (i=1:length(t)-1)
      DTi = t(i+1)-t(i);
      ai = a(i);
      ji = j(i+1);    % note: index of jerk is shifted by 1
      Tdi = 1/amax^2*[ai^2*DTi + ai*ji*DTi^2 + ji^2*DTi^3/3];
      tduty = tduty + Tdi;
   end
   
   dut = sqrt(tduty/tmax);   % duty
   ac = amax * dut;          % continuous acceleration
   
   if (nargout == 0)
      
         % convert units

      angle = strcmp(unit,'grd') | strcmp(unit,'deg') | strcmp(unit,'°');
      if (angle)
         vfac = 1/360; 
         kconv = 1;  % kconv = 360; 
         vmax = vmax*kconv;  % convert from rev/s to °/s
         amax = amax*kconv;  % convert from rev/s2 to °/s2
      else 
         vfac = 1;
         kconv = 1;  % kconv = 1000; 
         vmax = vmax*kconv;   % convert from m/s to mm/s
         amax = amax*kconv;   % convert from m/s2 to mm/s2
      end
      
         % plot ...
         
      cls(o);
      %carma.motmenu({smax,vmax,amax,[tj algo],unit,infotext},'duty');  % add motion menus
 
      subplot(211);
      hold off
      
      plot([0 tmax*1000],[ac ac]*vfac,'r-.');
      hold on
      set(gca,'xlim',[0 tmax*1000]);
      xlim = get(gca,'xlim');
      plot(xlim,[0 0],'k');
      
      %plot(t*1000,a,'m');
      
      for (i=1:length(t)-1)
         ai = a(i); ji = j(i+1);  dt = t(i+1)-t(i);
         plot([t(i) t(i+1)]*1000,[a(i) a(i)+j(i+1)*[t(i+1)-t(i)]]*vfac,'r'); hold on;
         plot([t(i+1) t(i+1)]*1000,[a(i)+j(i+1)*[t(i+1)-t(i)], a(i+1)]*vfac,'r'); hold on;
      end
      
      set(gca,'ylim',1.2*max(abs(a))*[-1 1]);
      
      if angle
         unit1 = 'rev';
         title(sprintf(['%s: %g ',unit,' / %g ms (%g ms + %g ms)'],infotext,Rd(max(smax)),Rd(tmax*1000),Rd(tref*1000),Rd(tadd*1000)));
         xlabel(sprintf(['n_m = %g ',unit1,'/s (%g),   a_m = %g ',unit1,'/s^2 (%g), t_j = %g ms (%g)'],Rd(vm/360),Rd(vmax/360),Rd(am/360),Rd(amax/360),Rd(tj*1000),Rd(tj*1000)));
         ylabel(['a [',unit1,'/s^2]']);
      else
         unit1 = unit;
         title(sprintf(['%s: %g ',unit,' / %g ms (%g ms + %g ms)'],infotext,Rd(max(smax)),Rd(tmax*1000),Rd(tref*1000),Rd(tadd*1000)));
         xlabel(sprintf(['v_m = %g ',unit,'/s (%g),   a_m = %g ',unit,'/s^2 (%g), t_j = %g ms (%g)'],Rd(vm),Rd(vmax),Rd(am),Rd(amax),Rd(tj*1000),Rd(tj*1000)));
         ylabel(['a [',unit,'/s^2]']);
      end
      
      subplot(212);
      hold off
      plot(xlim,[0 0],'k');
      set(gca,'xlim',[0 tmax*1000]);
      hold on
      for (i=1:length(d))
         if (abs(d(i)) > epsi) plot(t(i)*1000,d(i)*vfac,iif(d(i)>0,'g^','gv'), [t(i) t(i)]*1000,[0 d(i)]*vfac,'g:'); end
      end
      t = [t(1) t(1) t(2) t(2) t(3) t(3) t(4) t(4) t(5) t(5) t(6) t(6) t(7) t(7) t(8) t(8) t(9) t(9) t(10) t(10)];
      j = [j(1) j(2) j(2) j(3) j(3) j(4) j(4) j(5) j(5) j(6) j(6) j(7) j(7) j(8) j(8) j(9) j(9) j(10) j(10) 0];
      carabull.color(plot(t*1000,j*vfac),'yo');
      xlabel(sprintf(['T_{duty}= %g ms,   a_{cont}= %g %s/s^2,   duty = %g %%'],Rd(tduty*1000),Rd(ac*vfac),unit1,Rd(dut*100)));
      ylabel(sprintf('j [%s/s^3]',unit1));
      title(sprintf('Jerk: (j_m = %g mm/s3)',o.rd(amax/tj)));
      
      set(gca,'ylim',1.2*max(abs(j))*[-1 1]);
      shg
   else
      td = tduty;
      du = dut;
      acont = ac;
   end
      
   ac = 0;
end
   
%==========================================================================
% Auxillary Functions
%==========================================================================

function y = Rd(x)   % round to one digit after comma
   y = round(10*x)/10;
end
function x = CubeSolve(c,limits)
%
% CUBESOLVE solve cubic equation by interval half method
%
%           c(1)*x^3 + c(2)*x^2 + c(3)*x + c(4) = 0
%
   if (nargin < 2) limits = [-10000 10000]; end
   
   X = limits;   % short hand form
   Y = c(1)*X.^3 + c(2)*X.^2 + c(3)*X + c(4);
   
   n = 50;           % 50 iterations
   for (i=1:n)
      if (all(Y>0) | all(Y<0))
         error(sprintf('problem solving cubic equation: Y=[%g %g] for X=[%g %g]',Y(1),Y(2),X(1),X(2)));
      end
      
      if (Y(1) > Y(2)) Y = Y([2 1]);  X = X([2 1]); end  
      
      x = mean(X);
      y = c(1)*x^3 + c(2)*x^2 + c(3)*x + c(4);
      
      %fprintf('x: [%g %g] %g;  y: [%g %g] %g\n',X(1),X(2),x,Y(1),Y(2),y);
      
      if (y == 0)
         break;
      elseif (y < 0)
         X(1) = x;  Y(1) = y;
      else
         X(2) = x;  Y(2) = y;
      end
   end
end
function [s,T] = DutyMap(o,smax,vmax,amax,tj,algo,unit,infotext)
%
% DUTYMAP   Plot duty map
%
   tc = vmax/amax;
   
   tjv = sqrt(vmax/amax*tj);              % velocity limiting jerk time 
   tj = min([tj,tjv]);                    % actual jerk time
   
   sm0 = 0;  sx0 = 0;  sy0 = 0;  sa0 = 0;
   
   if (tj == 0)
      sv0 = vmax^2/amax;                  % characteristic distance regarding velocity mode 
   elseif (algo == 0)
      sv0 = vmax*(vmax/amax*tj/tj+tj);    % characteristic distance regarding velocity mode 
      sa0 = 2*amax*tj^3/tj;               % characteristic distance regarding acceleration mode 
   elseif (algo == 1 | algo == 2)
      sv0 = vmax*(vmax/amax*tj/tj+tj);    % characteristic distance regarding velocity mode 
      sa0 = amax*tj^2;                    % characteristic distance regarding acceleration mode 
      sx0 = CubeSolve([1,-3*sv0,3*sv0^2+vmax^3/amax*tj,-sv0^3],[0 sv0]);      
      sy0 = vmax^2/amax; 
      sm0 = max(sx0,sy0);                 % characteristic distance regarding mixed mode 
   else
      error(sprintf('bad algo: %g',algo));
   end
   
   s0 = 1.5*max([sv0,sm0]);
   
   p = 100;
   s = s0 * (1:p).^2/p^2;
   
   for (i=1:length(s))
      [td,ac,du] = duty(o,s(i),vmax,amax,[tj algo],unit,infotext);
         
      tduty(i) = td;
      acont(i) = ac;
      duty(i) = du;
   end
  
   
   cls(o);
   %carma.motmenu({smax,vmax,amax,[tj algo],unit,infotext},'duty map');  % add motion menus
    
   subplot(211)
   
   plot(s,duty*100);
   hold on
   
   xlim = get(gca,'xlim');  ylim = get(gca,'ylim');
   
   if (0 < sv0 & sv0 <= max(xlim)) plot([sv0 sv0],ylim,'b-'); end
   if (0 < sa0 & sa0 <= max(xlim)) plot([sa0 sa0],ylim,'r-'); end
   if (0 < sm0 & sm0 <= max(xlim)) plot([sm0 sm0],ylim,'g-'); end
   
   title(sprintf('Duty Map (Algo %g):    v_{max}= %g %s/s, a_{max}= %g %s/s2, t_s= %g ms',algo,Rd(vmax),unit,Rd(amax),unit,Rd(tj*1000)));
   xlabel(sprintf('motion distance [%s]',unit));
   ylabel('duty factor [%]');
   shg;
   
   subplot(212)
   
   plot(s,tduty*1000);
   hold on
   
   xlim = get(gca,'xlim');  ylim = get(gca,'ylim');
   
   if (0 < sv0 & sv0 <= max(xlim)) plot([sv0 sv0],ylim,'b-'); end
   if (0 < sa0 & sa0 <= max(xlim)) plot([sa0 sa0],ylim,'r-'); end
   if (0 < sm0 & sm0 <= max(xlim)) plot([sm0 sm0],ylim,'g-'); end
   
   critical = sprintf('  Characteristics: t_c=%g ms, s_{a0}=%g, s_{m0}=%g, s_{v0}=%g',Rd(tc*1000),Rd(sa0),Rd(sm0),Rd(sv0));
   
   xlabel(sprintf('%s',critical));
   ylabel('duty time [ms]');
   shg;
end
