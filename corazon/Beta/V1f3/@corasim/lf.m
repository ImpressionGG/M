function oo = lf(o,omega)
%
% LF   Linear factor
%
%         G = lf(o,2)                  % G = 1/(1+2*s)
%         G = lf(o)                    % G = 1/s
%
%      Copyright(c): Bluenetics 2020
%
%      See also: CORASIM, TRF, QF
%
   if (nargin == 1)
      oo = trf(corasim,[1 0],[1]);
   elseif (nargin == 2)
      oo = trf(corasim,[1/omega 1],[1]);
   end
end
