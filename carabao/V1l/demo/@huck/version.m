function vers = version(obj,arg)       % HUCK Class Version           
%
% VERSION   HUCK class version / release notes
%
%       vs = version(huck);             % get HUCK version string
%
%    See also: HUCK
%
%--------------------------------------------------------------------------
%
% Release Notes HUCK/V1A
% =======================
%
% - created: 09-Sep-2017 19:09:31
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('huck/version'));
   idx = max(findstr(path,'@HUCK'));
   vers = path(idx-4:idx-2);
end   
