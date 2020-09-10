function o = create(o,varargin)
% 
% CREATE   Creating/managing CARALOG objects
%
%    CARALOG objects deal with trace data and vector sets. Trace data 
%    objects hold recordings of data which happen in time, e.g. sampled
%    measurements. Trace data can be in stream form (sequence of scalars)
%    or in vector set form (sequence of vectors). Both types can be indexed
%    by time or not. CARALOG Traces are a special kind of data and a
%    couple of CARALOG methods are specialized on dealing with trace data.
%
%       o = create(o,[x;y;z])          % create 'vset' trace (vector set)
%       o = create(o,t,[x;y;z])        % create 'vset' trace with time info
%
%       o = create(o,'x',x,'y',y)      % create 'stream' trace
%       o = create(o,t,'x',x,'y',y)    % create 'stream' trace w. time info
%
%    Traces are represented as CARALOG objects with special types.
%
%    1) Type 'vset' trace representing a vector set
%
%    Consider the following construction of the trace with according
%    internal storage
%
%       xyz = [x;y;z]                 % create vector set
%       o = create(o,xyz)             % create 'vset' trace (vector set)
%
%       data(o,'time')                % 1:size(xyz,2), just an index vector
%       data(o,'vset')                % the vector set xyz with trace data
%
%    Consider the alternative construction of the trace with explicite time
%    vector information
%
%       o = create(o,t,xyz)           % create 'vset' trace with time info
%
%       type(o)                       % object type = 'vset'
%       data(o,'time')                % the provided time vector t
%       data(o,'vset')                % the vector set xyz with trace data
%
%    2) Type 'stream' trace (data stream). The variables a and b represent
%    vector sets which have to be in dimensional integrity with the time
%    vector and with each other
%
%       t = 1:0.1:10;                  % time vector
%       a = 2.4*rand(3,length(t))      % data stream a
%       b = 1.8*rand(3,length(t))      % data stream b
%
%       assert(length(t)==size(a,2))   % dimensional integrity
%       assert(length(t)==size(b,2))   % dimensional integrity
%       assert(size(a,1)==size(b,1))   % dimensional integrity
%
%    First we construct a stream object without time information. The
%    several pairs like 'a',a or 'b',b represent vector sets with identi-
%    cal dimensions. The first argument of each pair is the symbolic name 
%    of the vector set. It can be any valid identifier except the symbol
%    'time'.
%
%       o = carma;                     % create empty CARMA object
%       o = create(o,'a',a,'b',b)      % create a 'stream' trace w/o time
%
%       type(o)                        % object type = 'stream'
%       data(o,'time')                 % 1:length(t), just an index vector
%       data(o,'a')                    % the vector set a
%       data(o,'b')                    % the vector set b
%
%    Now we add time information during construction
%
%       o = create(core,t,'x',x,'y',y) % create 'stream' trace with time
%
%       type(o)                       % object type = 'stream'
%       data(o,'time')                % the provided time vector t
%       data(o,'a')                   % the vector set a
%       data(o,'b')                   % the vector set b
%
%    What has been described up to here is minimum information which must
%    be provided during construction of a trace object. There is additional
%    information which can be added to a CARALOG object and will be stored
%    in the parameter part of a trace object (SIZES, LABEL). Consult the 
%    help for the methods listet in the 'See also' part!
%
%    See also: CARALOG, TRACE, SHELL, DATA, LABEL, SYMBOL, PLOT, MATRIX
%              SIZES, CONFIG
%
   if (nargin < 2)
      error('at least 2 input args expected!');
   end
   
   list = varargin;
   if (length(list) == 1 && iscell(list{1}))
      list = list{1};
   end
   
   stream = isa(list{1},'char') && ~is(list{1},'bulk');
   if ~stream && (length(list) == 1)
      arg = list{1};
      stream = (isa(arg,'double') && min(size(arg)) == 1);  % time vector
   elseif ~stream && (length(list) >= 3)
      stream = isa(list{1},'double') && isa(list{2},'char');
   end
%   
% The major arg syntax we are dealing with is shown below. He have to find
% out whether the syntax means a 'vset' or 'streams' construction 
%
%     o = trace(core,[x;y;z])       % create 'vset' trace (vector set)
%     o = trace(core,t,[x;y;z])     % create 'vset' trace with time info
%
%     o = trace(core,'x',x,'y',y)   % create 'stream' trace
%     o = trace(core,t,'x',x,'y',y) % create 'stream' trace w. time info
%
% We have to construct a 'stream' object if either arg2 is a string or
% if arg2 is a double and arg3 is a string. Otherwise we deal with a vset
% object.
%
   if stream
      o = Stream(o,list);
   elseif ischar(list{1}) && iscell(list{3})
      o = Bulk(o,list);
   else
      o = Vset(o,list);
   end
   o = launch(o,'shell');              % provide launch function
end

%==========================================================================
% Local Functions
%==========================================================================

function o = Stream(o,list)            % Setup Stream Typed Trace      
%
% STREAM   Create a 'stream' typed trace object
%
%             o = Stream(o,{'a',a,'b',b})    % without time info
%             o = Stream(o,{t,'a',a,'b',b})  % with time info
%
   i0 = 1;                                   % 1 extra arg (arg1)
   dat.time = [];
   
   if isa(list{1},'double')
      dat.time = list{1};
      list(1) = [];                          % delete first list element
      i0 = 2;                                % 2 extra args (arg1,arg2)
   end
   
   if (rem(length(list),2) ~= 0)
      error('arglist (arg3) must consist of pairs (symbol,vset)!');
   end

   sizes = [0 0];  
   cfg = {};                                 % init config list
   
   for (i=1:2:length(list)-1)
      sym = list{i};                         % stream symbol
      val = list{i+1};                       % value (vector set)
      
      if ~isa(sym,'char')
         error(sprintf('string expected for stream symbol (arg%g)!',i0+i));
      end
      if ~isa(val,'double')
         error(sprintf('double expected for vector set (arg%g)!',i0+i+1));
      end
      
      [m,n] = size(val);
      if any(sizes) && any(sizes~=[m,n])
         error('all vector sets must have equal sizes!');
      end
      sizes = [m,n];
      
      eval(['dat.',sym,' = val;']);
      cfg{end+1} = sym;
   end
  
% if time vector has not been provided we create an artificial time vector 
% based on indices

   if isempty(dat.time)
      dat.time = 1:n;
   end

   if any(sizes~=0)
      if (length(dat.time) ~= n)
         error('length of time vector must match length of data streams!');
      end
   end
   
% final integrity cross check with time vector and then replace object
% data by new built up data structure. Don't forget to set data type


% complete config and data

   o = type(o,'stream');                     % set stream type
   o = data(o,dat);                          % provide data
   %o = config(o,cfg);                       % default configuration
   return
end

function o = Bulk(o,list)              % Setup Bulk Typed Trace        
%
% BULK   Create a 'bulk' typed trace object
%
%             o = Bulk(o,{'bulk',any,tab})   % without time info
%
   if ~is(list{1},'bulk')
      error('bulk type expected for this kind of syntax!');
   end
   o = compose(o,list{3});       % compose the bulk object
   o = set(o,list{2});           % finally add parameters
   return
end

function o = Vset(o,list)              % Setup Vector Set Typed Trace  
%
% VSET  Create a 'vset' typed trace object
%
%          o = Stream(o,{[x;y;z]})           % without time info
%          o = Stream(o,{t,[x;y;z]})         % with time info
%
   if 1+length(list) < 2 || 1+length(list) > 3
      error('2 or 3 input args expected!');
   end
   
   dat.time = [];                            % let time always be 1st
   dat.vset = list{1};                       % without time info
   dat.time = 1:size(dat.vset,2);            % without time info
   
   if (length(list) >= 2)
      dat.time = list{1};                    % with time info
      dat.vset = list{2};                    % with time info
   end
  
% final integrity cross check with time vector and then replace object
% data by new built up data structure. Don't forget to set data type

   if (size(dat.time,2) ~= size(dat.vset,2))
      error('column numbers of time vector and vector set must match!');
   end
   
   o = data(o,dat);       
   o = type(o,'vset');                       % that's all
   return
end

function o = Special(o,varargin)       % Special Data Construction     
%
% SPECIAL   Special data construction
%
%    Special data construction: There a special forms of quick data con-
%    struction for vector sets. These special forms are all characterized
%    by the second argument not being a string.
%
%       o = caracook;                  % construct CARACOOK object
%       o = data(o,{xy})               % construct from vector set
%       o = data(o,{t,xy})             % construct from vector set
%
%       o = data(o,{img})              % construct from image
%       o = data(o,{img,map})          % construct from image & cmap
%
   dat = varargin{1};                  % object type is changed to 'data'
   o = type(o,'data');                 % or 'image', depending on args
   
   if isa(dat,'uint8')
      o.typ = 'image';
   elseif iscell(dat)
      if isa(dat{1},'uint8')
         o.type = 'image';      
      end
   end

   switch class(dat)
       case 'double'
          if (~isempty(dat))
             o.data.format = '#DOUBLE';
             o.data.x = [];
             o.data.y = dat;
          end
       case 'uint8'
          o.data.format = '#IMAGE';
          o.data.image = dat;
          o.data.cmap = [];       % no color map provided  
          
       case 'cell'
          switch o.type
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
                o.data.format = '#DOUBLE';
                o.data.x = x;
                o.data.y = y;
                if  (length(dat) >= 3)
                   o.data.yf = yf;
                end

             case 'image'
                check(length(dat)==2,'2 element cell array expected for arg1!'); 
                img = dat{1};  cmap = dat{2};
                check(isa(img,'uint8'),'1st element of arg1 must be uint8 for #IMAGE format!'); 
                check(size(cmap,2)==3,'3 columns expected for colormaps (#IMAGE format)!'); 
                o.dat.format = '#IMAGE';
                o.dat.image = img;
                o.dat.cmap = cmap;
                
             otherwise
                error('data or image expected if arg1 is a cell array!');
          end
          
       case 'struct'
          o.data = dat;
          
       otherwise
          error(['core(): data type ',class(dat),' not supported!']);
   end
   return
end
