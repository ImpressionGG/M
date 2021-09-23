function display(o)
%
% DISPLAY  Display an IMAT object
%   
   M = icast(o);

   if isempty(o.name)
      fprintf('\n   <imat[%g,%g] @ 2^%g: [',o.m,o.n,o.expo);
   else
      fprintf('\n   <imat %s: [%g,%g] @ 2^%g: [',o.name,o.m,o.n,o.expo);
   end
   
   sep = '';
   format longg
   for (i = 1:o.len)
      fprintf('%s%ld',sep,o.mant(i));  sep = ' ';
   end
   format short
   margin = 2^31/max(abs(double(o.mant)));
   fprintf('] @ margin: %g\n',margin);
   
   disp(M);
end