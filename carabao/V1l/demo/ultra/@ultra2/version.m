function vers = version(obj,arg)       % ULTRA2 Class Version           
%
% VERSION   ULTRA2 class version / release notes
%
%       vs = version(ultra2);          % get ULTRA2 version string
%
%    See also: ULTRA2
%
%--------------------------------------------------------------------------
%
% Release Notes ULTRA2/V1A
% =======================
%
% - created: 27-Jun-2017 21:31:09
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('ultra2/version'));
   idx = max(findstr(path,'@ULTRA2'));
   vers = path(idx-4:idx-2);
end   
