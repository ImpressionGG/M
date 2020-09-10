function vers = version(obj,arg)       % CONTROL Class Version           
%
% VERSION   CONTROL class version / release notes
%
%       vs = version(control);         % get CONTROL version string
%
%    See also: CONTROL
%
%--------------------------------------------------------------------------
%
% Release Notes CONTROL/V1A
% =======================
%
% - created: 29-Jun-2017 20:07:41
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('control/version'));
   idx = max(findstr(path,'@CONTROL'));
   vers = path(idx-4:idx-2);
end   
