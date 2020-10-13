function o = remove(o,idx)
% 
% REMOVE   Remove an object from the list of objects of a container
%
%    Syntax
%       o = remove(o,3)              % remove 3rd object from list
%
%    Note: if index of object to remove is out of range then no action is
%    taken, but the returned object will be empty.
%
%    See also: CORAZON, REMOVE, PASTE
%    Copyright (c): Bluenetics 2020 
%
   if (nargin ~= 2)
      error('2 input args expected!');
   end
   if ~isa(idx,'double') || length(idx) ~= 1
      error('index (arg2) must be a scalar number');
   end
   if round(idx) ~= idx
      error('index (arg2) must be an integer');
   end
%
% arg checks passed, let's go on with the real task
%
   len = data(o,inf);                  % get length of trace list
   
   if isnan(len)
      error('object''s data type is not for removing objects!')
   end
   
   if (idx < 1 || idx > len)
      o = [];                          % index out of range
      return
   end

% remove the objects

   olist = data(o);                    % get container's trace list
   olist(idx) = [];                    % delete item from list
   o = data(o,olist);                  % put list back into object
   
   return
end   

