function out = profiler(name,mode)
%
% PROFILER   Collect/display profiling info. First arg is a smart object
%            which has so far no meaning except enable access to SMART
%            method profile()
%
%               old = profiler('on');   % switch profiler on
%               old = profiler('off');  % switch profiler off
%
%               profiler('debug');      % print internal structure
%
%               profiler([]);              % init
%
%               profiler('main',1)      % begin profiling
%               profiler('sub1',1)      % begin profiling
%               profiler('sub1',0)      % end profiling
%               profiler('sub2',1)      % begin profiling
%               profiler('sub2',0)      % end profiling
%               profiler('main',0)      % end profiling
%               profiler                % display of profiling
%
%               profiler('load.begin')  % store time stamp
%               profiler('load.end')    % store time stamp
%
%               profiler                % show profiling info
%
%            Profile time stamps can be nested. An internal stack tracks
%            the nesting.
%
%            Profiling demos:
%
%               profiler(0)             % run profiling demo #0
%               profiler(1)             % run profiling demo #1
%               profiler(2)             % run profiling demo #2
%               profiler(5)             % run profiling demo #5
%
%            See also: SMART
%
   global GlobSmartProfileBypass
   
   if (GlobSmartProfileBypass)
      if (nargin >= 2)
         if nargout > 0
            out = [];
         end
         return;               % bypass profiling if disabled
      end
   end

   cpuenter = myclock;         % store current clock at entry time

   global GlobSmartProfile
   p = GlobSmartProfile;
   
   if (nargin == 0)
      show(p);                 % graphical display of profiling info
      if nargout > 0
         out = p;
      end
      return
   elseif nargin == 1
      nmb = name;
      if isempty(nmb)
         GlobSmartProfile = [];      % initialize
         return
      elseif strcmp(name,'on')
         if nargout > 0
            out = iif(GlobSmartProfileBypass,'off','on');
         end
         GlobSmartProfileBypass = 0;
      elseif strcmp(name,'off')
         if nargout > 0
            out = iif(GlobSmartProfileBypass,'off','on');
         end
         GlobSmartProfileBypass = 1;
      elseif strcmp(name,'debug')
         fprintf('Profiling Stack:\n');
         disp(p.stack);      
      else
         profdemo(nmb);
      end
      return
   end
   
   try
      eval(['x.',name,'=0;']);
   catch
      name
      error('arg2 must be compliant with identifier syntax!');
   end

   if (mode == 2)
      if setting('profile')
         p = [];                     % init
      end
   end
   
   try   
      idx = find(name == ' ');
      name(idx) = idx*0 + '_';       % replace spaces by underscores
      
%     if mode == 0 | isempty(p) | eval('p.level','0') < 1
      if isempty(p)
         if (mode <= 0)
            fprintf('*** Warning: end profile encountered for empty profile stack!\n');
            GlobSmartProfile = [];
            out = [];
            return
         end
         p = [];                     % reset profiling info
         p.cpustart = cpuenter;      % store cpu time at profiling start
         p.cpulast = cpuenter;       % store cpu time at entry
         p.cpunow = cpuenter;        % store cpu time at entry
         p.cpuend = cpuenter;        % store cpu time at profiling start
         p.level = 1;                % init nesting level
         p.overhead = 0;             % current overhead
         p.time.overhead = 0;        % accumulated overhead times
         p.stack = {'other'};        % reset profiling stack
         symbol = name;              % to be defined for trace (see end)
         %mode = 0;                   % overwrite mode
      end

      dt = cpuenter - p.cpunow - p.overhead;

      if (mode > 0)  % begin a level for mode > 0

         symbol = p.stack{p.level};

            % make sure that p.cpu.'symbol' exists (by default 0)

         cmd = ['p.time.',symbol,'=eval(''p.time.',symbol,''',''0'');'];
         eval(cmd);

            % add ellapsed time

         cmd = ['p.time.',symbol,'=p.time.',symbol,'+dt;'];
         eval(cmd);

         p.level = p.level + 1;
         p.stack{p.level} = name;

      else                 % exit a level for mode <= 0

         symbol = p.stack{p.level};
         p.level = p.level - 1;
         p.stack = p.stack(1:p.level);

            % make sure that p.cpu.'symbol' exists (by default 0)

         cmd = ['p.time.',symbol,'=eval(''p.time.',symbol,''',''0'');'];
         eval(cmd);

         if ~strcmp(name,symbol)
            stack
            fprintf(['*** profile(): nesting error when processing: ',symbol,'\n']);
         end

            % add ellapsed time

         cmd = ['p.time.',symbol,'=p.time.',symbol,'+dt;'];
         eval(cmd);

      end

      p.cpulast = p.cpunow;
      p.cpunow = cpuenter;

      p.trace = sprintf([symbol,':%10.6f s'],dt);

         % final refresh of accumulated overhead & GlobSmartProfile
         % note: 0.29 ms extra time for creating SMART object

      p.cpuend = myclock + 1e-6;    % plus 1µs to avoid divide by zero
      p.overhead = (p.cpuend - cpuenter)*1.03;   % add some percent more 
      p.time.overhead = p.time.overhead + p.overhead;
      GlobSmartProfile = p;

   catch
      name
      p
      fprintf('*** exception catched during profiling\n');
      GlobSmartProfile = [];
   end
   
   if nargout > 0
      out = p;
   end
   return
   
%==========================================================================

function t = myclock
%
% MYCLOCK   Get system clock in seconds
%
   c = clock;
   t = c(6) + [c(5) + [c(4) + c(3)*24]*60]*60;
   return

%==========================================================================

function show(prof)
%
% SHOW   Display profiling info
%
   if (isempty(prof))
      fprintf('No profiling info available!\n');
      return
   end
   
   time = 0;                         % init
   names = {};
   
   fprintf('Profiling Information\n');
   names = fields(prof.time);
   for (i=1:length(names))
      name = names{i};
      time(i) = eval(['prof.time.',name]);
   end

   total = prof.cpuend - prof.cpustart;
   leakage = total - sum(time);
   core = total - prof.time.overhead;
   
   names{end+1} = 'leakage';
   time(end+1) = leakage;
   
   n = length(time);
   for (i=1:n)
      ti = time(i);
      fprintf(['   %10.6f s  %5.1f %%  %5.1f %%  ',names{i},'\n'],...
              ti,rd(ti/total*100,1),rd(iif(i==1,0,ti/core*100),1));
   end
   fprintf('   --------------------------------\n');
   fprintf(['Total   %10.6f s  %5.1f %% (core %10.6f s)\n'],...
            total,100,core);
   
   if ~isempty(prof.stack)
      %stack
      %error('profile(): nesting error!');
   end
   
   return

%==========================================================================

function profdemo(nmb)
%
% PROFDEMO   Run profiling demo
%
   switch nmb
      case 0
         profdemo0;
      case 1
         profdemo1;
      otherwise
         profdemon(nmb);
   end
   return

%==========================================================================

function profdemo0
%
% PROFDEMO0   Run profiling demo #0
%
   fprintf('Run only profiling wthout bodies ...\n');
   
   p = profile(smart,'main',0);     % reset & begin profiling main
   p = profile(smart,'sub1',1);     % begin profiling sub1
   p = profile(smart,'sub1',-1);    % end profiling sub1
   p = profile(smart,'sub2',1);     % begin profiling sub1
   p = profile(smart,'sub2',-1);    % end profiling sub1
   p = profile(smart,'main',-1);    % reset & begin profiling main

   profile(smart);
   return
   
%==========================================================================

function profdemo1
%
% PROFDEMO1   Run profiling demo #1
%
   n = 10;
   
   p = profile(smart,'main',0)     % reset & begin profiling main
   time = p.time
   
   for (i=1:10000) magic(n); end

   p = profile(smart,'sub1',1)     % begin profiling sub1
   p.time
   for (i=1:10000) magic(20); end
   p = profile(smart,'sub1',-1)    % end profiling sub1
   time = p.time
   
   for (i=1:10000) magic(n); end
   
   p = profile(smart,'sub2',1)     % begin profiling sub1
   time = p.time
   for (i=1:10000) magic(40); end
   p = profile(smart,'sub2',-1)    % end profiling sub1
   time = p.time

   for (i=1:10000) magic(n); end
   
   p = profile(smart,'main',-1)    % reset & begin profiling main
   time = p.time

   profile(smart);
   return
   
%==========================================================================

function profdemon(n)
%
% PROFDEMON   Run profiling demo #n
%

   n = n*10;
   
   p = profile(smart,'main',0)     % reset & begin profiling main
   time = p.time
   
   for (i=1:10000) magic(n); end

   p = profile(smart,'sub1',1)     % begin profiling sub1
   p.time
   for (i=1:10000) magic(20); end
   p = profile(smart,'sub1',-1)    % end profiling sub1
   time = p.time
   
   for (i=1:10000) magic(n); end
   
   p = profile(smart,'sub2',1)     % begin profiling sub1
   time = p.time
   for (i=1:10000) magic(40); end
   p = profile(smart,'sub2',-1)    % end profiling sub1
   time = p.time

   for (i=1:10000) magic(n); end
   
   p = profile(smart,'main',-1)    % reset & begin profiling main
   time = p.time

   profile(smart);
   return
   
%eof   