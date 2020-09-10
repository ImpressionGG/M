function [smo,arg] = compose(obj,arg,verbose)
%
% COMPOSE   Compose a SHELL object from a data log object and return
%           a SMART object containing the bulk data.
%
%              smo = compose(shell,prslist);    % compose from parser list
%              smo = compose(shell,loglist);    % compose from log list
%              smo = compose(shell,logtable);   % compose from parser list
%
%              smo = compose(she,ltab,verbose); % call with verbose mode
%
%           Each list entry or table entry denotes log data of a single
%           data point and comprises the following items:
%
%              <symbol>  symbol which identifies data of a data stream
%              <t>       time of data point [s]
%              <x>       x coordinate of data point [mm]
%              <y>       y coordinate of data point [mm]  
%              <z>       z coordinate of data point [mm]       (optional)
%              <th>      theta coordinate of data point [°]    (optional)
%              <system>  number of system (e.g. gantry number) (optional)
%              <tag>     mnemonic info for better readability  (optional)
%
%
%           Formats of arg2 can be as follows:
%
%           1) Parser List (list of lists): each list entry is a list of
%              the following entities:
%
%                 { <symbol> [<x> <y> <z> <th>] <t> <system> <tag> }
%
%              Example 1:
%
%              prslist = {{'pU.L', [-0.001 0.001 0.000 0], 0.1, 1, 'ULC'}
%                         {'pV.L', [-0.002 0.003 0.000 0], 0.1, 1, 'SC'}
%                         {'pU.L', [ 0.001 0.002 0.000 0], 0.2, 1, 'ULC'}
%                         {'pV.L', [ 0.002 0.002 0.000 0], 0.2, 1, 'SC'}
%                         {'pU.L', [-0.001 0.003 0.000 0], 0.3, 1, 'ULC'}
%                         {'pV.L', [-0.002 0.001 0.000 0], 0.3, 1, 'SC'}
%                         {'pU.L', [ 0.001 0.002 0.000 0], 0.4, 1, 'ULC'}
%                         {'pV.L', [ 0.002 0.002 0.000 0], 0.4, 1, 'SC'}
%                         {'pU.L', [-0.001 0.001 0.000 0], 0.5, 1, 'ULC'}
%                         {'pV.L', [-0.002 0.003 0.000 0], 0.5, 1, 'SC'}
%                        };
%              smo = compose(shell,prslist);
%
%           2) Log List (list of strings): each list entry is a string of
%              the following entities:
%
%                 '<symbol> <t> <x> <y> <z> <th> <system> <tag>'
%
%              Example 2:
%
%              loglist = {'pU.L 0.1 -0.001 0.001 0.000 0 1 ULC'
%                         'pV.L 0.1 -0.002 0.003 0.000 0 1 SC'
%                         'pU.L 0.2  0.001 0.002 0.000 0 1 ULC'
%                         'pV.L 0.2  0.002 0.002 0.000 0 1 SC'
%                         'pU.L 0.3 -0.001 0.003 0.000 0 1 ULC'
%                         'pV.L 0.3 -0.002 0.001 0.000 0 1 SC'
%                         'pU.L 0.4  0.001 0.002 0.000 0 1 ULC'
%                         'pV.L 0.4  0.002 0.002 0.000 0 1 SC'
%                         'pU.L 0.5 -0.001 0.001 0.000 0 1 ULC'
%                         'pV.L 0.5 -0.002 0.003 0.000 0 1 SC'
%                        };
%              smo = compose(shell,loglist);
%
%           3) Log Table (string table - matrix format): each row
%              of the table (all  rows have the same length) is a
%              string of the following entities:
%
%                 '<symbol> <t> <x> <y> <z> <th> <system> <tag>'
%
%              Example 3:
%
%              logtable = ['pU.L 0.1 -0.001 0.001 0.000 0 1 ULC'
%                          'pV.L 0.1 -0.002 0.003 0.000 0 1 SC '
%                          'pU.L 0.2  0.001 0.002 0.000 0 1 ULC'
%                          'pV.L 0.2  0.002 0.002 0.000 0 1 SC '
%                          'pU.L 0.3 -0.001 0.003 0.000 0 1 ULC'
%                          'pV.L 0.3 -0.002 0.001 0.000 0 1 SC '
%                          'pU.L 0.4  0.001 0.002 0.000 0 1 ULC'
%                          'pV.L 0.4  0.002 0.002 0.000 0 1 SC '
%                          'pU.L 0.5 -0.001 0.001 0.000 0 1 ULC'
%                          'pV.L 0.5 -0.002 0.003 0.000 0 1 SC '
%                         ];
%              smo = compose(shell,logtable);
%
%           Remark: the calling syntax
%
%              [smo,arg] = compose(shell,'test');
%              [smo,arg] = compose(shell,n);         % n = 1,2 or 3
%
%           creates a test data SMART object
%
%           See also: SHELL SMART SMART/COMPOSE
%
   if (nargin < 3) 
      verbose = either(option(obj,'make.verbose'),0);
   end
   
   if isempty(arg)
      smo = compose(smart,{});  % trivial composition
      return
   end
   
% check for syntactic sugar call

   if (ischar(arg) && size(arg,1) == 1)
      if strcmp(arg,'test')
         [smo,arg] = compose(obj,3);   % create test data
         return
      end
   end

% no special calls anx more! continue with standard processing
   
   if iscell(arg)
      entry = arg{1};   % at least one entry must exisat!
      if iscell(entry)
         smo = cpfprslist(arg);
         return
      elseif ischar(entry)
         smo = cpfloglist(arg);
         return
      end
   elseif ischar(arg)
         dim = either(get(obj,'dimension'),4);
         smo = cpflogtable(arg,verbose,dim);
         return
   elseif (all(size(arg)==[1 1]) && isa(arg,'double'))
      switch arg
         case 1
            prslist = {{'pU.L', [-0.001 0.001 0.000 0], 0.1, 1, 'ULC'}
                       {'pV.L', [-0.002 0.003 0.000 0], 0.1, 1, 'SC'}
                       {'pU.L', [ 0.001 0.002 0.000 0], 0.2, 1, 'ULC'}
                       {'pV.L', [ 0.002 0.002 0.000 0], 0.2, 1, 'SC'}
                       {'pU.L', [-0.001 0.003 0.000 0], 0.3, 1, 'ULC'}
                       {'pV.L', [-0.002 0.001 0.000 0], 0.3, 1, 'SC'}
                       {'pU.L', [ 0.001 0.002 0.000 0], 0.4, 1, 'ULC'}
                       {'pV.L', [ 0.002 0.002 0.000 0], 0.4, 1, 'SC'}
                       {'pU.L', [-0.001 0.001 0.000 0], 0.5, 1, 'ULC'}
                       {'pV.L', [-0.002 0.003 0.000 0], 0.5, 1, 'SC'}
                      };
            smo = compose(shell,prslist);
            arg = prslist;
            return
            
         case 2
            loglist = {'pU.L 0.1 -0.001 0.001 0.000 0 1 ULC'
                       'pV.L 0.1 -0.002 0.003 0.000 0 1 SC'
                       'pU.L 0.2  0.001 0.002 0.000 0 1 ULC'
                       'pV.L 0.2  0.002 0.002 0.000 0 1 SC'
                       'pU.L 0.3 -0.001 0.003 0.000 0 1 ULC'
                       'pV.L 0.3 -0.002 0.001 0.000 0 1 SC'
                       'pU.L 0.4  0.001 0.002 0.000 0 1 ULC'
                       'pV.L 0.4  0.002 0.002 0.000 0 1 SC'
                       'pU.L 0.5 -0.001 0.001 0.000 0 1 ULC'
                       'pV.L 0.5 -0.002 0.003 0.000 0 1 SC'
                      };
            smo = compose(shell,loglist);
            arg = loglist;
            return
            
         case 3
            logtable = ['pU.L 0.1 -0.001 0.001 0.000 0 1 ULC'
                        'pV.L 0.1 -0.002 0.003 0.000 0 1 SC '
                        'pU.L 0.2  0.001 0.002 0.000 0 1 ULC'
                        'pV.L 0.2  0.002 0.002 0.000 0 1 SC '
                        'pU.L 0.3 -0.001 0.003 0.000 0 1 ULC'
                        'pV.L 0.3 -0.002 0.001 0.000 0 1 SC '
                        'pU.L 0.4  0.001 0.002 0.000 0 1 ULC'
                        'pV.L 0.4  0.002 0.002 0.000 0 1 SC '
                        'pU.L 0.5 -0.001 0.001 0.000 0 1 ULC'
                        'pV.L 0.5 -0.002 0.003 0.000 0 1 SC '
                      ];
            smo = compose(shell,logtable);
            arg = logtable;
            return
            
         otherwise
            error('arg2: use value 1,2, or 3 for test data creation!'); 
      end
   end
         
   error('arg2: list of lists, list of strings or string table expected!');
   return
   
   
%==========================================================================
% Auxillary Functions
%==========================================================================

function smo = cpfprslist(list)     % compose from parser list
%
   smo = compose(smart,list);       % checks have to be done aerlier
   return
   
%==========================================================================

function smo = cpfloglist(list)     % compose from log list
%
   prslist = {};
   for (i=1:length(list))
      entry = scan(list{i});
      prslist{i} = entry;
   end
   smo = compose(smart,prslist);    % checks have to be done aerlier
   return
   
%==========================================================================

function smo = cpflogtable(table,verbose,dim)   % compose from log table
%
   VERBOSE_ALIFE = 1;          % verbose level for life signals
   MODULUS_ALIFE = 20000;      % life signal traced each 20000 times

   profiler('cpflogtable',1);
   
   if (nargin < 3) dim = 4; end
   
   [m,n] = size(table);             % size of table
   prslist{m} = [];                 % dimensioning table (for faster speed)

   count = 0;
   for (i=m:-1:1)                   % reverse order tremendously speeds up!

         % The following code is an inline implementation of
         % the statement "entry = scan(table(i,:));" for speed-up

      args = textscan(table(i,:),'%s%f%f%f%f%f%f%s');

         % in next try statement everything would work if only the
         % catch part would be only provided. But for speed up we
         % execute without eval commands, which runs faster

      try
         S = args{1};  symbol = S{1};
         t = args{2};  x = args{3};  y = args{4}; z = args{5};
         th = args{6}; system = args{7};
         T = args{8};  
         if (length(T)) tag = T{1}; else tag = ''; end
      catch
         S = eval('args{1}','{''???''}');  symbol = S{1};
         t = eval('args{2}','0');
         x = eval('args{3}','0');
         y = eval('args{4}','0');
         z = eval('args{5}','0');
         th = eval('args{6}','0');
         system = eval('args{7}','0');
         T = eval('args{8}','{''''}');  tag = eval('T{1}','''''');
      end

      switch dim
         case 1
            prslist{i} = {symbol, [x]', t, system, tag};
         case 2
            prslist{i} = {symbol, [x y]', t, system, tag};
         case 3
            prslist{i} = {symbol, [x y z]', t, system, tag};
         otherwise
            prslist{i} = {symbol, [x y z th]', t, system, tag};
      end
      
      count = count+1;
      if (verbose >= VERBOSE_ALIFE & rem(count,MODULUS_ALIFE) == 0)
         fprintf('   %7.0f entries scanned\n',count)
      end
   end
   
   if (verbose >= VERBOSE_ALIFE)
      fprintf('Composing bulk data ...\n',count)
   end
      
      % Now we are going to create a smart object. Checks have to be
      % done aerlier. The call "smo = compose(smart,prslist) would work,
      % but we need to pass the verbose arg.

   smo = compose(smart,prslist,dim,0,verbose);   
   
   profiler('cpflogtable',0);
   return

%==========================================================================

function entry = scan(line)
%
% SCAN    Scan a text line and compose a parser list entry
%         Syntax of line is:
%
%            '<symbol> <t> <x> <y> <z> <th> <system> <tag>'
%
%         Since some of the arguments are optional we also can have:
%
%            '<symbol> <t> <x> <y> <z> <th> <system>
%            '<symbol> <t> <x> <y> <z> <th>
%            '<symbol> <t> <x> <y> <z>
%            '<symbol> <t> <x> <y>
%
   args = textscan(line,'%s%f%f%f%f%f%f%s');

      % in next try statement everything would work if only the
      % catch part would be only provided. But for speed up we
      % execute without eval commands, which runs faster
      
   try
      S = args{1};  symbol = S{1};
      t = args{2};  x = args{3};  y = args{4}; z = args{5};
      th = args{6}; system = args{7};
      T = args{8};  
      if (length(T)) tag = T{1}; else tag = ''; end
   catch
      S = eval('args{1}','{''???''}');  symbol = S{1};
      t = eval('args{2}','0');
      x = eval('args{3}','0');
      y = eval('args{4}','0');
      z = eval('args{5}','0');
      th = eval('args{6}','0');
      system = eval('args{7}','0');
      T = eval('args{8}','{''''}');  tag = eval('T{1}','''''');
   end
   
   entry = {symbol, [x y z th]', t, system, tag};
   return
   
%eof   
