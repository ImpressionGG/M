function vers = version(obj,arg)       % ESPRESSO Class Version           
%
% VERSION   ESPRESSO class version / release notes
%
%       vs = version(espresso);        % get ESPRESSO version string
%
%    See also: ESPRESSO
%
%--------------------------------------------------------------------------
%
% Release Notes ESPRESSO/V1A
% =======================
%
% - created: 29-Dec-2015 12:50:07
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('espresso/version'));
   idx = max(findstr(path,'@ESPRESSO'));
   vers = path(idx-4:idx-2);
end   
