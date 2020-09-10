function out = ctranspose(obj)
% 
% CTRANSPOSE   Tensor conjugate transpose (including conjugation)
%
%                 S = space(tensor,1:5);
%                 Vket = vector(S,2);
%
%                 Vbra = Vket';     % conjugate transpose
%                 
%              See also CTRANSPOSE
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
            bra = either(data(obj,'vector.bra'),0);
            obj = data(obj,'vector.bra',~bra);
            out = matrix(obj,M');
            return

      case '#OPERATOR'
            M = matrix(obj);
            lab = labels(obj);
            obj = labels(obj,lab');
            out = matrix(obj,M');
            return

      case '#HISTORY'
            bra = either(data(obj,'history.bra'),0);
            out = data(obj,'history.bra',~bra);
            return

   end
   return
   
   error('cannot perform tensor transpose (bad type)!');
end
