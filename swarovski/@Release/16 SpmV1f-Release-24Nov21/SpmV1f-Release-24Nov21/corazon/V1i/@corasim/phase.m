function oo = phase(o,col)             % Corasim Phase Plot            
%
% PHASE  Bode phase plot of a CORASIM object
%
%           phase(o)                   % bode phase plot
%           phase(o,'g')               % phase plot in green color
%
%        Options:
%
%           oscale           omega scaling factor => fqr(G,om*oscale)
%           color            color propetty (default: 'r')
%
%           omega.low        omega range, low limit (default: 0.1)
%           omega.low        omega range, high limit (default: 100000)
%           omega.points     number of points to be plotted (default: 1000)
%
%           phase.low        phase range, low limit (default: -270)
%           phase.high       phase range, high limit (default: 90)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, BODE, PHASE, FQR, NYQ, STEP
%
   oo = opt(o,'magnitude.enable',0, 'phase.enable',1);
   if (nargin >= 2 && ischar(col))
      oo = opt(oo,'color',col);
   end

   oo = bode(oo);
end
