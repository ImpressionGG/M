function vers = version(obj,arg)       % CAPPUCCINO Class Version           
%
% VERSION   CAPPUCCINO class version / release notes
%
%       vs = version(cappuccino);      % get CAPPUCCINO version string
%
%    See also: CAPPUCCINO
%
%--------------------------------------------------------------------------
%
% Release Notes CAPPUCCINO/V1A
% =======================
%
% - created: 21-Aug-2016 08:47:04
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('cappuccino/version'));
   idx = max(findstr(path,'@CAPPUCCINO'));
   vers = path(idx-4:idx-2);
end   
