function oo = magni(o,col)             % Corasim Magnitude Plot             
%
% MAGNI  Bode magnitude plot of a CORASIM object
%
%           magni(o)                   % bode magnitude plot
%           magni(o,'g')               % magnitude plot in green color
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
%           magnitude.low    magnitude range, low limit (default: -80)
%           magnitude.high   magnitude range, high limit (default: 80)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORASIM, BODE, PHASE, FQR, NYQ, STEP
%
   oo = opt(o,'magnitude.enable',1, 'phase.enable',0);
   if (nargin >= 2 && ischar(col))
      oo = opt(oo,'color',col);
   end

   oo = bode(oo);
end
