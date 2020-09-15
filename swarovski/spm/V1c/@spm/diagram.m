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
   o = with(o,'view');                 % unwrap view options
   o = opt(o,'yscale',1,'yunit','N');
 
   sym = arg(o,1);
   t = arg(o,2);
   F = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,t,F,'yyr');
   
   Epilog(o,['Force ',sym],sym);
end

%==========================================================================
% Elongation
%==========================================================================

function o = Elongation(o)             % Elongation Diagram            
   o = with(o,'view');                 % unwrap view options
   
   sym = arg(o,1);
   t = arg(o,2);
   y = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,t,y,'g');
   
   Epilog(o,['Elongation ',sym],sym);
end

%==========================================================================
% Mode
%==========================================================================

function o = Mode(o)                   % Mode Diagram                  
   o = with(o,'view');                 % unwrap view options
 
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
      plot(o,t,x,col);
   else
      plot(t,x);
   end
   
   Epilog(o,['Mode ',sym],sym);
end

%==========================================================================
% Orbit
%==========================================================================

function o = Orbit(o)                  % Orbit Diagram                 
   o = with(o,'view');                 % unwrap view options
   o = opt(o,'xscale',opt(o,'yscale'));% copy y-scaling factor
   o = opt(o,'xunit',opt(o,'yunit'));  % copy y-unit
   
   sym = arg(o,1);
   ya = arg(o,2);
   yb = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,ya,yb,'g');
   
   try
      sym1 = sym(4:5);
      sym2 = sym(1:2);
   catch
      sym1 = 'ya';  sym2 = 'yb';
   end
  
   Epilog(o,['Orbit ',sym2,' (',sym1,')'],sym1,sym2);
end

%==========================================================================
% Helper
%==========================================================================

function o = Epilog(o,tit,sym1,sym2)   % Epilog Tasks for Diagrams     
   title(tit);
   
   if (nargin == 3)
      xlabel(['time [',opt(o,{'xunit','?'}),']']);
      ylabel([sym1,' [',opt(o,{'yunit','?'}),']']);
   elseif (nargin == 4)
      xlabel([sym1,' [',opt(o,{'xunit','?'}),']']);
      ylabel([sym2,' [',opt(o,{'yunit','?'}),']']);
   end
   
   grid(o);
   heading(o);
end
