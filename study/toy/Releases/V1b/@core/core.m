function out = core(typ,par,dat)
%
% CORE   Core object constructor
%
%    CORE objects are composed of data and parameters. They provide power-
%    ful mechanisms based on SET/GET methods to access data and parameters.
%
%    CORE objects provide mechanisms for creation of menu shells. The CORE
%    object class serves usiually as a base class for other derived target
%    classes.
%
%    1) The simplest call to constructor CORE will create a plain CORE
%    object of type 'tutorial' with empty parameters and data. As the
%    there are no output arguments are applied a menu shell with tutorial
%    menu items will be launched .
%
%       core                           % launch CORE tutorial menu shell
%
%    2) Standard way of CORE object construction with 3 arguments. First
%    arg (typ) specifies the type of the CORE object. Second arg (par)
%    needs to be a struct and provides thew parameters. Finally the third
%    arg (dat) - also a struct - is for the CORE object's data.
%
%       obj = core(typ,par,dat);       % constructor with parameters & data
%       obj = core('generic',par,dat); % generic object with param. & data
%       obj = core('data',par,dat)     % data object with parameter & data
%
%    3) Providing less than 3 input args causes the use of defaults, which
%    means empty data or parameter  structures, or even that the default
%    type 'generic' has to be applied.
%
%       obj = core(typ,par);          % constructor with empty data
%       obj = core(typ);              % type based CORE object construction
%       obj = core;                   % typ = 'generic', no param. & data
%
%    4) Instead of structures also CORE objects can be applied for any of
%    the arguments. This will just mean that the proper values will be
%    taken from the corresponding objects.
%
%       ob1 = core('fee',par1,dat1);
%       ob2 = core(ob1,par2,dat2);    % typ = 'fee';
%       ob2 = core('foo',ob1,dat2);   % par = par1;
%       ob2 = core('foo',par2,ob1);   % dat = dat1;
%       ob2 = core(ob1,ob1,ob1);      % same as ob2 = core('fee',par1,dat1)
%
%    If the first argument is a derived CORE object then the CORE object to
%    be constructed will be the derived object.
%
%       obj = core(derived)           % extract CORE object from derived 
%
%    5) There a special forms for the creation of data objects, which are
%    CORE objects of type 'data'. These special forms are all characterized
%    by the first argument not being a string and not being an object.
%
%    Data objeczt creation from vector sets
%
%       obj = core(xy)                 % construct from vector set
%       obj = core({t,xy})             % construct from vector set
%
%    Data creation from image & colormap
%
%       obj = core(img)                % construct from image
%       obj = core({img,map})          % construct from image & cmap
%
%    6) A call to CORE without assignment of output arguments applies
%    implicitely applies the MENU method which opens a figure with pre-
%    defined rolldown menus.
%
%       core                   % same as core('tutorial')
%       core('tutorial')       % open a figure with tutorial menus
%       core('generic')        % open a figure with a FILE menu
%       core('test')           % open a figure with test menus
%       core('simple')         % open a figure with simple demo menus
%       core('advanced')       % open a figure with advanced demo menus
%
%    Applied to a derived object a call to CORE accesses the parent
%    (or grand parent+ object)
%
%    Example 1:
%       obj = type(core,'empty')      % menus: 
%       obj = type(core,'generic')    % menus: file
%       obj = type(core,'test')       % menus: file, test
%       obj = type(core,'toolbox')    % menus: file, tools
%       obj = type(core,'simple')     % menus: file, simple
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
%       camera       camera operations
%       cls          clear screen
%       check        check menu functionality
%       choice       choice menu functionality
%       cons         construct a list
%       control      animation loop control
%       dark         set dark screen
%       default      define default setting
%       either       provide proper default
%       gfo          get figure object
%       gso          get screen object
%       iif          inline if
%       ket          check if ket or select bra vector from a space
%       match        string matches a list of strings?
%       profiler     profiler function
%       rd           round function
%       ready        change to ready state
%       setting      get/set global setting
%       some         similar to ~isempty()
%       vargfix      fix varargs after recursive passing down of varargs
%
%    Methods:
%       access       access parent object from a derived object
%       arg          get object's argument during callback
%       ball         plot sphere of a ball
%       caller       get name of calling function (or caller of callers)
%       cbsetup      callback setup for cbinvoke
%       check        add check functionality to menu item
%       cleanup      cleanup object
%       click        setup mouse button click callback
%       data         get/set shell object's data structure
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
%       kid          get kid class object
%       launch       launch shell of an object
%       menu         setup shell menu & handle menu callbacks
%       mitem        add a roll down menu item, or retrieve uimenu handle
%       mount        mount a root menu item in prepared menu structure
%       open         open .MAT file (load & launch)
%       option       get/set option
%       parent       -get parent class object of a derived object
%       plotinfo     setup/popup plot info
%       profiling    -start/stop profiling
%       propagate    propagate a menu callback to parent
%       provide      -provide parameter setting if parameter is empty
%       radio        add radio button bar
%       refresh      refresh graphics or setup refresh callback
%       save         save object
%       set          set parameter of a CORE object
%       shortcuts    get shortcuts for menu setup
%       stop         stop current loop/task?
%       structure    extract object's data structure
%       text         plot text
%       terminate    clear stop flag
%       timer        animation timer control
%       toolbox      toolbox administration
%       translate    translate an option
%       tutorial     open a tutorial menu shell
%       upath        convert to UNIX style path
%       update       update graphics
%       version      version/known bugs of CORE object class
%       wait         wait for animation timer tick
%
%    Try also this:
%
%       core toolbox     % create & open a toolbox shell
%       core tutorial    % create & open a tutorial shell
%       core test        % create & open a test shell
%
%    See also: GET, SET, DISPLAY, DISP, DERIVE
%
   if (nargin == 0 && nargout > 0) % be fast: create a generic CORE object
      obj.type = 'generic';        % this will take only 0.05 msec
      obj.parameter = [];
      obj.data = [];
      out = class(obj,'core');     % convert structure to class object
      return
   end
   
% Step 1: without input arguments type will either be 'generic' or
% 'tutorial'. This depends on the number of output args. If the number of
% output args is zero subsequently a tutorial menu shell will be launched

   typ = eval('typ','''generic''');
   par = eval('par','[]');
   dat = eval('dat','[]');
   
% Step 2: any argument of type object will be converted. If typ is a CORE
% object or derived CORE object then the CORE object will be extracted

   if isobject(par)
      par = get(par);
   end

   if isobject(dat)
      dat = data(dat);
   end
   
   if isobject(typ)
      if isa(typ,'core')
         out = Extract(typ,par,dat);
         return
      else
         typ = type(typ);
      end
   end

% Step 3: class object creation

   obj.type = typ;
   obj.parameter = par;
   obj.data = dat;
   
   obj = Process(obj);          % post processing depending on type

   assert(isa(obj.type,'char'));
   obj = class(obj,'core');     % convert structure to class object

% launch a figure with menu when nargout = 0;

   if (nargout == 0)
      launch(obj);              % launch figure with menu
   else
      out = obj;                % otherwise assign obj to output arg
   end
   
   return
end

%==========================================================================
% Check a Condition
%==========================================================================

function obj = Extract(obj,par,dat) 
%
% EXTRACT   Extract CORE object from a derived core object and overwrite
%           with parameters and data (if non-empty)
%
   obj = access(obj,'core');      % parent access
   if ~isempty(par)
      obj = set(obj,par);
   end
   if ~isempty(dat)
      obj = data(obj,dat);
   end
   return
end

%==========================================================================
% Process Data
%==========================================================================
   
function obj = Process(obj)
%
% PROCESS   Post process data
%
% redefine typ to an image object if detected

   if ischar(obj.type)
      return                     % everything OK
   end
   
% otherwise type needs to be interpreted as data

   dat = obj.type;
   obj.type = 'data';
   
   if isa(dat,'uint8')
      obj.typ = 'image';
   elseif iscell(dat)
      if isa(dat{1},'uint8')
         obj.type = 'image';      
      end
   end

   switch class(dat)
       case 'double'
          if (~isempty(dat))
             obj.data.format = '#DOUBLE';
             obj.data.x = [];
             obj.data.y = dat;
          end
       case 'uint8'
          obj.data.format = '#IMAGE';
          obj.data.image = dat;
          obj.data.cmap = [];       % no color map provided  
          
       case 'cell'
          switch obj.type
             case 'data'
                if (length(dat)==2)
                   x = dat{1};  y = dat{2};
                elseif (length(dat)==3)
                   x = dat{1};  y = dat{2};  yf = dat{3};
                else
                   error('2 or 3 element list expected for data!');
                end

                check(strcmp(class(x),'double'),'1st list element of arg1 expected to be of class ''double''!'); 
                check(strcmp(class(y),'double'),'2nd list element of arg1 expected to be of class ''double''!'); 
                obj.data.format = '#DOUBLE';
                obj.data.x = x;
                obj.data.y = y;
                if  (length(dat) >= 3)
                   obj.data.yf = yf;
                end

             case 'image'
                check(length(dat)==2,'2 element cell array expected for arg1!'); 
                img = dat{1};  cmap = dat{2};
                check(isa(img,'uint8'),'1st element of arg1 must be uint8 for #IMAGE format!'); 
                check(size(cmap,2)==3,'3 columns expected for colormaps (#IMAGE format)!'); 
                obj.dat.format = '#IMAGE';
                obj.dat.image = img;
                obj.dat.cmap = cmap;
                
             otherwise
                error('data or image expected if arg1 is a cell array!');
          end
          
       case 'struct'
          obj.data = dat;
          
       otherwise
          error(['core(): data type ',class(dat),' not supported!']);
   end
   return
end

%==========================================================================
% Check a Condition
%==========================================================================

function check(condition,errmsg) 
%
% CHECK    Check condition to be true. If failing then invoke error with
%          specified error message.
%
   if (~condition)
      error(['smart(): ',errmsg]);
   end
   return
end

