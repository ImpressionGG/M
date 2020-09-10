function out = profile(obj,name,mode)
%
% PROFILE    Collect/display profiling info. First arg is a smart object
%            which has so far no meaning except enable access to SMART
%            method profile()
%
%               profile(smart,[]);         % init
%
%               smo = smart;               % create SMART object
%               profile(smo,'main',0)      % reset & begin profiling
%               profile(smo,'main',1)      % begin profiling
%               profile(smo,'sub1',1)      % begin profiling
%               profile(smo,'sub1',-1)     % end profiling
%               profile(smo,'sub2',1)      % begin profiling
%               profile(smo,'sub2',-1)     % end profiling
%               profile(smo,'main',0)      % end profiling
%               profile(smo)               % graphical display of profiling
%
%               profile(smart,'load.begin')% store time stamp
%               profile(smart,'load.end')  % store time stamp
%
%            Profile time stamps can be nested. An internal stack tracks
%            the nesting.
%
%            Profiling demos:
%
%               profile(smart,0)           % run profiling demo #0
%               profile(smart,1)           % run profiling demo #1
%               profile(smart,2)           % run profiling demo #2
%               profile(smart,5)           % run profiling demo #5
%
   global GlobSmartProfile
out = GlobSmartProfile;
return
   
   cpuenter = myclock;         % store current clock at entry time
   p = GlobSmartProfile;
   
   if (nargin == 1)
      show(p);                 % graphical display of profiling info
      if nargout > 0
         out = p;
      end
      return
   end

   if nargin ~= 3
      nmb = name;
      if isempty(nmb)
         GlobSmartProfile = [];      % initialize
         return
      end
      profdemo(nmb);
      return
   end

   try   
      idx = find(name == ' ');
      name(idx) = idx*0 + '_';       % replace spaces by underscores
      
%     if mode == 0 | isempty(p) | eval('p.level','0') < 1
      if mode == 0 | isempty(p)
         if (mode < 0)
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
         p.overhead = 0;             % accumulated profiling overhead time
         p.level = 1;                % init nesting level
         p.time = [];                % reset all profiling times
         p.stack = {'other'};        % reset profiling stack
         symbol = name;              % to be defined for trace (see end)
         %mode = 0;                   % overwrite mode
      end

      dt = cpuenter - p.cpunow;

      if (mode > 0)  % begin a level for mode >= 0

         symbol = p.stack{p.level};

            % make sure that p.cpu.'symbol' exists (by default 0)

%          cmd = ['p.time.',symbol,'=eval(''p.time.',symbol,''',''0'');'];
%          eval(cmd);
         if ~isfield(p.time,symbol)
            p.time.(symbol) = 0;
         end

            % add ellapsed time

%          cmd = ['p.time.',symbol,'=p.time.',symbol,'+dt;'];
%          eval(cmd);
         p.time.(symbol)=p.time.(symbol)+dt;

         p.level = p.level + 1;
         p.stack{p.level} = name;

      elseif mode < 0                 % exit a level for mode < 0

         symbol = p.stack{p.level};
         p.level = p.level - 1;
         p.stack = p.stack(1:p.level);

            % make sure that p.cpu.'symbol' exists (by default 0)

%          cmd = ['p.time.',symbol,'=eval(''p.time.',symbol,''',''0'');'];
%          eval(cmd);
         if ~isfield(p.time,symbol)
            p.time.(symbol) = 0;
         end

         if ~strcmp(name,symbol)
            stack
            fprintf(['*** profile(): nesting error when processing: ',symbol,'\n']);
         end

            % add ellapsed time

%          cmd = ['p.time.',symbol,'=p.time.',symbol,'+dt;'];
%          eval(cmd);
         p.time.(symbol)=p.time.(symbol)+dt;

      end

      p.cpulast = p.cpunow;
      p.cpunow = cpuenter;

      p.trace = sprintf([symbol,':%10.6f s'],dt);

         % final refresh of accumulated overhead & GlobSmartProfile
         % note: 0.29 ms extra time for creating SMART object

      p.cpuend = myclock + 1e-6;    % plus 1µs to avoid divide by zero
      p.overhead = p.overhead + (p.cpuend - cpuenter) + 0.29e-3;
      GlobSmartProfile = p;

      if nargout > 0
         out = p;
      end
   catch
      name
      p
      fprintf('*** exception catched during profiling\n');
      GlobSmartProfile = [];
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
   
%    time = 0;                         % init
%    names = {};
   
   fprintf('Profiling Information\n');
   names = fields(prof.time);
   time = NaN(1,length(names));
   for i=1:length(names),
      name = names{i};
      time(i) = prof.time.(name); % time(i) = eval(['prof.time.',name]);
   end

   total = prof.cpuend - prof.cpustart;
   overhead = total - sum(time);
   
   names{end+1} = 'overhead';
   time(end+1) = overhead;
   
   for (i=1:length(time))
      ti = time(i);
      fprintf(['   %10.6f s  %5.1f %%  ',names{i},'\n'],ti,ti/total*100);
   end
   fprintf('   --------------------------------\n');
   fprintf(['   %10.6f s  %5.1f %%  ','total','\n'],total,100);
   
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