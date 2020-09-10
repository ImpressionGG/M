function vers = version(obj,arg)       % FACEUP Class Version           
%
% VERSION   FACEUP class version / release notes
%
%       vs = version(faceup);          % get FACEUP version string
%
%    See also: FACEUP
%
%--------------------------------------------------------------------------
%
% Release Notes FACEUP/V1A
% =======================
%
% - created: 26-Jul-2017 04:33:59
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('faceup/version'));
   idx = max(findstr(path,'@FACEUP'));
   vers = path(idx-4:idx-2);
end   
