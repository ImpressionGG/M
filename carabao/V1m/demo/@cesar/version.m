function vers = version(obj,arg)       % CESAR Class Version           
%
% VERSION   CESAR class version / release notes
%
%       vs = version(cesar);           % get CESAR version string
%
%    See also: CESAR
%
%--------------------------------------------------------------------------
%
% Release Notes CESAR/V1A
% =======================
%
% - created: 12-Jan-2018 12:51:21
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('cesar/version'));
   idx = max(findstr(path,'@CESAR'));
   vers = path(idx-4:idx-2);
end   
