function par = access(obj,classname)
%
% ACCESS   Access parent object from a derived object
%
%             par = access(obj,classname)
%             par = access(obj,'shell')
%             par = access(obj,'streams')
%
%          See also: SHELL
%
   par = obj;
   while ~strcmp(class(par),classname)
      par = parent(par);
      if isempty(par)
         error(['cannot access parent class ''',classname,...
                ''' from object class ''',class(obj),'!']);
      end
   end
   return

%eof   