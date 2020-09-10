function varargout = var(o,varargin)  
%
% VAR   Get or set object variable settings
%  
%    Object variables are stored in object's work properties.
%  
%         vars = var(o)                % get work variable settings
%         var(o,vars)                  % refresh all variable settings
%
%      Set/get specific variable setting
%
%         value = var(o,'flag')        % get value of specific setting
%         value = var(o,{'flag',0})    % get with default value (if empty)
%
%         o = var(o,'flag',1)          % set value of specific setting
%         o = var(o,{'date'},now)      % set only if empty
%
%      Multiple variable settings
%
%         [a,b,c] = var(o,'a','b','c')
%         [a,b] = var(o,{'a',0},{'b',pi})
%
%         o = var(o,'a',1, 'b',2, 'c',3)
%         o = var(o,{'a'},1, {'b'},2)
%
%      Copyright(c): Bluenetics 2020 
%
%      See also: CORDOBA, PROPERTY
%
   section = 'var';                    % here we store settings
   if (nargin == 1)
         vars = work(o,section);
         if (nargout == 0)
            disp(vars);
         else
            varargout{1} = vars;
         end
   elseif (nargin == 2)
         tag = varargin{1};
         if iscell(tag)
            defval = tag{2};  tag = tag{1};
            value = var(o,tag);
            if isempty(value)
               value = defval;
            end
         elseif ischar(tag) && isempty(findstr(tag,'.'))            
            wrk = o.work;
            if ~isfield(wrk,'var')
               value = [];
            else
               vars = wrk.var;
               if isfield(vars,tag)
                  value = vars.(tag);
               else
                  value = [];
               end
            end
         elseif isempty(tag) || isstruct(tag)
            o.work.var = tag;          % initialize vars with struct
            value = o;
         else
            value = work(o,[section,'.',tag]);
         end
         varargout{1} = value;
   elseif (nargin == 3) && (nargout > 0) && (nargout ~= nargin-1)
         tag = varargin{1};  value = varargin{2};
         if iscell(tag)
            tag = tag{1};
            if isempty(var(o,tag))
               o = var(o,tag,value);
            end
         elseif isempty(findstr(tag,'.'))            
            o.work.var.(tag) = value;
         else
            o = work(o,[section,'.',tag],value);
         end
         varargout{1} = o;
   elseif (nargin >= 3) && (nargout > 0) && (nargout == nargin-1)
      for (i=1:nargout)
         tag = varargin{i};
         varargout{i} = var(o,tag);
      end
   elseif (nargin >= 5) && nargout == 1 && rem(nargin,2) == 1
      for (i=1:2:nargin-1)
         tag = varargin{i};  value = varargin{i+1};
         o = var(o,tag,value);
      end
      varargout{1} = o;
   else
      error('bad calling syntax!');
   end
end

