function ok = istrf(o)                 % Is Object a Transfer Function
%
% ISTRF   Check if object is a transfer function for which a description
%         can be displayed, step response and bode diagram can be plotted
%
%            ok = istrf(o)
%
%         See also: TRF
%
   ok =  isa(o,'trf') && ~container(o) && ~isempty(o.data);
end