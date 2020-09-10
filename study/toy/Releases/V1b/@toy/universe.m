function uni = universe(obj,S)
%
% UNIVERSE   Create a universe consisting of a tensor product of splits.
%            Object is implemented as toy object, type '#UNIVERSE'.
%
%               H = space(toy,1:5);
%               T = operator(H,'>>');         % shift operator
%               S0 = split(H,{'1','2','*'});
%               S1 = split(H,{'2','3','*'});
%
%               U = universe(T);              % create an empty universe
%               U = universe(U,S0);           % add a split
%               U = universe(U,S1);           % add another split
%
%            Retrieve data from universe
%
%               universe(U,0)                 % transition matrix
%               universe(U,1)                 % 1st split
%               universe(U,2)                 % 2nd split
%     
%            Retrieve universe from a history
%
%               Y = history(T*split(H,labels(H))^3,'1','2','3');
%               U = universe(Y);
%
%            See also: TOY, SPACE, SPLIT, HISTORY
%
   if (nargin == 1)
      
      if property(obj,'history?')    % extract universe
         dat.space = data(obj,'space');
         dat.oper = data(obj,'oper');
         dat.uni = data(obj,'uni');
         obj = type(obj,'#UNIVERSE');
         uni = data(obj,dat);
         return
      end
      
      if ~property(obj,'operator?')
         error('operator expected for arg1!');
      end

      if ~property(obj,'unitary?')
         error('unitary operator expected for arg1!');
      end
      
      uni = type(obj,'#UNIVERSE');   % convert obj to universe
      uni = data(uni,'uni.list',{});   % initialize list

      assert(uni);
      return
   end
   
% if nargin == 2 we want to add a split to a universe

   if nargin == 2
      if ~property(obj,'universe?')
         error('universe expected for arg1!');
      end

      if isa(S,'double')   % indexing (retrieving) data
         idx = S;           
         list = property(obj,'list');

         if (idx == 0)   % transition operator
            uni = property(obj,'transition');
         elseif (idx > 0 && idx <= length(list))
            uni = list{idx};
         else
            error(sprintf('index out of range: %g!',idx));
         end
         return
      end
      
% argument is a split

      if ~property(S,'split?')
         error('split expected for arg2!');
      end
      
      if ~(space(obj) == space(S))
         error('cannot add split to universe with incompatible space!');
      end
      
      list = data(obj,'uni.list');
      list{end+1} = S;
      uni = data(obj,'uni.list',list);
      assert(uni);
      return
   end
   
   error('1 or 2 input args expected!');
   return
end
