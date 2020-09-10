function Y = history(U,varargin)
%
% HISTORY    Create a history in a universe. Object is implemented as 
%            a tensor object with format '#HISTORY'.
%
%               H = space(tensor,1:5);
%               T = operator(H,'>>');         % shift operator
%               S = split(H,{'1','2','*'});
%
%               U = T*S^3;                    % create a universe
%
%            Create histories
%
%               Y = history(U,'1','2','1');
%               Y = history(U,{'1','2','*'});
%     
%            Index (access) a projector from a history
%
%               P = history(Y,idx)    % access projector label
%               P = projector(Y,idx)  % access projector
%
%               U = history(Y,0);     % access universe
%               U = universe(Y);      % same as above
%
%            Bra-Ket Product: let Y1,Y2 be histories
%
%               chain(Y1)'*chain(Y2)  % check orthogonality
%               Y1'*Y2                % same as above (short hand)
%
%            See also: TENSOR, SPACE, SPLIT, UNIVERSE, MTIMES
%

% the next step deals with different kinds of calling syntax to create
% a history. Finally we need a list of indexing labels for projectors

   list = varargin;
   
   if (length(list) == 1)
      if iscell(list{1})
         list = list{1};
      end
   end
   
% in the first trial we try to interprete U as a history and check if
% the syntax demands indexing a projector from the history

   if property(U,'history')
      Y = U;                     % interprete arg1 as a history
      if (nargin ~= 2)
         error('2 input args expected!')
      end
      idx = varargin{1};
      if ~(isa(idx,'double'))
         error('double expected for index');
      end
      
      if (idx == 0)
         U = universe(Y);       % extract universe
         Y = U;                 % return universe as out arg1
      else
         list = property(Y,'list');
         n = property(Y,'number');
         if (idx < 0 || idx > n)
            error('index out of range!');
         end
         
         S = list{idx};         % get idx-th projector
         Y = S;                 % return split as out arg1
      end
      return
   end
   
% the first trial failed! As a second trial we try to interprete U as
% a universe and work on creation of a new history
      
   if ~property(U,'universe')
      error('history or universe expected for arg1!');
   end
   
% now arguments are held in list, no matter which calling syntax chosen

   n = property(U,'number');
   
   if (length(list(:)) > n)
      error(sprintf('max %g projector labels expected!',n));
   elseif (length(list(:)) < n)
      n = length(list(:));
      slist = data(U,'uni.list');
      slist = slist(1:n);
      U = data(U,'uni.list',slist);     % adopt universe
   end
   
% check if projector labels are able to index a projector

   try
      for (i=1:length(list))
         sym = list{i};
         if ~(ischar(sym) || isa(sym,'double'))
            error('bad symbol');
         end
         S = universe(U,i);    % get i-th split
         P = projector(S,sym);
      end
   catch
      if isa(sym,'double')
         sym = sprintf('%g',sym);
      end
      error(['bad label for indexing a projector in universe: ',sym]);
   end
   
% now everything is clear. Create the history  

   Y = format(U,'#HISTORY');
   Y = data(Y,'history.bra',0);
   Y = data(Y,'history.list',list);
   assert(Y);
   return
   
end
