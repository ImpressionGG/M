function o = set(o,tag,value,varargin)                                    
%
% SET   Set a parameter for a CORAZITA object
%
%          o = set(o,bag)              % refresh with a bag of parameters
%          o = set(o,[])               % clear all parameters
%          o = set(o,'date',date)      % set a specific parameter
%
%       Conditional set
%
%          o = set(o,{'date'},now)     % set only if empty
%
%       Multiple set
%
%          o = set(o,'a',1,'b',2,...)  % multiple setting
%          o = set(o,'a,b,c',1,2,3)    % compact multiple setting
%          o = set(o,'sys','A,B',1,2)  % compact multiple setting
%
%          o = set(o,{'a,b,c'},1,2,3)  % compact multiple setting
%          o = set(o,'sys',{'A,B'},1,2)% compact multiple setting
%
%       Example 1:
%       
%          A = [-1 0;0 -2]; B = [1;1]; C = [1 1]; D = 0;
%          o = set(o,'system','A,B,C,D',A,B,C,D);
%          [A,B,C,D] = get(o,'A,B,C,D');
%
%       Example 2:
%          o = set(o,{'b,c'},[1 0],1);
%          o = set(o,'system',{'C,D'},[1 0],1);
%
%       Copyright(c): Bluenetics 2020 
%
%       See also: CORAZITA, GET, PROP
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
         istag = ischar(tag) || iscell(tag);
         
         if (istag && ~isempty(find(tag==',')))
            o = MultiSet(o,tag,[{value},varargin]);
            return
         elseif (ischar(tag) && (ischar(value) || iscell(value)))
            if iscell(value)
               tags = value{1};
            else
               tags = value;
            end
            
               % pass over values (!), not tags !
            if ~isempty(find(tags==','))
               o = CompactSet(o,tag,value,varargin);
               return;
            end
         end
         
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

%==========================================================================
% Helper Functions
%==========================================================================

function o = MultiSet(o,tags,list)
   conditional = iscell(tags);
   if (conditional)
      tags = tags{1};
   end
   
   idx = find(tags == ',');
   idx = [0,idx,length(tags)+1];
   
   if (length(list) ~= length(idx)-1)
      error('number of (comma separated) tags does not match number of values');
   end
   
   for (i=1:length(list))
      if (conditional)
         value = get(o,[name,'.',list{i}]);
         if isempty(value)
            o = set(o,[name,'.',tag],list{i});
         end
      else
      tag = tags(idx(i)+1:idx(i+1)-1);
         o = set(o,tag,list{i});
      end
   end
end
function o = CompactSet(o,name,tags,list)
   conditional = iscell(tags);
   if (conditional)
      tags = tags{1};
   end
   
   idx = find(tags == ',');
   idx = [0,idx,length(tags)+1];
   
   if (length(list) ~= length(idx)-1)
      error('number of (comma separated) tags does not match number of values');
   end
   
   for (i=1:length(list))
      tag = tags(idx(i)+1:idx(i+1)-1);
      if (conditional)
         value = get(o,[name,'.',tag]);
         if isempty(value)
            o = set(o,[name,'.',tag],list{i});
         end
      else
         o = set(o,[name,'.',tag],list{i});
      end
   end
end
