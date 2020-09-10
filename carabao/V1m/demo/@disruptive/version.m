function vers = version(obj,arg)       % DISRUPTIVE Class Version           
%
% VERSION   DISRUPTIVE class version / release notes
%
%       vs = version(disruptive);      % get DISRUPTIVE version string
%
%    See also: DISRUPTIVE
%
%--------------------------------------------------------------------------
%
% Release Notes DISRUPTIVE/V1A
% =======================
%
% - created: 21-May-2018 13:18:44
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('disruptive/version'));
   idx = max(findstr(path,'@DISRUPTIVE'));
   vers = path(idx-4:idx-2);
end   
