function vers = version(o,arg)       % TEST4 Class Version
%
% VERSION   TEST4 class version / release notes
%
%       vs = version(test4);           % get TEST4 version string
%
%    See also: TEST4
%
%--------------------------------------------------------------------------
%
% Features TEST4/V1A
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
% Release Notes TEST4/V1A
% =======================
%
% - created: 24-Oct-2021 06:22:49
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('test4/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@TEST4'));
   vers = path(idx-4:idx-2);
end
