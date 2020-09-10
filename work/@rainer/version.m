function vers = version(o,arg)       % RAINER Class Version
%
% VERSION   RAINER class version / release notes
%
%       vs = version(rainer);          % get RAINER version string
%
%    See also: RAINER
%
%--------------------------------------------------------------------------
%
% Features RAINER/V1A
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
% Release Notes RAINER/V1A
% =======================
%
% - created: 07-Sep-2020 22:03:16
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('rainer/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@RAINER'));
   vers = path(idx-4:idx-2);
end
