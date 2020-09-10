function list = symbols(obj)
%
% SYMBOLS    Get symbol list of a space, vector or operator
%
%               H = space(tensor,{'u','d'});
%               H = setup(H,'x',normalize(H('u')+H('d')));
%
%               list = symbols(H);
%
%            See also: TENSOR, SPACE, VECTOR, PROJECTOR, LABELS
%
   fmt = format(obj);
   
   switch fmt
      case {'#SPACE','#VECTOR','#OPERATOR','#PROJECTOR','#SPLIT'}
         list = property(obj,'symbols');
      otherwise
         error('bad format!');
   end
   
   return
end
