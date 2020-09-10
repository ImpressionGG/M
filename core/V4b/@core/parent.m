function par = parent(obj)
%
% PARENT    Return parent class object from a CORE object or derived 
%           CORE object. Return empty if no parent (e.g. for CORE object)
%
%              par = parent(obj)
%
%           See also: CORE, KID
%
   if strcmp(class(obj),'core')
      par = [];
   else
      s = struct(obj);
      flds = fields(s);
      parname = flds{end};
      par = eval(['s.',parname],'[]');
      %par.class = s.class;                  % preserve class attribute
   end
   return
   
%eof   