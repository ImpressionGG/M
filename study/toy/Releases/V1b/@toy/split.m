function obj = split(H,list)
%
% SPLIT      Construct a split object, which is a decomposition of
%            a Hilbert space into subspaces represented by  a list
%            of projectors. If the sum of projectors of the split does
%            not sum up to identity a complementary projector '[*]' will
%            be automatically added to the split.
%
%               H = space(toy,{'u','d'});
%               S = split(H,{'u','d'});        % split into [u] and [d]
%
%               H = space(toy,1:3);
%               S = split(H,{'1',{'2','3'}});  % split into [1] and [2,3]
%
%               H = space(toy,{'u','d'});
%               H = setup(H,'A',normalize(H('u')+H('d')));
%               H = setup(H,'B',normalize(H('u')-H('d')));
%               S = split(H,{'A','B'})         % split into [A] and [B]
%
%            A very usual split
%
%               S = split(H,labels(H));
%
%            Using projectors:
%
%               psi0 = H(1) + 2*H(2);
%               P0 = projector(H,psi0);
%               PZ = operator(H,1)-P0;
%               S = split(H,{P0,PZ});
%
%            Complementary projector [*]
%
%               H = space(toy,{'a','b','c','d','e'});
%               S = split(H,{'a',{'b','c'},'*'});
%
%               Pa  = S('a');    % same as Pa  = projector(S,'a')
%               Pbc = S('b,c');  % same as Pbc = projector(S,'b,c')
%               Pz  = S('*');    % same as Pz  = projector(S,'*')
%
%            See also: TOY, SPACE, VECTOR, PROJECTOR, OPERATOR
%
   if (nargin < 2)
      error('2 input args expected!');
   end
   
   if (property(H,'split?') && ischar(list))
      S = H;  idx = list;
      obj = projector(H,idx);
      return
   elseif ~(property(H,'space?'))
      error('object (arg1) must be a space!');
   end
 
% Check consistency of the split list

   plist = {};
   [m,n] = size(list);
   complement = [];
   
   for (i=1:m)
      for (j=1:n)
         arg = list{i,j};
         if ischar(arg)
            if strcmp(arg,'*')
               if ~isempty(complement)
                  error('only 1 occurence of ''*'' arg allowed!');
               else
                  complement = [i,j];
               end
            else
               P = projector(H,arg);
               plist{i,j} = P;
            end
         elseif iscell(arg)
            P = projector(H,arg);
            plist{i,j} = P;
         elseif isa(arg,'toy')
            if property(arg,'projector?')
               plist{i,j} = arg;
            else
               error('projector expected,if toy argument!');
            end
         else
            arg
            error('bad argument!');
         end
      end
   end

% Check consistency: add up to identity

   P = operator(H,0);       % init with null operator
   [m,n] = size(plist);
   
   for (i=1:length(plist(:)))
      Pi = plist{i};  % next projector
      if ~isempty(Pi)
         P = P+Pi;

         for (j=1:i-1)
            Pj = plist{j};
            if ~isempty(Pj)
               if ~property(Pi*Pj,'null?') || ~property(Pj*Pi,'null?')
                  error('non orthogonal projectors found in list (arg2)');
               end
            end
         end
      end
   end
   
   if ~property(P,'eye?')
      if isempty(complement)
         error('split does not add up to identity!');
      else
         P = eye(P) - P;
         P = data(P,'oper.symbol','*');
         plist{complement(1),complement(2)} = P;
      end
   end

% Create split object

   obj = type(H,'#SPLIT');
   obj = data(obj,'split.list',plist);

   assert(obj);
   return
end

