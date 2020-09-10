function vers = version(obj,arg)       % BOOST Class Version           
%
% VERSION   BOOST class version / release notes
%
%       vs = version(boost);           % get BOOST version string
%
%    See also: BOOST
%
%--------------------------------------------------------------------------
%
% Release Notes BOOST/V1A
% =======================
%
% - created: 13-May-2018 05:42:50
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('boost/version'));
   idx = max(findstr(path,'@BOOST'));
   vers = path(idx-4:idx-2);
end   
