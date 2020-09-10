function obj = cspace(obj,varargin)
%
% CSPACE   Compound space based on complete commuting set of observables 
%
%    Creating a compound space relative to a complete set of commuting
%    observables.
%
%       obj = cspace(H,O1);            % relative to 1 operator
%       obj = cspace(H,O1,O2);         % relative to 2 operators
%       obj = cspace(H,O1,O2,O3);      % relative to 3 operators
%
%       obj = cspace(H,{O1,O2,...});   % relative to list of operators
%
%    See also: TOY, OPERATOR, SPACE, WAVE
%
   if ~property(obj,'space?')
      error('arg1 must be of type space!');
   end

% Create a list of observables

   observable = varargin;
   if length(varargin) == 1
      if iscell(varargin{1})
         observable = varargin{1};
      end
   end

% now we need to check the type of the observables

   for (i=1:length(observable))
      Op = observable{i};
      if ~property(Op,'operator?')
         error(sprintf('operator expected for arg%g!',i+1));
      end
   end
   
% Build up eigen vector matrix list and index list

   Op = observable{1};
   M = matrix(Op)+0;
   [V,D] = eig(M);
   list = {V};                    % list of eigen vector matrices
   index = {diag(D)};             % list of eigen values
   
   for (i = 2:length(observable))
      Oi = observable{i};
      Op = Op .* Oi;
      M = matrix(Oi)+0;
      [V,D] = eig(M);
      list{1,end+1} = V;          % list of eigen vector matrices
      index{1,end+1} = diag(D);   % list of eigen values
   end
   
   if ~(obj == space(Op))
      error('space (arg1) must match composite space of operators!');
   end
   
% Now we have checked that the provided space and the composite space of
% the observables are compatible. We also have built up the list of eigen
% vector matrices and eigen values. Create now a wave function object.
   
   obj = space(Op);
   obj = type(obj,'#CSPACE');     % change object type to '#CSPACE'
   obj = data(obj,'cspace.index',index);
   obj = data(obj,'cspace.list',list);
   obj = data(obj,'cspace.observable',Op);
   obj = data(obj,'cspace.olist',observable);

% now calculate the Kronecker product of matrices

   [M,T] = Kronecker(list);
   obj = data(obj,'cspace.basis',M);
   obj = data(obj,'cspace.itab',T);

   assert(obj);
   return
end

%==========================================================================
% Kronecker Product

function [M,T] = Kronecker(varargin)
%
% KRONECKER   Kronecker product of matrices
%
%                M = Kronecker(M1,M2)
%                M = Kronecker(M1,M2,M3,...)
%
%                M = Kronecker({M1,M2})
%                M = Kronecker({M1,M2,M3,...})
%
%             Also an index table T can be calculated:
%
%                [M,T] = Kronecker(M1,M2,M3,...)
%                [M,T] = Kronecker({M1,M2,M3,...})
%
   list = varargin;
   
   if (nargin < 1)
      error('at least 1 input arg expected!');
   end
   
   if iscell(list{1})
      list = list{1};
      if (length(list) < 1)
         error('at least 1 matrix in matrix list (arg 1) expected!');
      end
   end
      
% all checks positive! Let's start now ...

   M = list{1};                % first eigen vector matrix
   T = (1:length(M))';
   
   for (k=2:length(list))
      Mk = list{k};
      [m,n] = size(M);
      [mk,nk] = size(Mk);
      for (i=1:m)
         ii = (i-1)*mk;
         for (j=1:n)
            jj = (j-1)*mk;
            MM(ii+(1:mk),jj+(1:nk)) = M(i,j)*Mk;
         end
      end
      M = MM;
   end
   
   for (k=2:length(list))
      Mk = list{k};
      Tk = (1:length(Mk))';
      [m,n] = size(T);
      for (i=1:m)
         tt = (i-1)*size(Tk,1);
         TT(tt+(1:length(Tk)),1:n) = ones(size(Tk))*T(i,:);
         TT(tt+(1:length(Tk)),n+1) = Tk;      
      end
      T = TT;
   end
   
   
   return
end
