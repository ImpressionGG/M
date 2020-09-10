function oo = smart(o,line)
%
% SMART   Create a smart signal configuration
%
%            o = caramel('foo');       % 'foo' typed CARAMEL object
%            oo = smart(foo,'t[s], x[µ]:r#1@1, y[µ]:b#2@1, th[m°]:g#3@2');
%
%         Meaning of lexical parts:
%            x, y, th               symbol names
%            :r, :2b, :g(|o)2       color/width/type strings
%            #1, #2, #3             subplot index
%            @1, @2                 category number
%
%         The existing configuration is resetted and a new configuration
%         is setup according to the definition line string.
%
   [o,symbols,descriptors] = Parse(o,line);  
   [o,descriptors] = Smart(o,descriptors);

%  o.data = [];                        % initialize data property
   dat = o.either(o.data,struct(''));  % data
   tags = fields(dat);
   if isempty(tags)
      zero = [];                       % empty data array
   else
      tag = tags{1};
      zero = 0*dat.(tag);              % proper dimension
   end
   
   for (i=1:length(symbols))
      tag = symbols{i};
      if ~ischar(tag)
         error('all args expected to be char!');
      end
      
      value = o.iif(i==1,0:length(zero)-1,zero);
      o.data.(tag) = o.either(data(o,tag),value);  % initialize data member
   end

   o = launch(o,'shell');              % provide launch function
   o = config(o,symbols);              % default configuration

   for (i=1:length(descriptors))
      bag = descriptors{i};
      o = config(o,bag.sym,{bag.sub,bag.col,bag.cat,bag.label});
   end
   oo = o;                             % pass to output arg
end

%==========================================================================
% Work Horses
%==========================================================================

function [o,symbols,descriptors] = Parse(o,line)                
%
% PARSE Parse the following syntax which is given by example
%
%          oo = smart(caramel,'t[s],x[µ]:r#1,y[µ]#2,th[m°]@g',rand(1+m*3,n));
%   
   symbols = {};
   descriptors = {};
   
      % now parse line string
      
   if length(line) > 0 && line(1) == ','
      line(1) = [];
   end
   line(end+1) = ',';
   
   sym = '';  col = '';  cat = 0;  sub = 0;  unit = '';  label = '';
   n = length(line);  i = 1;
   
   c = Get('impossible error!');
   while (1)
      if (c == ' ')
         c = Get('bad character after white space!');
         continue
      elseif (c == ',')
         if ~isempty(sym)
            bag.sym = sym;
            bag.col = col;
            bag.cat = cat;
            bag.sub = sub;
            bag.unit = unit;
            bag.label = o.either(label,sym);
            symbols{end+1} = sym;
            descriptors{end+1} = bag;
         end
         sym = '';  col = '';  cat = '';  sub = '';  unit = '';  label = '';
         if (i >= n)
            break;
         end
         c = Get('impossible error!');
         continue;               % separator
      elseif IsLetter(c) || IsDigit(c) && ~isempty(sym)
         sym(end+1) = c;
         c = Get('separator expected!');
         continue
      elseif (c == '[')
         c = Get('character expected for unit!');
         while (c ~= ']')
            unit(end+1) = c;
            c = Get('character expected for unit!');
         end
         c = Get('separator expected!');
         continue
      elseif (c == ':')
         c = Get('character expected for color string!');
         while ~IsSpecial(c)
            col(end+1) = c;
            c = Get('character expected for color string!');
         end
         continue
      elseif (c == '@')
         c = Get('digit expected for category number!');
         cat = 0;
         while IsDigit(c)
            cat = cat*10 + (c - '0');
            c = Get('digit expected for category number!');
         end
         continue
      elseif (c == '#')
         c = Get('digit expected for subplot number!');
         sub = 0;
         while IsDigit(c)
            sub = sub*10 + (c - '0');
            c = Get('digit expected for subplot number!');
         end
         continue
      else
         error('syntax error: unexpected character!');
      end
   end % while
   oo = o;
   return
      
   function c = Get(errmsg)            % Get Character                 
      if (i > n)
         error(['syntax error: ',errmsg]);
      end
      c = line(i);  i = i+1;
   end
   function ok = IsLetter(c)           % Is Character a Letter         
      ok = ('a' <= c && c <= 'z' || 'A' <= c && c <= 'Z');
   end
   function ok = IsDigit(c)            % Is Character a Digit          
      ok = ('0' <= c && c <= '9');
   end
   function ok = IsSpecial(c)          % Is it a Special Character     
      ok = (c == ' ' || c == ',' || c == '#' || c == '@');
      ok = ok || (c == ':' || c == '[' || c == ']');
   end
end
function [o,descriptors] = Smart(o,descriptors)                        
   o = subplot(o,'layout',1);          % set subplot layout
   
   if (length(descriptors) >= 1)
      bag = descriptors{1};            % representing time dimension
      bag.sub = NaN;                   % default for time symbol
      bag.col = '*';                   % default for time symbol
      bag.cat = 0;                     % default for time symbol
      descriptors{1} = bag;            % store back
   end

   units = {};
   n = category(o,inf);
   for (cat=1:n)
      [spec,limit,unit] = category(o,cat);
      units{end+1} = unit;
   end
   
   maxsub = 0;
   for (i=2:length(descriptors))
      bag = descriptors{i};
      if isempty(bag.sym)
         error('symbol cannot be empty!');
      end
      [sub,col,cat] = config(o,bag.sym);
      
      if isempty(cat)
         cat = find(o,bag.unit,units);
         if (cat == 0)
            units{end+1} = bag.unit;
            cat = length(units);
            o = category(o,cat,[],[],bag.unit); 
         end
      end
      
      if isempty(bag.cat)
         bag.cat = cat;
      end
      if isempty(bag.sub)
         bag.sub = o.either(sub,maxsub+1);
      end
      if isempty(bag.col)
         bag.col = o.either(col,o.color(i));
      end
      if isempty(bag.unit)
         if length(units) >= cat
            unit = units{cat};
            bag.unit = unit;
         end
      end
      descriptors{i} = bag;
      maxsub = max(maxsub,bag.sub);
   end
end
