function cpoly = chr(o)
%
% CHR   Calculate characteristic polynomial of a quadratic matrix.
%
%          A = matrix(o,magic(2))
%          cpoly = chr(A)
%
%       Example: characteristic polynomial
%
%          o = base(corinth,100)
%
%          A = matrix(o,diag([-1 -2]))
%          s = ratio(o,[1 0],1);        % s/1
%          sI = mul(s,matrix(o,eye(size(A))))
%          cpoly = det(sub(Si-A))
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORINTH, MATRIX, DET
%
   A = o;                              % nice name of arg1
   [m,n] = size(A);

   if (~type(o,{'matrix'}) || (m ~= n))
      error('quadratic matrix expected');
   end

   s = ratio(o,[1 0],1);
   I = matrix(o,eye(n));
   sI = s*I;
   sIminusA = sI - A;

      % characteristic polynomial

   cpoly = det(sIminusA);
end

