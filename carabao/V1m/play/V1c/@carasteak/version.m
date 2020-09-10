function vers = version(obj,arg)       % CARASTEAK Class Version           
%
% VERSION   CARASTEAK class version / release notes
%
%       vs = version(carasteak);       % get CARASTEAK version string
%
%    See also: CARASTEAK
%
%--------------------------------------------------------------------------
%
% Release Notes CARASTEAK/V1A
% =======================
%
% - created: 09-Apr-2016 19:16:04
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('carasteak/version'));
   idx = max(findstr(path,'@CARASTEAK'));
   vers = path(idx-4:idx-2);
end   
