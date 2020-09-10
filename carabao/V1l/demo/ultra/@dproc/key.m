function [out1,out2] = key(prc,arg2,arg3)
% 
% KEY    Get key of a named process element
%      
%             k = key(prc,name)    % get key of a process
%             k = key(prc,i,j)     % create key from i and j
%             [i,j] = key(prc,k)   % decompose key
%             base = key           % get base for calculating key
%
%          See also   DISCO, DPROC

   if (nargin <= 1)
      out1 = 100000;
      return
   end
   
   if ( isstr(arg2) )
      name = arg2;
      [i,j,k] = index(prc,name);
      out1 = k;
   else
      base = 100000;
      if (nargin >= 3)
         i = arg2;  j = arg3;
         k = base*i + j;
         out1 = k;
      else
         i = floor(arg2/base);
         j = rem(arg2,base);
         if ( nargout <= 1)
            out1 = [i j];
         else
            out1 = i;  out2 = j;
         end
      end
   end


% eof

