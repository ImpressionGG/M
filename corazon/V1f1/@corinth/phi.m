function [Phi,H] = phi(A,B)
%
% PHI    transition matrix according to given dynamic matrix
%
%           Phi = phi(A)
%           [Phi,H] = phi(A,B)
%
%        Example:
%
%           A = matrix(o,magic(3));    % dynamic matrix
%           Phi = phi(A);              % calculate transition matrix
%
%           B = [1 1; 0 1; 1 0];
%           [Phi,H] = phi(A,B);
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, DET, INV
%
   o = A;                              % some lines are better readable
   [m,n] = size(A);
   if (m ~= n)
      error('quadratic matrix expected');
   end

      % auxillary stuff

   s = ratio(o,[1 0]);
   I = matrix(o,eye(n));
 
      % calc inv(s*I-A)

   sI = s*I;
   sIminusA = sI - A;
   Phi = inv(sIminusA);

      % check if also H matrix to be calculated

   if (nargout >= 2)
      if (nargin < 2)
         error('arg2 missing');
      end

      [mB,nB] = size(B);
      if (mb ~= m)
         error('row numbers of A (arg1) and B (arg2) must match');
      end

      H = Phi*B;
   end
end