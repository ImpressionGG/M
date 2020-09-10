function obj = projector(obj,varargin)
%
% PROJECTOR  Construct a projector given by index or index list
%
%               [V,E] = eig(magic(3)+magic(3)');  % orthonormal basis V
%               H = space(toy,-1:1,V);         % 3 dim Hilbert space
%
%               P1 = projector(H,1);
%               P23 = projector(H,[2 3]);
%
%            Alternative symbolic indexing
%
%               P1 = projector(H,'-1');
%               P23 = projector(H,{'0','1'});
%
%               P23 = projector(H,2,3);
%               P23 = projector(H,'0','1');
%
%            Cross check:
%
%               P1*P23    % zero matrix, since orthogonal projectors
%
%            Projector construction based on vectors
%
%               psi = [2 5 7]';         % must be nx1 vector
%               P = projector(H,psi);
%
%               psi1 = [2 5 7]';         % must be nx1 vector
%               psi2 = [3 4 2]';         % must be nx1 vector
%
%               P = projector(H,psi1,psi2);
%
%            Access projector from a split
%
%               S = split(H,labels(H));
%               P = projector(S,1);      % select by numeric index
%               P = projector(S,'-1');   % select by label index
%               P = projector(S,'[-1]'); % select by label index (use [..])
%
%            Access projector from a history
%
%               H = space(toy,1:5);   % 5 dim Hilbert space
%               T = operator(H,'>>');    % unitary operator
%
%               Y = history(T*split(H,labels(H))^3,'1','2','4');
%
%               P = projector(Y,1);      % access projector
%               P = history(Y,1);        % access projector label
%
%            See also: TOY, SPACE, MATRIX
%
   ok = 0;                 %  not OK by default

% handle split objects ...

   if (property(obj,'split?'))
      if (nargin < 2)
         error('2 input args expected!');
      end
      arg = varargin{1};
      obj = ProjectorFromSplit(obj,arg);
      return
   end

% handle history objects ...

   if (property(obj,'history?'))
      if (nargin < 2)
         error('2 input args expected!');
      end
      arg = varargin{1};
      obj = ProjectorFromHistory(obj,arg);
      return
   end
   
% now handle  space object

   if ~property(obj,'space?')
      error('object (arg1) must represent a Hilbert space!');
   end
   
   if ~property(obj,'simple?')
%      error('Can currently deal only with simple space!');
   end
   
   if (length(varargin) < 1)
      error('missing index or index list (arg2)!');
   end
   
      % process index arguments
   
   ilist = {};
   for (i=1:length(varargin))
      arg = varargin{i};
      if isa(arg,'double')
         arg = arg(:);
         for (j=1:length(arg))
            ilist{end+1} = arg(j);
         end
      elseif ischar(arg)
         ilist{end+1} = arg;
      elseif iscell(arg)
         arg = arg(:);
         for (j=1:length(arg))
            ilist{end+1} = arg{j};
         end
      end
   end
   
% cross check arguments. If they are of character type they have to match
% an entry of the labels list. Only strings and integers are allowed

   labels = property(obj,'labels');
   symbols = property(obj,'symbols');
   n = property(obj,'dimension');
   
   for (i=1:length(ilist))
      arg = ilist{i};
      if isa(arg,'double')
         assert(length(arg)==1);
         if (round(arg) ~= arg)
            error(sprintf('only integer numbers are allowed as indices (arg2) => %g!',arg));
         end
         if (arg < 1 || arg > n)
            error(sprintf('index (%g) out of range (1:%g)!',arg,n));
         end
      elseif ischar(arg)
         found = match(arg,symbols(:));
         if isempty(found)
            error(['No label matches symbolic label ''',arg,''' (arg2)!']);
         end
      else
         arg
         error('index must be either integer or string!');
      end
   end

% Now process index list. Distinguish between integer numbers
% and character strings

   index = [];  %symbols = {};  weight = [];
   
   for (i=1:length(ilist))
      arg = ilist{i};
      if isa(arg,'double')
         jdx = arg;
      elseif ischar(arg)
         jdx = min(match(arg,symbols(:)));
      end
      
      if (~any(index==jdx))
         index(1,end+1) = jdx;
      end
      ok = 1;
   end
   
   [index,order] = sort(index);
   
% post processing and finalizing

   if (~ok)
      error('index or index list (arg2) must be character or list of strings!');
   end
   
   obj = data(obj,'proj.type','ray');
   obj = data(obj,'proj.index',index);
   obj = type(obj,'#PROJECTOR');
   
   assert(obj);
   return
end

%==========================================================================
% Projector from Split
%==========================================================================

function out = ProjectorFromSplit(obj,arg)
%
% PROJECTOR-FROM-SPLIT
%
   list = property(obj,'list');
   labs = labels(obj);

   if isa(arg,'double')
      if (arg < 1 || arg > length(list(:)))
         error('index out of range!');
      end
      out = list{arg};
   elseif ischar(arg)
      idx = match(['[',arg,']'],labs(:));
      if isempty(idx)
         idx = match(arg,labs(:));
      end
      if isempty(idx)
         error(sprintf(['unsupported symbolic index : ',arg]));
      end
      out = list{idx};
   else
      error('bug!');
   end

   return
end

%==========================================================================
% Projector from History
%==========================================================================

function P = ProjectorFromHistory(obj,idx)
%
% PROJECTOR-FROM-HISTORY
%
   if (idx == 0)
      error('index must be > 0!');
   end
   
   sym = history(obj,idx);
   U = universe(obj);
   S = universe(U,idx);
   P = projector(S,sym);
   return
end
