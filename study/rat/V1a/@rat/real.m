function z = real(o,x,y)
%
% REAL   Convert to a real number
%
%           r = real(o)
%
%        See also: RAT
%
   base = o.base;
   x = o.num;  nx = length(x);
   y = o.den;  ny = length(y);
   
   expo = length(y);
   
   [q,r] = div(o,[x,0*y],y);
   nq = length(q);
   
   fac = base .^ (-(0:nq-1));
   z = q * fac(:);
end

