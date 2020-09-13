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
% - Toolbox to analyse and study SPM data based cutting process models
% - SPM data comprises a state space model of a cutting setup (apparatus +
%   kappl + crystal
%
%--------------------------------------------------------------------------
%
% Roadmap
% =======
% - make basic function running
% - comprehensive plotting of step and ramp responses
% - make some samples (new menu) for good toolbox test test
% - transfer matrix calculation
% - comparison of system matrix simulation and transfer function responses
%
%--------------------------------------------------------------------------
%
% Release Notes SPMX/V1A
% =======================
%
% - created: 13-Sep-2020 18:52:03
% - move A,B,C,D from o.par.sys to o.data; introduce spmx/prew method;
% - initial plot menu with eigenvalue plotting (Overview)  
%
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
