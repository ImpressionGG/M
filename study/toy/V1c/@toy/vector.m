function varargout = vector(obj,varargin)
%
% VECTOR     Construct a vector object for a given space
%
%               H = space(toy,{'u';'d'});
%               P = projector(H,'u');
%               C = space(toy,'game');
%
%               V = vector(H,1);
%               V = H(1);              % same as above
%
%               V = vector(H,'u');
%               V = H('u');            % same as above
%
%               V = vector(H);         % null vector
%               V = vector(H,[]);      % null vector
%
%               V = vector(C,{-1,1});  % index by eigen values
%               V = C({-1,1});         % same as above
%
%            Multiple outputs
%
%               [u,d] = vector(H,'u','d');
%
%            See also: TOY, DISPLAY
%
   profiler('vector',1);
   done = 0;
      
      % preprocess input arg list depending on nargin

   if (nargin == 1)
      arg = [];
   elseif (nargin == 2)
      arg = varargin{1};
   else                   % otherwise process arg list
      for (i=1:length(varargin))
         varargout{i} = vector(obj,varargin{i});
      end
      profiler('vector',0);
      return
   end
   
% If not multiple input/output args we process the zero arg or single
% arg case   
   
   if property(obj,'projector?')
      varargout{1} = vector(space(obj),arg);
      profiler('vector',0);
      return
   end
   
   if ~(property(obj,'space?') || property(obj,'cspace?') || property(obj,'vector?'))
      error('object (arg1) must be a space or vector or projector!');
   end
   
% Check if vector is initialized by a matrix
% This is given if the argument is a double non-scalar

   n = dim(obj);  sz = size(arg);

   if (length(arg) > 1 && isa(arg,'double'))
      V = vector(obj);
      V = opt(V,opt(obj));
      
      V = matrix(V,arg);
      if (min(sz) == 1)
         if (sz(2) == 1)    % bra vector
            %V = labels(V,labels(V)');    % transpose labels
         end
      end
      varargout{1} = V;
      profiler('vector',0);
      return
   end

% Process double argument which is the initializing matrix   
   
   if (isa(arg,'double') || ischar(arg) || iscell(arg))
      if isempty(arg)
         b = zeros(size(labels(obj)));
      elseif isa(arg,'double') 
         n = property(obj,'dimension');
         if (arg>= 1 && arg <= n)
            b = basis(obj,arg);
         else
            %error(sprintf('numeric index must be in range 1...%g!',n));
            % the rest of the code will be still supported
            symbols = property(obj,'symbols');
            if (arg > length(symbols))
               error('vector index out of range!');
            else
               sym = symbols{arg}; 
               spec = data(obj,'space.spec');
               b = assoc(sym,spec);
            end
         end
      elseif ischar(arg)
         try
            b = basis(obj,arg);
         catch  % if empty then we can search in specific vector setup structure
            spec = data(obj,'space.spec');
            b = assoc(arg,spec);
            
               % transpose if space is transposed
               
            sz = property(obj,'size');
            if (min(size(b))) == 1 && (all(size(b) == [sz(2) sz(1)]))
               b = b.';             % transpose
            end
         end
      elseif iscell(arg)   % index by eigen value
         b = basis(obj,arg);
      else
         error('bad index type!');
      end
      
      %if (size(b,1) == size(b,2))
      if iscell(b)
         b = b{1};                  % unpack
         V = operator(obj);
         if ischar(arg)
            V = data(V,'oper.symbol',arg);
         end
      %elseif (min(size(b)) == 1)    % then we have a vector
      else
         V = type(obj,'#VECTOR');
      end
      
      V = opt(V,opt(obj));
      V = matrix(V,b);
      done = 1;
   end
   
% Third case: both arguments are vectors. This means we have to create
% a tensor product of vectors

   if (~done && property(obj,'vector?') && isa(arg,'toy'))
      if property(arg,'vector?')
         v1 = obj;  v2 = arg;
         
         S1 = space(v1);
         S2 = space(v2);
         S = space(S1,S2);            % tensor product space
         
         V = vector(S,[]);           % the null vector

         M = Product(v1,v2);
         V = data(V,'vector.matrix',M);
         done = 1;      
      end
   end
   
   
% if still not processed then we have an error

   if ~done
      error('bad input argument (arg2)!');
   end
      
   assert(V);
   varargout{1} = V;    % return in output arg list
   profiler('vector',0);
   return
end

%==========================================================================
% Tensor Product for Matrix Elements
%==========================================================================

function M = Product(op1,op2)
%
% PRODUCT
%
   Ma = matrix(op1);
   Mb = matrix(op2);

   [am,an] = size(Ma);
   [bm,bn] = size(Mb);

   M = sparse(am*bm,an*bn);

   for (ai=1:am)                      % regarding rows of mi x ni ilabels
     for (aj=1:an)                    % regarding cols of mi x ni ilabels
         for (bi=1:bm)                % regarding rows of mj x nj jlabels
            for (bj=1:bn)             % regarding cols of mj x nj ilabels
              i = (ai-1)*bm + bi;
              j = (aj-1)*bn + bj;
              M(i,j) = Ma(ai,aj) * Mb(bi,bj);
           end
         end
      end
   end
   return
end
