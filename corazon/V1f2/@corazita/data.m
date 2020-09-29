function value = data(o,tag,value)  
%
% DATA   Get or set object data settings
%  
%    Object data is stored in object's data properties.
%  
%       bag = data(o)                  % get data settings
%       data(o,bag)                    % refresh all data settings
%
%    Set/get specific data setting
%
%       x = data(o,'x')                % get value of specific data 
%       o = data(o,'x',x)              % set value of specific data
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITA, PROPERTY
%
   section = 'data';    % here we store settings
   switch nargin
      case 1
         dat = prop(o,section);
         if (nargout == 0)
            disp(dat);
         else
            value = dat;
         end
         
      case 2
         if isempty(tag)
            value = prop(o,section,tag);  % clear all data
         elseif ischar(tag)
            value = prop(o,[section,'.',tag]);
         elseif iscell(tag) || isstruct(tag) || isempty(tag)
            value = prop(o,section,tag);
         else
            error('arg2 must be either string, structure, list or integer!');
         end
         
      case 3
         value = prop(o,[section,'.',tag],value);
      otherwise
         error('1,2 or 3 input args expected!');
   end
end

