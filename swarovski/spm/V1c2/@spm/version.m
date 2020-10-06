function vers = version(o,arg)         % SPM Class Version             
%
% VERSION   SPM class version / release notes
%
%       vs = version(spm);            % get SPM version string
%
%    See also: SPM
%
%--------------------------------------------------------------------------
%
% Features SPM/V1C
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
% Release Notes SPM/V1C
% =====================
%
% - created: 13-Sep-2020 18:52:03
% - move A,B,C,D from o.par.sys to o.data; introduce spm/prew method;
% - initial plot menu with eigenvalue plotting (Overview) 
% - full portation of spm @ plug3 to spm shell
% - force step response overview implemented
% - Plot>Transfer_Matrix menu item added
% - orbit plot added for step response andramp response
% - add 3-Mode Sample, Version A/B/C
% - add academic model #1
% - add academic model #2
% - add Select event registration in shell/Select menu
% - move all spmx/V1a stuff to new spm/V1c version
% - add View/Scale menu
% - move plot/Excitation stuff to Study menu
% - pimped spm/new with extra info for Academic #2 sample
% - menu File>Tools>Cache_Reset added
% - print transfer function and constrained trf to console
% - comparison of step responses: Gij(s) <-> Hij(s)
% - bug fixed: oo = var(oo,'G_1') instead of var(oo,'G1')
% - add number of plot points in simu menu
% - add Study>Motion menu
% - bug fix: motion Overview reacting on tmax setting
% - add Study/Motion/Profile menu item
% - bug fix: spm/shell - Select was not a dynamic menu
% - L(s) transfer matrix implemented
% - weight diagram added
% - step response overview for L(s) added
% - bode plot implemented for G(s)
% - bode plot implemented for H(s) and L(s)
% - bode overview for L(s)
% - adapt bode plots
% - motion response (enough for today)
% - change bode default settings
% - bode auto scaling
% - rloc plot added
% - open loop Bode plots implemented
% - bug fix: calculation of Tf1(s) in spm/brew
% - add spm/plot/NoiseRsp
% - SPM beta V1f1 @ corazon beta V1c1
% - starting SPM beta V1f2 @ corazon beta V1c2
% - make changes to use new corasim functionality
% - comprehensive Analyse menu with instable Schleifsaal model 
% - introduce trf/normalizing
% - bug fix: spm/brew - have to use scaled matrices
% - add Analyse>Stability/L1(s)_Calculation
% - cyan color for open loop transfer functions
% - rearrange select menu and rename "trfd" cache segment to "trf"
% - improve weight diagram and add weight overview for G(s)
% - make import of .spm files more flexible
% - import whole packages
% - bug fixed: refresh after normalizing
% - bug fixed: option passing for modal systems
% - frequency response error plot implemented
% - pimp SPM to make root locus work
% - nyquist diagram :-)))
% - stability diagram - gewaltige gschicht :-)))))
%
%
% Known bugs & wishlist
% =========================
% - none so far
%
%--------------------------------------------------------------------------
%
   path = upper(which('spm/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@SPM'));
   vers = path(idx-4:idx-2);
end
