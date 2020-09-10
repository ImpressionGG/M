function oo = version(o,varargin)                                      
%
% VERSION   CARABAO toolbox version / release notes
%
%    Print CARABAO release notes / bug list or get CARABAO version
%
%       vs = version(carabao);         % get CARABAO version string
%       version(carabao);              % type release notes / known bugs
%
%    See also: CARABAO
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
   path = upper(which('carabao/version'));
   idx = max(findstr(path,'\@CARABAO\VERSION.M'));
   vers = path(idx-3:idx-1);
   
   if (nargout == 0 || nin > 1)
      clc
      %help carabao/version
      type carabao/version
      line = '----------------------------------------';
      fprintf('%s%s\n',line,line);
      fprintf('CARABAO Toolbox - Version: %s\n',vers);
      fprintf('%s%s\n',line,line);
   else
      oo = vers;
   end
end   

%==========================================================================
% Known Bugs & ToDo's
%==========================================================================

function KnownBugsAndTodos             % Just a Dummy Function         
%
% Known Bugs & ToDo's & Wishes
% ============================
%
% - motion objects do not change title and comments after property edit
% - xlabel is still not perfect
% - 2D Analysis does not work for imported DANA object
% - Guerilla always opens two windows
% - Plot/Residual is not working and ends-up with a crash
% - ensemble plot for DANA object is in red and blue (should be color mix) 
% - speed-up object selection (and menu rebuild)
% - read all packages of a project folder or project sub folder
% - package import has to offer a package dialog with context
%   reconstruction, if package has no package info
% - separator does not work in Objects menu for empty packages
% - Arrow plot and related menu functions do no more work
% - history buttons for New Package dialog
% - default configuration of .dat file does not work properly
% - UniLogDrv must be able to read multiple objects in single log file
% - introduce View>Scale>Time menu for time scaling
% - make View>Camera>Spin working
% - export method must be transfered from CARASTEAK
% - carma shell does not redraw correctly if bullet option of a weird
%   object is changed if control(o,'options') is false. Obviously the
%   'plot' option gets lost for this case
% - after pasting & cutting a Carashit object, followed by a plot the
%   redraw function crashes (redraw still tries to invoke the carashit>plot
%   method
%
end

%==========================================================================
% Release Notes
%==========================================================================

function VersionV1B                                                    
%--------------------------------------------------------------------------
%
% Release Notes Carabao/V1B
% =========================
%
% - Nice functionality, including rapid prototyping shell
% - backup Carabao.V1b.bak1.zip
% - Release Carabao.V1b (11-Dec-2015)
%
end
function VersionV1C                                                    
%
% Release Notes Carabao/V1C
% =========================
%
% - length of time vector in carabao/shell>Create/Weird changed from 1001
%   to 1000 points
% - caracow/display and carabao/doisplay changed: WORK PROPERTIES -> WORK
%   PROPERTY
%
% Release Notes Carabao/V1D
% =========================
%
% - did some speed optimizations, checked with carashit/perform
% - cross checked with Carabao docu (chapter #1...#4)
%
% Release Notes Carabao/V1E
% =========================
%
% - added the CARALOG object 
% - caracow/manage accepts also function handles: menu(o,@Begin)
% - backup Carabao.V1e.bak3.zip (IMEC power work shop)
% - Release Carabao.V1e (for IMEC power work shop)
%
% Release Notes Carabao/V1F
% =========================
%
% - bug fixed in carabao/menu>CutCb: oo to be initialized (oo = o)
% - remove blank lines in carabao/shell
% - bug fixed in carashit/shell>Init: set launch function 
% - menu item Info>Query Info disabled
% - backup Carabao.V1f.bak1.zip
% - backup Carabao.V1f.bak2.zip (handed over to Birgit)
% - class CARMA created (previous CARALOG class)
% - class TPX created (copied from Birgit)
% - backup Carabao.V1f.bak3.zip
% - replaced all 'lambda' by 'gamma'
% - fixed carma/cook function (was a lot of work)
% - backup Carabao.V1f.bak4.zip
% - bug fix in CARMA shell's Info menu (carma/shell)
% - backup Carabao.V1f.bak5.zip
% - bug fixed in carabao/rapid: proper casting for generated
%   shell>New methods
% - CARALOG class removed (we have CARMA instead!)
% - backup Carabao.V1f.bak6.zip
% - bug fixed in choice/ChoiceCb: pull (refresh) object after each call 
% - bug fixed in check/CheckCb: pull (refresh) object after each call 
% - bug fixed in charm/CharmCb: pull (refresh) object after each call 
% - dirty hack in carabao/import to deal with control(o,'options)
% - backup Carabao.V1f.bak6.zip
% - control(~,'options') settings fixed in carma/menu>Config
% - backup Carabao.V1f.bak7.zip
% - toolbar on/off fix activated
% - backup Carabao.V1f.bak8.zip
% - carma menu File>New extended to File>New>Plain Trace and
%   File>New>Simple Trace (change in carma/menu/New, carma/menu/PlainTrace,
%   carma/menu/SimpleTrace)
% - carabao shell menu item Info>Debug>Auto CLC added in method
%   carabao/menu/Debug
% - bug fixed  in carma/menu/Current: behavior of menu refresh must depend
%   on control(o,'options') settings
% - backup Carabao.V1f.bak9.zip
% - export split into carma/export and carma/write
% - import implemented, splitting into carma/import and carma/read
% - backup Carabao.V1f.bak10.zip
% - bug fixed in carabao/inherit: if control(o,'options') == 0 we have to 
%   copy all those parent options to the object which do not already exist
%   in the object. The existing options are left unchanged
% - backup Carabao.V1f.bak11.zip
% - bug fixed in rapid/SeekText (issue with correct path estimation)
% - backup Carabao.V1f.bak12.zip
% - bug fixed in carabao/shell/NewCb: need to cat object to carabao in
%   order to create a CARABAO object
% - fine tuned carma/rapid method for rapid prototyping
% - backup Carabao.V1f.bak13.zip
% - changed carma/import, carma/export, carma/read and carma/write to new
%   standard (utilizing carabao/manage function)
% - formatting introduced in carabao/charm/Edit callback
% - CARASIM object added. Supports methods carasim/motion and carasim/duty.
% - backup Carabao.V1f.bak14.zip
% - some bugs fixed in carasim/motion and carasim/duty
% - backup Carabao.V1f.bak15.zip
% - multiple output for caracow/get implemented
% - carasim/step and carasim/plot running now on test level
% - backup Carabao.V1f.bak16.zip
% - bug fixed in carabao/choice/Choice and carabao/choice/Update (o was 
%   missing
% - backup Carabao.V1f.bak19.zip
% - carma/rapid method modified to support only read & write but no more
%   import & export
% - backup Carabao.V1f.bak20.zip
% - release Carabao.V1f (for Birgit's TPX)
%
end
function VersionV1D                                                    
%
% Release Notes Carabao/V1G
% =========================
%
% - bug fixed in carma/plot and carma/cook: be tolerant if selection
%   criteria forces to get an empty data stream
% - bug fixed in carma/menu/Category: callbacks fixed
% - labels of View>Config>Category menus redefined (e.g. '+/- 0.1')
% - can setup digits for statistics labels
% - removed refresh call when activating selecting gallery entry in
%   carabao/gallery
% - backup carabao.v1g.bak1
% - release carabao.v1g
%
end
function VersionV1H                                                    
%
% Release Notes Carabao/V1H
% =========================
%
% - bug fixed in carma/fetch/Symbols to make carma/fetch/Main functionality
%   working
% - plugin functionality added
% - backup carabao.v1h.bak1
% - improved plugin functionality
% - modification of carabao/shell, carma/shell, tpx/shell to provide plug
%   points
% - modified carma/rapid to provide plug points
% - backup carabao.v1h.bak2
%
end
function VersionV1I                                                    
%
% Release Notes Carabao/V1I
% =========================
%
% - bug fixed in carabao/choice: value can also be empty
% conditional data set/get implemented
% - rewrite carabull/util/isghandle to be compatible with lower MATLAB
%   versions than release 13
% - bug fixed in carma/capa: did not work correctly for ignore > 0
% - including carapbi methods: pbiread, expect, filedate, progress, token
% - included carapbi/imp_txt to import PBI text files
% - some bugs fixed in carma/cook: bias mode did not work for all plot 
%   modes, especially Ensemble and Offsets
% - backup carabao.v1i.bak1
% - caramel/read/Progress function added to show progress in figure bar
%
end
function VersionV1J                                                    
%
% Release Notes Carabao/V1J
% =========================
%
% - CARAMEL object class introduced
% - backup carabao.v1j.bak1
% - rewrite caramel/config, caramel/category and caramel/subplot including
%   some bug fixes
% - backup carabao.v1j.bak2
% - View>Plotting menu added for Caramel shell
% - backup carabao.v1j.bak3
% - new trace creation (caramel/shell) moved to plainplug and simpleplug
% - backup carabao.v1j.bak4
% - First version of PBIPLUG implemented
% - GUERILLA SHELL provided
% - backup carabao.v1j.bak5
% - import driver for .pbi files ported to pbiplug
% - backup carabao.v1j.bak6
% - bug fixed in pbiplug/PbiTxt and pbiplug/PbiPbi (clear data list
%   when starting with a new object)
% - backup carabao.v1j.bak7
% - bug fixed in carabao/menu/Info/Edit: Disp needs to be called with
%   mode argument
% - carabull/profiler method implemented
% - carashit/cuo, carashit/sho, carashit/ticn and carashit/tocn moved to 
%   carabull
% - backup carabao.v1j.bak8
% - GUERILLA rewritten in order to support proper rebuild
% - bug fixed in caramel/plot/LabelsStatistics (in case of empty t)
% - backup carabao.v1j.bak9
% - bug fixed in caramel/cook: crash if ignore setting is bigger than
%   matrix dimensions
% - backup carabao.v1j.bak10
% - logplug implemented
% - bug fix in caramel/category
% - bug fix in caramel/config
% - bug fix in caramel/subplot
% - bug fix in caramel/config: o = config(o,o) => update settings & rebuild
% - backup carabao.v1j.bak11
% - bug fixed in caramel/config (o=config(o,o)): menu refresh
%   (menu(po,'Config')) has to work on parent object!
% - danaplug implemented (first version)
% - danaplug automatically installed in GUERILLA
% - View>Signal menu item moved on top of View menu (caramel/shell)
% - backup carabao.v1j.bak12
% - Guerilla menu Analysis>Geometry ported
% - backup carabao.v1j.bak13
% - consolidation of caramel/plainplug & caramel/simpleplug to 
%   caramel/simple 
% - rename caramel/pbiplug to caramel/pbi
% - rename caramel/danaplug to caramel/dana
% - backup carabao.v1j.bak14
% - bug fix of menu Info>About Object>Edit (update did not work)
% - fine tuning of caramel/export method
% - export of simple & plain type seems to work now perfectly
% - implementation start of caramel/basis plugin
% - integration of caramel/basis plugin in guerilla
% - caramel/trace: dat.time changed to dat.t
% - backup carabao.v1j.bak15
% - caramel/read first time clean implementation
% - backup carabao.v1j.bak16
% - some finetuning of caramel/read
% - caramel/basis: import of vibration test implemented
% - backup carabao.v1j.bak17
% - caramel/read/PbiPbiDrv implemented
% - backup carabao.v1j.bak18
% - heavy bug fixed in caramel/plot: plot(x,y') instead of plot(x,y). The
%   plot was always good except when x and y were square matrices, which
%   happened in Flo's log file
% - backup carabao.v1j.bak19
% - TRF object implemented (transfer functions) derived from CARAMEL
% - backup carabao.v1j.bak20
% - dana/shell: File>New>Dana Object>Preset>Axis Error menu implemented.
%   a couple of parameters added to control/define the interpolation error
% - backup carabao.v1j.bak21
% - Analyse>Vibration Analaysis implemented
% - backup carabao.v1j.bak22
% - release carabao.v1jp0
% - some bugs fixed in Analyse>Vibration Analaysis
% - pbi plugin and basis plugin are creating CARALYSE objects in GUERILLA
% - backup carabao.v1j.bak23
% - backup carabao.v1j.bak24
% - ETEL Telica plugin implemented
% - backup carabao.v1j.bak25
% - adaptions to telica plugin
% - backup carabao.v1j.bak26
% - changes in carabao/plot and carabao/labels: allow empty color string
%   and avoid plotting and labeling in case of empty color string
% - backup carabao.v1j.bak26
% - legend support
% - backup carabao.v1j.bak27
% - release carabao.v1j
%
end
function VersionV1K                                                    
%
% Release Notes Carabao/V1K
% =========================
%
% - bug fixed in carabao/current/Select: mandatory to refresh object after 
%   changing current index in control options
% - bug fixed in caramel/subplot: did not accept oo = subplot(o,[])
% - plugin bug fixed (plugin points for dynamic menus like Vibration
%   Analysis in menu Analysis)
% - backup carabao.v1k.bak1
% - bug fixed in carabao/shell/Analysis: 'no cube objects in basket!'
% - carabao/shell/NewStuff function added
% - backup carabao.v1k.bak2
% - release carabao.v1k
% - bug fixed in carabao/mhead: update menu item properties for 5+ args
% - caramel/project plugin implemented
%
end
function VersionV1L                                                    
%
% Release Notes Carabao/V1L
% =========================
%
% - caramel/new extended to add version and package parameter, as well as
%   shape parameter (structure) and junk parameter (cell array)
% - caramel/write method adopted to log for simple objects: comment lines,
%   structures and cell arrays
% - caramel/read method adopted to be able to read structure and cell array
%   parameters, as well as comment lines and empty lines anywhere in the
%   log file
% - backup carabao.v1l.bak2
% - menu View/Style/Title added and functionality to display package
%   extension in title (caramel/labels)
% - backup carabao.v1l.bak3
% - renamed carabao/package method to carabao/container
% - backup carabao.v1l.bak4
% - dialog Info/Parameters (carabao/menu/Parameter, carabao/menu/Dialog)
%   implemented
% - backup carabao.v1l.bak4
% - canvas color implemented in New functions and carabao/cls
% - carabao/menu/Parameter and carabao/menu/Dialog copied & extended to
%   caramel/menu
% - nicely working dialogs
% - backup carabao.v1l.bak5
% - dialog for new packages
% - backup carabao.v1l.bak8
% - implement export function for package (caramel/write/Package, .pkg)
% - backup carabao.v1l.bak9
% - read machine from parent++ directory when opening log root
% - bug fixed in carabull/fselect (need try ... catch)
% - implement import function for package (caramel/read/Package, .pkg)
% - backup carabao.v1l.bak10
% - project plugin name changed to kefalon plugin
% - canvas color moved to caramel/subplot functionality. Overloaded
%   method caramel/cls introduced to deal with canvas color
% - all shell object parameters moved to kefalon settings
% - backup carabao.v1l.bak11
% - auto discovery of highest run number
% - fine tuning
% - backup carabao.v1l.bak12
% - import of complete package folder implemented
% - export of BMC and VIB files implemented
% - backup carabao.v1l.bak13
% - syntax subplot(o,'canvas') changed to subplot(o,'color')
% - method caramel/collect implemented
% - caramel/menu/File added, which supports a File>Tools menu
% - caramel/shell adopted to support collection
% - big renaming of input/export drivers
% - now a nice version which can import total packages
% - backup carabao.v1l.bak14
% - caramel/tcp plugin supports import and display of TCB traces
% - bad bug fixed in caramel/category and caramel/subplot (several uses
%   of o.type had to be replaced by typ = CurrentType(o))
% - backup carabao.v1l.bak15
% - bug fixed in caramel/menu/Analysis (return oo instead of o)
% - Import menu of simple plugin changed ('General') and import menu
%   of caramel/shell changed (File>Import>Package is no a direct menu item)
% - Introduction of background style (View>Style>Background). The actual
%   background control is done by caramel/cls
% - backup carabao.v1l.bak16
% - import of TCB traces optimized
% - caramel/basket implemented. Extended carabao/basket by additional 
%   filtering by 'kind'
% - backup carabao.v1l.bak17
% - simplify caramel/plot method
% - backup carabao.v1l.bak18
% - cleanup caramel/plot method (rename functions & remove obsolete stuff)
% - changed the mode of returning plot handles (var(o,'hdl'))
% - quite nice cleaned up plot method, seems to be quite stable
% - backup carabao.v1l.bak19
% - faster version of caracow/opt (according to caracow/var)
% - speed optimization of caramel/plot and caramel/cook
% - plot routines perform now nicely with speed :-))))
% - backup carabao.v1l.bak20
% - token mode introduced for caramel/config in order to speed up
% - speed-up of caramel/plot by token mode implementation
% - very nice, fast performance
% - backup carabao.v1l.bak21
% - bug fix in labels/Statistics
% - carabao/new method implemented. Moved creation code from carabao/shell
%   to carabao/new
% - re-introduced carabao/read and carabao/write method
% - modified carabao/rapid to generate read and write methods and to
%   generate a complete CAPUCHINO shell which is able to create, import and
%   export .log data and to analyse it
% - backup carabao.v1l.bak22
% - some bugs fixed in carabao/rapid
% - looks good and stable
% - backup carabao.v1l.bak23
% - carabull/assoc method modified to add or update assoc pairs
% - backup carabao.v1l.bak24
% - method carabao/event introduced
% - methods carabao/menu/Begin, carabao/menu/Select changed in order to
%   leverage EVENT method for 'select' event.
% - methods caramel/menu/View, caramel/menu/Select and caramel/shell/Export
%   changed in order to leverage EVENT method for 'select' event.
% - backup carabao.v1l.bak25
% - creating CAPPUCCINO class, using carabao/rapid
% - testing CAPPUCCINO shell - performs smooth and well
% - backup carabao.v1l.bak26
% - carabao/menu/Current removed (is now obsolete)
% - caramel/menu/Current removed (is now obsolete)
% - kefalon/NewProject implemented
% - adopt some tolerance for carabao/rebuild to simplify plugins
% - caramel/onoff method implemented
% - bug fixed in caramel/write: write support for empty value
% - some fine tunig of caramel/simple and caramel/basis
% - backup carabao.v1l.bak27
% - method caramel/change implemented
% - some fine tuning & bugs fixed in caramel/simple, caramel/basis
% - caramel/tcb fine tuned and bugs fixed
% - nice performance of caramel/shell
% - backup carabao.v1l.bak28
% - some fine tuning
% - backup carabao.v1l.bak29
% - caramel/simple changed to caramel/sample (name change)
% - adoptions made in caramel/shell, caramel/sample, caramel/rapid
% - tested caramel/shell - very nice performance
% - backup carabao.v1l.bak30
% - caramel/shell/View finetuned, local function caramel/shell/Signaling
%   introduced
% - test also done with @moccha class - very good now!
% - backup carabao.v1l.bak31
% - caramel/wrap method added to deal with event handler entry points
%   I really like it !!! :-)
% - bug fixed in caramel/basis: double BASIS-entries in File>New menu
% - bug fixed in caramel/basis: did not disable export menu correctly
% - nicely working moccha toolbox, tested with package read for plugins
%   basis and tcb
% - backup carabao.v1l.bak32
% - bug fixed: vibration Analysis does not yet work with MATCHA shell
% - Analysis/Cpk_Overview implemented
% - backup carabao.v1l.bak33
% - dialog box for new runs implemented
% - BaBa SimSim application created, including @babasim class
% - kefalon plugin adopted to be used within BaBa SimSim
% - small trimming of kefalon
% - plot method, which is generated by rapid/caramel, changed to plot all
%   object types which support both x and y (formerly only type 'pln' and
%   'smp' was supported, the rest was delegate to menu(o,'About')
% - extensive testing of BaBa SimSim - looks very good
% - backup carabao.v1l.bak34
% - bug fixed in carabao/plot/Scatter (wrong title)
% - modified caramel/rapid to support Import of .log data
% - caramel/rapid: modified read & write method to support .log file format
% - caramel/rapid: modified shell to support .log file import/export
% - backup carabao.v1l.bak35
% - bug fixed in caramel/context (could not extract machine number from
%   #95088008800 syntax)
% - backup carabao.v1l.bak36
% - added dummy danaobj() function to emulate DANAOBJ constructor, what is
%   needed to read log data of a DANA object
% - read driver for .M DANA objects implemented
% - bug fix in caramel/labels, to xlabel either time [s], position [#]
%   or matrix [#]
% - backup carabao.v1l.bak37
% - bug fixed in caralyse/shell/Import:  plugin(oo,'carabao/shell/Import'); 
%   replaced by plugin(oo,'caralyse/shell/Import'); 
% - backup carabao.v1l.bak38
% - CARALYSE changed to CIGARILLO
% - removed 'new' in menu text in sample/New
% - DANAOBJ dummy function installed in subfolder 'hacks' of CARABAO folder
% - bugfix in caracow/setting: setting failed when checking whether access
%   to user data is working, if a non-carabao figure (like DANA window) is
%   the current figure. To fix this bug userdata has to be checked to be a
%   structure (otherwise carabull/gcf will crash subsequently). if userdata
%   is not a structure then the check in setting has to proceed like with
%   an error on accessing userdata (means: to return an empty value)!
% - carabao figures and danaobj windows are working now in harmony
% - changed 'dana' type to 'bqr' type of DANA/BQR objects
% - changed $DANA$ menu tag to $BQR$
% - backup carabao.v1l.bak39
% - bug fix in caramel/menu/Parameter: crashed if comment is char but not
%   list; fixed by autoembed text into a list
% - add system info in caramel/new/Simple and caramel/new/plain
% - bug fixed:guerilla shell does not register correctly
% - bug fixed: current hack with DANAOBJ is a very bad hack!
% - backup carabao.v1l.bak40
% - caramel/bqr: removed package ID from title
% - demo/ultra implemented
% - backup carabao.v1l.bak41
% - bug fixed in carabao/charm: updating value from command line did not
%   work
% - backup carabao.v1l.bak42
% - ultra: Simulation>Cycle Studies implemented (works well)
% - backup carabao.v1l.bak43
% - bug fixed in carabao/choice: updating value from command line did not
%   work
% - backup carabao.v1l.bak44
% - some comment bugs fixed in caramel/trace
% - caramel/rapid creates now also simu method
% - adding Signal functionality to simu method
% - backup carabao.v1l.bak45
% - bug fixed in carabao/plot/StreamX, ./StreamY, and ./Scatter. Final hold
%   off added
% - bug fixed in caramel/plot/CorePlot: had to add a cls(o) at the begin-
%   ning, otherwise it is to sensitivew and too confusing
% - backup carabao.v1l.bak46
% - bug fixed in caramel/menu/Pick
% - caramel/inherit introduced to support configuration inheritance if
%   called with 1 input arg
% - bug fixed: caramel/config/Default: actualizing of category removed!
% - caramel/rapid updated to generate new style simu method
% - bug fixed in caramel/plot/Clip: switch current selection back to zero
%   to make refresh properly working after object selection!
% - backup carabao.v1l.bak47
% - small change in caramel/rapid: how to setup the categories
% - backup carabao.v1l.bak48
% - bug fixed in caramel/plot/Clip: need to unpack style options, etc.
% - backup carabao.v1l.bak49
% - new method caramel/graph (clip & plot)
% - introduced new calling syntax for caller(o,'PasteCb') to detect the
%   origin of a callback execution
% - backup carabao.v1l.bak50
% - carabao/message extended to support horizontal and vertical alignment
%   option.
% - caracow/arg extended to support 'list = arg(o)', same as 'list =
%   arg(o,0)'
% - lots of studies
% - starting to implement brute force studies
% - backup carabao.v1l.bak51
% - scatter plot implemented (ultra/plot)
% - backup carabao.v1l.bak52
% - some adaptions to algorithms, logings, Signal menu (ultra/study)
% - backup carabao.v1l.bak53
% - caramel/log method added
% - bug fixed in caramel/config: default initialization provides label
% - reworking of caramel/rapid to make use of caramel/log
% - reworking of ultra/study to make use of caramel/log
% - added 'Damped Oscillation' (Simu4) to caramel/rapid
% - backup carabao.v1l.bak54
% - backup carabao.v1l.bak55
% - introduce ultra/jumbo and setup a process flow for 20.000 UPH @ 8BH
% - backup carabao.v1l.bak56
% - finally got Signal menu switching running for shell(caramel)
% - backup carabao.v1l.bak57
% - big step: configuration management fully rewritten. Major control by
%   means of caramel/change
% - backup carabao.v1l.bak58
% - add wrapper function for Signal menu (caramel/menu, caramel/wrap)
% - caramel/graph and ultra/graph are calling now event(o,'signal') in
%   order to rebuild View/Signal menu
% - backup carabao.v1l.bak59
% - modsdfied carabao/plot to use style options (carabao/plot/StreamX,
%   carabao/plot/StreamY,carabao/plot/Scatter)
% - adoption of trf/bode & trf/bodeaxes
% - backup carabao.v1l.bak60
% - demo/gaco class implemented (GACO = Gantry Control)
% - TRF constructor adopted for factor syntax, like Gs = trf(5,{},{2})
% - TRF/CAN method implemented (wrapper method)
% - TRF/ADD method implemented (wrapper method)
% - TRF/SUB method implemented (wrapper method)
% - backup carabao.v1l.bak61
% - improvement of TRF shell
% - backup carabao.v1l.bak62
% - method trf/rapid implemented
% - method caramel/paste added, to assign pasted objects to packages
% - trf/shell/Paste function implemented
% - backup carabao.v1l.bak63
% - improved trf/rapid to generate controller and plant method
% - improved trf/axes method in order to change canvas color
% - backup carabao.v1l.bak64
% - caramel/edit method implemented
% - carabao menu/edit adopted to have invisible Edit/Property menu item
% - trf/plant modified to support property edit
% - trf/controller modified to support property edit
% - trf/finish method introduced
% - backup carabao.v1l.bak65
% - carabao/edit changed to edit provided object directly
% - more fine tunig, e.g. carabao/edit, trf/plant, etc
% - backup carabao.v1l.bak66
% - trf/finish, trf/plant, trf/controller, trf/new: add color property
% - crabao/call changed to retrieve invoking stuff before call
% - bug fixed in trf/display: displays container objects and objects with
%   struct data in the usual carabao style
% - bug fixed in TRF constructor: can now construct from bag structure
% - default edit mode implemented for carabao/edit
% - carabao/color is averaging for multiple character strings
% - bode & step colors fixed (single TRF, open loop 'y', closed loop 'b')
% - backup carabao.v1l.bak67
% - bug fixed in carabao/menu/NewShell: added launch function before launch 
% - bug fixed: new package creates now a unique ID
% - bug fixed: new package does not set title properly
% - backup carabao.v1l.bak68
% - bug fixed: creation of a package does not automatically auto select.
%   to fix this bug a cnditional refreshing had to be implemented for
%   carabao/paste, also for caramel/paste
% - bug fix: bode plot does not display mutiple lines after creation
% - bug fix: PLOT<Description does not work properly for high order
%   transfer functions
% - move methods caramel/ready and caramel/busy to carabull/ready and
%   carabull/busy
% - insert busy and ready calls in carabull/master
% - caramel/activate moved to carabao/activate
% - bug fixed: pasting a transfer function should go into package, if
%   selected
% - backup carabao.v1l.bak69
% - trf/shell: Analysis/Sensitivity menu added
% - backup carabao.v1l.bak70
% - nasty bug fixed in carasim/motion (pre-signals did not work!)
% - Study menu implemented for TRF shell
% - backup carabao.v1l.bak71
% - implement Study/Motion menu in trf/study
% - bug fixed in carabull/ready: special dealing for Menu/Close and
%   Menu/Exit
% - backup carabao.v1l.bak72
% - some adoptions of carasim/motion
% - backup carabao.v1l.bak73
% - splitting up carasim/motion into functions - a lot of work!
% - backup carabao.v1l.bak74
% - carasim/motion & carasim/duty: algo can be set via option
% - trf/study: motion map and duty map implemented
% - some bug fix in carsim/duty
% - backup carabao.v1l.bak75
% - all fragmentation of carasim/motion done, except input args
% - backup carabao.v1l.bak76
% - carasim/motion: function motion/InArgs implemented
% - backup carabao.v1l.bak77
% - all main stuff of carasim/motion put into carasim/motion/Motion
% - backup carabao.v1l.bak78
% - pull(o) introduced in carabao/event/Invoke
% - bug fixed in play/shell/Signal: changed 'switch type(current(o))'
%   to 'switch active(o). This has also to be changed in caramel/rapid
% - carabao/active changed with lots of remarks to explain the activation
%   philosophy, and with extension of syntax mode 'active(0)' to display
%   also configuration callbacks
% - changed caramel/rapid to provide a Study menu instead of Simulation
%   menu
% - changed caramel/rapid: some cosmetics in study/Config 
% - lots of changes to get active type running
% - added 'type' control ption which stores active type: chasnges in 
%   carabao/refresh and carabao/invoke
% - reset callback to {@menu 'About'} in paste if object type differs 
%   from active type
% - seems to work now fairly. Not sure if everything runs consistently ???
% - backup carabao.v1l.bak80
% - changes adopted to TRF shell
% - backup carabao.v1l.bak81
% - carasim/motion extended by Trace functionality (calculates motion 
%   variables according to given time stamps)
% - some adaptions in carabao/sample plugin to adopt to new (active) style
% - backup carabao.v1l.bak81
% - caramel/motion plugin implemented. Allows to edit parameters
% - backup carabao.v1l.bak82
% - caramel/signal method implemented
% - overloaded caramel/type method which supports type(o,o) syntax
% - more powerful syntax for caramel/log to create log objects
% - backup carabao.v1l.bak83
% - fine tuning te SW; quite a nice version. not yet perfect, but nice!!
% - backup carabao.v1l.bak84
% - backup carabao.v1l.bak85
% - structure of carabao version file changed
% - title slightly changed in new plain and new simple (caramel/new)
% - bug fixed in caramel/signal: signal(o,cfg,label,tag) installs a signal
%   menu item but does not yet actualize the Signal menu
% - backup carabao.v1l.bak86
% - added View>Config>Type menu
% - changed play8/study/Config and play8/study/Signal
% - backup carabao.v1l.bak87
% - added type specific option listing in caramel/config, caramel/category,
%   and caramel/subplot
% - added mode subplot(o,'Signal') for caramel/subplot
% - added type(o) syntax for caramel/type in order to list type specific
%   subplot, category and config options
% - started to make cblist passing to active obsolete
% - backup carabao.v1l.bak88
% - backup carabao.v1l.bak89
% - bug fixed in caramel/change/Signal: must fetch subplot(o,'Signal')
%   from an object with type equal to active type
% - backup carabao.v1l.bak90
% - now basic functionality is working really very nice. Never been on this
%   level!
% - backup carabao.v1l.bak91
% - bug fixed: Plot&Clip not shows motion chart initially: trf/study/Signal
%   and trf/study/Config menus were not setup correctly
% - backup carabao.v1l.bak92
% - bug fixed in trf/shell/description: only strf/qtrf/ztrf typed objects
%   to be considered for description
% - caramel/menu/Subplot: SubplotCb callback added to invalidate signal 
%   mode subplot(o,'Signal');
% - super nice version !!!
% - backup carabao.v1l.bak93
% - CARAMEL method caramel/var implemented which allows multiple variable
%   read and multiple variable set
% - caramel/motion plugin updated
% - caramel/motion plugin tested with trf/shell
% - nice behavior
% - backup carabao.v1l.bak94
% - caramel/motion plugin: bugs fixed
% - caramel/motion plugin: Analysis menu implemented
% - caramel/analysis: error messages added for m=1 or n=1
% - backup carabao.v1l.bak95
% - remove Motion stuff in Study menu
% - very very nice version
% - backup carabao.v1l.bak96
% - bug fixed in caramel/sample plugin
% - backup carabao.v1l.bak97
% - new method trf/qtf implemented
% - new method trf/rsp implemented
% - backup carabao.v1l.bak98
% - carabao/plugin method completely rewritten
% - backup carabao.v1l.bak99
% - config converted to new option/settings style
% - backup carabao.v1l.bak100
% - subplot converted to new option/settings style
% - backup carabao.v1l.bak101
% - made some tests with new-control flag activated & worked well
% - backup carabao.v1l.bak102
% - config options converted to new style !
% - backup carabao.v1l.bak103
% - bug fixed in View>Config>Stream menu: opts(oo,..) instead opts(o,..)
% - backup carabao.v1l.bak104
% - bug fixed in carabao/plugin/ShowPlugins: remove owerwriting plugins
%   list with arg(o,1)
% - carabao/cast extended with a balancig functionality for oo = cast(o)
% - had to introduce casting in carabao/plugin/PlugPoint
% - finally able to plugin Analysis>Motion>Integrity menu
% - backup carabao.v1l.bak105
% - could make Analysis>Motion>Integrity menu finally running!
% - backup carabao.v1l.bak106
% - fixed bugs in trf/rapid: had to adopt to new Config and Signal style,
%   and some other bugs
% - bug fixed: event(o,'config') is not called after shell setup, thus
%   View>Config>Type does not display correctly => fixed it in
%   caramel/change/Signal => call to event(o,'config')
% - backup carabao.v1l.bak107
% - caramel/working method introduced
% - changed caramel/graph to use default plot mode from
%   setting(o,'mode.plot') if no explicite plot mode (arg2) provided
% - replace graph(o) call by plot(o) call
% - File>Extras menu added for CARAMEL shell in order to activate hidden
%   Study menu
% - Study menu added to CARAMEL shell
% - tested with rapid(caramel,'play') => works well
% - method caramel/opt introduced to extend caracow/opt by supporting
%   multiple set/get
% - backup carabao.v1l.bak108
% - predict/study/Uncertainty implemented
% - lots of finetuning of smart
% - caramel/symbol modified
% - not sure if everything still works
% - backup carabao.v1l.bak109
% - bug fix in caramel/cook when calculating repeatability
% - backup carabao.v1l.bak110
% - carabao/cast extended to support syntax o = cast(o,oo) for tag&class
%   conversion
% - bug fixed: rebuild does not build-up Analysis menu; had to wrap
%   shell/Plot call in caramel/shell/Setup and trf/shell/Setup as well
%   in caramel/rapid and trf/rapid
% - changed Animation menu of carashit to Plot menu
% - looks now very, very good!
% - backup carabao.v1l.bak111
% - made guerilla more or less running
% - time variant observer implemented for predict/study
% - backup carabao.v1l.bak112
% - setting 'mode.overlays' introduced. Needed a lot of changes in 
%   caramel/cook, caramel/plot, caramel/labels, caramel/menu
% - new method caramel/modes introduced to support clean dealing with 
%   plot modes
% - carabao/menu/Fix added to support window position fixing if desired
% - carabao/menu/Debug menu changed to support window fixing
% - carabao/menu/Begin had to be changed for above!
% - backup carabao.v1l.bak113
% - demo/@fito starting to integrate
% - backup carabao.v1l.bak114
% - first parts of @fito are running
% - backup carabao.v1l.bak115
% - more options pro ided ('style','view') in caramel/modes
%   remove option unpacking in caramel/menu/CbPlot
% - in caramel/menu/Bias use setting(o,{'mode.bias'},'absolute') by default
%   instead of 'drift'. Need to change caramel/shell/init and
%   cigarillo/shell/init
% - implemented extended color strings ('x:r2(:o)','y:5g('|o')',...)
%   in carabull/color and caramel/smart, caramel/log, caramel/plot
% - fito/labels method introduced
% - backup carabao.v1l.bak116
% - log also q in fito/simu
% - backup carabao.v1l.bak117
% - all FITO menu items now adopted and seem to work well
% - backup carabao.v1l.bak118
% - carabull/plot implemented
% - cleaned carabull/color to deal with same color string parameters
%   as MATLAB/plot
% - changed caramel/plot to work with carabull/plot instead of 
%   caramel/plot/PlotXY
% - backup carabao.v1l.bak119
% - cuk class created (derived from caramel)
% - trf/c2d method created
% - backup carabao.v1l.bak120
% - simulation of huck oscillations
% - looks already very good!
% - backup carabao.v1l.bak121
% - huck pump and huck converter implemented
% - backup carabao.v1l.bak122
% - good progress of huck shell
% - backup carabao.v1l.bak123
% - bug fixed in caramel/plot/CorePlot: did not plot bullets
% - backup carabao.v1l.bak124
% - phase cut converter V1 & V2
% - backup carabao.v1l.bak125
% - CARAVEL object implemented to deal with images
% - bug fixed in carabao/menu/Title
% - backup carabao.v1l.bak126
% - backup carabao.v1l.bak127
% - rearangements in huck/study.m
% - backup carabao.v1l.bak128
% - changed huck/study simulation loop into nested loops
% - backup carabao.v1l.bak129
% - new demo class CESAR created. To study images
% - carabao/plot/Basket added to plot all objects of basket
% - adaption of caramel/map to support mapping of 1D-vectors
% - CESAR shell is now a nice analysis tool
% - backup carabao.v1l.bak130
% - cesar/shell/Init modified to set drift and style settings
% - backup carabao.v1l.bak131
% - backup carabao.v1l.bak132
% - backup carabao.v1l.bak133
% - backup carabao.v1l.bak134
% - backup carabao.v1l.bak135
% - backup carabao.v1l.bak136
% - backup carabao.v1l.bak137
% - symmetrize spec and limit in caramel/category for scalar arguments
% - huck/study: basic phase angle control including Signal implemented
% - backup carabao.v1l.bak138
% - some labels for plot (huck/study/PlotBoost)
% - backup carabao.v1l.bak139
% - backup carabao.v1l.bak140
% - short before rewriting with timer callbacks
% - backup carabao.v1l.bak141
% - huck/SimuBP1 controls now boost signal - cool!
% - backup carabao.v1l.bak142
% - first time whole triac & boost control works
% - backup carabao.v1l.bak143
% - caramel/menu/PlotCb: update 'mode.plot' setting with actual plot mode
% - caramel/menu/Plot: setup of Plot menu delegated to caramel/plot/Setup
% - caramel/menu/PlotCb: obsoleted
% - caramel/plot/Plot: renamed to PlotBasket
% - caramel/plot/Plot added as Plot callback
% - caramel/plot/Setup added to buildup Plot menu (using callback Plot)
% - backup carabao.v1l.bak144
% - backup carabao.v1l.bak145
% - caramel/rapid updated to deal with new style of plot method
% - backup carabao.v1l.bak146
% - backup carabao.v1l.bak147
% - changed View/Style/Digits menu to offer 0...4 digits for statistic
%   labels (caramel/menu/Style)
% - backup carabao.v1l.bak148
% - backup carabao.v1l.bak149
% - atan bug fixed in boost/study/Luenberger
% - backup carabao.v1l.bak150
% - boost/study/study7 rewritten to work with tick/tock engine
% - backup carabao.v1l.bak151
% - boost/engine  method added - running!
% - backup carabao.v1l.bak152
% - boost/controller  method added - running!
% - backup carabao.v1l.bak153
% - boost/engine and boost/core methods added
% - everything running nicely!
% - backup carabao.v1l.bak154
% - adding some comments to boost/controller
% - adding some comments to boost/engine
% - adding some comments to boost/core
% - backup carabao.v1l.bak155
% - boost/plot/Phase: data aspect ratio 1:1 set
% - backup carabao.v1l.bak156
%
% * bug: shell(o) crashes if o is an image object
% * bug: style.overlays mode should be 'time' by default and special
%   setup for 'index' in caramel and cigarillo
% * bug in cigarillo/shell/Export: enable/disable does not work!
%
end
