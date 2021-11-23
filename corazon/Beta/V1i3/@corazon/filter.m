%
% FILTER   Filter a data stream
%
%             yf = filter(o,y,t)
%
%          Options:
%             o = opt(o,'type','LowPass2')  % filter type
%             o = opt(o,'bandwidth',f)      % filter bandwidth [Hz]
%             o = opt(o,'zeta',0.6)         % filter damping
%             o = opt(o,'kind',1)           % kind of filtering
%
%          kind=0 means simple forwards filtering, kind=2 forces fore/back
%          filtering, and kind=3 performs highpass filtering with subse-
%          quent fore/back low pass filtering.
%
%          Filter Types:
%             'order2':   order 2 filter
%
%          Filter composition: return system matrices A,B,C,D in 
%          var(oo,'A'), var(oo,'B'), var(oo,'C') and var(oo,'D'),
%          and numerator/denominator in var(oo,'num'), var(oo,'den').
%
%             oo = filter(with(sho,'filter'))
%
%             oo = filter(o,'LowPass2')
%             oo = filter(o,'HighPass2')
%             oo = filter(o,'LowPass4')
%             oo = filter(o,'HighPass4')
%             oo = filter(o,'Integrator')
%
%          Note: the result can be easily converted to a transfer
%          function class object by calling oo = trf(oo).
%
%             Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, COOK, TRF
%
