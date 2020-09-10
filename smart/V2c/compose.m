function smo = compose(smo,list,dim,pts,verbose,nanmode,tslice)
%
% COMPOSE  Compose parsed list to a SMART object
%
%             smo = compose(smo,list,dim)  % verbose=0, nanmode=1, tslice=5
%             smo = compose(smo,list,dim,verbose,nanmode,tslice);
%
%          Arguments
%             smo:      SMART object, contains all relevant data
%             list:     list of parsed data
%             dim:      data dimension (typical 2..4)
%             points:   description of points dimension structure
%             verbose:  verbose level; level dependent echo trace messages
%             nanmode:  data gaps to be filled with zeros (nanmode = 0/1)
%                       If nanmode is a cell array, then it means time
%                       slice collection mode
%             tslice:   max length of a timeslice
%
%
%             save(obj,list,dim,0,1,5);   % typical call
%
   profiler('compose',1);

   VERBOSE_INFO = 1;       % print initial info for parsing
   VERBOSE_ELLAPSED = 1;   % verbose level for printing ellapsed time
   
   tstart = clock;         % read out clock

   if (nargin < 2) error('compose(): at least 2 args expected!'); end
   if (nargin < 3) dim = 4; end
   if (nargin < 4) pts = 0; end
   if (nargin < 5) verbose = 0; end
   if (nargin < 6) nanmode = 1; end
   if (nargin < 7) tslice = 5;  end

   dirty = 0;        % dirty flag
   t0 = [];          % init
   t = 0;            % current time

   collect = [];                        % init collection of symbol indices
   record = [];                         % data record for time slice
   table = '';                          % empty symbol table
   system = [];                         % empty table for system numbers

   data = addrecord(pts);               % initialize data
   
      % Loop to compose SMART data from list
      
   for (listidx = 1:length(list))    % repeat for all records
          
         % Control is done by parsed list
         % fetch each entry from the list and process ...
            
      entry = list{listidx};
      sym = entry{1};  val = entry{2};  tnew = entry{3};  snmb =entry{4};
      if (verbose >= 2) 
          token = entry{5};  val = [val(:); NaN; NaN; NaN; NaN]; 
          fprintf([sym,' %14.8f %14.8f %14.8f %14.8f   @%14.8f  %g  %s\n'],...
             val(1),val(2),val(3),val(4),tnew,snmb,token);
      end

      numbers = [val(:);iif(nanmode,NaN,0)*zeros(dim,1)]; 
      numbers = numbers(1:dim);   % get numbers, add some 0's or NaN's
         
         % check if symbol provided by the table
         % if no: print warning; if yes: continue processing
         
      idx = match(sym,table);   % is this a symbol we can deal with?
         
      if isempty(idx)
         idx = size(table,1) + 1;
         table(idx,1:length(sym)) = sym;     % mind new symbol in table
         system(idx) = snmb;                 % mind system number in table
      end
      
         % Do we have to flush the data record. This has to be done when
         % either symbol time is out of time slice [t,t+tslice] or in case
         % of symbol clash
            
      clash = ~isempty(find(collect==idx));
      if (tnew > t + tslice | clash)
         if (dirty)
            data = addrecord(data,t,record,nanmode,verbose);
            if (nanmode)
               record = record * NaN;
            end
            collect = [];                  % reset symbol collection
         end
         dirty = 0;                        % reset dirty flag
         t = tnew;
      end
      
         % add symbol to collection
         % add symbol data to record
            
      if ~isempty(idx)
         record(idx,:) = numbers';
         collect = [collect,idx];          % add symbol to collect
         dirty = 1;                        % new data added to record
      end
   end % repeat for all records
   if (dirty)
      data = addrecord(data,t,record,nanmode,verbose);
   end
   data = addrecord(data,table,system);    % trim data
   smo = smart('#BULK',[],data);           % create SMART object for bulk 
   
   tell = etime(clock,tstart);             % ellapsed time in seconds
   if (verbose >= VERBOSE_ELLAPSED)
      fprintf('Ellapsed time for composing bulk data: %g s\n',tell);
   end

   profiler('compose',0);
   return
   
%==========================================================================
% auxillary functions
%==========================================================================
   
function  data = addrecord(data,t,record,nanmode,verbose)
%   
% ADDRECORD  Add new record to bulk data
%
%               data = addrecord(points);                  % init data
%               data = addrecord(data,table,system);       % complete data
%               data = addrecord(data,t,record,verbose)    % add record
%
   VERBOSE_ALIVE = 1;                     % each Nth record to trace!
   MODULUS_ALIVE = 200;                   % each Nth record to trace!

   if (nargin == 1)                       % then init data
      points = data;
      data = [];                          % initialize data
      data.kind = 'bulk';                 % data is of kind bulk
      data.t = [];                        % time stamps
      data.bulk = [];                     % bulk data(x,y,z,theta)
      data.cnt = 0;                       % number of records added
      data.dim = NaN;                     % dimension undefined
      data.points = points;               % points description
      return
   elseif (nargin == 3)                   % trim & complete data
      [m,n] = size(data.bulk);
      if (m > data.cnt)
         data.bulk(data.cnt+1:m,:) = [];  % trim bulk data
         data.t(data.cnt+1:m) = [];       % trim time stamps
      end
      
      list = {};
      table = t;                          % here arg2 is symbol table
      system = record;                    % here arg3 is system
      for (i=1:size(table,1))
         sym = table(i,:);
         idx = find(sym==0);
         sym(idx) = [];
         list{i} = sym;
      end
      data.symbols = list;                % add symbol table
      data.system = system;               % add system number table
      return
   end
   
      % extract dimension. Dimension must stay constant during repeated
      % calls of addrecord()
      
   dim = size(record,2);
   if (isnan(data.dim))
      data.dim = dim;                   % can initialize as long undefined
   end
   
   if (dim ~= data.dim)
      error('addrecord(): dimension must be left unchanged during subsequent calls!');
   end

      % now we can flatten record to a single row which is planned
      % to be appended later to data.bulk
      
   row = record'; row = row(:)';        % convert record to single row
   
      % if record size has getting bigger we have to blow up
      % existing size of data.bulk. Dependig on 'nanmode' we
      % will append zero columns or NaN columns ...

   [mb,nb] = size(data.bulk);
   nr = length(row);

   if (mb <= data.cnt)
      N = 50;                            % blow up by N = 50
      data.bulk(mb+N,nr) = 0;            % blow up data.bulk
      data.t(mb+N,1) = 0;                % blow up data.t
   end
   
   if (nb < nr & mb > 0)
      columns = zeros(mb,nr-nb);
      if (nanmode) columns = columns*NaN; end
      data.bulk(1:mb,nb+1:nr) = columns;
   end

      % now append time and flattened record to data
   
   data.cnt = data.cnt + 1;
   
   if (verbose >= VERBOSE_ALIVE)
      if (rem(data.cnt,MODULUS_ALIVE) == 0)
         fprintf('   add record #%g: t = %g\n',data.cnt,t);
      end
   end
   
   
   factor = 1000;                               % convert [mm] to [µm]
   data.t(data.cnt) = t;                        % add time
   data.bulk(data.cnt,1:nr) = row * factor;     % add flattened record

   return
   
%==========================================================================
   
function out = match(arg1,arg2)
%
% MATCH   Get match index of a label string
%         Return 0 if not found!
%
%         Slow lookup: (search needs 8 ms for list length of 30)
%
%            idx = match('vA1',list)    % e.g. list = {'uM1','uM2','pU','vA1','vA2'}
%
%         Quick lookup:  (search needs 0.9 ms for list length of 30)
%
%            table = match(list)        % calculate match table from list
%            idx = match('vA1',table)   % e.g. table=['uM1';'uM2';'pU ';'vA1';'vA2']
%            idx = match('vA2',table)
%

   if (nargin == 1) % then calculate match table
      list = arg1;
      [m,n] = size(list);
      
      if (m == 1) list = list'; m = n; end
      
      table = [];
      for(i=1:m)  % for all rows
         lab = list{i,1};
         l = length(lab);
         table(i,1:l) = lab;
      end
      out = table;      
      
   else % calculate match index
      str = arg1;     % string to match
      table = arg2;   % match table
      
      if iscell(table)
         table = match(table);  % convert match table from match list
      end
      [m,n] = size(table);
      
      if length(str) > n
         idx = [];   % not found
      else
         search = 0*table(1,:);
         search(1:length(str)) = str;
         strtab = setstr(ones(m,1)*search);
         idx = find(~sum(abs(table-strtab)'));
      end
      out = idx;
   end
   
% eof      
   
