function vers = version(o,arg)       % ECOS Class Version
%
% VERSION   ECOS class version / release notes
%
%       vs = version(ecos);            % get ECOS version string
%
%    See also: ECOS
%
%--------------------------------------------------------------------------
%
% Features ECOS/V1A
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
% Release Notes ECOS/V1A
% =======================
%
% - created: 22-Dec-2020 11:34:10
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('ecos/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@ECOS'));
   vers = path(idx-4:idx-2);
end
