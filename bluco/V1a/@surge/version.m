function vers = version(o,arg)       % SURGE Class Version
%
% VERSION   SURGE class version / release notes
%
%       vs = version(surge);           % get SURGE version string
%
%    See also: SURGE
%
%--------------------------------------------------------------------------
%
% Release Notes SURGE/V1A
% =======================
%
% - created: 24-Jun-2020 15:03:51
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('surge/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@SURGE'));
   vers = path(idx-4:idx-2);
end
