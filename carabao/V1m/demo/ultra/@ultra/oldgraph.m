function oo = graph(o,varargin)   % Plot Graph of a Trace Object           
%
% GRAPH  Plot graph of a CARAMEL trace object (or derived). At the same
%        time put object into clipboard for pasting into object list.
%        GRAPH calls method PLOT.
%
%           graph(o,'Scatter')         % scatter analysis
%
%    See also: ULTRA, STUDY, PLOT
%
   [gamma,oo] = manage(o,varargin,@Scattering);
   oo = gamma(oo);
end

%==========================================================================
% Local Functions to be Dispatched
%==========================================================================

function oo = Scatter(o)                % Stream Plot                   
   co = cast(o,'caramel');
   oo = graph(o,'Overlay');
   subplot(1,2,2);
   plot(o,'Scatter');
end
