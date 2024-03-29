function oo = version(o,varargin)                                      
%
% VERSION   CORAZON toolbox version / release notes
%
%    Print CORAZON release notes / bug list or get CORAZON version
%
%       vs = version(corazon);         % get CORAZON version string
%       version(corazon);              % type release notes / known bugs
%
%    See also: CORAZON
%    Copyright (c): Bluenetics 2020 
%
   if (nargout == 0)
      Version(o,nargin)
   else
      oo = Version(o,nargin);
   end
end

%==========================================================================
% Version Work Horse
%==========================================================================

function oo = Version(o,nin)           % Actual Version Work Horse     
   path = upper(which('corazon/version'));
   path = upath(o,path);
   idx = findstr(path,'/@CORAZON/VERSION.M');
   path = path(1:max(idx)-1);
   
   jdx = findstr(path,'/');
   vers = path(max(jdx)+1:max(idx)-1);
   
   if (nargout == 0 || nin > 1)
      clc
      %help corazon/version
      type corazon/version
      line = '----------------------------------------';
      fprintf('%s%s\n',line,line);
      fprintf('CORAZON Toolbox - Version: %s\n',vers);
      fprintf('%s%s\n',line,line);
   else
      oo = vers;
   end
end   

%==========================================================================
% Corazon Power Features
%==========================================================================

function CorazonPowerFeatures                                          
%
% - universal data model with type, tag, parameters, data and working
%   variables. easy casting of an object from one class to another class
%
% - graphical roll down menu based shell for the management of a list of
%   data objects
%
% - automatic graphics refresh on change of menu settings
%
% - data objects can be organized as a plain list or as a hierarchical list
%   grouped by so called packages
%
% - basic plot functions to deal with symbolic colors, line width, line
%   types, stem plots, options for labeling and scaling (options can be
%   assigned with default settings, to be setup in the menu)
%
% - cook method: to summarize data access raw data, calculated and cached
%   data
%
% - cache functionality with user defined cache segments
%
% - data brewer, fully integrated into cache mechanism
%
% - easy menu build-up with user definable menu building blocks
%
% - event method to control selective menu refresh
%
% - plugin generation 
%
% - rapid toolbox or plugin generation
%
% - organisation in shell object, package objects and data objects,
%   menu functions act differently on different package types
%
end

%==========================================================================
% Known Bugs & ToDo's
%==========================================================================

function KnownBugsAndRoadmap           % Just a Dummy Function         
%
% Known Bugs
% ==========
%
% - no known bugs so far :-)
%
% Roadmap
% =======
%
% - default support for import/export of CSV files
% - easier dynamic menu management:
% -    a) move 'dynamic(o)' from shell to method!
% -    b) make shell/Dynamic an obsolete function (no update required)
% - version core for better support of version method of rapid toolboxes
%
end

%==========================================================================
% Release Notes
%==========================================================================

function VersionV1A                                                    
%--------------------------------------------------------------------------
%
% Release Notes Corazon/V1A
% =========================
%
% - Nice functionality, including rapid prototyping shell - bug: cannot
%   paste filt object into shell - bug: style menu of weird/cube/ball objs
%   to be located under Select
% - bug fixed: cannot paste filt object into shell
% - bug fixed: style menu of weir/cube/ball objects to be located under 
%   Select
%
end

function VersionV1B                                                    
%--------------------------------------------------------------------------
%
% Release Notes Corazon/V1B
% =========================
%
% - bug fixed in corazon/rapid: wrong arg list passing in generated
%   study/Callback 
% - made corazito/call method tolerant against empty refresh callback
%
end

function VersionV1C                                                    
%--------------------------------------------------------------------------
%
% Release Notes Corazon/V1C
% =========================
%
% - bug fixed in corazon/rapid: in plot/Callback assignment oo = o must
%   be executed before checking empty list. Otherwise method crashes e.g.
%   if all objects are cleared and refresh calls plot.
%
end

function VersionV1D                                                    
%
% Release Notes Corazon/V1D
% =========================
%
% - Introduction of comma separated tags to CORAZITA method prop() and
%   CORAZON methods get(), set(), data(), var() and opt() provides syn-
%   tactic sugar for multiple set/get.
%
% - CORASIM class added to support discretisation of continuous time
%   state space models and to simulate and plot both continuous time and
%   discretized state space models. CORASIM provides a shell to study
%   step and ramp responses.
%
% - Improved corazita/manage method to be tolerant against non-character
%   and non function_handle arguments
%
% - new corazon/paste syntax for single object pasting with implicite
%   inheritance of launch function (syntactic sugar)
%
% - extend corazon/shell with many hidden pre-defined dynamic menus which
%   can be activated with plugin functionality. Such plugin functionality 
%   is demonstrated by corazon/sample plugin
%
% - modify corazon/plot to understand scalar subplot indicator and to 
%   handle hold option
%
% - introduction of corazon/enable method for easy enable/disable of menu
%   items depending on a general condition or depending on a basket's type
%   list
%
% - corazon/basket extended with additional syntax for typelist check, to
%   be designed in compatibility with corazon/enable syntax
%
% - cleanup and better internal program structure for corazon/plot method,
%   using a local Plot() function to deal with single (non container) ob-
%   jects, and using a standardized local Basket() function to deal with
%   basket lists. This new structure allows the simplified approach that 
%   plot core functions can be written to deal with simple (non container)
%   objects, while the Basket function deals with the looping through the
%   basket list.
%
% - introduction of figure size menu and figure fixing. Bug fix of figure
%   fixing, while obsoleting window fix menu item in Info/Debug menu
%
% - Improve corazon/menu/End to support a menu/End plug point which can be
%   used for general plugins. The menu/End plug point adopts dynamically to
%   the shell objet class.
%
% - Add corazon/simple plugin for simple plugin demonstration. This plugin
%   triggers only on the menu/End and curret/Select plug points. Tested
%   with corazon/shell, corasim/shell and spm/shell.
%
% - Add heading method to provide a header for plots
%  
% - Improve corazon/rapid method to generate method structures according to
%   the latest programming style. Also add rapid plugin creation feature.
%
% - Pimp corazon/choice method to support mixed cell array pairs and
%   numeric arrays in arg list
%
% - Proide  cache functionality with corazon/cache method and corazon/brew
%   template method
%
% - CORINTHian arithmetics added (exact rational arithmetics based on 
%   variable length integer representation)
%
% - provide method corazon/select to retrieve package structured object
%   tree, select object tree branches and objects in given branches
%
% Change Log V1d1:
%
% - extension of corazita/set to support comma separated tags
% - extension of corazita/get to support comma separated tags
% - extension of corazita/prop to support comma separated tags
% - extension of corazita/var to support comma separated tags
% - extension of corazon/data to support comma separated tags
% - corazita/manage method be tolerant for non empty arg list which
%   does not have char string or function handle as first arg
% - corasim class added for simulation objects
% - new paste syntax to inherit launch function
% - plugin functionality
% - adopt corazon/rapid to provide plug points
% - add more powerful corazon/opt with comma separated tags
% - corazon/plot modified to understand scalar subplot indicator
% - corazon/plot to support hold option
% - corazon/basket to support typelist check
% - standard structure for plot/Basket
% - transform corazon/plot (better style and structure)
% - introduce figure size menu and figure fixing
% - add enable() method to enable/disable menu items
% - add Analyse menu to sample plugin 
% - add general plugins to corazon/sample
% - add corazon/simple plugin for simple plugin demonstration
% - add mitem(o,'') functionality to clear separator activation flag
% - add additional plug point in corazon/current to trigger simple plugin
%   menu rebuild after selection of object
% - bug fixed: creation of SMP object does not refresh Plot menu (menu/End
%   is not rebuilt after reselection of objects! solution: additional 
%   plug point in current/Select
% - make corazon/simple plugin complete
% - had to modify corasim/Plot function to support input plotting
% - adopt corazon/sample plugin to trigger also on current/Select plug
%   point
% - add simulation parameter menu in simple plugin
% - bug fix: Multi color corazito/plot did not support bullets 
% - add heading method
% - add corazon/dark method (dark mode) 
%
% Change Log V1d2:
%
% - add corazon/split to extract package
% - display package in figure headings
% - corazon/rapid updated to use analyse.m instead of analysis.m
% - initial window size 2/3 of screen and centered
% - add rapid plugin creation (corazon/rapid)
% - add corazon/dark method (dark mode) 
% - extend corazon/heading to support dark mode
% - add auto substitution of underscores in corazon/uscore
% - pimp corazon/choice method to support mixed cell array pairs and
%   numeric arrays in arg list
% - restructure rapid to support View menu
% - unify basic structure for plot methods
% - adopt corazon/cls for dark mode
% - add dynamic View menu to corazon/shell
% - clip object in rapid generated plugin study
% - corinth class added with basic mantissa operations (add/sub/mul/div)
% - add feature and roadmap section in rapid version.m generation
% - corazon/shell: move View menu items to corazon/menu
% - corazon/rapid: move View menu item generation to corazon/menu
% - bug fix in corazon/inherit (inherit of color and launch)
% - fix flickering bug in corazon/plot and corazita/plot in dark mode
% - bug fix in corazon/cls in context with canvas color and dark mode
% - adoption of corazon/plot to support dark mode
% - add dark mode default in corazon/shell and rapid->shell
% - ommit setting 'method' parameter field in corazon/read
% - bug fix in corazon/rapid: bad study template
% - add corazon/wrap function
% - bug fix (dark mode) in corazon/heading
% - pimp corinth constructot from real
% - construction of corinthian polynomials
% - bug fix in corinth/form
% - corinthian polynomial addition and subtraction
% - [num,den,xpo]=peek(o) and o=poke(o,num,den,xpo)
% - improve corinth constructor to deal with lists
% - test added for polynomial add/sub/mul
% - add corinth/order method
% - add polynomial division method
% - add trf printing in corinth/display
% - rename type 'ratio' to 'number' (in all files)
% - corinth/number method for number construction (tested)
% - corinth/size method added
% - corinth: rational functions and rational matrix
% - bug fixed in corinth constructor
% - rational matrix generation from real matrix
% - corinth: casting, corinth/iszero and corinth/iseye fully implemented
% - corinth: add/sub/mul numbers, polynomials, ratios & matrices (test
%   pending)
% - add method corasim/trf and add casting to corasim/system
% - add corasim/step method
% - bug fixed in corazon/plot: dark mode, invert black and white
% - bug fixed in corazon/filter (advanced method same as back/fore)
% - method corazon/select added
% - methods corazon/brew and corazon/cache added
% - extend corazon stuff by type 'txy' objects, provide corazon/new/Txy
%   extension and adopt corazon/plot method for 'txy' stuff
% - update help text in corazita/shelf
% - adopt closeup to ignore axis with shelf settings 'closeup=0'
% - add closeup sliders to corazon/shell Overview diagram
% - bug fix in corazon plot: catch crashes when changing object selection
% - corazon/rapid: rename launch functions to WithCuo,WithSho,WithBsk
% - corazon/plot to provide a prolog for easy corazon/plot standard use
% - improvement of corazon/plot and corazon/rapid
% - bug fixed in mhead: set userdata
% - bug fixed in corazon/split: run number to be sprintf'ed as '%d'
% - corazon/type: add syntactic sugar for type check (with type list)
% - bug fixed in coracon/menu/Activate: set figure title
% - pimp corazon/menu/Objects to support package organization
% - pimp corazon/read/ReadPkgPkg: store file & dir in parameters
% - pimp progress display in figure bar during import
% - pimp corazon/read/Open to set file & dir as parameters
% - add corazon/idle and pimp shell launch in dark mode
% - add corazon/subplot method
% - pimp corazon/manage to support plot(o,'') syntax
% - pimp corazon/cls to support hold mode
% - Release V1d
%
% Known Bugs / Wishlist
% - corazon/shell and corazon/rapid generated shells do not refresh
%   correctly
end

function VersionV1E                                                    
%
% Release Notes Corazon/V1E
% =========================
%
% - New method corazon/progress to display progress in figure head line.
%   Extension of corazon/import to display progress bar
%
% - Extension of corazon/import to alert on missing package or duplicate 
%   package import or data object import
%
% - improvement of corazon/add method to sort object children of shell 
%   object in order to group package objects and related data objects
%
% - extension of corazon/closeup to provide user callbacks
%
% Change Log V1e:
%
% - add corazon/progress method to display progess message in menu bar
% - pimp corazon/import to display progress message in menu bar
% - bug fix: paste - bring objects into right order with packages => add
% - bug fix in corazon/charm: could not initialize value with empty string
% - extend corazon/progress by supporting progress option
% - corazonv1e3 beta
% - bug fixed in corazon/read/Sort: not all non-assigned packages added
% - rewrite corazon/add to use sorting of object IDs if provided
% - change corazon/import: no more Duplicate option in dialog
% - corazon/message: add pitch option
%
% Known Bugs / Wishlist
% - corazon/shell and corazon/rapid generated shells do not refresh
%   correctly
end

function VersionV1F                                                    
%
% Release Notes Corazon/V1F
% =========================
%
% - Excessive extension of CORASIM class to support transfer function
%   representation and arithmetics, conversions from state space to trans-
%   fer function and vice versa, step response plot, bode diagrams and root
%   locus plot
%
% - extension of corazon/display method with second argument to display
%   other class objects (e.g used for corinth objects, which have usually
%   their own display method but shell objects are displayed in the usual
%   corazon format
%
% - extension of corazon/mitem to support easy change of menu item attri-
%   butes
%
% Change Log V1f:
%
% - pretty polynomial display
% - implement corinth/gcd for polynomials as well as corinth/ran for ratios
% - new Git repository 'M'
% - another trial ...
% - rewrite display method for polynomials
% - rewrite display method for rational functions
% - bug hunt: polynomial with real coefficients
% - corinth/touch introduced
% - bug fixed: polynomial GCD :-))) - corinth.bak1
% - first time all corinthian tests passed :-))) - corinth.bak2
% - corinth/chr: characteristic equation 
% - pimp corinth/display for pretty matrix display
% - corinth/phi (transition matrix) - with tests :-)))))
% - basic profiling added :-)))
% - change corazon/menu: the way About is called
% - pimp corazon/display to display other class objects
% - pimp corazon/profiler to be a bit faster and by default off
% - add some verbose control for corinth objects
% - terrible, dirty bug fixed in corinth/div/Divide (guess too low!) :-)))
% - 1 million mantissa tests passed :-)))))
% - bug fixed: corazon/display - 2nd arg only accepted for display if obj
% - bug fixed: corinth/div: args were not trimmed
% - add peek/poke functionality for matrix
% - bug fixed in can/Matrix and trim/Matrix
% - add normalizing within cancelation of rational functions
% - provide mandatory opt field during corinth construction
% - double based transfer matrix calculation of an order 48 SPM object
% - quick arithmetics: 1 million test passed :-)))
% - super speed-up of gcd with quick arithmetics
% - replace o = mitem(o) syntax by o = mitem(o,gcf) syntax
% - set separator=[] during o=mitem(o,hdl) in corazita/corazon */mitem
% - pimp corazon/mitem to support attribute changes of menu items
% - updating Corazon V1F release notes
% - plug3 to deactivate cleanly unused menu items and add useful
% - fine tune corazon/rapid to generate plot method with ~type(o,{}) syntax
% - pimp corazon/heading to call dark(o,'Axes') at the end
% - add xscale & yscale option to corazito/plot
% - implement corinthian trf type (construct,add,can,trim)
% - implement plus, minus, mtimes, mul, div, inv for corynthian trf
% - corinthian methods num & den added
% - bug fix: corazon/cast -> duplicate to corinth/cast
% - corinth/mrdivide and corinth/mldivide correct implementation 
% - bug fix in corinth/cast: older version replaced by newest Cast fct
% - subplot pimped for 4 arguments
% - pimp sho to inherit shell options with one input arg
% - add corasim/modal and corasim/peek methods
% - bug fix: corasim/modal (was a hard job) :-)))
% - bug fix: corazon/menu/Select no more container check (critical !!!)
% - add corasim/reduce method
% - bug fix: set tmax max(tmax,10*Ts) for discrete time step response
% - corasim: reworked data representation
% - bug fix: corazon shell - dynamic Select menu
% - pimp corasim: stepo response plots, max time rounding, menus
% - corazon plot/Menu: plot/About added, also in corasim plot/Menu
% - plot overview for corasim/motion objects
% - bug fix: labeling in motion/Overview
% - corasim/profile implemented
% - bug fix: corasim/menu/Objects separator conditionally if children
% - critical bug fix: dynamic/ShowMenus - shell object instead of data obj
% - minor bug fix: corinth/display - formatting
% - corazon/menu/ClearCb: => show About instead of refresh
% - corasim/bode implemented
% - bode options adopted
% - method corasim/ismodal added
% - work around for corasim/peek/Ss2zp
% - bug fix: corasim/bode/Auto - deal with zero trf
% - corasim/rloc and corinth/rloc implemented
% - bug fixed: corasim/sim - discretize also for strf type
% - corazon beta V1f1
%
% - starting corazon beta V1f2
% - add corasim/can, corasim/poke, corasim/matrix, corasim/inv, 
%   corasim/times
% - add corasim/plus, corasim/minus, corasim/mrdivide
% - add clear screen to corasim/menu/View
% - pimp corasim/bode to inherit shell options
% - pimp corasim/step to inherit shell options
% - add trimming to corasim/num and corasim/den
% - SPM toolbox pimped
% - idle(o) at end of subplot(o) to let graphics refresh
% - bug fix: corasim/display - eliminate Display,Trf
% - pimp corazon/display to display figure number
% - bug fix: inherit figure handle to children in corazon/menu/begin
% - pimp corasim/display to display Ratio details by default
% - bug fix: corasim/fqr to retrn also omega as output arg2
% - rloc pimped to have colored branch parts
% - add modal transformation to corasim/modal method
% - new corasim type "modal" introduced
% - corasim/fqr and corasim/bode for large modal systems :-))))) 
% - corazon/snif added
% - add object id stored in o.work.id
% - add corasim/new root locus demo objects
% - pimp corasim/step and corasim/plot/Step
%
% - starting corazon beta V1f3
% - trim at the end of corasim/can
% - corasim/gain, corasim/lf and corasim/qf added
% - corasim/display pimped to show also gain
% - bug fix: corazito/plot - tolerant against mix of column & row vectors
% - remove dialog box in corazon/read/Progress
% - add method corazon/tree, while obsoleting corazon/select
% - bug fix @ corazon/arg: could not handle o = arg(o,[])
% - corasim types 'szpk','zzpk' and 'qzpk' added
% - pimp corasim/mul and corasim/inv to deal with new types
% - corasim/can extended to deal with new types
% - corasim zpk types implemented with basic arithmetic
% - some adaptions in arithmetic basic routines regarding ZPK objects
% - corasim/lf pimped to allow zpk typed linear factors
% - corasim/fqr: add expression based FQR
% - method corasim/psion added, omega-scale corasim/fqr, corasim/bode
% - fix some verbose copy isues in corasim arithmetics
% - introduce psiw type transfer function representations fpr corasim objs
% - display & bode for psiw type TRFs
% - corasim/orange implemented
% - bad bug fix: calculation of FQR in psion was wrong!
%
%
% Known Bugs / Wishlist
% - none so far
end

function VersionV1G                                                    
%
% Release Notes Corazon/V1G
% =========================
%
% - Support of MATLAB symbolic toolbox
% - bug fixed: hard refresh of cache (also if current obj is shell obj)
%
%
% Change Log V1g1:
%
% - starting corazon beta V1g1
% - corasim/mrdivide to preserve type if one operand is a double
% - corasim/gain adapted for zpk representations
% - corasim/fqr adaption for zpk representations
% - SPM toolbox running with smaller cancel epsilon
% - corasim/system extended to convert from ss to zpk
% - block permutation for zpk to ss
% - add corasim/vpa and corasim/check methods
% - pimp corasim/display to deal with VPA
% - bug fix in corasim/vpa: eliminate inf in zero poles after double conversion
% - pimp corazito/plot and corazon/subplot to support hold & semilog/lolog
% - pimp corazon/stop method to set stop flag
% - in corazon/collect use corazon/tree instead of corazon/select

%
% Known Bugs / Wishlist
% - none so far
%
end

function VersionV1H                                                    
%
% Release Notes Corazon/V1H
% =========================
%
% - basis for MINISPM V1E toolbox
%
%
% Change Log V1h:
%
% - starting corazon V1h
% - obsoletion of corazon/select call in corazon/collect
%
% - Release version CORAZON V1H
% - store subplot indizes in axes shelf
% - corazon/message to be displayed in subplot
% - corazon/children method added

%
% Known Bugs / Wishlist
% - none so far
%
end

function VersionV1I                                                    
%
% Release Notes Corazon/V1I
% =========================
%
% + add corazon/children method
% + improve corazon/progress for simplified progress messages
%
% Change Log V1i1 (beta):
%
% - starting corazon-v1i1 (beta)
% + improve corazon/progress method for simplified progress messages
% + add corazon/children method
% - bug fix in corasim/bode (axis scaling, axis visibility)
% - Edit>Copy/Cut to copy/cut whole packages or all shell objects
% - color defaults added to corasim/bode
% - corazon/id extended to identify object for given ID
% - bug fix: corazon/id (did not return 2nd arg)
%
% Change Log V1i2 (beta):
%
% - starting corazon-v1i2m (beta)
% - add functionality to corazon/cache() to clear cache segment
% - bug fix corazon/cache() - deal with empty cache on cache segment delete
% - bug fix corazon/dark: change control.dark settings
% - bug fix: corazon/subplot - always axis on
% - add corazon/make method
% - bug fix corazon/dark: change control.dark settings
% - package objects have always zero number parameter
% - add corazon/pkg method
% - pimp object inheritance of corazon/children and corazon/pkg
% - option cache.hard to allow/prohibit hard refresh of cache
%
% Change Log V1i3 (beta):
%
% - pimp corazito/master to deal with stop requests
% - pimp corazito/stop
%
% Change Log V1i4 (beta):
%
% - bugfix in corazon/plot: return NaN (pseudo handle) for empty plot
%   vectors (otherwise calling function can get irritated because assuming
%   that the plot is not handled by corazon/plot
% - adding a confirmation dialog in corazon/stop
% - adding corazita/axes method
% - change output arg semantics of corazon/subplot
% - bugfix: subplot handling in corazon/message
% - corazon/menu/SaveCallback: use corazon/save instead of corazita/save
% - corazon/clean: do not clean cache
%
% Change Log V1i5 (beta):
%
% - bugfix in corazon/cls: focus thief fixed
%
% Change Log V1i6 (beta):
%
% - corazon/folder method added
% - adopt corazita/menu to create uifigure if control.ui otion set
% - bugfix corazon/pull: set figure handle before fetching settings
% - many adoptions to use figure handles correctly (based on corazon/figure
% - can select in bode diagram between f and omega
% - bugfix corazon/plot: inherit axes and deal with subplot
% - bugfix in corazito/ready: exception handler for File/Exit case
% - cache(o,o,[]) - cache hard clear syntax supported
% - menu rebuild clears refresh callback and ends with a done-message
% - bugfix in corazon/id: need to inherit options from shell objects
% - pimp corazita/load and corazita/open to open file by path
% - bugfix: o=cache(o,o,[]) syntax
% - legacy sample plugin added
% - corazon/cache: calling syntax for hard clear of all caches added
% - two out args for corazon/subplot
% - optional path for corazon/save
%
% Change Log V1i8 (beta):
%
% - corleon/save: replace struct conversion to property wise conversion
% - corazon/rapid: change Plot template to check handles with corazon type
%
% Change Log V1i8 (beta):
%
% - corazito/master: bug fix: do not append empty arg to arg list
% - corazon/rapid: generate improved plot method
% - corazon/plot: bug fix: hold control (subplot() always set hold on)
% - corazo/heading: implicite hold off
% - corazon: bug fix of cuo and sho (in case of unavailable shell window)
% - corazon/menu/About: bug fix - options to be inherited
%
% Known Bugs / Wishlist
% - none so far
%
end

