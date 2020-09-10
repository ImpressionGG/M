function [o,chains] = schedule(o,stop,verbose)
% 
% SCHEDULE  Schedule a process
%      
%             obj = schedule(obj,stop)       % stop time
%             obj = schedule(obj,{steps})
%             obj = schedule(obj)            % steps = 10
%
%          See also   DISCO, DPROC
%
   knd = kind(o);
   dat = data(o);

% check arguments

   if (~strcmp(knd,'process'))
      error('Arg1 must be of kind process!');
   end
   
   if (nargin < 3)
      verbose = 0;
   end
   o.work.verbose = verbose;
   
   if (nargin < 2)
      steps = 10;
      stop = inf;
   else
      if (iscell(stop))
         steps = stop{1};
         stop = inf;
      else
         steps = inf;
      end
   end

% setup lists

   [m,n] = sizes(o);
   o.work.number = zeros(m,1);          % number of columns (elements in a chain)
   o.work.time = zeros(m,1);       % last stop time of chain i
   o.work.threads = {};
   
% setup matrix of process elements (table) and initialize state

   [o.work.table,o.work.elist,o.work.keys] = element(o);

% setup initial state and event dependencies, initialize sequences

   for (i=1:m)
      [obj,tstop] = run(o.work.table{i,1},0);
      o.work.state(i) = key(o,name(obj));
      o.work.sequence{i} = {obj};      % sequences are sucessively constructed
      o.work.time(i) = tstop;
      o.work.tail(i) = 0;
      o.work.number(i) = 1;
      [x,y] = points(obj);
      o.work.critical{i,1} = {{[i i],[0 tstop],[0 y(length(y))]}};
      o.work.critical{i,2} = {name(obj)};
   end
   
% setup dependence matrix

   for (i=1:length(o.work.elist))
      keylist = Depends(o,o.work.elist{i});
      depend{i} = keylist;
   end

     % start scheduling
     
   o = Schedule(o,steps,stop,depend);
   threads = o.work.threads;
   critical = o.work.critical;
   
   %fprintf('Stop\n');
   
   for (i=1:m)
      seqargs{i} = setp(element(o,i),'list',o.work.sequence{i});
   end
   
   text = getp(o,'text');
   o = process(dproc(name(o)),seqargs{:});
   o = setp(o,'threads',threads,'text',text,'critical',critical);
end

%==========================================================================
% Helper Functions
%==========================================================================

function o = Schedule(o,steps,stop,depend)
   kk = 0;  o.work.tend = 0;
   while (kk < steps & o.work.tend <= stop)
      w = o.work;
      kk = kk+1;
      if (w.verbose >= 1)
         fprintf('Step %g: ',kk);
         ShowState(o,w.state,w.time);
      end
      state = w.state;  time = w.time;  tail = w.tail;   % copy
      
         % first search for the earliest steps to perform      
         
      w.starting = inf;  % init
         
      for (i=1:length(w.elist))
         keyi = w.keys(i);
         if ~Contains(state,keyi)
            dependi = depend{i};
            [rdy,objidx] = Ready(o,i,state,dependi); 
            if rdy  % if an object is ready
               obj = w.elist{i};       % object which is ready
               start = 0;
               for (j=1:length(objidx))
                  [ii,jj] = key(o,objidx(j));
                  el = w.table{ii,jj};
                  start = max(start,w.time(ii));
               end
               
               if (start < w.starting)
                  w.starting = start;
                  w.ready = i; 
                  w.indices = {objidx};
               elseif (start == w.starting)
                  w.ready = [w.ready i];
                  w.indices{length(w.indices)+1} = objidx;
               end
            end
         end
      end
      
         % now run all ready process steps at starting time
         
      o.work = w;                      % update work variables
      o = RunReady(o,state,time,tail);      
   end
end

function o = RunReady(o,state,time,tail)   
   w = o.work;
   verbose = w.verbose;
   %for (i=1:length(w.elist))
   for (iii=1:length(w.ready))
      i = w.ready(iii);
      objidx = w.indices{iii};

      obj = w.elist{i};
      [x,y] = points(obj);
      yhead = y(1);  ytail = y(length(y));

      if (verbose >= 1) 
         fprintf(['   Depending on events: ',SmartLook(getp(w.elist{i},'events')),'\n'])
      end

      start = 0;  newthreads = {}; namefrom = '';
      for (j=1:length(objidx))
         [ii,jj] = key(o,objidx(j));
         el = w.table{ii,jj};
         start = max(start,w.time(ii));
         namefrom = name(el);
         newthreads{j} = {ii,[w.time(ii) w.time(ii)],[w.tail(ii),yhead],namefrom};
         if (verbose >= 1)
            fprintf('      event %g: (at %g) ',j,w.time(ii));
            el 
         end
      end

      if (start == w.starting)
         [obj,tstop] = run(obj,start);               
         w.tend = max(w.tend,tstop);
         if (verbose == 0)
            %fprintf(['%6g: ',info(obj),'\n'],start);
         else
            fprintf(['   Run (%g to %g): ',info(obj),'\n'],start,tstop);
         end

            % get key(k) and row index (ii)

         k = w.keys(i);
         [ci,ans] = key(o,k);
         state(ci) = k;        % update state 
         time(ci) = tstop;     % update time
         w.number(ci) = w.number(ci)+1;   % increment number of chain items
         tail(ci) = ytail;

            % update threads

         crit = {};    maxx = -inf;
         for (j=1:length(newthreads))
            thread = newthreads{j};       
            thread{1} = [thread{1} ci];
            threadx = thread{2};

            if (max(threadx) >= maxx)   % find critical thread
               crit = thread;
               maxx = max(threadx);
            end

            if (verbose >= 2)
               fprintf(['      Thread ',thread{4},'(%g) -> ',name(obj),'(%g)\n'],threadx(1),threadx(2));
            end
            w.threads{length(w.threads)+1} = thread;
         end

            % update critical threads

         cidx = crit{1};         % chain indices from - to
         cf = cidx(1);           % chain index from

         threadlist = w.critical{cf,1};
         threadlist{length(threadlist)+1} = crit;
         w.critical{ci,1} = threadlist;

         namelist = w.critical{cf,2};   % name list
         namelist{length(namelist)+1} = name(obj);
         w.critical{ci,2} = namelist;

            % add to sequence

         seq = w.sequence{ci};
         number = w.number;
         seq{number(ci)} = obj;
         w.sequence{ci} = seq;
      end % if start
   end % for iii
   
   w.state = state;                    % state transition
   w.time = time;                      % time transition
   w.tail = tail;                      % tail transition
   o.work = w;                         % restore work property
   
   if (w.verbose >= 2)
      ShowSequences(o);
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function keys = Depends(o,obj)         % Get Keys of Dependend Objects 
   keys = [];
   events = getp(obj,'events');

   for (i=1:length(events))
      evi = events{i};
      kvec = [];
      for (j=1:length(evi))
         k = key(o,evi{j});      
         if isempty(k)
            error(['could not find object for event ''',evi{j},''' of <',info(obj),'>']);
         end
         kvec(j) = k;
      end
      keys{i} = kvec;
   end
end
function [ok,objidx] = Ready(o,oidx,state,keys)                                   
   objidx = [];
   if (~isempty(keys))
      for (i=1:length(keys))
         kvec = keys{i};
         ok = 1;
         for (j=1:length(kvec))
            idx = find(kvec(j)==state);
            if (isempty(idx))
               ok = 0;
            end
         end
         if (ok)   
            objidx = kvec;   % return indices of depending objects
            ShowReadyCondition(o,oidx,state,keys,ok)
            return;
         end 
      end
   end
   ok = 0;
   ShowReadyCondition(o,oidx,state,keys,ok)
end
function ok = Contains(state,element)                                  
   ok = false;
   if (isempty(state) || isempty(element))
      return
   end
   for (i=1:length(element))
      idx = find(state==element(i));
      if (isempty(idx))
         return
      end
   end
   ok = true;
end
function ShowState(o,state,time)                                       
   fprintf('State: <');
   if (nargin >= 3)
      PrintState(o,state,time)
   else
      PrintState(o,state)
   end
   fprintf('>\n');
end
function PrintState(o,state,time)                                       
   text = '';  sep = '';
   for (i=1:length(state))
      el = element(o,state(i));
      if isa(el,'dproc')
         text = [text,sep,name(el)];
         if (nargin >= 3)
            text = [text,sprintf('(%g)',time(i))];
         end
      else
         text = [text,' []'];
      end
      sep = ' ';
   end
   fprintf(text);
end
function idx = ChainIndex(o,k)                                         
   [idx,j] = key(o,k);
end
function sm = SmartLook(events)                                        
   sm = '';
   for (i=1:length(events))
      evi = events{i};
      for j=1:length(evi)
         str = evi{j};  n = length(str);
         sm = [sm,str,' '];
      end
      if (i < length(events)) sm = [sm,';']; end
   end
end
function ShowSequences(o)              % Show Scheduled Sequences      
   seq = o.work.sequence;
   for (i=1:length(seq))
      fprintf('Sequence %g:\n',i);
      seqi = seq{i};
      for (j=1:length(seqi))
         fprintf('   ');
         obj = seqi{j};
         display(obj);
      end
   end
   ShowState(o,o.work.state);
end
function ShowReadyCondition(o,idx,state,keys,ok)
   if (o.work.verbose < 3)
      return
   end
   obj = o.work.elist{idx};
   name = getp(obj,'name');
   if (ok)
      fprintf('%10s: condition TRUE,  <',name);
   else
      fprintf('%10s: condition FALSE: <',name);
   end
   PrintState(o,state);
   fprintf('> =?= {');
   orsep = '';
   for (i=1:length(keys))
      fprintf(orsep);  orsep = ' | ';
      keyvec = keys{i};
      andsep = '';
      for (j=1:length(keyvec))
         objkey = keyvec(j);
         [ii,jj] = key(o,objkey);
         obj = o.work.table{ii,jj};
         name = getp(obj,'name'); 
         fprintf([andsep,name]);  andsep = ' & ';
      end
   end
   fprintf('}\n');
end