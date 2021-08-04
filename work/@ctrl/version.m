function vers = version(o,arg)       % CTRL Class Version
%
% VERSION   CTRL class version / release notes
%
%       vs = version(ctrl);            % get CTRL version string
%
%    See also: CTRL
%
%--------------------------------------------------------------------------
%
% Features CTRL/V1A
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
% Release Notes CTRL/V1A
% =======================
%
% - created: 04-Aug-2021 12:10:04
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('ctrl/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@CTRL'));
   vers = path(idx-4:idx-2);
end
