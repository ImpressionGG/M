function o = trace(o,varargin)
% 
% TRACE   Deal with trace type objects
%
%    Check if object is a trace type CARALOG object, or setup as a
%    trace type object. The TRACE method overwrites all data as well as
%    the existing type information with 'trace', and it provides 'shell'
%    method as launch method (if not initialized).
%
%       ok = trace(o)                  % check if trace object
%
%       o = trace(o,'x',x,'y',y)       % make a trace object
%       o = trace(o,t,'x',x,'y',y)     % make a trace object with time info
%
%    CARALOG trace data can be in stream type form (sequence of scalars)
%    The data can be indexed by index numbers or by time stamps. CARALOG
%    stream type traces has a specific data representation and several
%    CARALOG methods are specialized on trace typed data.
%
%    See also: CARALOG, PLOT, LABEL, CONFIG, CATEGORY, SUBPLOT
%
   while (nargin == 1)                % check nargin
      %o = ~container(o) && isequal(o.type,'trace');
      o = ~container(o);
      return
   end
%
% otherwise investigate the syntax of the argin list
%
   list = varargin;
   if (length(list) == 1 && iscell(list{1}))
      list = list{1};
   end
   
   ok = isa(list{1},'char') && ~is(list{1},'bulk');
   if ~ok && (length(list) == 1)
      arg = list{1};
      ok = (isa(arg,'double') && min(size(arg)) == 1);  % time vector
   elseif ~ok && (length(list) >= 3)
      ok = isa(list{1},'double') && isa(list{2},'char');
   end
%
% if ok setup as a stream object, otherwise generate an error
%
   if ok
      o = Trace(o,list);
   else
      error('bad calling syntax!');
   end
end

%==========================================================================
% Local Functions
%==========================================================================

function o = Trace(o,list)            % Setup Trace Type Object      
%
% TRACE   Make a trace type object
%
%    Overwrites all data, also type info by 'trace'.
%    Launch method 'shell' is provided, if not initialized.
%
%       o = Trace(o,{'a',a,'b',b})    % without time info
%       o = Trace(o,{t,'a',a,'b',b})  % with time info
%
   i0 = 1;                             % 1 extra arg (arg1)
   dat.time = [];
   
   if isa(list{1},'double')
      dat.time = list{1};
      list(1) = [];                    % delete first list element
      i0 = 2;                          % 2 extra args (arg1,arg2)
   end
   
   if (rem(length(list),2) ~= 0)
      error('arglist (arg3) must consist of pairs (symbol,vset)!');
   end

   sizes = [0 0];  
   cfg = {};                           % init config list
   
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


% complete config,data and launch method

   o = data(o,dat);                    % overwrite data
   if o.is(o.type,'shell')
      o = type(o,'trace');             % set 'trace' type
   end
   o = launch(o,'shell');              % provide launch function
   o = config(o,cfg);                  % default configuration
end
