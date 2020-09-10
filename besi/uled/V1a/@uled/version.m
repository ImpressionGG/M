function vers = version(o,arg)       % ULED Class Version
%
% VERSION   ULED class version / release notes
%
%       vs = version(uled);            % get ULED version string
%
%    See also: ULED
%
%--------------------------------------------------------------------------
%
% Features ULED/V1A
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
% Release Notes ULED/V1A
% =======================
%
% - created: 30-Aug-2020 17:30:27
% - uled/cost method & new Mfc1BH concep implemented
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('uled/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@ULED'));
   vers = path(idx-4:idx-2);
end
