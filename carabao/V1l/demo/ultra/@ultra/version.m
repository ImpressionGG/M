function vers = version(obj,arg)       % ULTRA Class Version           
%
% VERSION   ULTRA class version / release notes
%
%       vs = version(ultra);           % get ULTRA version string
%
%    See also: ULTRA
%
%--------------------------------------------------------------------------
%
% Release Notes ULTRA/V1A
% =======================
%
% - created: 13-Apr-2017 17:47:45
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('ultra/version'));
   idx = max(findstr(path,'@ULTRA'));
   vers = path(idx-4:idx-2);
end   
