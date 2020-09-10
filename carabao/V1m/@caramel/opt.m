function varargout = opt(o,varargin)  
%
% OPT   Get or set object options. Method caramel/opt is an extension of
%       method caracow/opt to support multiple get/set syntax.
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
%      Multiple get
%
%         [a,b,c] = opt(o,'a','b','c')
%         [a,b,c] = opt(o,{'a',1},{'b',pi},{'c',NaN})
%
%      Multiple set
%
%         o = opt(o,'a',1, 'b',pi, 'c',NaN)
%         o = opt(o,{'a'},1, {'b'},pi, {'c'},NaN})
%
%      See also: CARAMEL, PROPERTY
%
   section = 'opt';    % here we store settings
   switch nargin
      case 1
         opts = work(o,section);
         if (nargout == 0)
            disp(opts);
         else
            varargout{1} = opts;
         end
      case 2
         tag = varargin{1};
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
                        varargout{1} = [];
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
         varargout{1} = value;
      case 3
         tag = varargin{1};  value = varargin{2};
         if (nargout == 2)
            varargout{1} = opt(o,varargin{1});
            varargout{2} = opt(o,varargin{2});
            return
         elseif iscell(tag)
            tag = tag{1};
            if isempty(opt(o,tag))
               o = opt(o,tag,value);
            end
         elseif isempty(findstr(tag,'.'))            
            o.work.opt.(tag) = value;
         else
            o = work(o,[section,'.',tag],value);
         end
         varargout{1} = o;
      otherwise
         if (nargout + 1 == nargin)    % multiple get
            for (i=1:nargout)
               varargout{i} = opt(o,varargin{i});
            end
         elseif (nargout == 1)         % multiple set
            if rem(length(varargin),2) ~= 0
               error('odd number of input args expected for multiple set!');
            end
            for (i=1:2:length(varargin))
               tag = varargin{i};  value = varargin{i+1};
               o = opt(o,tag,value);
            end
            varargout{1} = o;
         else
            error('bad calling syntax!');
         end
   end
end

