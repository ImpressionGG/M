function varargout = get(o,varargin) 
%
% GET   Get a parameter from a CORAZITA.
%
%          bag = get(o)                % get a bag of all parameters
%          date = get(o,'date')        % get a specific parameter
%          date = get(o,{'date',now})  % get with default value (if empty)
%
%       Multiple get
%
%          [a,b,...] = get(o,'a','b',...)
%          [a,b,...] = get(o,{'a',1},{'b',2},...)
%
%          [a,b,c] = get(o,'a,b,c')
%          [a,b,c] = get(o,{'a,b,c',1,2,3})
%
%          [A,B,C] = get(o,'system','A,B,C')     % system.A, system.B, ...
%
%       Copyright(c): Bluenetics 2020 
%
%       See also: CORAZITA, SET, PROP
%
   section = 'par';                    % work with parameter section
   
   switch nargin
      case 1
         varargout{1} = o.par;
      case 2
         tag = varargin{1};
         if iscell(tag)
%           if (length(tag) == 2 && nargout == 1)
            if (length(tag) == 2 && nargout <= 1)
               defval = tag{2};  tag = tag{1};
               varargout{1} = get(o,tag);
               if isempty(varargout{1})
                  varargout{1} = defval;
               end
            else
               if (nargout ~= length(tag)-1)
                  error('size of tag list must match number of out args!');
               end
               
               tags = tag{1};
               args = tag(2:end);
               idx = find(tags == ',');
               idx = [0,idx,length(tags)+1];

               for (i=1:nargout)
                  tag = tags(idx(i)+1:idx(i+1)-1);
                  value = get(o,tag);
                  if isempty(value)
                     varargout{i} = args{i};
                  else
                     varargout{i} = value;
                  end
               end
            end
         elseif isempty(findstr(tag,'.'))            
            if isfield(o.par,tag)
               varargout{1} = o.par.(tag);
            elseif (nargout > 1 && ischar(tag) && ~isempty(find(tag==',')))
               tags = tag;
               idx = find(tags == ',');
               idx = [0,idx,length(tags)+1];

               if (nargout ~= length(idx)-1)
                  error(['number of (comma separated) tags does not match',...
                         ' number of out args']);
               end

               for (i=1:nargout)
                  tag = tags(idx(i)+1:idx(i+1)-1);
                  varargout{i} = get(o,tag);
               end
            else
               varargout{1} = [];
            end
         else
            varargout{1} = prop(o,[section,'.',tag]);
         end
      otherwise
         
            % first check: [A,B,C] = get(o,'system','A,B,C')
            
         if (ischar(varargin{1}) && ischar(varargin{2}))
            prefix = varargin{1};
            tags = varargin{2};
            idx = find(tags == ',');

            if ~isempty(idx)
               if (length(idx)+1 ~= nargout)
                  error('tag list size must match number of out args!');
               end
               
               idx = [0,idx,length(tags)+1];
               for (i=1:nargout)
                  tag = tags(idx(i)+1:idx(i+1)-1);
                  varargout{i} = get(o,[prefix,'.',tag]);
               end
               return
            end
         elseif (nargout ~= nargin-1)
            error('nargin must be 1+nargout!');
         end
         
         for (i=1:length(varargin))
            varargout{i} = get(o,varargin{i});
         end
   end
end
