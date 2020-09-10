function V = gain(obj)
%
% GAIN    Gain factor of a transfer function
%
%            V = gain(Ps)
%
%         See also: TFF, LF, QF
%
   Num = num(obj);  deg_num = length(Num)-1;
   Den = den(obj);  deg_den = length(Den)-1;
   
   if ( all(Num == 0)  &  all( Den == 0 ) )
      V = NaN;
   elseif ( all(Num == 0) )
      V = 0;
   elseif ( all(Den == 0) )
      V = inf;
   else
      V = 0;
      for (i=deg_num+1:-1:1)
	      if ( abs(Num(i)) > 1e8*eps )
            V = Num(i); break;
         end
      end
      for (i=deg_den+1:-1:1)
	      if ( abs(Den(i)) > 1e8*eps )
            V = V/Den(i); break;
         end
      end
   end
   return
   
%eof   