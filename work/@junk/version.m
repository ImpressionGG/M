function vers = version(o,arg)       % JUNK Class Version
%
% VERSION   JUNK class version / release notes
%
%       vs = version(junk);            % get JUNK version string
%
%    See also: JUNK
%
%--------------------------------------------------------------------------
%
% Features JUNK/V1A
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
% Release Notes JUNK/V1A
% =======================
%
% - created: 24-Oct-2021 09:07:57
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('junk/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@JUNK'));
   vers = path(idx-4:idx-2);
end
