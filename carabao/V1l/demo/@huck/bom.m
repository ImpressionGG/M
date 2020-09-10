function blist = bom(o,list)           % Bill of Materials             
%
% BOM   Bill of materials: Get a list of bill of materials or print bill of
%       materials
%
%          bom(o);                                      % print table
%          bom(o,{{'C1','C4µ7'},{'L1','L47n'}});        % print bom
%          list = bom(o,{{'C1','C4µ7'},{'L1','L47n'}}); % get bom
%
%       List of components
%
%       Resistors
%          1k@1/4W           1 kOhm / 0.25 W
%          10k1/4W           10 kOhm / 0.25 W
%
%       Capacitors
%          47uF@10V          47µF / 10 V
%          100uF@6.3V        100µF / 6.3 V
%
%       SCRs
%          BT169             0.8A / 800 V   (peak 10A)
%
%       See also: HUCK
%
   if nargout >= 1
      blist = GetBom(o,list);
   elseif nargin >= 2
      PrintBom(o,list);
   elseif nargin == 1
      PrintTable(o);
   end
end

%==========================================================================
% Table Setup
%==========================================================================

function table = Table(o)              % Component Table                
   A = 'A';  V = 'V';  Ohm = 'Ohm';    % short hands
   W = 'W';  E = '€';  kOhm = 'kOhm';  % short hands
   uF = 'µF'; uH = 'µH';  mA = 'mA';   % short hands
   P = '%'; mOhm = 'mOhm';             % short hands
   table = {
      'Resistors'
      
      {'0.2@1/4W',{0.2 Ohm 1/4 W}  {.001 E 5000} [02 04 02], {'Murata', '???'}, ''}
      {'0.4@1/4W',{0.4 Ohm 1/4 W}  {.001 E 5000} [02 04 02], {'Murata', '???'}, ''}
      {'1@1/4W',  {  1 Ohm 1/4 W}  {.001 E 5000} [02 04 02], {'Murata', '???'}, ''}
      {'86@1/4W', { 86 Ohm 1/4 W}  {.001 E 5000} [02 04 02], {'Murata', '???'}, ''}
      {'100@1/4W',{100 Ohm 1/4 W}  {.001 E 5000} [02 04 02], {'Murata', '???'}, ''}
      {'220@1/4W',{220 Ohm 1/4 W}  {.001 E 5000} [02 04 02], {'Murata', '???'}, ''}
      {'1k@1/4W', {  1 kOhm 1/4 W} {.001 E 5000} [02 04 02], {'Murata', '???'}, ''}
      {'10k@1/4W',{ 10 kOhm 1/4 W} {.001 E 5000} [02 04 02], {'Murata', '???'}, ''}

      'Capacitors'
      
      {'1uF@10V',   {  1 uF 10 V 10 P}  {.169 E 4000} [32 25 14], {'Panasonic', 'ECP-U01105MA5'}, ''}
      {'1uF@16V',   {  1 uF 16 V 10 P}  {.070 E 4000} [10 05 05], {'Murata',    'GRM155R61C105KE01D'}, ''}
      {'4.7uF@16V', {4.7 uF 16 V 20 P}  {.026 E 4000} [32 16 16], {'Vishay',    'VJ1206V475MXJTW1BC'}, ''}
      {'47uF@10V',  { 47 uF 10 V 20 P}  {.071 E 4000} [35 28 19], {'AVX',    'TAJB476M010TNJ'}, ''}
      {'47uF@16V',  { 47 uF 16 V 10 P}  {.110 E 4000} [60 32 28], {'AVX',    'TAJC476K0165NJ'}, ''}
      {'100µF@6.3V',{100 uF 6.3 V} {.111 E 5000} [32 16 16], {'Murata', 'GRM31CD80J107ME39L'}, ''}
      {'470uF@16V', {470 uF 16 V 20 P}  {.130 E 4000} [73 43 38], {'AVX',    'TCJ5477M016R0100'}, ''}

      'Inductors'
      
      {'1uH@1.6A',  {  1 uH .361 A 55 mOhm},{0.361 '€' 36000}, [25 20 09], {'Bourns','CVH252009-1R0M'}, '!!'}
      {'10uH@15mA', { 10 uH 1.76 A 89 mOhm 20 P},{0.021 '€' 3000}, [404025], {'Wurth','74404043100A'}, '!'}
      {'10uH@2.6A', { 10 uH 15 mA 46 mOhm},{0.020 '€' 8000}, [60 60 28], {'Taiyo',    '???'}, ''}
      {'4.7uH@1.1A',{ 4.7 uH 1.1 A 290 mOhm},{0.140 '€' 5000}, [20 16 11], {'???',    '???'}, ''}
      {'4.7uH@3A',  { 4.7 uH 3.0 A 31 mOhm 20 P},{0.082 '€' 24000}, [60 60 28], {'Taiyo',   'NR6028T4R7M'}, '!!!'}

      'Diodes'
         
      {'D50V@.2A',  { 0.2 'A' 50 'V'},{0.010 '€' 5000},  [29 13 10], {'ON-Semi',  'BAV74LT1G'}, 'dual diode, 0.5A surge'}
      {'D600V@.25A',{ 0.25 'A' 600 'V'},{0.028 '€' 5000},[30 14 10], {'NEXPERIA', 'BAW101.215'}, 'dual diode, 4.5A surge'}
      {'D1kV@1A',   { 1 'A' 1000 'V'},{0.026 '€' 5000},  [46 29 21], {'DIODES',   'S1M-13-F'}, 'single diode, 30A surge'}

      'Zener Diodes'
         
      {'Z3.3V@.3W',  { 3.3 'V' 0.3 'W'},{0.011 '€' 5000},  [17 13 09], {'ON-Semi',  'MM3Z3V3T1G'},   ''}
      {'Z6.3V@.3W',  { 6.3 'V' 0.3 'W'},{0.011 '€' 5000},  [17 13 09], {'???',      '???'},          ''}
      {'Z15V@.5W',   {  15 'V' 0.5 'W'},{0.017 '€' 5000},  [29 17 14], {'Diodes',   'BZT52C15-7-F'}, ''}
      {'Z75V@.3W',   {  75 'V' 0.3 'W'},{0.011 '€' 5000},  [29 13 10], {'ON-Semi',  'BZX84C75LT1G'}, ''}
      {'Z200V@1W',   { 200 'V' 1.0 'W'},{0.052 '€' 5000},  [48 28 24], {'TW Semi',  '15MA200ZR2'},   ''}

      'Thyristors'
         
      {'BT169H', { 0.8 'A' 800 'V'},{0.036 '€' 5000},  [52 48 42], {'WeEn',  'BT169H/01U'}, 'SCR 0.8A, peak 10 A'}
      
      'Triacs'
         
      {'BTA204W-800',{1.0 A 800 V 0.7 V 11 A} {.172 E 20000} [73 67 18],   {'WeEn',  'BT131-600,116'}, 'Triac 1A, TO-92, peak 13.8A, 1.2Von'}
      {'BT131-600', { 1.0 A 600 V 1.2 V     } {.078 E 50000} [52 48 42],   {'WeEn',  'BT131-600,116'}, 'Triac 1A, TO-92, peak 13.8A, 1.2Von'}
      {'BT137S-600',{ 8.0 A 600 V 1.3 V 71 A} {.194 E 10000} [100 67 24],  {'WeEn',  'BT137S-600,118'}, 'Triac 8A, DPAK-3, peak 71A, 1.3Von'}
      {'BT139-800G',{  16 A 800 V 1.2 V     } {.304 E 10000} [160 100 47], {'WeEn',  'BT139-800G,127'}, 'Triac 16A, TO-220, peak 170A, 1.2Von'}
      
   };   % end of table
end

%==========================================================================
% GetBom
%==========================================================================

function olist = GetBom(o,list)        % Get BoM                        
   table = Table(o);
   olist = {};
   for (i=1:length(list))
      pair = list{i};
      name = pair{1};  item = pair{2};
      found = false;
      for (j=1:length(table))
         entry = table{j};
         if iscell(entry) && isequal(entry{1},item)
            olist{end+1} = entry;
            found = true;
            break
         end
      end
      if ~found
         error(['cannot find item ''',item,'''!']);
      end
   end
end

%==========================================================================
% PrintBom
%==========================================================================

function o = PrintTable(o)
   table = Table(o);
   for (i=1:length(table))
      entry = table{i};
      if ischar(entry)
         PrintHead(upper(entry));   
      else      
         Print('',entry);
      end
   end
end
function o = PrintBom(o,list)          % Print BoM List                
   table = Table(o);
   cost = 0;
   if ~isempty(list) && ischar(list{1})
      PrintHead(list{1});
      list(1) = [];
   else
      PrintHead;
   end
   
   for (i=1:length(list))
      pair = list{i};
      if isempty(pair)
         continue                      % ignore empty spacers
      end
      name = pair{1};  item = pair{2};
      found = false;
      for (j=1:length(table))
         entry = table{j};
         if iscell(entry) && isequal(entry{1},item)
            Print(name, entry);
            price = entry{3};
            cost = cost + price{1};
            found = true;
            break
         end
      end
      if ~found
         error(['cannot find item ''',item,'''!']);
      end
   end
   PrintFoot(cost);
end
function Print(name,entry)             % Print BoM Entry               
   id = entry{1};                      % component ID
   q = entry{2};                       % primary quantity
   price = entry{3};
   sizes = entry{4};
   supplier = entry{5};
   comment = entry{6};
   
   fprintf('%-4s %-12s',name,id);           % id
   
   rating = '';
   for (j=1:2:length(q))
      sep = carabull.iif(j==1,'',',');
      val = carabull.trim(Val(q{j},4));
      unit = q{j+1};
      rating = [rating,sep,sprintf('%s%s',val,unit)];
   end
   fprintf('| %-20s|',rating);

   txt = sprintf('%6f',price{3});
   unit = price{2};
   fprintf(' %s%5.3f #%s|',unit,price{1},Val(price{3},-6));
   fprintf(' %-10s| %-20s | %s',supplier{1},supplier{2},comment);
   fprintf('\n');
end
function PrintHead(head)               % Print BoM Head                
   fprintf('%s\n',Underline);
   if (nargin >= 1)
      fprintf('%-17s\n%s\n',head,Underline('-'));
   end
   fprintf('Name ID          | Rating              | Pricing       | Supplier  | Article              | Comment\n');
   fprintf('%s\n',Underline);
end
function PrintFoot(total)              % Print BoM Footer              
   fprintf('%s\n',Underline);
   fprintf('Total cost:                        €%6.3f\n',total);
end
function s = Val(x,n)                  % Format Value                  
   if (n > 0)
      s = sprintf('                      %g',x);
      s = s(end-n+1:end);
   else
      s = sprintf('%g                      ',x);
      s = s(1:-n);
   end
end
function txt = Underline(chr)          % Generate Underline String     
   if nargin < 1
      chr = '=';
   end
   n = 110;
   txt = char(zeros(1,n) + chr);
end
