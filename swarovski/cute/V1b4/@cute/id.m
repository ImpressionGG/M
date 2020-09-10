function [ID,number,machine,digits] = id(o,path,dummy)
%
% ID  Get object ID from object or extract object ID from a path. The re-
%     sulting object ID can be either a package info object ID or a data
%     object ID.
%
%        ID = id(o)                  % return package ID or data object ID
%        [ID,number,machine] = id(o) % return package ID or data object ID
%
%
%     Examples for object IDs are:
%
%        '@LPC03.200609.0.PKG'       % for package info object
%        '@LPC03.200609.5.CUT'       % for data object with run number 5
%
%     Object ID can also be extracted from a directory path
%
%        ID = id(o,'.../LPC03_200609']             % ID = '@LPC03.200609'
%        ID = id(o,'.../LPC03_20060901']           % ID = '@LPC03.20060901'
%        ID = id(o,'.../LPC03_20060901_Text']      % ID = '@LPC03.20060901'
%        ID = id(o,'.../LPC03_20060901Text']       % ID = '@LPC03.20060901'
%        ID = id(o,'.../LPC03_20060901 Text']      % ID = '@LPC03.20060901'
%
%        ID = id(o,'.../@LPC03.20060901.CUT']      % ID = '@LPC03.20060901'
%        ID = id(o,'.../@LPC03.20060901.CUT_Text'] % ID = '@LPC03.20060901'
%        ID = id(o,'.../@LPC03.20060901.CUT.Text'] % ID = '@LPC03.20060901'
%        ID = id(o,'.../@LPC03.20060901.CUT Text'] % ID = '@LPC03.20060901'
%
%     Test
%
%        id(o,[],[]);                 % perform ID tests
%
%     Examples:
%
%        oo = cute('pkg')
%        oo.par.package = '@LPC03.200609'
%        ID = id(oo)                               % ID = '@LPC03.200609'
%
%        oo = cute('cut')
%        machine = 'LPC03'
%        digits = '200609'
%        oo.par.package = ['@',machine,'.',digits];
%        oo.par.number = 5
%        [ID,number,machine,digits] = id(oo)       % ID = '@LPC03.200609.5'
%
%     Copyright(c): Bluenetics 2020
%
%     See also: CUTE, COLLECT
%
   if (nargin == 1)
      [ID,number,machine,digits] = GetId(o);
   elseif (nargin == 2)
      [ID,number,machine,digits] = Extract(o,path);
   elseif (nargin == 3)
      Test(o);
   else
      error('1,2 or 3 input args expected!');
   end
end

%==========================================================================
% Helpers
%==========================================================================

function [ID,number,machine,digits] = GetId(o)   % Get Object ID                 
   if type(o,{'pkg'})
      number = [];
      package = get(o,'package');
      ID = [package,'.0.PKG'];
      if isempty(ID)
         error('undefined package ID');
      end
   elseif type(o,{'cut'})
      number = get(o,{'number',0});
      package = get(o,'package');
      if isempty(package)
         error('undefined package ID');
      end
      ID = sprintf('%s.%d.CUT',package,number);
   elseif type(o,{'scp'})
      number = get(o,{'number',0});
      package = get(o,'package');
      if isempty(package)
         error('undefined package ID');
      end
      ID = sprintf('%s.%d.SCP',package,number);
   elseif type(o,{'mpl'})
      ID = [];
      number = [];
      machine = get(o,'machine');
      digits = '';
      return
   else
      ID = '';  number = [];  machine = '';  digits = '';
   end
   
   chunk = [package,'.'];
   idx = find(chunk=='.');
   machine = package(2:idx(1)-1);   % extract machine ID
   digits = package(idx(1)+1:idx(2)-1);
end
function [ID,number,machine,digits] = Extract(o,path) % Extract Package ID  
   [dir,file,ext] = fileparts(path);                  % from Path
   name = [file,ext];
   chunk = [name,'_'];
   
   if (chunk(1) == '@')
      [ID,number] = CorazonExtract(o,chunk);
   else
      [ID,number] = SpecialExtract(o,chunk);
   end
   
   function [ID,number] = CorazonExtract(o,chunk)                      
      assert(length(chunk)>0 && chunk(1)=='@');
      
      idx = find(chunk=='.');
      if isempty(idx)
         error('bad package identifier syntax: missing dot');
      end
      
      machine = chunk(2:idx(1)-1);
      tail = chunk(idx(1)+1:end);
      
      digits = '';
      for (i=1:length(tail))
         if ('0' <= tail(i) && tail(i) <= '9')
            digits(end+1) = tail(i);
         else
            break;
         end
      end
      
      if isempty(digits)
         error('bad package identifier syntax: missing package number');
      end

      ID = ['@',machine,'.',digits,'.0.PKG'];
      number = [];
   end
   function [ID,number] = SpecialExtract(o,chunk)                      
      number = [];
      
      idx = find(chunk=='_');
      if length(idx) < 2
         error('bad package identifier syntax: missing underscore');
      end
      
      machine = chunk(1:idx(1)-1);
      tail = chunk(idx(1)+1:end);

      digits = '';
      for (i=1:length(tail))
         if ('0' <= tail(i) && tail(i) <= '9')
            digits(end+1) = tail(i);
         else
            break;
         end
      end
      
      if isempty(digits)
         error('bad package identifier syntax: missing package number');
      end

      ID = ['@',machine,'.',digits,'.0.PKG'];
      number = [];
   end
end

%==========================================================================
% Test
%==========================================================================

function Test(o)
   is = @isequal;                      % short hand

      % CORAZON Naming
      
   [ID,number,machine,digits] = id(o,'@LPC03.1');
   assert(is(ID,'@LPC03.1.0.PKG'));
   assert(is(number,[]));
   assert(is(machine,'LPC03'));
   assert(is(digits,'1'));

   [ID,number] = id(o,'@LPC03.1 Text');
   assert(is(ID,'@LPC03.1.0.PKG'));

   [ID,number] = id(o,'@LPC03.1Text');
   assert(is(ID,'@LPC03.1.0.PKG'));

   [ID,number] = id(o,'@LPC03.1.Text');
   assert(is(ID,'@LPC03.1.0.PKG'));

   [ID,number] = id(o,'@LPC03.1_Text');
   assert(is(ID,'@LPC03.1.0.PKG'));

   
   [ID,number,machine,digits] = id(o,'@LPC03.200609');
   assert(is(ID,'@LPC03.200609.0.PKG'));
   assert(is(number,[]));
   assert(is(machine,'LPC03'));
   assert(is(digits,'200609'));

   [ID,number] = id(o,'ghjgghj/@LPC03.200609');
   assert(is(ID,'@LPC03.200609.0.PKG'));

   [ID,number] = id(o,'ghjgghj/@LPC03.200609 Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));
   
   [ID,number] = id(o,'ghjgghj/@LPC03.200609Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));
   
   [ID,number] = id(o,'ghjgghj/@LPC03.200609.CUT');
   assert(is(ID,'@LPC03.200609.0.PKG'));
   
   [ID,number] = id(o,'ghjgghj/@LPC03.200609_Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));
   
      % Special Naming
      
   [ID,number]=id(o,'LPC03_200609');
   assert(is(ID,'@LPC03.200609.0.PKG'));

   [ID,number]=id(o,'LPC03_200609Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));

   [ID,number]=id(o,'LPC03_200609.Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));

   [ID,number]=id(o,'LPC03_200609 Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));

   [ID,number]=id(o,'ghjgghj/LPC03_200609');
   assert(is(ID,'@LPC03.200609.0.PKG'));

   [ID,number]=id(o,'ghjgghj/LPC03_200609Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));

   [ID,number]=id(o,'ghjgghj/LPC03_200609_Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));

   [ID,number]=id(o,'ghjgghj/LPC03_200609.Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));

   [ID,number]=id(o,'ghjgghj/LPC03_200609-Text');
   assert(is(ID,'@LPC03.200609.0.PKG'));
   
      % other tests
      
   oo = cute('pkg');
   oo.par.package = '@LPC03.200609';
   [ID,number] = id(oo);                    % ID = '@LPC03.200609.0.PKG'
   assert(is(ID,'@LPC03.200609.0.PKG'));

   oo = cute('cut');
   oo.par.package = '@LPC03.200609';
   [ID,number,machine,digits] = id(oo);     % ID = '@LPC03.200609.0.CUT'
   assert(is(ID,'@LPC03.200609.0.CUT'));
   assert(is(number,0));
   assert(is(machine,'LPC03'));
   assert(is(digits,'200609'));

   oo = cute('cut');
   oo.par.package = '@LPC03.200609';
   oo.par.number = 5;
   [ID,number,machine,digits] = id(oo);     % ID = '@LPC03.200609.5.CUT'
   assert(is(ID,'@LPC03.200609.5.CUT'));
   assert(is(number,5));
   assert(is(machine,'LPC03'));
   assert(is(digits,'200609'));
      
   oo = cute('cut');
   oo.par.package = '@LPC03.200609';
   oo.par.number = 123456789;
   [ID,number] = id(oo);                    % ID = '@LPC03.200609.5.CUT'
   assert(is(ID,'@LPC03.200609.123456789.CUT'));

   oo = cute('scp');
   oo.par.package = '@LPC03.200609';
   oo.par.number = 17;
   [ID,number] = id(oo);                    % ID = '@LPC03.200609.17.SCP'
   assert(is(ID,'@LPC03.200609.17.SCP'));
   
   fprintf('   all tests passed without issues :-)\n');
end
