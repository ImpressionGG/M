function o = set(o,tag,value,varargin)                                    
%
% SET   Set a parameter for a CARACOW object
%
%          o = set(o,bag)              % refresh with a bag of parameters
%          o = set(o,[])               % clear all parameters
%          o = set(o,'date',date)      % set a specific parameter
%          o = set(o,'a',1,'b',2,...)  % multiple setting
%
%       Conditional set
%
%          o = set(o,{'date'},now)     % set only if empty
%
%       See also: CARACOW, GET, PROP
%
   section = 'par';
   
   switch nargin
      case 2
         value = tag;
         if isstruct(value)
            o.par = value;
         elseif isempty(value) && isa(value,'double')
            o.par = [];             % always double empty ([])
         else
            error('struct or empty [] expected for arg2!');
         end
      case 3
         if iscell(tag)
            tag = tag{1};
            if isempty(get(o,tag))
               o = set(o,tag,value);
            end            
         elseif isempty(findstr(tag,'.'))            
            o.par.(tag) = value;
         else
            o = prop(o,[section,'.',tag],value);
         end
      otherwise
         if rem(length(varargin),2) ~= 0
            error('odd number of input args expected!');
         end
         o = set(o,tag,value);
         for (i=1:2:length(varargin))
            tag = varargin{i};  value = varargin{i+1};
            if ~ischar(tag)
               error(sprintf('char string expected for arg%g!',3+i));
            end
            o = set(o,tag,value);
         end
   end
end
