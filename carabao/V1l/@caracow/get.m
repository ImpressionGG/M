function varargout = get(o,varargin) 
%
% GET   Get a parameter from a CARACOW.
%
%          bag = get(o)                % get a bag of all parameters
%          date = get(o,'date')        % get a specific parameter
%          date = get(o,{'date',now})  % get with default value (if empty)
%
%       Multiple get
%          [a,b,...] = get(o,'a','b',...)
%          [a,b,...] = get(o,{'a',1},{'b',2},...)
%
%       See also: CARACOW, SET, PROP
%
   section = 'par';                    % work with parameter section
   
   switch nargin
      case 1
         varargout{1} = o.par;
      case 2
         tag = varargin{1};
         if iscell(tag)
            defval = tag{2};  tag = tag{1};
            varargout{1} = get(o,tag);
            if isempty(varargout{1})
               varargout{1} = defval;
            end
         elseif isempty(findstr(tag,'.'))            
            if isfield(o.par,tag)
               varargout{1} = o.par.(tag);
            else
               varargout{1} = [];
            end
         else
            varargout{1} = prop(o,[section,'.',tag]);
         end
      otherwise
         if (nargout ~= nargin-1)
            error('nargin must be 1+nargout!');
         end
         for (i=1:length(varargin))
            varargout{i} = get(o,varargin{i});
         end
   end
end
