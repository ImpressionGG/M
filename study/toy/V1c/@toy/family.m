function varargout = family(U,initials)
%
% FAMILY    Build the support of a consistent family of histories
%
%               H = space(toy,0:5);
%               T = operator(H,'>>');
%               S0 = split(H,{'0','*'});
%               S = split(H,{'0','1','2','3','*'});
%               U = T*S0*S*S;
%
%               list = family(U);
%               list = family(U,'0');
%               list = family(U,{'0','1'});
%
%            Multiple output args
%
%               [Y1,Y2] = family(U,{'0','1'});
%
%            See also: TOY, SPACE, OPERATOR, SPLIT, UNIVERSE, HISTORY
%
   if (nargin ~= 1 && nargin ~= 2)
      error('1 or 2 input args expected!');
   end
   
   if ~property(U,'universe?')
      error('universe expected (arg1)!');
   end
   
   S0 = universe(U,1);   % get first split
   
   if (nargin < 2)
      initials = labels(S0);
   else
      if ~(ischar(initials) || iscell(initials))
         error('string or list expected for arg2!');
      end
      
      if ischar(initials)
         initials = {initials};      
      end
   end
   initials = initials(:)';
   
% Test indexing labels whether they can index a projector

   list = initials;
   for (i=1:length(initials))
      sym = initials{i};
      try
         P = projector(S0,sym);   % test whether this works
      catch
         error(['bad label for indexing an initial projector: ',sym]);
      end
   end

% now put all initial elements one level deeper

   for (i=1:length(initials))
      initials{i} = {initials{i}};
   end
   
% OK - all preparations are done!

   n = property(U,'number');      % get history length
   support = {};                  % init support
   chainops = {};                 % list of according chain operators
   
   for (j=2:n)                 % for increasing length do the studies
      for (i=1:length(initials))
         y0 = initials{i};           % next initial label
      
         S = universe(U,j);
         labs = labels(S);
         
         for (k=1:length(labs))
            sym = labs{k};
            sym = sym(2:end-1);   % without leading '[' and trailing ']'
            
            y = y0;  y{end+1} = sym;
            Y = history(U,y);

               % calculate chain operator and check whether the chain
               % operator of new history is orthogonal to all chain 
               % operator of all histories in current constructed support
%Y
            K = chain(Y);
            if ~property(K,'null?')
               idx = Orthogonal(K,chainops);
               if (idx > 0)
                  fprintf('*** inconsistent histories:\n');
                  fprintf(['    ',info(Y),'\n']);
                  Yidx = history(U,support{idx});
                  fprintf(['    ',info(Yidx),'\n']);
               end

               %['add ',info(Y)]                  

               support{end+1,1} = y;
               chainops{end+1,1} = K;
            end
            fprintf('.');
         end % for k
         fprintf(':');
      end % for i
      fprintf('\n');

      initials = support;
      list = support;
      support = {};                  % init support
      chainops = {};                 % list of according chain operators
   end % for j
   
% post processing

   for (i=1:length(list))
      y = list{i};
      Y = history(U,y);
      list{i} = Y;
   end
   
   if (nargout == 0)
      fprintf('Support of history family:\n');
      for (i=1:length(list))
         Y = list{i};
         fprintf(['   ',info(Y),'\n']);
      end
   elseif (nargout == 1)
      varargout{1} = list;
   else
      for (i=1:nargout)
         if (i <= length(list))
            Y = list{i};
         else
            Y = [];
         end
         varargout{i} = Y;
      end
   end
   return
end

%==========================================================================
% Check Orthogonality
%==========================================================================

function idx = Orthogonal(op,list)
%
% ORTHOGONAL  Check if operator op is orthogonal to all projectors
%             in list. Return 0 if orthogonal, otherwise return first 
%             index of non orthogonal chain operator
%
   idx = 0;                     % by default orthogonal (idx = 0)
   for (i=1:length(list))
      opi = list{i};
      op0 = op'*opi;
      if ~property(op0,'null?')
         idx = i;               % return index of non orthogonal chain op
         return
      end
   end
   return
end