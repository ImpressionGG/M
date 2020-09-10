function vers = version(o,arg)       % TRADE Class Version
%
% VERSION   TRADE class version / release notes
%
%       vs = version(trade);           % get TRADE version string
%
%    See also: TRADE
%
%--------------------------------------------------------------------------
%
% Release Notes TRADE/V1A
% =======================
%
% - created: 21-Jul-2020 23:25:40
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('trade/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@TRADE'));
   vers = path(idx-4:idx-2);
end
