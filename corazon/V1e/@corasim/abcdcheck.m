function err = abcdcheck(o,A,B,C,D)
%
% ABCDCHECK Check that dimensions of A,B,C,D are consistent.
%           Give error message if not and return 1. Otherwise return 0.
%
%              err = abcdcheck(o,A,B,C,D)
%
%           See also: SIMU
%
   err = 0;
   [ma,na] = size(A);
   if (ma ~= na)
      errmsg('The A matrix must be square')
      err = 1;
   end
   if (nargin > 2)
      [mb,nb] = size(B);
      if (ma ~= mb)
         errmsg('The A and B matrices must have the same number of rows')
         err = 1;
      end
      if (nargin > 3)
         [mc,nc] = size(C);
         if (nc ~= ma)
            errmsg('The A and C matrices must have the same number of columns')
            err = 1;
         end
         if (nargin > 4)
            [md,nd] = size(D);
            if (md ~= mc)
               errmsg('The C and D matrices must have the same number of rows')
               err = 1;
            end
            if (nd ~= nb)
               errmsg('The B and D matrices must have the same number of columns')
               err = 1;
            end
         end
      end
   end
end