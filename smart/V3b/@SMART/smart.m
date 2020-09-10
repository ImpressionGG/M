function obj = smart(format,parameter,data)
% 
% SMART   Create a SMART Object (constructor)
%
%            obj = smart(format,parameter,data)
%
%         Alternative constructor calls
%
%            obj = smart                % create generic SMART object
%            obj = smart(kind)          % create a SMART of specified kind
%            obj = smart('#GENERIC');   % same as obj = smart
%            obj = smart(obj)           % copy constructur
%
%         Creating SMART Data Objects 
%
%            obj = smart('#DATA',parameter,xy)   % standard way of construction
%
%         Creation from vector sets
%
%            obj = smart(xy)                     % construct vom vector set
%            obj = smart({t,xy})                 % construct vom vector set
%
%         Adding Parameters
%
%            obj = smart(xy,parameter)           % add params by structure
%         
%            obj = smart(xy,object)              % add params from object
%            obj = smart({t,xy},object)          % add params from object
%            obj = smart({t,xy},gcfo)            % add options from gcfo
%
%
%         Public Functions
%         ================
%
%         Figure
%
%            ASPECT     set symmetric aspect ratio
%            BRIGHT     set to bright background
%            CLOSEALL   close all figures
%            DARK       set to dark background
%            RESIZE     resize figure to default size
%            TEXTBOX    used to label figures
%
%         Handle Graphics
%
%            CHILD      get children of a handle graphics object
%            FILLR      draw filled rectangle
%            GTREE      Print graphics tree
%            HLINE      draw horizontal lines
%            VLINE      draw vertical lines
%
%         Change Mouse Pointer
%
%            READY      set arrow mouse pointer (indicating ready state)
%            BUSY       set watch mouse pointer (indicating busy state)
%
%         Smart Functions
%
%            DEG        factor to convert degrees to radians
%            IIF        inline if
%            INDEX      index range of vector or matrix
%            LAST       last element of a vector
%            MDISP      formatted display matrix
%            ONE        proper dimensioned matrix containing ones 
%            ZERO       proper dimensioned matrix containing zeros
%            STRUCTURE  create a structure (similar to STRUCT)
%
%         Data  Treatment
%
%            DRIFT      Calculate drift values of data
%            FILTER1D   One dimensional filtering, several modes
%            FILTER2D   Two dimensional filtering, several modes
%
%         Data Saving
%
%            SAVEDATA   save data to M-file
%
%         Smart Objects
%         =============
%
%         Smart Methods
%
%            SMART      constructor
%            CYCLIST    cyclical argument list
%            DATA       retrieve SMART data
%            DEFAULT    provide default figure/menu setting
%            DISPLAY    display method
%            FILTER     option based filter application to data
%            FIELD      get object's field (addressed by field name)
%            FILTER     option based filter application to data
%            FORMAT     get object's format  
%            GET        get object's parameter
%            INFO       get object info
%            KIND       get object kind
%            *menu         % open figure with machine analysis menu
%            OPTION     get (menu selected) option during a figure/menu callback 
%            PLOT         % plot function with various options 
%            PROPERTY   get object's properties
%            PROFILE    colllect/display profiling info
%            SAVE       save SMART object to file
%            SET        set object's parameter
%            SETTING    get/set menu controlled settings
%            TOOLBOX    SMART toolbox control functions
%
%          Generic constructor (used to do access methods in construction
%          phase of object):
%
%             obj = smart('#GENERIC');  % SMART generic object
%             obj = smart('#DATA');     % SMART data object
%
%          See also SMART/TOOLBOX SMART/CRASH

% first of all check syntax for copy constructor

   if (nargin == 1)
      if (isa(format,'struct'))    % copy constructor
         obj = format;             % construct from object structure
         obj = class(obj,'smart');
         return
      end
   end

% handle the calling conventions for SMART data object construction

   if (nargin == 1 || nargin  == 2)
      if (~ischar(format))     % expect cell array or vector set as arg1
          data = format;       % arg1 is the data arg
          format = '#DATA';    % and a DATA object has to be constructed
      end
   end
   
% setup arg defults, if args not provided
          
%    eval('format;','format = ''#GENERIC'';');
   if ~exist('format','var'),
      format = '#GENERIC';
   end
%    eval('parameter;','parameter = [];');
   if ~exist('parameter','var'),
      parameter = [];
   end
%    eval('data;','data = [];');
   if ~exist('data','var'),
      data = [];
   end

% if parameter is object instead of struct then extract params from object

   if (isobject(parameter))
      pobj = parameter;              % meaning of arg2 is: object
      parameter = get(pobj);         % get object's parameter
   elseif (~(isa(parameter,'struct') || isempty(parameter)))
      error('smart(): struct or object expected for arg2!');
   end
   
   obj.format = format;
   obj.parameter = parameter;

% post process data

   switch class(data);
       case 'double'
          obj.data.kind = 'double';
          obj.data.x = [];
          obj.data.y = data;
          
       case 'cell'
          if (length(data)==2)
             x = data{1};  y = data{2};
          elseif (length(data)==3)
             x = data{1};  y = data{2};  yf = data{3};
          else
             error('2 or 3 element list expected for data!');
          end
              
          check(strcmp(class(x),'double'),'1st list element of arg1 expected to be of class ''double''!'); 
          check(strcmp(class(y),'double'),'2nd list element of arg1 expected to be of class ''double''!'); 
          obj.data.kind = 'double';
          obj.data.x = x;
          obj.data.y = y;
          if  (length(data) >= 3)
             obj.data.yf = yf;
          end
          
       case 'struct'
          check(isfield(data,'kind'),'struct argument requires ''kind''!');
          obj.data = data;
          
       otherwise
          error(['smart(): data type ',class(data),' not supported!']);
   end

% create class object
   
   obj = class(obj,'smart');  % convert to class object

   return
   
%==========================================================================
% Auxillary Function

function check(condition,errmsg) 
%
% CHECK    Check condition to be true. If failing then invoke error with
%          specified error message.
%
   if (~condition)
      error(['smart(): ',errmsg]);
   end
   return

% eof   