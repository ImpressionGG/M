function vers = version(obj,arg)       % BABASIM Class Version           
%
% VERSION   BABASIM class version / release notes
%
%       vs = version(babasim);         % get BABASIM version string
%
%    See also: BABASIM
%
%--------------------------------------------------------------------------
%
% Release Notes BABASIM/V1A
% =======================
%
% - created: 24-Aug-2016 12:51:30
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('babasim/version'));
   idx = max(findstr(path,'@BABASIM'));
   vers = path(idx-4:idx-2);
end   
