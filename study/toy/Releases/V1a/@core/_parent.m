function par = parent(obj)
%
% PARENT    Return parent class object from a shell object or derived 
%           SHELL object. Return empty if no parent (e.g. for SHELL object)
%
%              par = parent(obj)
%
%           See also: SHELL, KID
%
   if strcmp(class(obj),'shell')
      par = [];
   else
      s = struct(obj);
      flds = fields(s);
      parname = flds{end};
      par = eval(['s.',parname],'[]');
   end
   return
   
%eof   