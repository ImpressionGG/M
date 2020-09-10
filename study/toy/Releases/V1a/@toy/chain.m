function op = chain(T,varargin)
%
% CHAIN      Chain operator.
%
%            1) First argument is a space
%            ============================
%
%               H = space(toy,[1 3 5; 2 4 6]);
%               H = setup(H,'psi0',H('3'));
%               T = operator(H,'>>');
%
%               P0 = projector(H,'psi0');
%               P1 = projector(H,'4','5');
%               P2 = projector(H,'6');
%
%               C = chain(T,P0,P1);          % chain operator
%               C = chain(T,P0,P1,P2,..);    % chain operator
%
%               C = chain(T,{P0,P1});        % chain operator
%               C = chain(T,{P0,P1,P2,..});  % chain operator
%
%            There is also a chain operator syntax based on labels
%            and label lists
%
%               C = chain(T,'psi0','1',{'4','5','6'});
%               C = chain(T,'psi0','1','4,5,6');
%
%            Same as:
%
%               Psi0 = projector(H,'psi0');
%               P1 = projector(H,'1');
%               P456 = projector(H,{'4','5','6'});
%               C = chain(T,Psi0,P1,P456);
%
%            2) First argument is a universe
%            ===============================
%
%               H = space(toy,1:8);
%               S0 = split(H,{'1','*'});
%               S = split(H,labels(H));
%               T = operator(H,'>>');      % shift operator
%               U = T*S0*S*S;
%
%               C = chain(U,'1','2','3')   % chain operator
%               C = chain(U,{'1','2','3'}) % chain operator
%
%            3) Chain operator of a history
%            ==============================
%
%               H = space(toy,1:8);
%               S = split(H,labels(H));
%               T = operator(H,'>>');      % shift operator
%
%               Y = history(T*S^3,'1','2','3');
%               C = chain(Y)               % chain operator
%
%            See also: TOY, SPACE, PROJECTOR, SPLIT, BORN
%
   if property(T,'universe?')
      U = T;                     % arg1 is a universe
      T = universe(U,0);         % extract transition operator
   else
      U = [];                    % otherwise no universe
   end
   
   if property(T,'history?')
      if (nargin ~= 1)
         error('1 input arg expected if chain operator applied to history!');
      end
      U = history(T,0);
      list = property(T,'list');
      op = chain(U,list);
      return
   end
   
   if ~property(T,'operator?')
      error('arg1 must be a unitary operator!');
   end
   
   if ~property(T,'unitary?')
      error('arg1 must be a unitary operator!');
   end

% process input list of projectors

   list = varargin;
   if (iscell(list{1}) && length(list) == 1)
      list = list{1};
   end

% now list of projectors processed

   if isempty(U)
      if (length(list) < 2)
         error('at least 2 projectors expected!');
      end
   else
      ulist = property(U,'list');
      n = length(ulist);
      %if (length(list) ~= n)
      if (length(list) > n)
         error(sprintf('history length can be max %g!',n));
      end
   end
   
   H = space(T);               % extract Hilbert space
   for (i=1:length(list))
      P = list{i};
      if iscell(P)
         P = projector(H,P);
      elseif ischar(P)
         sym = Extract(P);
         if isempty(U)
            P = projector(H,sym);
         else
            S = ulist{i};
            assert(length(sym)==1);
            sym = sym{1};
            P = projector(S,sym);
         end
      end
      
      if ~(property(P,'projector?') || property(P,'operator?'))
         error('projector expected!');
      end
      
      if (i==1)
         op = P;
      else
         op = P*T*op;
      end
   end
   
% post processing

%    symbols = property(op,'symbols');
%    M = matrix(op);
%    H = space(op);
%    plist = {};
%    
%    for (i=1:size(M,2))
%       for (j=1:length(symbols(:)))
%          sym = symbols{j};
%          V = vector(H,sym);
%          M1 = matrix(V);
%          if (all(M(:,i)==M1(:)))
%             plist{end+1} = sym;
%          end
%       end
%    end
%       
%    if ~isempty(plist)
%       op = projector(H,plist);
%    end

   op = option(op,'weight',1);
   return
end

%==========================================================================
% Extract symbol list
%==========================================================================

function list = Extract(text)
%
% EXTRACT   Extract according to the exammples
%
%              sym = 'a'  ->  list = {'a'}
%              sym = 'a,b' -> list = {'a','b'}
%
   assert(ischar(text));
   
   list = {};  sym = '';
   for (i=1:length(text))
      if (text(i) == ',')
         if isempty(sym)
            error('syntax error!');
         end
         list{end+1} = sym;
         sym = '';
      else
         sym(end+1) = text(i);
      end
   end
   
   if ~isempty(sym)
      list{end+1} = sym;
   end
   return
end
