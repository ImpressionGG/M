function varargout = operator(obj,varargin)
%
% OPERATOR   Construct a vector object for a given space
%
%               S = space(toy,{'u','d'});
%               M = eye(dim(S));
%
%               op = operator(S,M);   % M is the operator matrix
%
%               op = operator(S,'null');       % null operator
%               op = operator(S,0);            % null operator
%               op = operator(S);              % null operator
%
%               op = operator(S,'eye');        % identity
%               op = operator(S,1);            % identity
%               op = operator(S,n);            % n * identity
%
%               op = operator(S,'forward');    % forward shift
%               op = operator(S,'>>');         % forward shift
%
%               op = operator(S,'backward');   % backward shift
%               op = operator(S,'<<');         % backward shift
%
%            See also: TOY, VECTOR, PROJECTOR
%
   if (nargin < 2)
      arg = 0;
   else
      arg = varargin{1};
   end
   
   if ~(property(obj,'space?') || property(obj,'operator?'))
      error('object (arg1) must be a space or operator!');
   end
 
   done = 0;
   n = dim(obj);
   M = arg;
   
% First case: special operators like eye (identity), forward shift and
% backward shift operator

   if ~done && isa(arg,'double') && length(arg) == 1
      M = arg * sparse(eye(n));
   elseif ~done && ischar(arg)
      switch arg
         case 'null'
            M = sparse(n,n);
         case 'eye'
            M = sparse(eye(n));
         case {'>>','forward'}
            M = sparse(n,n);
            for (i=1:n-1)
               M(i+1,i) = 1;
            end
            M(1,n) = 1;
         case {'<<','backward'}
            M = sparse(n,n);
            for (i=1:n-1)
               M(i,i+1) = 1;
            end
            M(n,1) = 1;
         otherwise
            op = vector(obj,arg);   % get by symbolic index
            if ~property(op,'operator?')
               error(['symbol ''',arg,''' is not refering to an operator!']);
            end
            done = 1;
      end
   end

% Second case: argument is an operator matrix
% This is the case if the argument is a double

   if (~done && isa(M,'double'))
      if any([n n] ~= size(M))
         error('operator matrix (arg2) must be nxn and match space dimension!');
      end
      
      op = type(obj,'#OPERATOR');
      op = data(op,'oper.matrix',M);
      done = 1;      
   end

% Third case: both arguments are operators. This means we have to create
% a tensor product of operators

   if (~done && property(obj,'operator?') && isa(arg,'toy?'))
      if property(arg,'operator?')
         op1 = obj;  op2 = arg;
         
         S1 = space(op1);
         S2 = space(op2);
         S = space(S1,S2);            % tensor product space
         
         op = operator(S,'null');     % the null operator

         M = Product(op1,op2);
         op = data(op,'oper.matrix',M);
         done = 1;      
      end
   end
   
% Conclude with an assertion of the new operator

   if (~done)
      error('bad argument (arg2)');
   end
   
   assert(op);
   varargout{1} = op;
   
% handle multiple output args   

   n = length(varargin);
   if (n > 1)
      for (i=2:n)
         sym = varargin{i};
         op = vector(obj,sym);
         if ~property(op,'operator?')
            error(['symbol ''',sym,''' is not refering to an operator!']);
         end
         varargout{i} = op;
      end
   end
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

