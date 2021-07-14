function oo = qf(o,omega,zeta)
%
% QF   Quadratic factor 1 + 2*zeta*s/omega + (s/omega)^2
%
%         G = qf(o,omega,zeta)      % G = 1/(1+2*zeta*s/omega+(s/omega)^2)
%
%      Copyright(c): Bluenetics 2020
%
%      See also: CORASIM, TRF, LF
%
   oo = trf(corasim,[1/omega^2 2*zeta/omega 1],[1]);
end
