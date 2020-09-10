function value = var(o,tag,value)  
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
            value = vars;
         end
      case 2
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
         value = o;
      otherwise
         error('1,2 or 3 input args expected!');
   end
end

