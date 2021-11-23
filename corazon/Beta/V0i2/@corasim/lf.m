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
      oo = ZeroLf(o);
   elseif (nargin == 2)
      oo = LinearFactor(o,omega);
   end
end

%==========================================================================
% Construct Linear Factor
%==========================================================================

function oo = ZeroLf(o)                % Construct Zero Linear Factor       
   if type(o,{'szpk','zzpk','qzpk'})
      oo = zpk(o,[0],[],1);
   else
      oo = trf(o,[1 0],[1]);
   end
   
   T = o.either(data(o,'T'),0);
   oo.data.T = T;
end
function oo = LinearFactor(o,omega)    % Construct Non-Zero Linear Factor       
   if type(o,{'szpk','zzpk','qzpk'})
      oo = zpk(o,[-omega],[],1/omega);
   else
      oo = trf(o,[1/omega 1],[1]);
   end
   
   T = o.either(data(o,'T'),0);
   oo.data.T = T;
end