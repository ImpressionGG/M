function vers = version(o,arg)       % MIND Class Version
%
% VERSION   MIND class version / release notes
%
%       vs = version(mind);            % get MIND version string
%
%    See also: MIND
%
%--------------------------------------------------------------------------
%
% Features MIND/V1A
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
% Release Notes MIND/V1A
% =======================
%
% - created: 02-Oct-2021 22:44:02
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('mind/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@MIND'));
   vers = path(idx-4:idx-2);
end
