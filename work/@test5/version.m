function vers = version(o,arg)       % TEST5 Class Version
%
% VERSION   TEST5 class version / release notes
%
%       vs = version(test5);           % get TEST5 version string
%
%    See also: TEST5
%
%--------------------------------------------------------------------------
%
% Features TEST5/V1A
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
% Release Notes TEST5/V1A
% =======================
%
% - created: 24-Oct-2021 06:28:42
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('test5/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@TEST5'));
   vers = path(idx-4:idx-2);
end
