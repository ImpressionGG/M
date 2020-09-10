function oo = real(o)
%
% REAL   Convert CORINTH object to a real object
%
%           r = real(o)
%
%        See also: CORINTH, NEW, TRIM, FORM, ADD, SUB, MUL, DIV, COMP
%
   switch o.type
      case 'number'
         oo = Number(o);
      case 'poly'
         oo = Poly(o);
      otherwise
         error('implementation')
   end
end

%==========================================================================
% Convert Number to Real
%==========================================================================

function z = Number(o)                 % Convert Rational Numb. to Real
   o = form(o);
   
   base = o.data.base;
   expo = o.data.expo;
   x = o.data.num;  nx = length(x);
   y = o.data.den;  ny = length(y);
    
   if (all(y==0))
      z = inf;
      return
   end
   
   nz = ceil(16/log10(base)) + 1;      % number of zero digits

   [q,r] = div(o,[x,zeros(1,nz)],y);
   nq = length(q);
      
   fac1 = base .^ (nq-1:-1:0);
   fac2 = base^(expo-nz);
   z = q * fac1(:) * fac2;
end

%==========================================================================
% Convert Polynomial to Real
%==========================================================================

function poly = Poly(o)                % Convert Poly to Real Vector   
   m = order(o);
   for (k=0:m)
      oo = peek(o,k);
      poly(m-k+1) = Number(oo);
   end
end


