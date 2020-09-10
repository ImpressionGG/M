function vers = version(obj,arg)       % MATCHA Class Version           
%
% VERSION   MATCHA class version / release notes
%
%       vs = version(matcha);          % get MATCHA version string
%
%    See also: MATCHA
%
%--------------------------------------------------------------------------
%
% Release Notes MATCHA/V1A
% =======================
%
% - created: 24-Aug-2016 18:18:41
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('matcha/version'));
   idx = max(findstr(path,'@MATCHA'));
   vers = path(idx-4:idx-2);
end   
