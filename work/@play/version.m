function vers = version(o,arg)       % PLAY Class Version
%
% VERSION   PLAY class version / release notes
%
%       vs = version(play);            % get PLAY version string
%
%    See also: PLAY
%
%--------------------------------------------------------------------------
%
% Features PLAY/V1A
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
% Release Notes PLAY/V1A
% =======================
%
% - created: 20-Aug-2020 08:07:54
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('play/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@PLAY'));
   vers = path(idx-4:idx-2);
end
