function out = profiler(name,mode)     % Profiler                      
%
% PROFILER   Collect/display profiling info.
%
%    First arg is a smart object which has so far no meaning except enable
%    access to CORE method profile()
%
%       old = o.profiler('on');        % switch profiler on
%       old = o.profiler('off');       % switch profiler off
%
%       o.profiler('debug');           % print internal structure
%
%       o.profiler([]);                % init
%
%       o.profiler('main',1)           % begin profiling
%       o.profiler('sub1',1)           % begin profiling
%       o.profiler('sub1',0)           % end profiling
%       o.profiler('sub2',1)           % begin profiling
%       o.profiler('sub2',0)           % end profiling
%       o.profiler('main',0)           % end profiling
%
%       o.profiler('load.begin')       % store time stamp
%       o.profiler('load.end')         % store time stamp
%
%       o.profiler                     % show profiling info
%
%    Profile time stamps can be nested. An internal stack tracks
%    the nesting.
%
%    Profiling demos:
%
%       o.profiler(0)                  % run profiling demo #0
%       o.profiler(1)                  % run profiling demo #1
%       o.profiler(2)                  % run profiling demo #2
%       o.profiler(5)                  % run profiling demo #5
%
%    See also: CARABULL
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

   cpuenter = MyClock;         % store current clock at entry time

   global GlobSmartProfile
   p = GlobSmartProfile;
   
   if (nargin == 0)
      Show(p);                 % graphical display of profiling info
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
            if (GlobSmartProfileBypass)
               out = 'off';
            else
               out = 'on';
            end
         end
         GlobSmartProfileBypass = 0;
      elseif strcmp(name,'off')
         if nargout > 0
           if (GlobSmartProfileBypass)
              out = 'off';
           else
              out = 'on';
           end
         end
         GlobSmartProfileBypass = 1;
      elseif strcmp(name,'debug')
         fprintf('Profiling Stack:\n');
         disp(p.stack);      
      else
         ProfDemo(nmb);
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

      p.cpuend = MyClock + 1e-6;    % plus 1µs to avoid divide by zero
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
end
   
%==========================================================================
% Auxillary Functions
%==========================================================================

function t = MyClock                   % Get System Clock in Seconds   
%
% MYCLOCK   Get system clock in seconds
%
   c = clock;
   t = c(6) + [c(5) + [c(4) + c(3)*24]*60]*60;
   return
end

function Show(prof)                    % Show Profiling Info           
%
% SHOW   Display profiling info
%
   global GlobSmartProfileBypass

   rd = @carabao.rd;                   % access utility
   if (isempty(prof))
      if ~GlobSmartProfileBypass
         fprintf('No profiling info available!\n');
      end
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
      d = 0;
      if (i~=1)
         d = ti/core*100;
      end
      fprintf(['   %10.6f s  %5.1f %%  %5.1f %%  ',names{i},'\n'],...
              ti,rd(ti/total*100,1),rd(d,1));
   end
   fprintf('   --------------------------------\n');
   fprintf(['Total   %10.6f s  %5.1f %% (core %10.6f s)\n'],...
            total,100,core);
   
   if ~isempty(prof.stack)
      %stack
      %error('profile(): nesting error!');
   end
   
   return
end

%==========================================================================
% Profiler Demos
%==========================================================================

function ProfDemo(nmb)                 % Proiler Demo Dispatcher       
%
% PROFDEMO   Run profiling demo
%
   switch nmb
      case 0
         ProfDemo0;
      case 1
         ProfDemo1;
      otherwise
         ProfDemoN(nmb);
   end
   return
end

function ProfDemo0                     % Profiler Demo 0               
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
end

function ProfDemo1                     % Profiler Demo 1               
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
end

function ProfDemoN(n)                  % Profiler Demo n               
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
end   

