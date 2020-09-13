function vers = version(o,arg)       % SPMX Class Version
%
% VERSION   SPMX class version / release notes
%
%       vs = version(spmx);            % get SPMX version string
%
%    See also: SPMX
%
%--------------------------------------------------------------------------
%
% Features SPMX/V1A
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
% Release Notes SPMX/V1A
% =======================
%
% - created: 13-Sep-2020 18:52:03
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('spmx/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@SPMX'));
   vers = path(idx-4:idx-2);
end
