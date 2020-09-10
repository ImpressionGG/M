function var = delta(o,tag)
%
% DELTA   Get data deviations
%
%            var = delta(o,'n')
%
   var = data(o,tag);
   var = var - var(1);
   
   for (i=2:length(var))
      if (abs(var(i)-var(i-1)) > 100)
         var(i) = var(i-1);
      end
   end
   

end