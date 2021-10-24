function vers = version(o,arg)       % TEST1 Class Version
%
% VERSION   TEST1 class version / release notes
%
%       vs = version(test1);           % get TEST1 version string
%
%    See also: TEST1
%
%--------------------------------------------------------------------------
%
% Features TEST1/V1A
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
% Release Notes TEST1/V1A
% =======================
%
% - created: 24-Oct-2021 07:49:02
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('test1/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@TEST1'));
   vers = path(idx-4:idx-2);
end
