function list = symbols(obj)
%
% SYMBOLS   Get symbol list of a space, vector or operator
%
%    Syntax
%
%       H = space(toy,{'u','d'});
%       H = setup(H,'x',normalize(H('u')+H('d')));
%
%       list = symbols(H);
%
%    See also: TOY, SPACE, VECTOR, PROJECTOR, LABELS
%
   typ = type(obj);
   
   switch typ
      case {'#SPACE','#VECTOR','#OPERATOR','#PROJECTOR','#SPLIT'}
         list = property(obj,'symbols');
      otherwise
         error('bad type!');
   end
   
   return
end
