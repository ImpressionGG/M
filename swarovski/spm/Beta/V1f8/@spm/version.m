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
% - trial to implement VPA for TRF add
% - proper defaults
%
% Features SPM/V1D
% ================
%
% - Replace old style principal transfer functions by normalized (and in-
%   vertible) principal transfer functions.
% - introduce plot menu for critical closed loop transfer functions
%
% Features SPM/V1E
% ================
%
% Features SPM/V1F
% ================
% - init organized setting is 'packages' by default
% - png/pdf method to create PDF files from current figure
% - deleting whole packages (package info and all data files belonging to a
%   package)
% - batch menu
% - plugin example for extension of batch menu
% - sensitivity analysis (damping,critical,weight)
% - accelerated calculation due to invalidation of specific cache segments
% - better information in diagram titles
% - damping variation on package level (via damping file) and object
%   specific via command shell; graphical damping overview for cross check 
% 
%--------------------------------------------------------------------------
%
% Roadmap
% =======
% + fix calculation bug (deviation between MiniSpm and SPM Toolbox)
% - implicite generation of non existing package info files
% + sensitivity calculation must work independent of settings
% + pareto controlled calculation of critical sensitivity
% - put sensitivity calculation into batch menu
% - what means red and magenta vertical line?
% + display actual variation and K-values in title in critical sensitivity
% + write sensitivity results into cache
% - pdf method: append to PDF during batch process
% + fix focus thief
% - diagram comparisons
% - version displays new features 
% - accelerate stability margin diagrams
% - cache invalidation by change of settings
% - cache dependency definition by a set of settings/options
% - sensitivity analysis for variation vectors
% - -----------------
% - pimp create package dialog to let user define variation & image
% - also modify edit properties
% - export package menu item
% - robust numerical algorithms fo systems with 100-1000 modes
% - verification of algorithms for system orders of 100-1000
% - comprehensive friction model (controllable with friction settings) 
% - state space representation of full blown closed loop dynamical system
% - comparison of system matrix simulation and transfer function responses
% - nonlinear transient analysis
% - -----------------
% - docu: change of default settings
% - docu: working with plugins
% - docu: pulling settings from one shell and pushing into another, i.e 
%         if an object has been stored two month ago, and I want to load
%         object and update shell with actual default settings
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
% - add Select/Basket/Pivot menu
% - introduce Plot/Transfer_Function/Bode_Plot menu item for shell object
% - introduce Plot/Transfer_Function/Magnitude_Plot menu item for shell 
%   object
% - hard refresh of cache in cook when accessing G 
% - hard refresh of cache in cook when accessing Lmu
% - default value for Gs-cancel epsilon: 1e-2
% - bug fixed: cook does not expand options using WITH
% - sensitive changes regarding oscale option in cook and bode methods
% - calculate critical frequency
% - draw critical frequency in several bode plots
% - new menu item: Plot>Principal_Transfer_Functions>L0(s)=G31(s)/G33(s)
% - first steps Analyse/Sensitivity
% - internal tracing to detect mismatches => numericaöl limits
% - first progress in sensitivity analysis
% - add method oscale
% - analyse: numeric quality check
% - weight sensitivity analysis implemented
% - heading added to weight sensitivity analysis
% - creating package info @ reading info file / provide parameter defaults
% - Plot>Critical_Loop -> new plot menu items
% - pimp phase diagrams
%
% Release Notes SPM/V1E
% =====================
%
% - start Beta SPM V1E1
% - cook matrices L0(s) state space representation
% - add process.contact option
% - add spm/eig method
% - multi contact stability analysis
% - trial to read D matrix
% - read swapped parameter into package info and upgrade spm objects
% - upgrade bug fixed
% - consult control toolbox for zpk conversion
% - bode plot for L0(s)
% - can switch between single contact and multi contact
% - can calculate ZPK without control system toolbox
% - internal selection parameters for stability margin calculation
% - move K0,f0,S0,T0 into loop segment
% - spm/stable method to work with options
% - add phi parameter for coordinate transformation
% - fine tune and test SPM toolbox - good status :-)))
% - check zero/pole quality of ss2zpk transformation in a study :-)
% - add spm/system method
% - add plot>Quality menu item
% - Gij ZPK-quality check implemented
% - Precision plot implemented
% - View>Miscellaneous menu added
% - pimp check algorithm
% - isolation of brew/CalcGij
% - reduced Sys0 calculation :-)
% - bug fix in spm/stable: sign of feedback
% - stability margin on multivariable state space system basis :-)))
% - make stability margin chart running again
% - rloc adaption to state space systems
% - stability coefficient plot
% - change term stability coefficient to stability range
% - trim info text
% - adopt stability analysis for negative mu
% - bug fix in stability overview
% - pimp stability margin chart
% - start with spm/rlocus method
% - pimp stability margin diagram and stability overview
% - bug fix in stability margin calculation for 180°
% - stability margin and stability range in one chart
% - simple calculation of stability margin
% - bode plot of spectrum implemented :-)
% - spm/contact method added
% - general definition of contact indices
% - extension of spm/contact to calc L0,K0,f0,K180,f180
% - setup analysis (basic diagrams)
% - caching for setup analysis
% - extended setup analysis
% - analyse: critical quantities
% - some fixes
% - stop mechanism added
% - color code for setup analysis diagrams
% - spm/critical method
% - release SPM V1E
% - in spm/critcal handle infinite K0
% - first time clean lambda(jw) calculation
%
%
% - start Release SPM V1E
% - pimp & bug fixes SPM V1E
% - pimping
% - add sample mode to setup analysis
%
% Release Notes SPM/V1F
% =====================
%
% - What's new
%   + clear cache @ omega or zeta varitation
%   + organization per packages is the default after start
%   + Edit>Copy and Edit>Cut act now on all objects of shell, if shell
%     object is selected, or on all objects of a package, if package 
%     object is selected
%   + Sensitivity Analysis
%   + View>Sensitivity menu for sensitivity analysis
%   + caching of sensitivity analysis data
%   + cache saved on File/Save As ... and re-loaded on File/Open
%   + setup study with reordering of forward cutting charts
%   + bug: stability margin calculation mistake
%   + bug: leaves gap after continuing sensitivity calculation
%   + incorporate package title into standard headings
%   + bug: sensitivity.S not cached after 1st run of Damping Sensitivity 
%   + bug: always same value of K0 for different damping settings
%   + add Setup Studies in Batch menu
%   + bug: Critical/Bode: bad phase for 180°
%   + bug: critical sensitivity: upper left diagram empty
%   + performance slow down during batch processing
%   + auto creation of package info file @ import package
%   + Modified Graphics (Andy's suggestion) for Stability Margin
%   + Comparison of Packages
%   + PNG file creation (No PDF) 
%   + show ID in package
%   + assertion in gamma algorithm replaced by warning
%   + verification of gamma algorithm
%   + critical sensitivity: spikes
%   + timing diagram: sometimes empty (change threshold)
%   + warning of warm cache refreshes
%   + footer with version and key parameters
%   + dynamic name for PNG directory (with version date of batch start)
%   + crashing setup study @LPC.2021040606.SPM model=v7 
%   + reorder setup configurations in setup study
%   + save .mat file with actual cache in PNG folder
%
% - Roadmap
%   - consolidation of algorithms (ommit anything which is not numerically
%     stable
%   + introduction of spm/system method to do: variation, normalization,
%     coordinate transformation
%   - introduce pivot coordinate transformation (theta)
%   + fast calculation of K0,f0,K180,f180 by spm/critical method
%   + introduction of 'critical' cache segment to cache L0,L0jw,G31jw,G33jw,
%     lambda(jw)as well as K0,f0,K180,f180
%   - pimp ANALYSE>STABILITY>NYQUIST AND Analyse>Stability>Overview  by
%     plotting 5x characteristic plots and displaying nyquist error
%   - add menu point Select>Coupling-Path for selection of coupling path
%   - calculate G(s) depending on selection of coupling path
%   - Additional Plot graphics for mode frequencies
%     
%
% - start beta SPM V1F1
% - organizing mode 'packages' by default
% - add Batch menu
% - add spm/batch method
% - add spm/pdf method
% - introduce methods spm/system, spm/principal and pimp spm/critical
% - introduction of spm/system method to do: variation, normalization,
%   coordinate transformation
% - introduction of 'critical' cache segment to cache L0,L0jw,G31jw,G33jw,
%   lambda(jw)as well as K0,f0,K180,f180
% - Schur transformation for FQR caöculation
% - fast calculation of K0,f0,K180,f180 by spm/critical method
% - setup study to access spm/critical instead of spm/stable
% - methods spm/psion and spm/lambda :-)))
% - fast algorithm to calculate K0,f0,K180,f180
% - two algorithms for critical quantities: eig & fqr
% - spm/lambda can create CORASIM systems
% - spm/critical: eigenvalue algorithm with no checks by default
% - pimp display of eigenvalue error
% - spm/critical to call lambda with PsiW31,PsiW33
% - nyquist plot in critical overview :-)))
% - brewing of lambda0,lambda180
% - recovery of part of Analyse>Stability menu :-)
% - add frequency plots to stability range
% - some trials with better condition numbers - set T0=1s by default
% - clear screen at begin of package import
% - Analyse>Principal>Genesis
% - bug fix in setup analysis: labeling
% - new 3-color stability margin diagrams with logarithmic chart
% - new 3-color setup analysis charts
% - spm/contact to accept binary coded contact IDs
% - pimp stability margin chart
%
% - start beta SPM V1F2
% + clear cache @omega or zeta varitation
% - first version of weight sensitivity for multi contact systems
% + Edit>Copy/Cut to copy/cut whole packages or all shell objects
% + View>Sensitivity menu for sensitivity analysis
% + caching of sensitivity analysis data
% + weight sensitivity and damping sensitivity analysis
% - bug fix: spectral settings to be used for spectral segment brewing
% - use critical FQR l0(jw) and l180(jw) in Critical Overview
% - pimp sensitivity graphics (only pareto modes, titles)
% - Sensitivity setting split into view settings and select settings
% - in spm/system call brewing stuff for system calculation
% - adopt stability margin plot (linear y-axis instead of dB)
% - implement spm/damping() method & provide basic SPM docu (help spm)
% - implement spm/png function
% - batch menu item for stability margin of all packages
% - reading of damping table during import
% - two step damping variation to be enabled/disabled by menu settings
% - damping syntax changed for side effect to the shell
% - tag SPM-V1F2 Beta Version SPM @ Corazon V1I2
%
% - start beta SPM V1F3
% - bug fix: deactivate menu Analyse>Stability_Margin for shell object
%   selection
% + fix bug: focus thief
% - display stop request by user in title
% - react to stop request on deeper levels of spm/critical
% - default for sensitivity.variation chosen to be 2
% - cleanup Analyse menu: no more Stability Margin
% - cached sensitivity
% - Critical Sensitivity utilizing now cache and working pareto driven
% - batch menu items for all damping sensitivity and critical sensitivity
% - tag SPM-V1F3 Beta Version SPM @ Corazon V1I3
%
% - start beta SPM V1F4
% - incorporate package title into standard headings
% - move Weight/Damping Sensitivity struff to spm/sensitivity method
% - pimp Critical Sensitivity diagram
% + bug fix: sensitivity.S not cached after 1st run of Damping Sensitivity 
% - bug fix: Critical Sensitivity diuagram, axis labeling
% - display damping variation in diagram title
% - damping calculation by spm/damping() method also incorporating global
%   damping variation (also valid for damping plot)
% - bug fix in analyse/Critical: missed to set search option properly,
%   i.e. missing o=with(o,'critical') statement
% - change critical.search default setting from 50 to 200 search points
%   to fix calculation error (Andy's mismatch between SPM toolbox and
%   minispm toolbox
% - adding a confirmation dialog in corazon/stop
% - refreshing damping variation subplot before calculation of critical 
%   damping sensitivity
% - bugfix: vertical lines in Critical Gain graphics
% - Critical Loci & Nyquist for Forward/Backward Cutting
% - pimp Analyse/Critical menu items (forward/backward/both cutting)
% - caching implemented for critical Bode & Damping
% - Nichols plot added
% - bug fix in heading
% - new menu item Analyse/Principal/Overview
% - extended Analyse/Principal menu
% - add Analyse/Principal/Nichols menu item
% + cache saved on File/Save As ... and re-loaded on File/Open
% - speed-up stability margin graphics   
% + batch processing basics implemented
% - tag SPM-V1F4 Beta Version SPM @ Corazon V1I4
%
% - start beta SPM V1F5 @ beta CORAZON V0i5
% - bug fix: focus thief in corazon/cls
% - tag SPM-V1F5 Beta Version SPM @ Corazon V1I5
%
% - start beta SPM V1F6 @ beta CORAZON V0i6
% - spm/critical method pimped to deal with k0=inf or K190=inf
% - spm/new extended to support 'Challenge' systems
% - bugfix in critical/Stable: upper K search bound at least 100
% - bugfix in spm/contact: return B,C,B1,B2,C1,C2 as variables
% - cook to retrieve actual contact indices and siso status
% - can select in bode diagram between f and omega
% - fixing Plot menu
% - cache based acceleration of Analyse/Principal & Analyse/Critical plots
% - spm/new: random systems added
% - two bugfixes in spm/psion
% - study/PsionCheck added
% - verification that both psion methods are working well
% - spm/new: changed parameters of 2-Mode system
% - spm/getphi: comments fixed
% - profiling added for spm/lambda
% - spm/critical: begin lambda algorithm
% - spm/lambda: lambda algorith for critical quantities completed
% - critical sensitivity with pareto processing
% - pimp damping sensitivity diagrams
% - spm/spectrum implemented
% - use glabally psiW31 and psiW33 instead of PsiW31 and PsiW33
% - toolbar plugin trial
% - damping sensitivity & critical sensitivity working fpr gamma algo
% - bug fix in lambda/Lambda: empty default instead 0 for progress option
% - pimp batch menu and batch functionality
% - add pareto to batch config
% - bugfix: batch/RunSpm - missing option inheritance
% - bugfix: spm/batch - dark mode control
% - EVerr check implemented for critical/CalcGamma
% - bugfix: brew/Critical and verification of stability margin diagram
% - weak critical check by default, no checks during batch processing
% - pareto value displayed in critical sensitivity (timimg diagram)
% - tag SPM-V1F6 Beta Version SPM @ Corazon V1I6

% - start beta SPM V1F7 @ beta CORAZON V0i7
% - batch prqocessing for whole package took 5750s (1.6s), no slow down :-)
% - dynamic name for PNG directory
% - bug fix: assertion message in spm/gamma
% - bug fix: cold cache refresh in analyse/Critical
% - about screen for package objects pimped
% - implement closeup for spm/bode
% - bugfix: small discontinuities in spectrum at critical frequency
% - bugfix: incorrect dominant magnitude
% - bugfix: critical sensitivity - introduce Cook()
% - adopt warning condition in spm/gamma (error check)
% - spmhack plugin added
% - use new corazon/cache syntax of clearing all caches
% - pimp spm/gamma  by adding critical flag to variables
% - spm/bode completed
% - all bode, phase, magnitue plots working for principal & critical
% - Critical Bode & Damping using spm/bode
% - all Bode diagrams of Analyse menu on state of the art
% - spm/nichols implemented, and all Nichols charts based on spm/nichols
% - bugfix in spm/gamma/Search: spikes @ critical sensitivity diagram :-)))
% - switching from corazon V0i7 to V1i7
% - bug: Nichols plot of reverse 2-Mode system not correct
% - tag SPM-V1F7 Beta Version SPM @ Corazon V1I7

% - start beta SPM V1F8 @ beta CORAZON V0i8
% - fix oo-bug in spm/batch
% - bugfix: Nyquist plots
% - add limit circles to Nyquist plot
% - bugfix: corruption during save no more occured again
% - bugfix: genesis plots no more working
% - adaptions in spm/sensitivity to deal with psiw-representation
% - quite a stable version
% - reorder setup indices
% - linear scale for stability margin in setup study
% - pimp setup study diagrams for SPM and PKG
% - intermediate save added to setup study batch processing
% - headline fixed for package setup study
% - add intermediate saving
% - setup symmetry study reordered
% - pimped setup symmetry study
% - advance from vorazon/V0i8 to V1i8
% - new methods spm/collect and spm/pkginfo
% + auto creation of package info file @ import package
% + comparison of packages (critical friction)
% - tag SPM-V1F8 Beta Version SPM @ Corazon V1I8


% Known bugs & wishlist
% =====================
% - bug: crash during setup study
%
%--------------------------------------------------------------------------
%
   path = upper(which('spm/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@SPM'));
   vers = path(idx-4:idx-2);
end
