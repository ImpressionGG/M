function c = polynom(o,x)
%
% POLYNOM  Convert roots to polynomial. Calculate characteristic polynomial
%          of an nxn square matrix A by returning a row vector with n+1
%          elements which are the coefficients  of the characteristic 
%          polynomial, det(lambda*eye(size(A))-A).
%
%             c = polynom(o,A)         % characteristic polynomial of A
%
%          Given a vector v whose elements are the coefficients of the 
%          polynomial whose roots are the elements of v.
%
%             c = polynom(o,v)         % polynomial according to roots v
%
%          For vectors, roots and polynom are inverse functions of each
%          other, up to ordering, scaling, and roundoff error.
%
%          Examples:
%
%             roots(polynom(o,1:20)) generates Wilkinson's famous example.
%
%          Class support for inputs A,V: double, single, sym
%
%          Copyright(c): Bluenetics 2020
%
%          See also CORASIM, PLUS
%
   [m,n] = size(x);
   if m == n                           % square matrix?
      e = eig(x);                      % Characteristic polynomial
   elseif (m==1) || (n==1)
      e = x;
   else
      error('input size');
   end

      % Strip out infinities
      
   e = e(isfinite(e));

      % Expand recursion formula
      
   n = length(e);
   c = [1 zeros(1,n,class(x))];
   for j=1:n
       c(2:(j+1)) = c(2:(j+1)) - e(j).*c(1:j);
   end

      % The result should be real if the roots are complex conjugates.
      
   if isequal(sort(e(imag(e)>0)),sort(conj(e(imag(e)<0))))
       c = real(c);
   end
end
