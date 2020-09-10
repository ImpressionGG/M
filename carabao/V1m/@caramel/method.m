function [out1,out2] = method(o,varargin)
%
% METHOD   Extract method and indices
%
%    1) Extract method & indices in order to decompose a matrix into a 
%    linear stream of data.
% 
%       [idx,name] = method(o,{t})     % extract from time matrix
%    
%       [idx,Idx] = method(o,name,m,n) % extract from data matrix by name
%
%    2) Get method matrix by name, or get method name by method matrix
%
%       meth = method(o,name)
%       name = method(o,meth)
%
%       meth = method(o,'BotLeftRowSawtooth')    % => [0 0;1 0;-1 1]
%       meth = method(o,'BotLeftRowMeander')     % => [0 0;1 0; 0 1]
%       meth = method(o,'BotLeftColSawtooth')    % => [0 0;0 1;1 -1]
%       meth = method(o,'BotLeftColMeander')     % => [0 0;0 1;1  0]
%
%       meth = method(o,'TopLeftRowSawtooth')    % => [0 1;1 0;-1 -1]
%       meth = method(o,'TopLeftRowMeander')     % => [0 1;1 0; 0 -1]
%       meth = method(o,'TopLeftColSawtooth')    % => [0 1;0 -1;1 1]
%       meth = method(o,'TopLeftColMeander')     % => [0 1;0 -1;1 0]
%
%       meth = method(o,'BotRightRowSawtooth')   % => [1 0;-1 0;1 1]
%       meth = method(o,'BotRightRowMeander')    % => [1 0;-1 0;0 1]
%       meth = method(o,'BotRightColSawtooth')   % => [1 0;0 1;-1 -1]
%       meth = method(o,'BotRightColMeander')    % => [1 0;0 1;-1 0]
%
%       meth = method(o,'TopRightRowSawtooth')   % => [1 1;-1 0;1 -1]
%       meth = method(o,'TopRightRowMeander')    % => [1 1;-1 0;0 -1]
%       meth = method(o,'TopRightColSawtooth')   % => [1 1;0 -1;-1 1]
%       meth = method(o,'TopRightColMeander')    % => [1 1;0 -1;-1 0]
%
%    3) Extract from data matrix by name
%
%       [idx,Idx] = method(o,name,m,n) % extract from data matrix by name
%
%    4) Extract from data matrix by name including system vector
%
%       [idx,Idx] = method(o,name,m,n,sys) % extract from  matrix by name
%
%    5) Consistency check
%
%       method(o)
%
%    6) There is an internal reverse mode which swaps the system order
%       internally, if the processing is from right to left (reverse = 1)
%       instead of processing from left to right (reverse = 0). This 
%       value of reverse can be explicitely changed by adding an exclam
%       character '!' to the method name.
%
%          [idx,Idx] = method(o,'blcs',m,n,sys)    % reverse = 0
%          [idx,Idx] = method(o,'trcs',m,n,sys)    % reverse = 1
%          [idx,Idx] = method(o,'blcs!',m,n,sys)   % reverse = 1
%          [idx,Idx] = method(o,'trcs!',m,n,sys)   % reverse = 0
%
%    Example 1:
%
%       Dx{j} = ...                          % given mxn matrices (j=1:r)
%       idx = method(o,'tlrs',m,n)           % get index
%       dx = [];
%       for (j=1:r)
%          Dxj = Dx{j}
%          dx = [dx,Dxj(idx)];               % build a flat data line
%       end
%
%    Example 2:
%
%       dx = ...                             % stream with sizes = [m n r]
%       [~,Idx] = method(o,'tlrs',ones(m,n)) % get index
%       DX = reshape(dx,m*n,r);
%       for (j=1:r)
%          Dxj = DX(:,j);
%          Dx{j} = Dxj(Idx);
%       end
%
%    See also: CARALOG, COOK
%
   while (nargin == 1)                 % constistancy check            
      ConsistencyCheck(o);
      return
   end
%
% Two input args and second argument is a list
% a) [idx,name] = method(o,{t}) % extract from time matrix
%
   while (nargin == 2 && iscell(varargin{1}))                          
      list = varargin{1};
      if length(list) ~= 1
         error('list with 1 element expected for arg 2!');
      end
      [out1,out2] = Extract(o,list{1});     % extract from time matrix
      return
   end
% 
% Two input args expected and arg2 is a double or a string   
% a) meth = method(o,name)
% b) name = method(o,meth)
%   
   va1 = varargin{1};
   while nargin == 2 && (isa(va1,'char') || isa(va1,'double'))         
      tab = Table(o);
      if isa(varargin{1},'double')
         meth = varargin{1};
         if any(size(meth) ~= [3 2])
            error('method (arg2) must be a 3x2 double matrix');
         end
         for (i=1:length(tab))
            pair = tab{i};
            if all(all(meth == pair{2}))
               out1 = pair{1};
               return
            end
         end
         error('Unknown method (arg2)!');
      elseif isa(varargin{1},'char')
         name = varargin{1};
         meth = assoc(name,tab);
         if isempty(meth)
            error(['unknown method name: ',name,'!']);
         end
         out1 = meth;
      else
         assert(0);                    % never come to this point!
      end
      return
   end
%
% Four input arguments
% a) [idx,Idx] = method(o,name,m,n) % extract from data matrix by name
%
   while (nargin == 4)                 % calculate indices             
      name = varargin{1};
      if isa(name,'double')
         name = method(o,name);
      end
      m = varargin{2};  n = varargin{3};
      [idx,Idx] = Index(o,name,m,n);
      out1 = idx;  out2 = Idx;
      return
   end
%
% Five input arguments - this algorithm needs several beers to digest!
% a) [idx,Idx] = method(o,name,m,n,sys) % extract from matrix by name
%
   while (nargin == 5)                 % calculate indices             
      [nin,name,m,n,sys] = o.args(varargin);
      
      if isa(name,'double')
         name = method(o,name);
      end
      
      sys = sys(:)';
      if (length(sys) ~= m*n)
         error('bad sized system vector (arg5)!');
      end
      
         % first we calculate the usual indices
         
      [idx,Idx,reverse] = Index(o,name,m,n);
      
      if isempty(sys)                  % then we are done
         out1 = idx;  out2 = Idx;
         return
      end
      if all(sys(:)==sys(1))           % then we are also done
         out1 = idx;  out2 = Idx;      % since we have no mixed mode
         return
      end
      
         % now it is tricky (to handle mixed mode). First reconstruct
         % the system matrix using the matrix index (Idx) we calculated.
      
      list = {};                       % init empty list
      system = sys;                    % take over
      while o.is(system)
         if (reverse)
            n = max(system(:));        % next system number
         else
            n = min(system(:));        % next system number
         end
         sdx = find(sys == n);         % where are the system numbers n?
         list{end+1} = sdx;          
         sdx = find(system == n);      % where are the system numbers n?
         system(sdx) = [];             % remove these items from index
      end
      
         % now we can buildup the new index sequence
         
      ivec = [];                      % init index vector
      for (i=1:length(list))
         ivec = [ivec,list{i}];       % add to ivec
      end
      
         % new index is available
         % and now the magic trick! The assertion prooves the invariant
         
      Index = ivec(Idx);
      index = InvIdx(Index);
      
         % make some final tests

      Sys = sys(Index);               % reconstructed
      assert(all(Sys(index)==sys));   % and prooved for consistancy

      out1 = index;  out2 = Index;
      return
   end
%
% never come beyond this point
%
   assert(0);
   return
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function [idx,Idx,reverse] = Index(o,name,m,n) % calculate indices by name     
%
   invert = (name(end) == '!');
   if (invert)
      name(end) = '';                  % scrap last character
   end
   
   CSidx = reshape(1:m*n,m,n);         % column wise sawtooth
   RSidx = reshape(1:m*n,n,m)';        % row wise sawtooth
   
   CMidx = CSidx;
   for (j=2:2:n)
      CMidx(:,j) = CMidx(m:-1:1,j);    % column wise meander
   end

   RMidx = RSidx;
   for (i=2:2:m)
      RMidx(i,:) = RMidx(i,n:-1:1);    % row wise meander
   end
   
   switch name
      case {'blrs','BotLeftRowSawtooth','BottomLeftRowSawtooth'}
         RSidx = RSidx(m:-1:1,:);
         Idx = RSidx;  reverse = 0;
      case {'blrm','BotLeftRowMeander'}
         RMidx = RMidx(m:-1:1,:);
         Idx = RMidx;  reverse = 0;
      case {'blcs','BotLeftColSawtooth','BottomLeftColSawtooth'}
         CSidx = CSidx(m:-1:1,:);
         Idx = CSidx;  reverse = 0;
      case {'blcm','BotLeftColMeander'}
         CMidx = CMidx(m:-1:1,:);
         Idx = CMidx;  reverse = 0;
      case {'tlrs','TopLeftRowSawtooth'}
         Idx = RSidx;  reverse = 0; 
      case {'tlrm','TopLeftRowMeander'}
         Idx = RMidx;  reverse = 0;
      case {'tlcs','TopLeftColSawtooth'}
         Idx = CSidx;  reverse = 0;
      case {'tlcm','TopLeftColMeander'}
         Idx = CMidx;  reverse = 0;
      case {'brrs','BotRightRowSawtooth'}
         RSidx = RSidx(m:-1:1,:);
         RSidx = RSidx(:,n:-1:1);
         Idx = RSidx;  reverse = 1;
      case {'brrm','BotRightRowMeander'}
         RMidx = RMidx(m:-1:1,:);
         RMidx = RMidx(:,n:-1:1);
         Idx = RMidx;  reverse = 1;
      case {'brcs','BotRightColSawtooth'}
         CSidx = CSidx(m:-1:1,:);
         CSidx = CSidx(:,n:-1:1);
         Idx = CSidx;  reverse = 1;
      case {'brcm','BotRightColMeander'}
         CMidx = CMidx(m:-1:1,:);
         CMidx = CMidx(:,n:-1:1);
         Idx = CMidx;  reverse = 1;
      case {'trrs','TopRightRowSawtooth'}
         RSidx = RSidx(:,n:-1:1);
         Idx = RSidx;  reverse = 1;
      case {'trrm','TopRightRowMeander'}
         RMidx = RMidx(:,n:-1:1);
         Idx = RMidx;  reverse = 1;
      case {'trcs','TopRightColSawtooth'}
         CSidx = CSidx(:,n:-1:1);
         Idx = CSidx;  reverse = 1;
      case {'trcm','TopRightColMeander'}
         CMidx = CMidx(:,n:-1:1);
         Idx = CMidx;  reverse = 1;
      otherwise
         error('bad name!');
   end
   
   reverse = o.iif(invert,~reverse,reverse);
   idx(Idx(:)) = 1:m*n;
end

function idx = InvIdx(Idx)             % Inverse of an Index           
%
% INV-IDX   Calculate the inverse of a matrix index, which is the index
%           vector
%
%              idx = InvIdx(Idx)
%
%           Because of the inverse relations the assertions below hold.
%
%           Performance: 70µs with assertions, 20µs without assertions
%
   idx(Idx(:)) = 1:length(Idx(:));
   %return                             % uncomment to skip assertions
%
% assertion 1: Idx(idx) -> counting sequence
%
   assert(all(Idx(idx) == 1:length(idx)));
%
% assertion 2: if Matrix = vector(Idx) => vector = Matrix(idx)
%
   vector = rand(1,length(idx));
   Matrix = vector(Idx);
   assert(all(Matrix(idx)==vector));
%
% assertion 3: if vector = Matrix(idx) => Matrix = vector(Idx)
%
   Matrix = rand(size(Idx));
   vector = Matrix(idx);
   assert(all(all(Matrix==vector(Idx))));
 end

function tab = Table(o)                % Conversion Table              
%
   tab = {{'BotLeftRowSawtooth',   [0 0;+1  0; -1 +1]}
          {'BotLeftRowMeander',    [0 0;+1  0;  0 +1]}
          {'BotLeftColSawtooth',   [0 0; 0 +1; +1 -1]}
          {'BotLeftColMeander',    [0 0; 0 +1; +1  0]}
          {'TopLeftRowSawtooth',   [0 1;+1  0; -1 -1]}
          {'TopLeftRowMeander',    [0 1;+1  0;  0 -1]}
          {'TopLeftColSawtooth',   [0 1; 0 -1; +1 +1]}
          {'TopLeftColMeander',    [0 1; 0 -1; +1  0]}
          {'BotRightRowSawtooth',  [1 0;-1  0; +1  1]}
          {'BotRightRowMeander',   [1 0;-1  0;  0  1]}
          {'BotRightColSawtooth',  [1 0; 0 +1; -1 -1]}
          {'BotRightColMeander',   [1 0; 0 +1; -1  0]}
          {'TopRightRowSawtooth',  [1 1;-1  0; +1 -1]}
          {'TopRightRowMeander',   [1 1;-1  0;  0 -1]}
          {'TopRightColSawtooth',  [1 1; 0 -1; -1 +1]}
          {'TopRightColMeander',   [1 1; 0 -1; -1  0]}
          {'blrs',                 [0 0;+1  0; -1 +1]}
          {'blrm',                 [0 0;+1  0;  0 +1]}
          {'blcs',                 [0 0; 0 +1; +1 -1]}
          {'blcm',                 [0 0; 0 +1; +1  0]}
          {'tlrs',                 [0 1;+1  0; -1 -1]}
          {'tlrm',                 [0 1;+1  0;  0 -1]}
          {'tlcs',                 [0 1; 0 -1; +1 +1]}
          {'tlcm',                 [0 1; 0 -1; +1  0]}
          {'brrs',                 [1 0;-1  0; +1  1]}
          {'brrm',                 [1 0;-1  0;  0  1]}
          {'brcs',                 [1 0; 0 +1; -1 -1]}
          {'brcm',                 [1 0; 0 +1; -1  0]}
          {'trrs',                 [1 1;-1  0; +1 -1]}
          {'trrm',                 [1 1;-1  0;  0 -1]}
          {'trcs',                 [1 1; 0 -1; -1 +1]}
          {'trcm',                 [1 1; 0 -1; -1  0]}
         };
   return
end

function [idx,name] = Extract(o,t)     % Extract from time matrix      
%
   name = Classify(o,t);
   [m,n] = size(t);
   idx = Index(o,name,m,n);
   return
end

function name = Classify(o,t)          % classify time matrix          
%
   [m,n] = size(t);
   if (m == 1)
      name = 'BotLeftColSawtooth';
      return
   elseif (n == 1)
      name = 'BotLeftRowSawtooth';
      return
   end
%
% process the general case
%
   tmin = min(t(:));
   
   while (tmin == t(1,1))              % top left                      
      name = 'TopLeft';
      while t(m,1) < t(1,n)            % t(bottom/left) < t(top/right)
         name = [name,'Col'];
         if t(1,2) < t(m,2)            % if saw tooth
            name = [name,'Sawtooth'];
         else                          % else meander
            name = [name,'Meander'];
         end
         return
      end
      while t(m,1) > t(1,n)            % t(bottom/left) > t(top/right)
         name = [name,'Row'];
         if t(2,1) < t(2,n)            % if saw tooth
            name = [name,'Sawtooth'];
         else                          % else meander
            name = [name,'Meander'];
         end
         return
      end
      error('non monotonic time stamps!');
      return
   end
   while (tmin == t(m,1))              % bottom left                   
      name = 'BotLeft';
      while t(1,1) < t(m,n)            % t(top/left) < t(bottom/right) 
         name = [name,'Col'];
         if t(m,2) < t(1,2)            % if saw tooth
            name = [name,'Sawtooth'];
         else                          % else meander
            name = [name,'Meander'];
         end
         return
      end
      while t(1,1) > t(m,n)            % t(top/left) > t(bottom/right) 
         name = [name,'Row'];
         if t(m-1,1) < t(m-1,n)        % if saw tooth
            name = [name,'Sawtooth'];
         else                          % else meander
            name = [name,'Meander'];
         end
         return
      end
      error('non monotonic time stamps!');
      return
   end
   while (tmin == t(1,n))              % top right                     
      name = 'TopRight';
      while t(m,n) < t(1,1)            % t(bottom/right) < t(top/left) 
         name = [name,'Col'];
         if t(1,n-1) < t(m,n-1)            % if saw tooth
            name = [name,'Sawtooth'];
         else                          % else meander
            name = [name,'Meander'];
         end
         return
      end
      while t(m,n) > t(1,1)            % t(bottom/right) > t(top/left) 
         name = [name,'Row'];
         if t(2,n) < t(2,1)            % if saw tooth
            name = [name,'Sawtooth'];
         else                          % else meander
            name = [name,'Meander'];
         end
         return
      end
      error('non monotonic time stamps!');
      return
   end
   while (tmin == t(m,n))              % bottom right                  
      name = 'BotRight';
      while t(1,n) < t(m,1)            % t(top/right) < t(bot/left)    
         name = [name,'Col'];
         if t(m,n-1) < t(1,n-1)        % if saw tooth
            name = [name,'Sawtooth'];
         else                          % else meander
            name = [name,'Meander'];
         end
         return
      end
      while t(1,n) > t(m,1)            % t(top/right) > t(bot/left) 
         name = [name,'Row'];
         if t(m-1,n) < t(m-1,1)        % if saw tooth
            name = [name,'Sawtooth'];
         else                          % else meander
            name = [name,'Meander'];
         end
         return
      end
      error('non monotonic time stamps!');
      return
   end
    
   return
end

function ConsistencyCheck(o)           % perform consistency check     
%
   tab = Table(o);
   for (i=1:length(tab))
      pair = tab{i};
      name = pair{1};
      meth = pair{2};
      
      result = method(o,name);
      assert(all(all(result==meth)));
      
      result = method(o,meth);
      assert(is(name,result));
   end

   t = [5 6; 3 4; 1 2];  
   [name,idx] = method(o,{t});
   assert(is(name,'BotLeftRowSawtooth'));
   assert(all(t(idx)==1:6));

   t = [5 6; 4 3; 1 2];  
   [name,idx] = method(o,{t});
   assert(is(name,'BotLeftRowMeander'));
   assert(all(t(idx)==1:6));

   t = [3 6; 2 5; 1 4];  
   [name,idx] = method(o,{t});
   assert(is(name,'BotLeftColSawtooth'));
   assert(all(t(idx)==1:6));
   
   t = [3 4; 2 5; 1 6];  
   [name,idx] = method(o,{t});
   assert(is(name,'BotLeftColMeander'));
   assert(all(t(idx)==1:6));

   t = [1 2; 3 4; 5 6];  
   [name,idx] = method(o,{t});
   assert(is(name,'TopLeftRowSawtooth'));
   assert(all(t(idx)==1:6));

   t = [1 2; 4 3; 5 6];  
   [name,idx] = method(o,{t});
   assert(is(name,'TopLeftRowMeander'));
   assert(all(t(idx)==1:6));
   
   t = [1 4; 2 5; 3 6];  
   [name,idx] = method(o,{t});
   assert(is(name,'TopLeftColSawtooth'));
   assert(all(t(idx)==1:6));

   t = [1 6; 2 5; 3 4];  
   [name,idx] = method(o,{t});
   assert(is(name,'TopLeftColMeander'));
   assert(all(t(idx)==1:6));

   t = [6 5; 4 3; 2 1];  
   [name,idx] = method(o,{t});
   assert(is(name,'BotRightRowSawtooth'));
   assert(all(t(idx)==1:6));
   
   t = [6 5; 3 4; 2 1];  
   [name,idx] = method(o,{t});
   assert(is(name,'BotRightRowMeander'));
   assert(all(t(idx)==1:6));

   t = [6 3; 5 2; 4 1];  
   [name,idx] = method(o,{t});
   assert(is(name,'BotRightColSawtooth'));
   assert(all(t(idx)==1:6));

   t = [4 3; 5 2; 6 1];  
   [name,idx] = method(o,{t});
   assert(is(name,'BotRightColMeander'));
   assert(all(t(idx)==1:6));

   t = [2 1; 4 3; 6 5];  
   [name,idx] = method(o,{t});
   assert(is(name,'TopRightRowSawtooth'));
   assert(all(t(idx)==1:6));

   t = [2 1; 3 4; 6 5];  
   [name,idx] = method(o,{t});
   assert(is(name,'TopRightRowMeander'));
   assert(all(t(idx)==1:6));

   t = [4 1; 5 2; 6 3];  
   [name,idx] = method(o,{t});
   assert(is(name,'TopRightColSawtooth'));
   assert(all(t(idx)==1:6));

   t = [6 1; 5 2; 4 3];  
   [name,idx] = method(o,{t});
   assert(is(name,'TopRightColMeander'));
   assert(all(t(idx)==1:6));
   
   fprintf('   consistency check for METHOD: OK!\n');
   return
end
