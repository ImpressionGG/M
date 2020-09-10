function value = subsref(obj,s)
%
% SUBSREF   Subscripted reference for SMART '#BULK' objects. 
%           Exapmple:
%
%              value = obj.pU   % get subscripted value by '.pU'
%
%           This statement will get the data part according to symbol 'pU'
%           of a SMART bulk data object. The special case
%
%              t = obj.time    % get time stamp vector
%
%           will retrieve the time stamp vector.
%
%           Remark: depending on option 'nanmode' all NaNs in the data will
%           be replaced (nanmode = 1) or NaNs will be left (nanmode=0).
%
%           See also: SMART DATA BULK
%
   n = length(s);
   sym  = '';
   for (i=1:n)
      if (s(i).type ~= '.')
         error('subsref for SMART objects expects always ''.''!');
      end
      sym = [sym,s(i).subs];
      if (i < n)
         sym = [sym,'.'];
      end
   end

      % check for '#BULK' format!
      
   fmt = format(obj);
   if ~strcmp(fmt,'#BULK')
      error('#BULK data format expected for subscripted reference!');
   end

      % get numerical index for data
   
   if (strcmp(sym,'time'))  % symbol 'time' gets special treatment
      idx = 0;
   else
      dat = data(obj);
      idx = match(sym,dat.symbols);
      if isempty(idx)
         error(['cannot subscript by symbol: ',sym,' !']);
      end
   end

      % now retrieve data

   rawval = retrieve(obj,idx);     % smart retrieve
   
   if either(option(obj,'nanmode'),1)
      for (i=1:size(rawval,1))
         value(i,:) = nanreplace(rawval(i,:));
      end            
   else
      value = rawval;
   end
   return

%==========================================================================
% Auxillary functions
%==========================================================================

function val = retrieve(obj,j)  
%
% RETRIEVE   Retrieve j-th data stream by numeric index (j).
%
%               val = retrieve(smo,j)
%
   profiler('retrieve',1);     % start profiling
   dat = data(obj);
   dim = dat.dim;

   bulk = dat.bulk;
   M = length(dat.t);               % length of time vector
   N = length(dat.symbols);         % length of symbol list 
   
   %Nts = dat.timestamps;            % number of columns for time stamps
   Nts = 1;
   if (Nts ~= 1)
      error('number of time stamps must be 1 for smart data storage!');
   end
   
   [m,n] = size(dat.bulk);
   if (m ~= M)
      error('inconsistent row numbers of bulk data!');
   end
   if (n ~= N*dim)
      error('inconsistent column numbers of bulk data!');
   end
   
   if (j == 0)   % time stamps
      if (Nts > 1)
         error('number of timestamps must be either 0 or 1!');
      elseif (Nts == 0)  % take index as time stamps
         val = 0:size(dat.bulk,1)-1;
      else  % take time stamps of bulk data
         val = dat.t';
      end
   elseif (1 <= j & j <= N)  % measurement data
      val = dat.bulk(:,dim*(j-1)+(1:dim))';   
   else
      error('index out of range!'); 
   end
     
   profiler('retrieve',0);     % end profiling
   return
   
%==========================================================================

function val = nanreplace(val)   % replace all NaNs
%
% NANREPLACE  Replace all NaNs in a vector set
%             1) Each leading NaN is to be replaced by the first 
%              non NaN value on the right side.
%
%             2) Each intermediate and trailing NaN is to be replaced the first 
%                non NaN value on the left side.

      % Start by temporarily adding a non-NaN dummy column. This dummy column
      % is called "stopper" and makres sure that the algorithm does not crash

   profiler('nanreplace',1);
   
   [m,n] = size(val);
   for (i=1:m)
      vi = val(i,:);
      if all(isnan(vi))
         vi = zeros(1,n);
      else
         jdx = find(~isnan(vi));
         jmin = min(jdx);
         vi(1) = vi(jmin);

         v = vi(1);
         for (j=2:n)
            if isnan(vi(j))
               vi(j) = v;
            else
               v = vi(j);
            end
         end
      end
      val(i,:) = vi;
   end
   
   profiler('nanreplace',0);
   return
   
   
%eof   
