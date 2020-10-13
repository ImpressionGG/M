function ok = iszero(o)                % Is Object Additive Unit       
%
% ISZERO  Is object equal to additive unit?
%
%            ok = iszero(number(o,0))
%            ok = iszero(poly(o,[0]))
%            ok = iszero(ratio(o,[0],[1]))
%            ok = iszero(matrix(o,zeros(n)))
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORINTH, ISEYE, NUBER, POLY, RATIO, MATRIX
%
   switch o.type
      case 'number'
         o = can(o);
         o = trim(o);
         [num,den,xpo] = peek(o);
         ok = (length(num)==1 && length(den)==1 && num==0 && den==1);
         
      case 'poly'
         
            % first apply fast check. If we're lucky we're soon done!
            
         o = can(o);
         o = trim(o);

         [num,den,xpo] = peek(o);
         if (isequal(num,0) && ~isequal(den,0))
            ok = true;
            return
         end
         
            % fast check was negative
            
         if order(o) > 0
            ok = false;
         else
            c0 = peek(o,0);            % peek 0-th coefficien
            ok = iszero(c0);
         end
      case 'ratio'
         [p,~,~] = peek(o);            % get numerator polynomial
         ok = iszero(p);
      case 'matrix'
         M = o.data.matrix;
         [m,n] = size(M);
         for (i=1:m*n)
            if ~iszero(M{i})
               ok = false;
               return
            end
         end
         ok = true;
   end
end
