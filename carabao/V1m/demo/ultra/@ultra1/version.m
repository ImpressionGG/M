function vers = version(obj,arg)       % ULTRA1 Class Version           
%
% VERSION   ULTRA1 class version / release notes
%
%       vs = version(ultra1);          % get ULTRA1 version string
%
%    See also: ULTRA1
%
%--------------------------------------------------------------------------
%
% Release Notes ULTRA1/V1A
% =======================
%
% - created: 27-Jun-2017 20:18:16
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('ultra1/version'));
   idx = max(findstr(path,'@ULTRA1'));
   vers = path(idx-4:idx-2);
end   
