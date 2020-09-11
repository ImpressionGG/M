function o = subsasgn(o,oper,oo)
%
% SUBSASGN Subscripted assign: assign an element of Corinthian matrix
%
%             M = matrix(o,magic(3));
%             M(2,3) = ratio(o,[1 2],[3 4 5])
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORINTH, MATRIX, SIZE, SUBSREF
%
   if ~type(o,{'matrix'})
      error('cannot index non-matrix');
   end

   switch oper.type
      case '()'
         subs = oper.subs;
         i = subs{1};  j = subs{2};

         if isa(oo,'double')
            oo = poly(o,oo);
         end

         oo = ratio(oo);               % cast to a matrix
         o.data.matrix{i,j} = oo;

      otherwise
         error('bad indexing syntax!');
   end
end