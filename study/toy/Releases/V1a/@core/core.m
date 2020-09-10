function out = core(varargin)
%
% CORE   Core object constructor
%
%    CORE objects are composed of data and parameters. They provide power-
%    ful mechanisms based on SET/GET methods to access data and parameters.
%
%    CORE objects provide mechanisms for creation of menu shells. 
%
%    The CORE object class serves usiually as a base class for other
%    derived target classes.
%
%       obj = core;                    % construct a generic core object
%       obj = core(typ);               % type based CORE object construction
%       obj = core(typ,par,dat);       % constructor with parameters & data
%
%       obj = core('generic',par,dat); % constructor with parameters & data
%       obj = core(par,dat);           % same as above
%
%    A core object can be provided with a type
%
%       obj = type(core,'toolbox');   
%
%    Optionally a variable parameter definition list can be specified
%
%       obj = core('title',title,'comment',comment);
%
%    A call to CORE without assignment of output arguments applies
%    the menu() method and opens a figure with specified menus:
%
%       core                   % construct & open figure for generic shell
%       type(core,'generic')   % construct & open figure for generic shell
%       type(core,'toolbox')   % construct & open figure with toolbox menus
%
%    Applied to a derived object a call to CORE accesses the parent
%    (or grand parent+ object)
%
%       obj = core(derived)       % access CORE object from derived
%
%    Example 1:
%       obj = type(core,'empty')      % menus: 
%       obj = type(core,'generic')    % menus: file
%       obj = type(core,'test')       % menus: file, test
%       obj = type(core,'toolbox')    % menus: file, tools
%       obj = type(core,'play')       % menus: file, play
%
%    Example 2:
%       title = 'Playing around';
%       comment = {'Don''t worry,','just play arround'};
%
%       obj = core('title',title,'comment',comment);
%       menu(obj);                     % setup menu shell
%
%    Example 3:
%       menu(type(core,'play'));       % open a menu shell to play
%
%    Global Functions
%       assoc        look-up a value from an assoc list
%       bra          check if bra or select bra vector from a space
%       bright       set bright screen
%       busy         change to busy state
%       call         compose menu handler call statement
%       cls          clear screen
%       cons         construct a list
%       dark         set dark screen
%       default      define default setting
%       either       provide proper default
%       gfo          get figure object
%       gso          get screen object
%       iif          inline if
%       ket          check if ket or select bra vector from a space
%       match        string matches a list of strings?
%       profiler     profiler function
%       ready        change to ready state
%       setting      get/set global setting
%       some         similar to ~isempty()
%       vargfix      fix varargs after recursive passing down of varargs
%
%    Methods:
%       access       -access parent object from a derived object
%       arg          get object's argument during callback
%       bulk         -get bulk data of a SHELL object
%       caller       get name of calling function (or caller of callers)
%       cbsetup      callback setup for cbinvoke
%       cbreset      -callback reset for cbinvoke
%       cbinvoke     -invoke a callback which has been cbsetup'ed before
%       data         get/set shell object's data structure
%       derive       supporting func. for derived construction from CORE
%       disp         display contents of a shell object in some detail
%       dispatch     dispatch command line arguments
%       display      display shell object in compact style
%       exec         -execute M-file
%       format       set/get format of shell object
%       get          get parameter of a CORE object
%       init         -initialize args
%       info         info text for shell object
%       insist       -insist on expected object class
%       invoke       invoke a callback function
%       integrity    -recover object integrity, if required
%       keyhit       default handler for key hit
%       keypress     -setup key-press-function
%       kid          -get kid class object
%       menu         setup shell menu & handle menu callbacks
%       mount        mount a root menu item in prepared menu structure
%       option       get/set option
%       parent       -get parent class object of a derived object
%       plotinfo     setup/popup plot info
%       profiling    -start/stop profiling
%       propagate    propagate a menu callback to parent
%       provide      -provide parameter setting if parameter is empty
%       set          set parameter of a CORE object
%       shortcuts    get shortcuts for menu setup
%       stop         stop current loop/task?
%       text         plot text
%       terminate    clear stop flag
%       timer        animation timer control
%       toolbox      toolbox administration
%       translate    -translate an option
%       tutorial     open a tutorial menu shell
%       wait         wait for animation timer tick
%
%    Try also this:
%
%       core toolbox     % create & open a toolbox shell
%       core tutorial    % create & open a tutorial shell
%       core test        % create & open a test shell
%
%    See also: GET, SET, DISPLAY, DISP
%
   varargin = vargfix(varargin);
   
   % Below code is replaced by upper varargfix call
   %
   % if (length(varargin) == 1)     % check calling convenience
   %    if (iscell(varargin{1}))    % for handing over varargin list
   %       varargin = varargin{1};  % remove one level!
   %    end
   % end
   
   if (length(varargin) == 0)
      if (nargout == 0)
         varargin = {'tutorial'};  % if call to constructor without any args
      else
         varargin = {'generic'};
      end
   end
   
      % length always >= 1 now!
      
   typ = varargin{1};
   
      % now varargin is handeled
      % continue with the real stuff
      
   if isa(typ,'core')
      out = access(typ,'core');    % parent access
      return
   end

   if isa(typ,'char')
      varargin(1) = [];    % ok, good argument
   else
      typ = 'generic';
   end

% setup predefined menu list items depending on format

   list = {};  title = '';
   switch typ
      case 'empty'
         list = {};
      case 'generic'
         list = {'file'};  title = 'generic';
      case {'toolbox'}
         list = {'file','tools'};  title = 'Toolbox Shell';
      case {'play'}
         list = {'file','play'};   title = 'A Shell to Play';
      case {'test'}
         list = {{'test'},'file','test','info'};  title = 'Test Shell';
      case {'tutorial'}
         list = {{'tutorial'},'file'};   title = 'Core Object Tutorial';
   end
   
   obj.tag = '';
   obj.class = mfilename;                % class core!
   obj.parameter.title = title;
   obj.parameter.comment = {};
   obj.parameter.menu = list;            % list of menus to be setup
   obj.type = typ;
   obj.data.format = '#';
   
% overwrite parameter & data with provided arguments when arg2 is a struct

   if (eval('(isstruct(varargin{1}) || isempty(varargin{1}))','0'))
      obj.parameter = varargin{1};
      obj.data = eval('varargin{2}','obj.data');
   end
   
   obj = class(obj,'core');     % convert structure to class object

% overwrite parameter with provided arg settings when arg2 is a string
   
   if eval('ischar(varargin{1})','0')
      obj = set(obj,varargin);   % set parameters
   end
   
% apply default handler when nargout = 0;

   if (nargout == 0)
      handle(obj);
   else
      out = obj;    % otherwise assign obj to output arg
   end
   
   return
   
%eof   
   