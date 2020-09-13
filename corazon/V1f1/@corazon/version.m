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
   idx = max(findstr(path,'/@CORAZON/VERSION.M'));
   vers = path(idx-3:idx-1);
   
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
% - Pretty polynomial display
%
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
%
%
% Known Bugs / Wishlist
% - corazon/shell and corazon/rapid generated shells do not refresh
%   correctly
end