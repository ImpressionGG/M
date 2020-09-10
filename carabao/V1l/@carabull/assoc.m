function [value,idx] = assoc(key,list,pair)
%
% ASSOC   Look-up a value from a list which is associated with a key.
%
%    Generic forms:
%
%       value = o.assoc(key,table)               % associate key with value
%       table = o.assoc(key,table,{key,value})   % add/update assoc pair
%       table = o.assoc(key,table,{})            % delete assoc pair
%
%    Key can be a numeric scalar or a character string. 
%
%       o.assoc(1,{{1,'red'},{2,'green'},'black'})   % => 'red'
%       o.assoc(2,{{1,'red'},{2,'green'},'black'})   % => 'green'
%       o.assoc(5,{{1,'red'},{2,'green'},'black'})   % => 'black'
%
%       o.assoc('$T',{{'$T','r'},{'$F','b'},'k'})    % => 'r'
%       o.assoc('$F',{{'$T','r'},{'$F','b'},'k'})    % => 'b'
%       o.assoc('$w',{{'$T','r'},{'$F','b'},'k'})    % => 'k'
%
%    An assoc list consists of a list of pairs {key,value} with an
%    optional single default value as the last list element; If no
%    default value is provided, the default value is an empty
%    matrix.
%
%       o.assoc(0,{{1,'r'},{2,'b'},'k'})             % => 'k'
%       o.assoc(0,{{1,'r'},{2,'b'}})                 % => []
%   
%    Assoc pairs can be updated, added, or replaced:
%
%       table = {{1,'red'},{2,'green'},'black'}
%       table = o.assoc(3,table,{3,'blue'})     % add/update assoc pair
%       table = o.assoc(2,table,{})             % delete assoc pair
%
%    Optionally get index of find position (index = 0 if not found)
%
%       [value,idx] = o.assoc(0,{{1,'r'},{2,'b'}})
%       [table,idx] = o.assoc(2,table,{2,'y'})
%
%    See also: CARABULL
%
   if ~(isnumeric(key) || ischar(key)) 
      %error('Input arg1 (key) must be numeric or character string!');
   end
%
% Two input args: associate a value with tag
% a) o.assoc(1,{{1,'red'},{2,'green'},'black'})   % => 'red'
% b) [value,idx] = o.assoc(0,{{1,'r'},{2,'b'}})
%
   while (nargin == 2)

      if ~iscell(list)
         error('Input arg2 (assoc list) must be a list (cell array)!');
      end

      idx = 0;                            % init by default
      n = length(list);
      for (i=1:n)
         pair = list{i};
         if iscell(pair) && length(pair) == 2   
            pairkey = pair{1};  value = pair{2};
            if isequal(key,pairkey)
               idx = i;
               return;
            end
         else                   % potentially a default value!
            if (i == n)         % last element?
               value = pair;    % return default value
               return
            else
               error('Default value of assoc list must be last list element!');
            end   
         end
      end

      value = [];               % if no default value is provided we return []
      return
   end
%
% Three input args: update assoc table
% a) table = o.assoc(tag,table,{tag,value})   % add/update assoc pair
% c) table = o.assoc(tag,table,{})            % delete assoc pair
% d) [table,idx] = o.assoc(2,table,{2,'y'})
%
   while (nargin == 3)
      if ~iscell(pair) || ~(length(pair) == 2 || length(pair)==0)
         error('arg3 must be a pair!');
      end
      
      if length(pair) == 2
         newkey = pair{1};  newval = pair{2};
         if ~isequal(key,newkey)
            error('key (arg1) akd key in pair (arg3{1}) must match!');
         end
      end
      
         % find out if assoc table has a default value at the end
         
      if isempty(list)
         hasdefault = false;
      else
         tail = list{end};
         if ~(iscell(tail) && length(tail) == 2)
            hasdefault = true;
         else                          % tail is a pair
            first = tail{1};
            if (isnumeric(first) || ischar(first))
               hasdefault = false;
            else
               hasdefault = true;
            end
         end
      end
      
         % get current association with index of pair
         
      [~,idx] = carabull.assoc(key,list);
      if (idx > 0)
         if isempty(pair)
            list(idx) = [];            % remove pair
         else
            list{idx} = pair;
         end
      elseif ~isempty(pair)            % key not in list
         if hasdefault
            list{end} = pair;
            list{end+1} = tail;
         else
            list{end+1} = pair;
         end
      end
      value = list;                    % return assoc list
      return
   end
%
% Everything beyond this point indicates bad calling syntax
%
   error('bad calling syntax: 2 or 3 input args expected!');
end
