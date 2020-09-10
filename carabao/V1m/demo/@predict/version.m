function vers = version(obj,arg)       % PREDICT Class Version           
%
% VERSION   PREDICT class version / release notes
%
%       vs = version(predict);         % get PREDICT version string
%
%    See also: PREDICT
%
%--------------------------------------------------------------------------
%
% Release Notes PREDICT/V1A
% =======================
%
% - created: 11-Aug-2017 12:32:09
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('predict/version'));
   idx = max(findstr(path,'@PREDICT'));
   vers = path(idx-4:idx-2);
end   
