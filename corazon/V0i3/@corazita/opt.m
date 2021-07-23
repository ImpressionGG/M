function value = opt(o,tag,value)  
%
% OPT   Get or set object options
%  
%    Object options are stored in object's work properties.
%  
%         opts = opt(o)                % get bag of options
%         opt(o,opts)                  % refresh all options
%
%      Get/set specific option setting
%
%         value = opt(o,'flag')        % get value of specific option
%         o = opt(o,'flag',1)          % set value of specific option
%
%      Conditional get/set option
%
%         value = opt(o,{'flag',0})    % get option or 0 (default) if empty
%         o = opt(o,{'flag'},0)        % set option only if empty
%
%      Copyright(c): Bluenetics 2020 
%
%      See also: CORAZITA, PROPERTY
%
   section = 'opt';    % here we store settings
   switch nargin
      case 1
         opts = work(o,section);
         if (nargout == 0)
            disp(opts);
         else
            value = opts;
         end
      case 2
         if iscell(tag)
            defval = tag{2};  tag = tag{1};
            value = opt(o,tag);
            if isempty(value)
               value = defval;
            end
         elseif ischar(tag)
            wrk = o.work;
            if ~isfield(wrk,'opt')
               value = [];
            else
               opts = wrk.opt;
               idx = find(tag == '.');
               if isempty(idx)
                  if isfield(opts,tag)
                     value = opts.(tag);
                  else
                     value = [];
                  end
               else
                  idx = [0,idx,length(tag)+1];
                  value = opts;
                  for (i=1:length(idx)-1)
                     chunk = tag(idx(i)+1:idx(i+1)-1);
                     if isfield(value,chunk)
                        value = value.(chunk);
                     else
                        value = [];
                        return
                     end
                  end
               end
            end
         elseif isempty(tag) || isstruct(tag)
            o.work.opt = tag;          % initialize opts with struct
            value = o;
         else
            value = work(o,[section,'.',tag]);
         end
      case 3
         if iscell(tag)
            tag = tag{1};
            if isempty(opt(o,tag))
               o = opt(o,tag,value);
            end
         elseif isempty(findstr(tag,'.'))            
            o.work.opt.(tag) = value;
         else
            o = work(o,[section,'.',tag],value);
         end
         value = o;
      otherwise
         error('1,2 or 3 input args expected!');
   end
end

