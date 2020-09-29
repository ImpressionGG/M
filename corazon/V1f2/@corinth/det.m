function D = det(o,M)
%
% DET   Calculate determinant of a corinthian matrix
%
%          D = det(o)
%          D = det(o,o.data.matrix)
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
%       See also: CORINTH, MATRIX
%
   if (nargin <= 1)
      [m,n] = size(o);

      if (~type(o,{'matrix'}) || (m ~= n))
         error('quadratic matrix expected');
      end

      M = o.data.matrix;
   end

      % calculate determinant from matrix of rational functions

   D = Determinant(o,M);
end

%==========================================================================
% Actual Calculation of Determinant
%==========================================================================

function D = Determinant(o,M)
   n = length(M);
   if (n == 1)
      D = M{1,1};
      return
   end

   D = ratio(o,0);
   sgn = +1;
   for (i=1:n)                         % develop after first column
      Mi = M;                          % init: copy M
      Mi(:,1) = [];                    % remove first column
      Mi(i,:) = [];                    % remove i-th row

      Di = Determinant(o,Mi);          % calculate i-th sub-determinant
      mi1 = sgn * M{i,1};
      term = mul(mi1,Di);
      D = add(D,term);

      sgn = -sgn;                      % alternating signs
   end
end
