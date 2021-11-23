function varargout = var(o,tag,value,varargin)  
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
%      Multiple Get:
%
%         [A,B,C] = var(o,'A,B,C');         % direct get
%         [A,B,C] = var(o,{'A,B,C',A,B,C}); % conditional get
%
%      Multiple Set:
%
%         o = var(o,'A,B,C',A,B,C);         % direct set
%         o = var(o,{'A,B,C'},A,B,C);       % conditional set
%
%      Example: easy access
%
%         o = set(o,'system','A,B,C',magic (2),ones(2,1),ones(1,2))
%         oo = var(o,get(o,'system'))
%         [A,B,C] = var(oo,'A,B,C')
%
%      Copyright(c): Bluenetics 2020 
%
%      See also: CORAZITA, PROPERTY
%
   section = 'var';                    % here we store settings
   switch nargin
      case 1
         vars = work(o,section);
         if (nargout == 0)
            disp(vars);
         else
            varargout{1} = vars;
         end
      case 2
         if iscell(tag)
            tags = tag;                % save input arg
            defval = tag{2};  tag = tag{1};
            if (ischar(tag) && isempty(find(tag==',')))
               varargout{1} = var(o,tag);
               if isempty(varargout{1})
                  varargout{1} = defval;
               end
            else
               varargout = prop(o,{'work.var'},tags);
            end
         elseif ischar(tag) && isempty(findstr(tag,'.'))            
            wrk = o.work;
            if ~isfield(wrk,'var')
               for (i=1:nargout)
                  varargout{i} = [];
               end
            else
               if ischar(tag) && isempty(find(tag==','))  % simple tag
                  vars = wrk.var;
                  if isfield(vars,tag)
                     varargout{1} = vars.(tag);
                  else
                     varargout{1} = [];
                  end
               else                    % process comma separated tags
                  varargout = prop(o,{'work.var'},tag);
               end
            end
         elseif isempty(tag) || isstruct(tag)
            o.work.var = tag;          % initialize vars with struct
            varargout{1} = o;
         else
            varargout{1} = work(o,[section,'.',tag]);
         end
      case 3
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
      otherwise
         if (iscell(tag) || (ischar(tag) && ~isempty(find(tag==','))))
            varargout{1} = prop(o,{'work.var'},tag,[{value},varargin]);
         else
            error('1,2 or 3 input args expected!');
         end
   end
end

