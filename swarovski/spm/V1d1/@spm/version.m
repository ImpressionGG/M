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
% - Predefined samples generation (new menu) for demonstrations and toolbox
%   function tests
% - Comprehensive plotting of step and ramp responses
% - Transfer matrix calculation of G(s), H(s) and principal function calcu-
%   lation of L0(s) = P(s)/Q(s) based on SPM state space representation
%   utilizing proper system normalization and optional system parameter 
%   variations (stiffness,damping)
% - Basic functions to inspect free system TFM G(s), constrained system 
%   TFM H(s), principal transfer functions L0(s) = P(S)/Q(s) and open loop
%   transfer function Lµ(s)
% - Basic diagrams: transfer function display (quotient of polynomials,
%   gain,poles,zeros, frequencies and dampings),  pole/zero diagram, 
%   step response diagram, bode diagram, nyquist diagram
% - Stability analysis tools like stability margin diagram, nyquist
%   analysis and root locus analysis
% - parameter variation studies: free defined process or design parameter,
%   intrinsic system parameters like stiffness and damping
% - loading and analysis of packages
% - cook method to access all important interna data
%
% Features SPM/V1D
% ================
%
% - Replace old style principal transfer functions by normalized (and in-
%   vertible) principal transfer functions.
% - introduce plot menu for critical closed loop transfer functions
%
%--------------------------------------------------------------------------
%
% Roadmap
% =======
% - pimp create package dialog to let user define variation & image
% - also modify edit properties
% - export package menu item
% - robust numerical algorithms fo systems with 100-1000 modes
% - verification of algorithms for system orders of 100-1000
% - comprehensive friction model (controllable with friction settings) 
% - state space representation of full blown closed loop dynamical system
% - comparison of system matrix simulation and transfer function responses
% - nonlinear transient analysis
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
% - activate display:"braces" option for correct display of exponents
% - spm toolbox V1c2 beta (@ corazon V1f2 beta)
% - good menu Plot>Transfer_Function implementation
%
% - started V1c3 beta
% - adopted omega scaling
% - super toobox status (reproduced 70-er Kugel stability)
% - bug fix: import package info
% - bug fix: spm/brew - remove plot About in spm/brew/ConstrainedDouble
% - add About plot for packages
% - implement plot/Image
% - add spm/stable method
% - add File>SetupParameter menu
% - first time stability margin chart over pivot angle :-)))
% - pimp brewing of data object and package object - brew menu item
% - stability margin chart
% - brew L0(s) to a stable transfer function
% - first time good stability margin chart
% - pimp speed of rloc diagram, access poles/zeros voa zpk()
% - pricipal TRF plot menu added
% - Release of SPM toolbox V1C
%
%
% Release Notes SPM/V1D
% =====================
%
% - start Beta SPM V1D1
% - add heading at the end of stability margin plot
% - extend spm/brew to calc P0/Q0
% - introduce normalizing for principal transfer functions
% - pimping pricipal transfer functions completed
% - Plot>Critical_Loop menu
% - Analyse>Checks>Eigenvalues menu
% - check availability of symbolic toolbox
% - add expression based FQR to principal TRFs
% - trial with vpa for precise calculation of P(s)/Q(s)
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
