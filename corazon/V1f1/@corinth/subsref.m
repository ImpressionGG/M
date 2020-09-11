function oo = subsref(o,oper)
%
% SUBSREF  Subscripted reference: access elements of Corinthian matrix
%
%             M = matrix(o,magic(3));
%             m23 = M(2,3)
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORINTH, MATRIX, SIZE, SUBSASGN
%
   switch oper.type
      case '.'                         % normal dot operation
         if (nargout == 0)
            eval(['o.',oper.subs,';']);
         else
            eval(['oo=o.',oper.subs,';']);
         end
         
      case '()'
         subs = oper.subs;

         switch o.type
            case 'ratio'
               i = subs{1};
               [num,den,xpo] = peek(o);
               if (i == 1)
                  oo = num;
               elseif (i == 2)
                  oo = den;
               else
                  error('index 1 or 2 expected for rational functions');
               end
                  
            case 'matrix'
               if (length(subs) == 1)
                  i = subs{1};
                  oo = o.data.matrix{i};
              elseif (length(subs)==2)
                  i = subs{1};  j = subs{2};
                  oo = o.data.matrix{i,j};
               else
                  error('bad calling sytax');
               end
            otherwise
               error('bad indexing operation');
         end

      otherwise
         error('bad indexing syntax!');
   end
end