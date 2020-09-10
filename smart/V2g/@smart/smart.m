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
%            obj = smart(xy)                     % construct from vector set
%            obj = smart({t,xy})                 % construct from vector set
%
%         Creation from image & colormap
%
%            obj = smart(img)                    % construct from image
%            obj = smart({img,map})              % construct from image & cmap
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
%            aspect     set symmetric aspect ratio
%            call       create a callback for uimenu() calls
%            cls        clear screen
%            bright     set to bright background
%            closeall   close all figures
%            dark       set to dark background
%            reinvoke   reinvoke a callback
%            resize     resize figure to default size
%            textbox    used to label figures
%            setting    get/set menu controlled settings
%
%         Handle Graphics
%
%            child      get children of a handle graphics object
%            fillr      draw filled rectangle
%            gtree      Print graphics tree
%            hline      draw horizontal lines
%            vline      draw vertical lines
%            color      convert text string into RGB color
%            style      change style (color,width) of a graphics object
%
%         Change Mouse Pointer
%
%            ready      set arrow mouse pointer (indicating ready state)
%            busy       set watch mouse pointer (indicating busy state)
%
%         Smart Functions
%
%            deg        factor to convert degrees to radians
%            either     return either non-empty value or default
%            iif        inline if
%            index      index range of vector or matrix
%            last       last element of a vector
%            match      indexed of matched entry in a list
%            mdisp      formatted display matrix
%            one        proper dimensioned matrix containing ones 
%            zero       proper dimensioned matrix containing zeros
%            structure  create a structure (similar to STRUCT)
%
%         Data Treatment
%
%            drift      Calculate drift values of data
%            filter1d   One dimensional filtering, several modes
%            filter2d   Two dimensional filtering, several modes
%            rd         Round to specified digits after comma
%
%         Data Saving
%
%            savedata   save data to M-file
%
%         Profiling
%
%            profiler   collect/display profiling info
%
%         Smart Objects
%         =============
%
%         Smart Methods
%
%            cyclist    cyclical argument list
%            data       retrieve SMART data
%            default    provide default figure/menu setting
%            display    display method
%            filter     option based filter application to data
%            field      get object's field (addressed by field name)
%            filter     option based filter application to data
%            format     get object's format  
%            get        get object's parameter
%            info       get object info
%            kind       get object kind
%            notes        % release notes
%            option     get (menu selected) option during a figure/menu callback 
%            plot         % plot function with various options 
%            property   get object's properties
%            save       save SMART object to file
%            set        set object's parameter
%            smart      constructor
%            subsref    subscript reference
%            symbol     Get symbol list of a bulk data object
%            toolbox    SMART toolbox control functions
%            version    get SMART toolbox version
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
      if (isa(format,'struct'))    % construct from object structure
         obj = migrate(format);    % data migration from SMART V1x to V2x
         obj = class(obj,'smart');
         return
      end
   end

% handle the calling conventions for SMART data object construction

   if (nargin == 1 || nargin  == 2)
      if (~isstr(format))      % expect cell array or vector set as arg1
          data = format;       % arg1 is the data arg
          format = '#DATA';    % and a DATA object has to be constructed
      end
   end

% setup arg defults, if args not provided
          
   eval('format;','format = ''#GENERIC'';');
   eval('parameter;','parameter = [];');
   eval('data;','data = [];');

% redefine format to an image object if detected

   if isa(data,'uint8')
      format = '#IMAGE';
   elseif iscell(data)
      if isa(data{1},'uint8')
         format = '#IMAGE';      
      end
   end

% if parameter is object instead of struct then extract params from object

   if (isobject(parameter))
      pobj = parameter;              % meaning of arg2 is: object
      parameter = get(pobj);         % get object's parameter
   elseif (~(isa(parameter,'struct') | isempty(parameter)))
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

       case 'uint8'
          obj.data.kind = 'image';
          obj.data.image = data;
          obj.data.cmap = [];       % no color map provided  
          
       case 'cell'
          switch format
             case '#DATA'
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

             case '#IMAGE'
                check(length(data)==2,'2 element cell array expected for arg1!'); 
                img = data{1};  cmap = data{2};
                check(isa(img,'uint8'),'1st element of arg1 must be uint8 for #IMAGE format!'); 
                check(size(cmap,2)==3,'3 columns expected for colormaps (#IMAGE format)!'); 
                obj.data.kind = 'image';
                obj.data.image = img;
                obj.data.cmap = cmap;
             otherwise
                error('#DATA or #IMAGE expected if arg1 is a cell array!');
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

function objstruct = migrate(objstruct)   
%
% MIGRATE   Migrate object's data structure from SMART V1x to SMART V2x
%           versions.
%
      % next statements are for compatibility. In earlier versions
      % we used the field 'gantry'. This has to be renamed to the
      % field name 'system'.

   if isfield(objstruct.data,'gantry')
      objstruct.data.system = objstruct.data.gantry;   % copy
      objstruct.data = rmfield(objstruct.data,'gantry');
   end
   return
          

% eof   