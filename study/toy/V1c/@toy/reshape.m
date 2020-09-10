function M = reshape(obj,M)
%
% RESHAPE   Reshape a matrix relative to a given space structure. The
%           kind of reshaping is influenced by the sizes of the space
%           and the index property.
%
%              H = space(toy,'spin').*space(toy,'spin')'
%              M = reshape(H,[1 0 1 0]);
%
%           See also: TOY, SPACE, VECTOR, KET
%
   sizes = property(obj,'size');
   n = prod(size(M));
   
   if (prod(sizes) ~= n)
      error('incompatible matrix dimensions for reshaping!');
   end
   
   index = property(obj,'index');
   
% calculate inverse index

   n = length(index(:));
   E = eye(n);
   T = E(:,index(:));
   
   if (n>4)
      'breakpoint';
   end
   invidx = T*(1:n)';

   assert(prod(size(index))==n);
   assert(prod(size(invidx))==n);
   
% assert proper inverse functionality

   range = index(invidx);
   assert(all(range(:)==(1:n)'));

   range = invidx(index);
   assert(all(range(:)==(1:n)'));
   
   %M = reshape(M(index),sizes);
   M = reshape(M(invidx),sizes);
   return
end