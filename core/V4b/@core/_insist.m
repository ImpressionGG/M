function obj = insist(obj,classnames)
%
% INSIST     Insist object class to be of required class name, otherwise
%            invoke an error.
%
%               obj = insist(obj,'chameo');   % insist obj to be a CHAMEO
%               class
%
   if ~iscell(classnames)
      classnames = {classnames};
   end
   
   name = class(obj);
   idx = match(name,classnames);
   
   if isempty(idx)
      error(['unexpected object class: ',name]);
   end
   return
   
%eof   