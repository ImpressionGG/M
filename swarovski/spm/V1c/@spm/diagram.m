function o = diagram(o,varargin)
%
% DIAGRAM   Plot diagram
%
%              diagram(o,'Force','F1',t,F1,sub)       % force 1
%              diagram(o,'Elongation','x2',t,x2,sub)  % elongation 2
%              diagram(o,'Mode','x4',t,x4,sub)        % mode 4
%
%           Copyright(c): Bluenetics 2020
%
%           See also: SPM, PLOT
%
   [gamma,oo] = manage(o,varargin,@Force,@Elongation,@Mode,@Orbit);
   oo = gamma(oo);
end

%==========================================================================
% Force
%==========================================================================

function o = Force(o)                  % Force Diagram                 
   Kms = var(o,{'Kms',1});             % time scaling correction
   ms = Kms*0.001;                     % factor ms/s
   N = 1;                              % factor N/N
 
   sym = arg(o,1);
   t = arg(o,2);
   F = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,t/ms,F/N,'yyr');
   
   title(['Force ',sym]);
   xlabel('time [ms]');
   ylabel([sym,' [N]']);
   
   grid(o);
   heading(o);
end

%==========================================================================
% Elongation
%==========================================================================

function o = Elongation(o)             % Elongation Diagram            
   Kms = var(o,{'Kms',1});             % time scaling correction
   ms = Kms*0.001;                     % factor ms/s
   um = 1e-6;
 
   sym = arg(o,1);
   t = arg(o,2);
   y = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,t/ms,y/um,'g');
   
   title(['Elongation ',sym]);
   xlabel('time [ms]');
   ylabel([sym,' [um]']);
   
   grid(o);
   heading(o);
end

%==========================================================================
% Mode
%==========================================================================

function o = Mode(o)                   % Mode Diagram                  
   Kms = var(o,{'Kms',1});             % time scaling correction
   ms = Kms*0.001;                     % factor ms/s
   um = 1e-6;
 
   colors = {'r','y','bc','m','gc','rw','yw','bcw','mw','gcw',...
             'rk','yk','bck','mk','gck'};
   
       % consult 'some magic' to generate unique color index
       
   sym = arg(o,1);
   idx = 1 + rem(sum(sym)-sum('x1')+10*length(colors),length(colors));
   col = colors{idx};
   
   t = arg(o,2);
   x = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   if (size(x,1) == 1)
      plot(o,t/ms,x/um,col);
   else
      plot(t/ms,x/um);
   end
   
   title(['Mode ',sym]);
   xlabel('time [ms]');
   ylabel([sym,' [um]']);
   
   grid(o);
   heading(o);
end

%==========================================================================
% Orbit
%==========================================================================

function o = Orbit(o)                  % Orbit Diagram                 
   Kms = var(o,{'Kms',1});             % time scaling correction
   ms = Kms*0.001;                     % factor ms/s
   um = 1e-6;
 
   sym = arg(o,1);
   ya = arg(o,2);
   yb = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,ya/um,yb/um,'g');
   
   try
      sym1 = sym(4:5);
      sym2 = sym(1:2);
   catch
      sym1 = 'ya';  sym2 = 'yb';
   end
   
   title(['Orbit ',sym2,' (',sym1,')']);
   xlabel([sym1,' [ms]']);
   ylabel([sym2,' [um]']);
   
   grid(o);
   heading(o);
end
