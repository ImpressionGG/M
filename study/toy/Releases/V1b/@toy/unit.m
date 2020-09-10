function obj = unit(obj)
%
% UNIT   Normalize to a (non-null) unit vector
%           
%           H = space('spin');                 % create spin space
%           V = unit(ket(H,'u')+ket(H,'d'));   % convert to unit length ket
%           V = unit(bra(H,'r')+bra(H,'l'));   % convert to unit length bra
%
%        Remark: null vectors remain unaffected!
%
%        See also: TOY, SPACE, KET, BRA, VECTOR, NORM, NORMALIZE
%
   switch type(obj)
      case '#VECTOR'
         if ~property(obj,'null?')
            obj = obj / norm(obj);
         end
         
      otherwise
         error(['type ',type(obj),' not supported for unit!']);
   end
   return
end
