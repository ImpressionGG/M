function [d,sym] = fetch(o,sym)        % Fetch Data by Symbol or Index 
%
% FETCH   Data fetch according to symbol or index
%
%            [d,sym] = fetch(o,sym)    % fetch data & update symbol
%
%         There are some special symbols to be managed:
%
%            d = fetch(o,idx)          % fetch data by config index
%            x = fetch(o,'x')          % fetch x-data by symbol
%
%            t = fetch(o,':')          % fetch data by 'time symbol'
%            s = fetch(o,'#')          % fetch system number info
%
%            rx = fetch(o,'!x')        % fetch main x-coordinates
%            ry = fetch(o,'!y')        % fetch main y-coordinates
%
%            rx = fetch(o,'$x')        % fetch reference x-coordinates
%            ry = fetch(o,'$y')        % fetch reference y-coordinates
%
%         See also: CARALOG, COOK
%
   [m,n,r] = sizes(o);
   r = floor(r);  mn = m*n; 
% 
% if FETCH is called with a stream index we have to convert the stream
% index into a symbol
%
   if isa(sym,'double')
      idx = sym;  
      if (sym)
         sym = config(o,idx);
      else
         sym = ':';
      end
   end
%
% fetch data according to symbol and make a single row out of it
%
   switch sym
      case {':','::'}
         d = data(o,'time');           % first trial: get 'time'
         if isempty(d)                 % if no time information then use
            d = data(o,'t');           % second trial: get 't'
         end
%          if isempty(d)                 % if no time information then use
%             tags = fields(o.data);
%             d = 1:length(o.data.(tags{1}));   % pseudo time 1,2,3,...,m*n*r
%          end
         if isempty(d)                 % if no time information then use
            d = 1:m*n*r;               % pseudo time 1,2,3,...,m*n*r
         end
      case '#'
         d = data(o,'sys');
         if isempty(d)                 % if no system info provided
            d = zeros(1,m*n*r);        % use a properly dim'ed zero vector
         end
      case {'!x','!y'}
         [d,sym] = Main(o,sym);
      case {'$x','$y'}
         d = Reference(o,sym);
      otherwise
         d = data(o,sym);              % fetch data
         d = d(:)';                    % reshape to a single row
   end
%
% if the data is empty there is no need for further processing
%
   if isempty(d) && isequal(sym,':')
      d = 1:m*n*r;                     % recover for special symbol: 1,2,..
   elseif isempty(d)                   % if empty but not special symbol
      return                           % no need for further processing
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [d,symbol] = Main(o,sym)      % Main X/Y Coordinates          
%
% MAIN   Get main x or y coordinates
%
%    The main x/y coordinates can only be calculated if the specified
%    symbol is configured for a subplot with exactly two traces. Otherwise
%    an empty matrix will be returned.
%
%       d = Main(o,'!x');
%       d = Main(o,'!y');
%       d = Main(o,'!z');
%       d = Main(o,'!th');
%
   symbols = Symbols(o,'');
%
% continue only if there are two active symbols in the configuration.
% otherwise return empty stream data
%
   if (length(symbols) ~= 2)
      d = [];  symbol = '?';           % cannot proceed - return empty
      return                           % bye bye!
   end
   
   switch sym
      case '!x'
         symbol = symbols{1};
         d = data(o,symbol);
      case '!y'
         symbol = symbols{2};
         d = data(o,symbol);
      otherwise
         d = [];  symbol = '?';
   end
end

function d = Reference(o,sym)          % Reference X/Y Coordinates     
%
   [m,n,r] = sizes(o);   
   meth = o.either(get(o,'method'),'tlrs');    % TopLeftRowSawtooth
   
   ix = 1:n;  iy = (m:-1:1);
   [Rx,Ry] = meshgrid(ix,iy);

      % we call cook to get the ensemble data. 
      % note that any option setting of 'scope' or 'ignore' needs to
      % be cleared, as this selection is in the responsibility of the
      % caller
      
   o = opt(o,'ignore',0);
   o = opt(o,'scope',[]);
   sys = cook(o,'#','ensemble');
   
   rx = [];  ry = [];
   for (i=1:r)
      sysi = sys(:,i);
      [idx,Idx] = method(o,meth,m,n,sysi);
      rx = [rx, Rx(idx)];
      ry = [ry, Ry(idx)];
   end
   
   switch sym
      case '$x'
         d = rx;
      case '$y'
         d = ry;
      otherwise
         d = [];
   end
   return
end

function [symbols,aux] = Symbols(o,symbol)                             
%
% SYMBOLS   Duplicated local function - see also cook>Symbols
%
   subidx = 0;                         % init subplot index 
   symbols = {};                       % construct symbols in this plot
   total = {};                         % total symbol list (active symbols)
   for (j=1:subplot(o,inf))
      symbols{j} = {};                 % initialize symbols (per subplot)
   end
   
   for (i=1:config(o,inf))
      [sym,sub,col,cat] = config(o,i);
      if (sub > 0)
         if isequal(sym,symbol) 
            subidx = sub;              % mind subplot index
         end
         list = symbols{sub};
         list{end+1} = sym;            % extend list of symbols
         symbols{sub} = list;
         total{end+1} = sym;           % add to total symbol list
      end
   end
%
% now extract the proper symbol list
%
   if length(total) == 2
      symbols = total;  aux = {};
   elseif (subidx > 0)
      symbols = symbols{subidx};
   else
      for (i=1:length(symbols))
         list = symbols{i};
         if length(list) == 2
            symbols = list;
            return
         end
      end
      symbols = {};
   end
end
