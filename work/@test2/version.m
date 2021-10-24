function vers = version(o,arg)       % TEST2 Class Version
%
% VERSION   TEST2 class version / release notes
%
%       vs = version(test2);           % get TEST2 version string
%
%    See also: TEST2
%
%--------------------------------------------------------------------------
%
% Features TEST2/V1A
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
% Release Notes TEST2/V1A
% =======================
%
% - created: 24-Oct-2021 05:58:42
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('test2/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@TEST2'));
   vers = path(idx-4:idx-2);
end
