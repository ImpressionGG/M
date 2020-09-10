function vers = version(obj,arg)       % HAR Class Version           
%
% VERSION   HAR class version / release notes
%
%       vs = version(har);             % get HAR version string
%
%    See also: HAR
%
%--------------------------------------------------------------------------
%
% Release Notes HAR/V1A
% =======================
%
% - created: 18-Jul-2017 18:17:17
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('har/version'));
   idx = max(findstr(path,'@HAR'));
   vers = path(idx-4:idx-2);
end   
