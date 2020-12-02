function vers = version(o,arg)       % BLUCO Class Version
%
% VERSION   BLUCO class version / release notes
%
%       vs = version(bluco);           % get BLUCO version string
%
%    See also: BLUCO
%
%--------------------------------------------------------------------------
%
% Features BLUCO/V1A
% ==================
%
% - Toolbox to analyse and study ...
%
%--------------------------------------------------------------------------
%
% Roadmap
% =======
% - roadmap item 1
% - roadmap item 2
% - roadmap item ...
%
%--------------------------------------------------------------------------
%
% Release Notes BLUCO/V1A
% =======================
%
% - created: 01-Dec-2020 15:31:14
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('bluco/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@BLUCO'));
   vers = path(idx-4:idx-2);
end
