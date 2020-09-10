function vc = vcenter(v)
%
% VCENTER  Center an object defined by a vector set
%
%             vc = vcenter(v)
%
%          Example
%              v = vchip(1,1)*20;
%              vc = vcenter(v);
%
%          See also: ROBO, VPLT, VCHIP, VSET
%
    [m,n] = size(v);
    
    vmax = max(v')';
    vmin = min(v')';
    
    vc = vmove(v,-(vmax-vmin)/2);
    
% eof    