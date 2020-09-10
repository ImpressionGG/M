function vers = version(obj,arg)       % GACO Class Version           
%
% VERSION   GACO class version / release notes
%
%       vs = version(gaco);            % get GACO version string
%
%    See also: GACO
%
%--------------------------------------------------------------------------
%
% Release Notes GACO/V1A
% =======================
%
% - created: 29-Jun-2017 20:39:28
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('gaco/version'));
   idx = max(findstr(path,'@GACO'));
   vers = path(idx-4:idx-2);
end   
