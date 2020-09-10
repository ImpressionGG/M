function ok = iseye(o)                % Is Object Multiplicative Unit 
%
% ISEYE   Is object equal to multiplicative unit?
%
%            ok = iseye(number(o,1))
%            ok = iseye(poly(o,[1]))
%            ok = iseye(ratio(o,[88],[88]))
%            ok = iseye(matrix(o,eye(n)))
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORINTH, ISZERO, NUBER, POLY, RATIO, MATRIX
%
   switch o.type
      case 'number'
         o = can(o);
         [num,den,~] = peek(o);
         if length(num) ~= 1 || length(den) ~= 1
            ok = false
         else
            ok = isequal(num(1)/den(1),1);
         end
      case 'poly'
         
            % first apply fast check. If we're lucky we're soon done!
            
         [num,den,xpo] = peek(o);
         if (isequal(num,1) && isequal(den,1) && xpo==0)
            ok = true;
            return
         end
         
            % fast check was negative
            
         o = can(o);
         if order(o) > 0
            ok = false;
         else
            c0 = peek(o,0);            % peek 0-th coefficien
            ok = iseye(c0);
         end
      case 'ratio'
         if (order(o) ~= 0)
            ok = false;
            return
         end
         [ox,oy,~] = peek(o);
         ox = number(ox);             % convert numerator polynomial to 
         oy = number(oy);
         oo = div(ox,oy);
         ok = iseye(oo);
      case 'matrix'
         M = o.data.matrix;
         [m,n] = size(M);

         ok = false;                   % by default false
         if (m ~= n)
            return
         end
         
         for (i=1:m)
            for (j=1:n)
               if (i == j)
                  if ~iseye(M{i,j})
                     return
                  end
               else
                  if ~iszero(M{i,j})
                     return
                  end
               end
            end
         end
         ok = true;
   end
end
