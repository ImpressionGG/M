function mdisp(M,fmt)
%
% MDISP  Display matrix data in pure matrix format
%
%           mdisp(magic(3));
%           mdisp({magic(3),hilb(5)});
%           mdisp(magic(3),'\t%0.7g');

   if ( nargin < 2)
      fmt = '\t%0.4g';
   end

   if ~iscell(M)
      M = {M};
   end
   
   for (k=1:length(M))
      Mk = M{k};
      [m,n] = size(Mk);
      for (i=1:m)
         for (j=1:n)
            fprintf(fmt,Mk(i,j));
         end
         fprintf('\n');
      end
      fprintf('\n');
   end
      
% eof
