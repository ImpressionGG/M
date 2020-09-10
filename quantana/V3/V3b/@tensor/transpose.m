function out = transpose(obj)
% 
% TRANSPOSE    Tensor transpose (excluding conjugation)
%
%                 S = space(tensor,1:5);
%                 Vket = vector(S,2);
%
%                 Vbra = Vket.';
%                 
%
   fmt = format(obj);
   
   switch fmt
      case {'#SPACE'}
            lab = labels(obj);
            out = labels(obj,lab');
            return
      
      case '#VECTOR'
            M = matrix(obj);
            lab = labels(obj);
            obj = labels(obj,lab');
            obj = data(obj,'vector.bra',~data(obj,'vector.bra'));
            out = matrix(obj,M');
            return

      case '#OPERATOR'
            M = matrix(obj);
            lab = labels(obj);
            obj = labels(obj,lab');
            out = matrix(obj,M');
            return
   end
   return
   
   error('cannot perform tensor transpose (bad type)!');
end
