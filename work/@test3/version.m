function vers = version(o,arg)       % TEST3 Class Version
%
% VERSION   TEST3 class version / release notes
%
%       vs = version(test3);           % get TEST3 version string
%
%    See also: TEST3
%
%--------------------------------------------------------------------------
%
% Features TEST3/V1A
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
% Release Notes TEST3/V1A
% =======================
%
% - created: 24-Oct-2021 06:01:25
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('test3/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@TEST3'));
   vers = path(idx-4:idx-2);
end
