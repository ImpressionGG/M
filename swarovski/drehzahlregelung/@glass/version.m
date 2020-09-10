function vers = version(obj,arg)       % GLASS Class Version           
%
% VERSION   GLASS class version / release notes
%
%       vs = version(glass);           % get GLASS version string
%
%    See also: GLASS
%
%--------------------------------------------------------------------------
%
% Release Notes GLASS/V1A
% =======================
%
% - created: 10-Feb-2020 23:02:00
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('glass/version'));
   idx = max(findstr(path,'@GLASS'));
   vers = path(idx-4:idx-2);
end   
