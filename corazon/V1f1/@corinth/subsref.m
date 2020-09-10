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
   if ~type(o,{'matrix'})
      error('cannot index non-matrix');
   end

   switch oper.type
      case '()'
         subs = oper.subs;
         i = subs{1};  j = subs{2};
         oo = o.data.matrix{i,j};

      otherwise
         error('bad indexing syntax!');
   end
end