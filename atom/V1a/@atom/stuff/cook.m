function [d,df,sym] = cook(o,sym,varargin)   % The Data Cook                 
%
% COOK   The data cook
%
%    Cook up data according to selected cook mode and bias mode options
%
%       [d,df,sym] = cook(o,idx)       % get cooked data by config index
%       x = cook(o,'x')                % get cooked x-data by symbol
%
%       t = cook(o,':')                % get cooked data by 'time symbol'
%       s = cook(o,'#')                % get cooked system number info
%
%       rx = cook(o,'!x')              % get cooked main x-coordinates
%       ry = cook(o,'!y')              % get cooked main y-coordinates
%
%       rx = cook(o,'$x')              % get cooked reference x-coordinates
%       ry = cook(o,'$y')              % get cooked reference y-coordinates
%
%    The cook mode can be also directly passed
%
%       x = cook(o,'x','overlay')           % explicite 'cook' mode option
%       x = cook(o,'x','overlay','drift')   % explicite 'drift' bias option
%       x = cook(o,'x',mode,bias,scope)   % explicite 'drift' bias option
%
%    COOK incorporates the following options:
%
%       opt(o,'cook')
%          'stream'                    % return a data stream
%          'fictive'                   % fictive stream
%
%          'overlay'                   % matrix based data overlays
%          'offset'                    % calculate mean values of overlay
%          'repeatability'             % repeatability stream corrected by mean
%          'sigma'                     % calculate sigma values of overlay
%
%          'ensemble'                  % ensemble of data threads
%          'average'                   % calculate average of ensemble
%          'spread'                    % calculate sigma values of ensemble
%          'deviation'                 % deviation of ensemble from average
%
%          'condensate1'               % calculate order 1 condensate
%          'condensate2'               % calculate order 2 condensate
%          'condensate3'               % calculate order 3 condensate
%
%          'segment'                   % calculate segments time stamps
%          'piece'                     % calculate data piece indices
%          'matrix'                    % calculate list of matrices
%
%       opt(o,'bias')
%          'drift'                     % drift mode
%          'absolute'                  % absolute mode
%          'abs1000'                   % absolute * 1000 mode
%          'deviation'                 % deviation mode
%
%       opt(o,'overlays')
%          'index'                     % index mode
%          'time'                      % time mode
%
   o.profiler('Cook',1);               % begin profiling
   
   o = Args(o,varargin);               % store args to options
   [d,sym] = FetchData(o,sym);         % fetch data & form properly

   if isequal(sym,':')                 % if symbol denotes time      
      d = CookTime(o,d,sym);
   else
      d = CookOther(o,d,sym);

      o = opt(o,'filter.enable',1);
      filtermode = opt(o,{'filter.mode','raw'});
      switch filtermode
         case 'raw'
            df = [];
         case 'filter'
            d = filter(o,d);  df = [];
         case 'noise'
            if ~isempty(d)
               d = d - filter(o,d);
            end
            df = [];
         case 'both'
            df = filter(o,d);
      end
   end
   o.profiler('Cook',0);               % end profiling
end

%==========================================================================
% Helper Functions
%==========================================================================

function d = CookTime(o,d,sym)         % Data Cooking for Time Symbol  
   mode = opt(o,'mode');               % get mode
   scope = opt(o,'scope');             % get scope option
   ignore = opt(o,'ignore');           % how many rows to ignore

   switch mode
      case {'ensemble','average','spread','deviation',...
            'condensate1','condensate2','condensate3'}
         d = 1:size(d,1);              % row numbering
         if ~isempty(scope)
            sidx = Scope(scope,ignore);
            if prod(size(sidx)) ~= length(d)
               error('bad settings! (change settings)');
            end
            d = sidx(:)';
         elseif (ignore > 0)
            d = d + ignore;
         end

      case {'overlay','offsets','sigma','repeatability',...
            'residual1','residual2','residual3'}
         overlays = opt(o,'overlays');
         if isequal(overlays,'index')
            one = ones(size(d,1),1);
            d = one*(1:size(d,2));     % use position indices instead
         elseif isequal(overlays,'time')
            d0 = d(:,1)*ones(1,size(d,2));
            d = d - d0;
         else
            error('bad overlays mode value!');
         end

      case {'grid','segment'}          % this is for segment grid lines
         t = d;  d = 1;
         for (i=1:size(t,1)-1)
            %d(end+1) = [t(i,end) + t(i+1,1)] / 2;
            d(end+1) = t(i+1,1);
         end
         d(end+1) = max(t(:));

      case {'piece'}                % for rows/column piece grid lines
         d = 1:size(d,2);           % use segment indices instead
         [m,n] = sizes(o);
         
         %l = property(o,'piece');   % length of piece
         method = get(o,'method');
         piece = m*n;
         if ~isempty(method) && method(3) == 'c'      % column wise
            piece = m;
         elseif ~isempty(method) && method(3) == 'r'  % row wise
            piece = n;
         end
         l = piece;
         
         p = m*n/l;                 % number of pieces

         t = reshape(d,l,p);        % reshape data to a matrix
         d = 1;
         for (j=1:p-1)
            %d(end+1) = [t(end,j) + t(1,j+1)] / 2;
            d(end+1) = t(1,j+1);
         end
         d(end+1) = max(t(:));

      case 'fictive'
         d = d';                    % transpose before flattening
         d = d(:)';                 % flatten and transpose to row

      case 'matrix'                 % list of matrices
         sidx = Scope(scope,ignore);
         for (i=1:length(sidx))
            di = d(:,sidx(i));
            Di = di(Idx);  D{i} = Di;
         end
         d = D;

      otherwise
         'I am ok!';
   end
end
function d = CookOther(o,d,sym)        % Data Cooking for Other Symbols
   overlays = opt(o,'overlays');       % get overlays option
   bias = opt(o,'bias');               % get bias option
   mode = opt(o,'mode');               % get mode
   scope = opt(o,'scope');             % get scope option
   filt = opt(o,'filter'); 
   
   if isempty(d)
      return                           % nothing to do if d is empty
   end
   
   while ~isequal(sym,':')                  % if other symbol than time     
      switch mode
         case 'offsets'                           % mean values of columns
            d = Offsets(o,d);
%             zero = 0*d(1,:);                      % in case of recovery
%             if isempty(d)
%                d = zero;                          % recovery if empty
%             else
%                d = o.iif(size(d,1)==1,d,mean(d));
%             end
% %           if (filt.enable)
% %              d = filter(o,d);                   % filter the offsets
% %           end
%             if isequal(bias,'drift')
%                d = d - d(1);                      % convert to drift
%             elseif isequal(bias,'deviation')
%                d = d - mean(d(:));                % convert to deviation
%             end
            
         case 'sigma'                             % std. dev. of columns
            d = o.iif(size(d,1)==1,0*d,std(d));

         case {'oldrepeatability'}
            avg = o.iif(size(d,1)==1,d,mean(d));  % row average values
            if ~isequal(filt.mode,'raw')
               avg = filter(o,avg);               % filter the offsets
            end
            d = d - ones(size(d(:,1))) * avg;     % unbiased

         case 'repeatability'
            d = Repeatability(o,d);
%           d0 = Offsets(o,d);
%           if isequal(bias,'drift')
%              d = d - d(:,1)*ones(size(d(1,:))); % convert to drift
%           elseif isequal(bias,'deviation')
%              d = d - mean(d(:));                % convert to deviation
%           end
%           d0 = ones(size(d(:,1))) * d0;
%           d = d - d0; 
            
         case {'residual1'}
            d = Residual(o,sym,1);                % calculate residual

         case {'residual2'}
            d = Residual(o,sym,2);                % calculate residual

         case {'residual3'}
            d = Residual(o,sym,3);                % calculate residual

         case {'fictive'}                         % fictive stream
            avg = o.iif(size(d,1)==1,d,mean(d));  % row average values      
            if ~isequal(filt.mode,'raw')
               avg = filter(o,avg);               % filter the offsets
            end
            d = d - ones(size(d(:,1))) * avg;     % unbiased
            d = d';                    % transpose before flattening
            d = d(:)';                 % flatten and transpose to row
            
         case {'stream'}                          % normal stream
            one = ones(size(d(1,:)));
            if isequal(bias,'drift')
               d = d - d(:,1)*one;                % convert to drift
            elseif isequal(bias,'deviation')
               d = d - mean(d(:));                % convert to deviation
            end
            
         case {'ensemble'}                        % mean values of rows
            one = ones(size(d(:,1)))';
            d = d';                               % transpose   
            if isequal(bias,'drift')
               d = d - d(:,1)*one;                % convert to drift
            elseif isequal(bias,'deviation')
               d = d - mean(d(:));                % convert to deviation
            end

         case {'average'}                         % mean values of rows
            d = d';                               % transpose   
            if isequal(bias,'drift')
               d = d - d(:,1)*ones(size(d(1,:))); % convert to drift
            elseif isequal(bias,'deviation')
               d = d - mean(d(:));                % convert to deviation
            end
            d = d';                               % transpose back   
            d = o.iif(size(d,2)==1,d',mean(d'));  % row average values      

         case {'overlay'}                         % mean values of rows
            if isequal(bias,'drift')
               d = d - d(:,1)*ones(size(d(1,:))); % convert to drift
            elseif isequal(bias,'deviation')
               d = d - mean(d(:));                % convert to deviation
            end

         case {'deviation'}                       % deviation of ensemble from average
            d = d';                               % transpose   
            if isequal(bias,'drift')
               d = d - d(:,1)*ones(size(d(1,:))); % convert to drift
            elseif isequal(bias,'deviation')
               d = d - mean(d(:));                % convert to deviation
            end
            d = d';                               % transpose back   
            D = d';                               % save data
            d = o.iif(size(d,2)==1,d',mean(d'));  % row average values      
            d = D - ones(size(D,1),1)*d;          % build deviation
            
         case {'spread'}                          % sigma values of rows
            d = d';                               % transpose   
            if isequal(bias,'drift')
               d = d - d(:,1)*ones(size(d(1,:))); % convert to drift
            end
            d = d';                               % transpose back   
            d = o.iif(size(d,2)==1,0*d',3*std(d')); % row average values      
            
         case {'condensate1'}              
            d = Condensate(o,sym,1);              % calculate condensate

         case {'condensate2'}              
            d = Condensate(o,sym,2);              % calculate condensate

         case {'condensate3'}              
            d = Condensate(o,sym,3);              % calculate condensate

         case 'matrix'                 % list of matrices
            if isequal(bias,'drift')
               d = d - d(:,1)*ones(size(d(1,:))); % convert to drift
            elseif isequal(bias,'deviation')
               d = d - mean(d(:));                % convert to deviation
            end
            sidx = Scope(scope,ignore);
            for (i=1:length(sidx))
               di = d(:,sidx(i));
               Di = di(Idx);  D{i} = Di;
            end
            d = D;
            
         otherwise
            'I am ok!';
      end
      return
   end
end

function [d,sym] = FetchData(o,sym)    % Fetch Data & Form Properly    
%
%
% FETCH-FORM   Fetch data & form properly according to index or symbol
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
%         See also: CARMA, COOK
%
   mode = opt(o,'mode');               % get mode
   [d,sym] = fetch(o,sym);             % fetch data by symbol or index
%
% The next big thing is re-arranging the data for overlay display. This is
% also the basis for many other cooking recipes for which different post
% processing will follow.
%
   bias = opt(o,'bias');               % get bias option
   scope = opt(o,'scope');             % get scope option
   ignore = opt(o,'ignore');           % how many rows to ignore
   
   [m,n,r] = sizes(o);
   r = floor(r);  mn = m*n; 

   mode = opt(o,'mode');
   switch mode
      case {'overlay','offsets','ensemble','average','spread','deviation',...
            'residual1','residual2','residual3',...
            'condensate1','condensate2','condensate3',...
            'sigma','grid','segment','piece','repeatability','fictive'}
         while ~isempty(d)                   % previously: while (1)
            D = Pick(o,d)';
            d = reshape(d(1:mn*r),mn,r)';   % transpose after reshaping
            if ~isempty(scope)
               sidx = Scope(scope,ignore);  % scope index
               d = d';                 % first transpose back
               d = d(:,sidx)';         % pick only columns in scope
            elseif ~isempty(ignore)
               idx = 1:min(ignore,size(d,1));
               d(idx,:) = [];          % ignore a number of rows
            end
            assert(isequal(d,D));
            break
         end
         %d = Pick(o,d)';              % pick data and transpose
         
      case 'stream'
         while ~isempty(d)                   % previously: while (1)
            D = Pick(o,d);  dd = D(:)';% pick data
            d = reshape(d(1:mn*r),mn,r)'; % transpose after reshaping
            if ~isempty(scope)
               sidx = Scope(scope,ignore);
               d = d';                 % first transpose back
               d = d(:,sidx)';        % pick only columns in scope
            elseif ~isempty(ignore)
               idx = 1:min(ignore,size(d,1));
               d(idx,:) = [];          % ignore a number of rows
            end
            d = d';  d = d(:)';        % transpose back & flatten to a row
            %assert(isequal(d,dd));
            break
         end
         %[~,d] = Pick(o,d);           % pick data and make a row
         
      case 'matrix'
         d = reshape(d(1:mn*r),mn,r);  % transpose after reshaping
         if isempty(scope)
            scope = 1:r;
         end
         meth = get(o,'method');
         if isempty(meth)
            error('method needs to be defined for split into matrices!');
         end
         [~,Idx] = method(o,meth,m,n); % index now calculated - rest later
         
      otherwise
         error(['bad mode: ',mode,'!']);
   end
end
function [D,d] = Pick(o,d)             % Pick Relevant Data Set        
%
% PICK   Pick data properly according to 'scope' and 'ignore' option
%        Input arg d must be a row or column vector.
%
%           D = Pick(o,d)              % pick data
%
%        Output arg d is a row vector and D is a matrix of columns
%        To get a data row vector (e.g. for stream plot) use
%
%           d = D(:)';
%
   if isempty(d);
      D = [];
      return
   end
   
   if min(size(d)) > 1
      error('data vector expected for arg2!');
   end

   scope = opt(o,{'scope',[]});  % pick columns according to scope
   ignore = opt(o,{'ignore',0}); % how many rows to ignore
   [m,n,r] = sizes(o);           % rows, columns, repeats
   r = floor(r);  mn = m*n;      % datapoints per matrix
   
   D = reshape(d(1:mn*r),mn,r);  % reshape data
   if ~isempty(scope)
      sidx = Scope(scope,ignore);
      D = D(:,sidx);             % pick only columns in scope
   elseif ~isempty(ignore)
      idx = 1:min(ignore,size(D,2));
      D(:,idx) = [];             % ignore a number of columns
   end
   
   if (nargout > 1)
      d = D(:)';
   end
end

function d = Offsets(o,d)              % Offset Calculation            
   bias = opt(o,'bias');               % get bias option
   zero = 0*d(1,:);                      % in case of recovery
   if isempty(d)
      d = zero;                          % recovery if empty
   else
      d = o.iif(size(d,1)==1,d,mean(d));
   end
%  if (filt.enable)
%     d = filter(o,d);                   % filter the offsets
%  end
   if isequal(bias,'drift')
      d = d - d(1);                      % convert to drift
   elseif isequal(bias,'deviation')
      d = d - mean(d(:));                % convert to deviation
   end
end
function d = Repeatability(o,d)        % Repeatability Calculation     
   bias = opt(o,'bias');               % get bias option
   d0 = Offsets(o,d);
   if isequal(bias,'drift')
      d = d-d(:,1)*ones(size(d(1,:))); % convert to drift
   elseif isequal(bias,'deviation')
      d = d - mean(d(:));              % convert to deviation
   end
   d0 = ones(size(d(:,1))) * d0;       % convert row to offset matrix
   d = d - d0;                         % subtract offsets
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function o = Args(o,args)              % Get Arguments                 
%
% ARGS   Store args to options - provide defaults as necessary
%
%           o = Args(o,args)
%
%        Remark: args might be {mode,bias,scope,ignore}
%
   o = modes(o);                       % provide plot modes
   
   if  (length(args) < 1)
      mode = opt(o,{'mode.cook','stream'});
   else
      mode = args{1};
   end
   
   if  (length(args) < 2)
      bias = opt(o,'bias');
   else
      bias = args{2};
   end
   
   if  (length(args) < 3)
      scope = opt(o,{'scope',[]});
   else
      scope = args{3};
   end
   
   if  (length(args) < 4)
      ignore = opt(o,{'ignore',0});
   else
      ignore = args{4};
   end
   
      % check scope
      
   [m,n,r] = sizes(o);
   r = floor(r);  mn = m*n;  

   while(1)                            % this is a WHILE-BREAK statement
      scope = scope(:)';
      if ~isempty(scope)
         if ~isa(scope,'double')
            error('option scope must be a double vector');
         end
         if any(scope < 1 | scope > r) || any(scope ~= round(scope))
            error('all scope indices must be integer values in range 1:repeats!');
         end
      end
      break
   end
      
      % set options properly
      
   o = opt(o,'mode',mode);
   o = opt(o,'bias',bias);
   o = opt(o,'scope',scope);
   o = opt(o,'ignore',ignore);
end
function c = Residual(o,symbol,order)                                  
%
% RESIDUAL   Calculate residual
%
%    A residual can only be calculated if the specified symbol is con-
%    figured for a subplot with exactly two traces. Otherwise an empty
%    matrix will be returned.
%
   if (order < 1 || order > 3)
      error('order (arg3) must be 1,2 or 3!');
   end
   
   scope = opt(o,{'scope',[]});        % subselection by scope
   ignore = opt(o,{'ignore',0});       % how many rows to ignore
   
   symbols = Symbols(o,symbol);
%
% continue only if there are two active symbols in the configuration.
% otherwise return empty stream data
%
   meth = get(o,{'method','TopLeftColSawtooth'});
   if (length(symbols) ~= 2) || isempty(meth)
      c = [];                          % cannot proceed - return empty
      return                           % bye bye!
   end
%
% get sizes for reshaping
%
   [m,n,r] = sizes(o);  
   r = floor(r);
%
% reshape data
%
   d1 = data(o,symbols{1});            % first coordinate
   while (1)
      D1 = Pick(o,d1);                 % pick data
      d1 = d1(:)';
      d1 = reshape(d1(1:m*n*r),m*n,r)';% reshape and transpose
      if ~isempty(scope)
         sidx = Scope(scope,ignore);
         d1 = d1(:,sidx);              % pick only columns in scope
      elseif ~isempty(ignore)
         d1(1:ignore,:) = [];          % ignore a number of rows
      end
      d1 = d1';                        % transpose back
      assert(isequal(d1,D1));
      break
   end
   %d1 = Pick(o,d1);                   % pick data
   
   d2 = data(o,symbols{2});            % second coordinate
   while (1)
      D2 = Pick(o,d2);                 % pick data
      d2 = d2(:)';
      d2 = reshape(d2(1:m*n*r),m*n,r)';% reshape and transpose
      if ~isempty(scope)
         sidx = Scope(scope,ignore);
         d2 = d2(:,sidx);              % pick only columns in scope
      elseif ~isempty(ignore)
         d2(1:ignore,:) = [];          % ignore a number of rows
      end
      d2 = d2';                        % transpose back
      assert(isequal(d2,D2));
      break
   end
   %d2 = Pick(o,d2);                    % pick data
   
   sys = cook(o,'#','stream');         % system information
   sys = sys(:)';
   
      % option 'scope' or 'ignore' might have reduced the number of
      % data points so r needs to be recalculated!
      
   r = prod(size(sys))/(m*n);
   sys = reshape(sys(1:m*n*r),m*n,r);
%
% cross check sizes
%
   [mn,rr] = size(d1);
   assert(mn==m*n && r==rr);
%
% now reconstruct the matrices in a loop
%
   [~,Idx] = method(o,meth,m,n);        % get indices
   for (j=1:r)
      D1j = d1(:,j);                    % get j-th column
      D1 = D1j(Idx);                    % reshape
      
      D2j = d2(:,j);                    % get j-th column
      D2 = D2j(Idx);                    % reshape
      
      Sj = sys(:,j);                    % get j-th column
      S = Sj(Idx);                      % reshape
      
      [Q1,Q2] = meshgrid(1:n,1:m);
      q = [Q1(:), Q2(:)]';
      d = [D1(:), D2(:)]';
      s = S(:)';  systems = s;
      
         % first calculate map by affine fit, then map isometric coordi-
         % nates to y. The difference d-y is the condensate

      c1(1:mn,j) = zeros(mn,1);        % init with zeros
      c2(1:mn,j) = zeros(mn,1);        % init with zeros
         
      while ~isempty(systems)
         sn = min(systems);            % system number
         index = find(sn == systems);
         if ~isempty(index)
            idx = find(sn == s);
            C = map(o,q(:,idx),d(:,idx),order);
            yidx = map(o,C,q(:,idx));
      
            c = d(:,idx)-yidx;           % residual
      
            c1(idx,j) = c(1,:)';
            c2(idx,j) = c(2,:)';
         end
         systems(index) = [];
      end
   end
%
% pick the proper data stream for the specified symbol
%
   if isequal(symbol,symbols{1})
      c = c1 - mean(c1')'*ones(1,r);
   elseif isequal(symbol,symbols{2})
      c = c2 - mean(c2')'*ones(1,r);
   else
      c = [];                           % should never happen!
   end
 end
function c = Condensate(o,symbol,order)                                
%
% CONDENSATE   Calculate condensate
%
%    A condensate can only be calculated if the specified symbol is con-
%    figured for a subplot with exactly two traces. Otherwise an empty
%    matrix will be returned.
%
   if (order < 1 || order > 3)
      error('order (arg3) must be 1,2 or 3!');
   end
   
   symbols = Symbols(o,symbol);
%
% continue only if there are two active symbols in the configuration.
% otherwise return empty stream data
%
   meth = get(o,{'method','TopLeftColSawtooth'});
   if (length(symbols) ~= 2) || isempty(meth)
      c = [];                          % cannot proceed - return empty
      return                           % bye bye!
   end
%
% get sizes for reshaping
%
   [m,n,r] = sizes(o);  
   r = floor(r);
%
% reshape data
%
   d1 = data(o,symbols{1});
   D1 = Pick(o,d1);                    % pick data
   d1 = d1(:)';
   d1 = reshape(d1(1:m*n*r),m*n,r);  
   if all(size(d1) == size(D1))
      assert(isequal(d1,D1));
   end
   d1 = D1;
   
   d2 = data(o,symbols{2});
   D2 = Pick(o,d2);                    % pick data
   d2 = d2(:)';
   d2 = reshape(d2(1:m*n*r),m*n,r);     
   if all(size(d2) == size(D2))
      assert(isequal(d2,D2));
   end
   d2 = D2;
%
% cross check sizes
%
   [mn,rr] = size(d1);
   r = prod(size(d1)) / (m*n);          % recalculate repeats
   assert(mn==m*n && r==rr);
%
% now reconstruct the matrices in a loop
%
   [~,Idx] = method(o,meth,m,n);        % get indices
   for (j=1:r)
      D1j = d1(:,j);                    % get j-th column
      D1 = D1j(Idx);
      
      D2j = d2(:,j);                    % get j-th column
      D2 = D2j(Idx);
      
      [Q1,Q2] = meshgrid(1:n,1:m);
      q = [Q1(:), Q2(:)]';
      d = [D1(:), D2(:)]';
      
         % first calculate map by affine fit, then map isometric coordi-
         % nates to y. The difference d-y is the condensate
         
      C = map(o,q,d,order);
      y = map(o,C,q);
      
      c = d-y;                          % condensate
      
      c1(1:mn,j) = c(1,:)';
      c2(1:mn,j) = c(2,:)';
   end
%
% pick the proper data stream for the specified symbol
%
   if isequal(symbol,symbols{1})
      c = c1 - mean(c1')'*ones(1,r);
   elseif isequal(symbol,symbols{2})
      c = c2 - mean(c2')'*ones(1,r);
   else
      c = [];                           % should never happen!
   end
end
function [symbols,aux] = Symbols(o,symbol)                             
%
% SYMBOLS   Duplicated local function - see also fetch>Symbols
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
      symbols = {};
   end
end
function sidx = Scope(scope,ignore)    % Calculate Scope Indices       
%
% SCOPE   Calculate scope indices while excluding indices to be ignored
%
   sidx = scope;                       % scope index
   if ~isempty(ignore)
      idx = find(sidx > ignore);
      sidx = sidx(idx);
   end
end