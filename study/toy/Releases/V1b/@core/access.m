function par = access(obj,classname)
%
% ACCESS   Access parent object from a derived object
%
%             par = access(obj,classname)
%             par = access(obj,'core')
%             par = access(obj,'toy')
%
%          See also: CORE
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
end
   