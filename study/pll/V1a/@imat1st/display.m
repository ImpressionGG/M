function display(o)
%
% DISPLAY  Display an IMAT object
%
   d = reshape(o.data/2^o.expo,o.m,o.n);
   
   if isempty(o.name)
      fprintf('\n   <imat[%g,%g] @ 2^%g: [',o.m,o.n,o.expo);
   else
      fprintf('\n   <imat %s: [%g,%g] @ 2^%g: [',o.name,o.m,o.n,o.expo);
   end
   
   sep = '';
   format longg
   for (i = 1:o.len)
      fprintf('%s%g',sep,o.data(i));  sep = ' ';
   end
   format short
   fprintf('] @ margin %g>\n',o.margin);
   
   disp(d);
end