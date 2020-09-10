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
% Release Notes ESPRESSO/V1C
% ==========================
%
% - created: 07-Apr-2016
% - espresso/import modified
% - espresso/plot modified
% - Analysis>Ensemble menu item added
% - espresso.v1f.bak1 @ 09-Apr-2016
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
