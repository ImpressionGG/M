function vers = version(o,arg)       % PLL Class Version
%
% VERSION   PLL class version / release notes
%
%       vs = version(pll);             % get PLL version string
%
%    See also: PLL
%
%--------------------------------------------------------------------------
%
% Release Notes PLL/V1A
% =======================
%
% - created: 19-May-2020 08:41:04
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('pll/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@PLL'));
   vers = path(idx-4:idx-2);
end
