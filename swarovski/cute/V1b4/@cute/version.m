function vers = version(o,arg)         % CUTE Class Version
%
% VERSION   CUTE class version / release notes
%
%              vs = version(cute);            % get CUTE version string
%
%           See also: CUTE
%
%--------------------------------------------------------------------------
%
% Setup
% =====
%
% In a case clause of use.m add the following code
%
%
%     function use(tag,version)
%       version.cute = 'V1a';
%
%       switch (tag)
%          case 'cute'
%           use corazon
%           addpath([mhome,'/swarovski/cute/',version.cute]);
%           fprintf(['   using Cute Toolbox ',version.cute,'\n']);
%           articles(cute,artpath);
%           directory(cute,cutpath);
%           disp(pwd)
%       end
%     end
%
%
% Features CUTE/V1A
% ==================
%
% - corazon based toolbox with plugin support
%
% - articles library data can be located in definable directory. Method
%   cute/articles to be used during setup to specify path. Alternatively
%   cute/articles can be used to see the list of articles
%
% - default path can be pre-defined using: directory(cute,defaultpath)
%
% - Package info file can be provided semi automatic (user can edit info)
%   See File/Tools/Package_Info
%
% - Import of single cutting log data
%
% - Reading packages by selecting package directories, and displaying
%   object list in hierarchical grouping by packages
%
% - Study menu can be activated/deactivated (>File/Extras/Study_Menu)
%
% - Cluster method/parameters determining behavior of cluster algorithm
%   for automatic detection of facette segments can be adjusted in
%   Select>Internal/Cluster menu.
%
% - Raw data are brewed with respect to velocity filter selection and
%   rotation settings (rotation selected or deselected). In addition
%   streams can be compacted (to cut out uninteresting passages) or
%   the stream part according to a facette can be closed up. Method 
%   cute/brew is called to brew data and store in cache, while method
%   cute/cook is used to access raw data or brewed data.
%
% - all data is calculated from raw data and stored in a cache. cache 
%   data is maintained to improve speed as long according settings are not
%   changed. When settings are changed (e.g. facette selection or rotation
%   settings, then cache is automatically refreshed by invoking brew
%   method properly
%
% - Providing method cute/spec to retrieve specs according to figure
%   settings; calling of cute/spec without output args draws proper 
%   spec limits according to given symbol and menu settings
%
% - Providing method cute/cpk to calculate strong and weak Cpk values 
%   for a given stream (identified bx stream symbol). Calling cute/cpk
%   without output args plots the situation under which Cpk values are
%   calculated in order to investigate plausibility for correctness of Cpk
%   algorithm
%
% - Provide an overview analysis to show acceleration magnitude and
%   optional the effect of the facette cluster filter
%
% - Metrics like Cpk and magnitude reserve calculated for each object and
%   buffered in the according package object with the option to store
%   package object with buffers back to file. Possibility to display 
%   metrics over huge sets of objects based on buffered package information
%
% - cockpit plot as an overview over all accelerations, velocities and
%   elongations (both time plots and orbit plots
%
% - dark mode support; dark or bright mode can be chosen in View>Dark menu
%
%
% Features CUTE/V1B
% ==================
%
% - with File>Import>Package_Info_(.xlsx) the data of the measurement plan
%   can be imported into a package, which can be exported to a package info
%   file in the related log data directory. This further allows to import
%   files of a package with automatic inheritance of the measurement plan
%   information from the package info file
%
% - package info objects typically contain a list of files which relates 
%   to the list of their child objects. in 'full' the full data of the
%   measurement plan is imported, while in 'relevant' mode the measurement
%   plan information related to object files in the same directory is im-
%   ported. This allows to copy some .csv files into a directory together
%   with the unchanged measurement plan, while only parts of the measure-
%   ment plan (the relevant information) is imported into the package.
% 
% - for long lasting operations like package import or cache brewing the
%   progress is displayed in the figure title bar
%
% - plugin examples to demonstrate adding of menu items, and to introduce
%   additional metrics values
%
%--------------------------------------------------------------------------
%
% Roadmap
% =======
% * toolbox to analyse and study ...
% * 3 Orbit views (cutting plane x/y, perpendicular y/z and x/z,
%   all corrected by Lagen and Facette angles)
% * for all 3 quantities: acceleration, velocity, elongation
% * transformation into cutting coordinate system 
% * acceleration limits to be plotted in 2D-Plots
% - friction coefficients, damping coefficients ???
% - parameters for compatibility: form of oscillation (elliptical), length
%   of principal and non-principal axis, rotation in cutting coordinate
%   system
% * deterioration factor, Cpk (maximum value of iscillation with respect 
%   to defined spec for each facette)
% * no automized calculation of occuring maximum frequency
% 
% * change 'kappl' identifier to 'variant' identifier => obsolete!
% * evolution plot for velocity and elongation
% * basket filter for package objects
% * basket filter for shell object
% * read measurement plan and store parameters in packages
% * inherit package parameters to object files being imported
% * show metrics of an object (in addition to package and shell)
% * metrics view for objects
%
%--------------------------------------------------------------------------
%
% Release Notes CUTE/V1A
% =======================
%
% - created: 06-Aug-2020 18:32:17
% - add roadmap/feature definition
% - add cute/articles with path setting and listing
% - cute/write is not yet supported
% - add cute/read driver and cute/collect method
% - adapt Select menu to support object grouping of packages
% - pimp File/New menu, File/Import and File/Export - provide import menu
%   item for single file import
% - grouping of packages in Select/Objects menu
% - provide package info (menu item File/Tools/Package_Info)
% - Study menu can be activated/deactivated (>File/Extras/Study_Menu)
% - add cute/cook, cute/analyse cute/crowd, cute/facette & cute/velocity
% - cute/analyse/Cockpit running
% - orbit and evolution reasonably working :-)
% - method cute/spec and cute/cpk
% - magnitude overview with optional display of facette filter
% - cute/diagram method
% - filter study added
% - PolarCache study implemented and running well :-)))
% - Polar Cache test with brewing :-)))
% - add cluster parameters and cluster parameter menu
% - first time raw data plotting works with new cache :-)))
% - figure refreshing causes data brewing (being displayed)
% - facette closeup working again :-)))
% - plot menu progresses: Raw Data, Magnitude, Orbits
% - first 1-2-3 plots :-)
% - some adoption to hard/soft type refresh of cache method
% - pimp Plot/Process menu and Plot/Kappl menu
% - sigma cluster method implemented :-)))
% - bug fixed: Facette menu not refreshing - fix: wrap Facette menu!
% - level and sigma clustering
% - bug fixed: run number check in cute/split function hacked => %d format
%   to be used instead of %g format
% - improved Cpk calculation with graphics
% - Cpk algorithm implemented and basically verified :-)))
% - Cpk graphics completed (introduced relevance parameter :-)))
% - small pimps here & there
% - bug fixed in Facette menu build-up
% - pimp plot/About for pkg and cul objects
% - brew package data
% - pimp package data brewing
% - nice cpk/mgr chart
% - bug fixed in cute/menu/Activate: set figure title
% - bug fixed: verbose talking in cute/spec (else -> elseif)
% - move cute/menu/Organize and cute/menu/Objects to corazon/menu
% - About plot for article type
% - pimp progress display in figure bar during import
% - pimp plot menu
% - pimp plot About
% - read package info from file
% - structure changed of package cache segment & data representation
% - extend package reading with Header and Data
% - can export/import package info and Cpk is working :-)))))
% - verified THDR calculation and display of THDR algorithm mechanics :-)))
% - bug fix: thdr calculation
% - introduce 'spec' cache segment for proper redraw of metrics plot upon
%   change of THDR spec
% - bug fixed in cute/readf: file name composition
% - well tested metrics calculation & metrics plotting :-)))
% - extend Metrics plot from packages to also shell object :-)))
% - clean implementation of velocity filter
% - cockpit working again :-)))
% - velocity and elongation orbit implemented!
% - orbit overview implemented
%
%
% Release Notes CUTE/V1B
% ======================
%
% - created: 24-Aug-2020
% - read measurement plan
% - adopt plot/About for packages according data from measurement plan
% - save measurement plan as package tested
% - import measurement plan from two kinds of directories
% - package import with only children file import
% - caching of package info parameters in 'package' cache segment
% - basket menu skeleton
% - fairly nice basket menu
% - basket filter for package objects :-)))
% - bug fix in cute/basket: call list = basket(o)
% - full package import from .xlsx and relevant import from .xlsx
% - adopt cutoff frequency for THDR calculation, caching
% - cutev1b2 beta
% - bug fix in cute/read/ReadPkgXlsx: read Excel file into table
% - evolution plot for a,v and s :-))
% - clean implementation of package and obj import @ data upgrade :-))))
% - metrics for data objects
% - fine tune graphical layout
% - metrics plot for shell object selection :-)))
% - View>Heading menu added
% - progress bar updates for package import and cache brewing
% - bug fixed in metrics plot: basket parameters do not match with file name
% - bug fixed in brew/PackageBrew: have to seek by number
% - improved text display in plot/Metrics also for packages
% - pimp text display for plot/CutMetrics
% - cutev1b3 beta
% - minor bug fixed: missing semicolon in cute/collect/Import @ line 245
% - cute/id method implemented
% - spec color can be selected in menu
% - bug fixed: corazon/add comes with an assertion if package imported and
%   package already loaded
% - bug fixed in cute/plot/Text: display run number in object identifier
% - adoption of cute/id to return also machine and digits
% - bug fixed: loading .pkg (package info from LPC03_20060903 and the .csv
%   file with run number 5 (in 'Andy Test' folder) screws up package info
%   cache (wrong assignments) => introduce 'mpl' type for measurement plan
% - introduce mpl type for measurement plan
% - bug fixed: in above scenario after additionally loading .csv file with
%   run number 3 => warning cannot upgrade object
% - bug fixed: cannot import package with 2 .csv files (assertion)
% - bug fixed: cannot load .csv file when package loaded package naming
% - bug fixed: filename of .csv object contains slash ('...Lage5_01/.csv')
% - minor bug fixed: text exceeds plot frame for metrics with 2 objects 
% - several major bugs fixed :-)))
% - cuteplug1 sample
% - minor bug fix: Cockpit: remove metric values in diagrams and move to 
%   heading
% - cuteplug2 sample
% - better info for evolution plot
% - closeup adoption for orbit plots
% - more process plots (velocity,elongation)
% - implement select(o,ID)
% - bug fix in cute/metrics: wrong xlim setting
% - add objids to pacage cache
% - introduce oid as parameter  (changing standard for package oid) 
% - ignore scope data files during package import
% - pimp Cpk mechanics: replace pareto with threshold
% - cold refresh bug fixed in metrics/CutMetrics
% - provide cuteplug1, cuteplug2, cuteplug3 deno plugins
% - ellipse implemented in orbit plots and evolution
%
%
% Known bugs & wishlist
% =========================
% - minor bug: filtered magnitude (in overview) does not compare to mag-
%   nitude of raw signal
% - minor bug: hidden File/Extra and File/Tools menu header not working!
%
%--------------------------------------------------------------------------
%
   path = upper(which('cute/version'));
   path = upath(o,path);
   idx = max(findstr(path,'@CUTE'));
   vers = path(idx-4:idx-2);
end
