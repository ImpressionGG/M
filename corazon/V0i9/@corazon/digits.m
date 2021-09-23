function dig = digits(o)
%
% DIGITS   Return maximum digit number of a corinthian object
%
%             n = digits(o)
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORINTH, ORDER, SIZE
%
   switch o.type
      case 'number'
         [num,den,~] = peek(o);
         dig = max(length(num),length(den));

      case 'poly'
         [num,den,~] = peek(o);
         dig = max(size(num,2),size(den,2));

      case 'ratio'
         [num,den,~] = peek(o);
         n1 = digits(num);
         n2 = digits(den);
         dig = max(n1,n2);

      case 'matrix'
         dig = 0;
         [m,n] = size(o);
         for (i=1:m)
            for (j=1:n)
               oo = o.data.matrix{i,j};
               dig = max(dig,digits(oo));
            end
         end

      otherwise
         error('internal');
   end
end