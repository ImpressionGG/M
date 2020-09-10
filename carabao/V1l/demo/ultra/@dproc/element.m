function [dp,elist,keys] = element(obj,idx,j)
% 
% ELEMENT  Get a process element referenced by chain index i and 
%          element of chain index j.
%      
%             dp = element(obj,i);       % get chain i
%             dp = element(obj,i,j);     % get element i,j
%             dp = element(obj,[i j]);   % get element i,j
%             dp = element(obj,'V1');    % get element named 'V1'
%
%          For processes:
%
%             [em,elist,keys] = element(obj);         % get element matrix of process
%
%          See also   DISCO, DPROC

   dp = [];   % empty if no element found
   elist = [];
   keys = [];

   narginp = nargin;
   
   if (narginp < 1)
      error('missing arg1!');
   end

% resolve key

   if (narginp == 2)
      if ~isstr(idx) & strcmp(kind(obj),'process')
         base = key(obj);
         if (idx >= base)
            j = rem(idx,base);
            idx = floor(idx/base);
            narginp = 3;
         end
      end
   end
   
% dispath kind

   knd = kind(obj);   
   switch knd
      case {'process'}
         % for one input argument return element matrix or element array
         
         if (narginp == 1)
            [m,n] = sizes(obj);
            em{m,n} = [];   % dimension element matrix
            k = 0;
            for (i=1:m)
               for (j=1:n)
                  el = element(obj,[i,j]);      
                  em{i,j} = el;
                  if (~isempty(el))
                     k = k+1; 
                     elist{k} = el;
                     keys(k) = key(obj,i,j);
                  end
               end
            end
            dp = em;      % set output arg
            return
         end

            % first check if idx is a string (name)

         if (narginp == 2) 
            if isstr(idx)
               name = idx;
               idx = index(obj,name);
               if (isempty(idx))
                  return;
               end
            elseif (length(idx) == 1)   % retrieve chain i
               if (idx < 1) | (idx > length(obj.data.list))
                  return;
               end 
               dp = obj.data.list{idx};   
               return
            end
         end
         
            % assume idx beeing numeric

         if (narginp < 3)
            if (length(idx) ~= 2)
               error('arg2 must be 2-vector!');
            end
            i = idx(1);  j = idx(2);
         else
            if (length(idx) ~= 1)
               error('arg2 must be scalar!');
            end
            if (length(j) ~= 1)
               error('arg3 must be scalar!');
            end
            i = idx;
         end
         
         % ok - find chain and element
         
         if (i < 1) | (i > length(obj.data.list))
            return;
         end 
         ch = obj.data.list{i};   
         chain = getp(ch,'list');
         
         if (j < 1) | (j > length(chain))
            return
         end 
         dp = chain{j};
         
      case {'chain','sequence'}
         if ( narginp > 2) error('only two arguments expected!'); end

         if ( narginp == 1 )
            dp = obj.data.list;
            return;
         end

         if isstr(idx)
            name = idx;
            idx = index(obj,name);
            if (isempty(idx))
               return;
            end
         end

         if (length(idx) ~= 1)
            error('scalar expected to index kind chain or sequence!'); 
         end

         if (idx < 1) | (idx > length(obj.data.list))
            return;
         end 
         dp = obj.data.list{idx};   

      otherwise
         error('arg1 must be of kind process, chain or sequence!');
   end



   if (narginp == 2) 
      if isstr(idx)
         name = idx;
         idx = index(obj,name);
         if (isempty(idx))
            return;
         end
      elseif (length(idx) == 1)   % retrieve chain i
         if (idx < 1) | (idx > length(obj.data.list))
            return;
         end 
         dp = obj.data.list{idx};   
         return
      end
   end
end
