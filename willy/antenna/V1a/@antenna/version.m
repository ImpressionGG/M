function vers = version(o,arg)       % ANTENNA Class Version
%
% VERSION   ANTENNA class version / release notes
%
%       vs = version(antenna);         % get ANTENNA version string
%
%    See also: ANTENNA
%
%--------------------------------------------------------------------------
%
% Release Notes ANTENNA/V1A
% =======================
%
% - created: 27-Jul-2020 00:08:34
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('antenna/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@ANTENNA'));
   vers = path(idx-4:idx-2);
end
