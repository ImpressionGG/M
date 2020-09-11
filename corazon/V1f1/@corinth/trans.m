function oo = trans(A,B,C,D)
%
% PHI    calculate transition matrix or transfer matrix according to given
%        dynamic matrix or system matrices
%
%           Phi = trans(A)             % calculate transition matrix
%           [Phi,H] = trans(A,B)       % calculate transfer matrix
%
%        Example:
%
%           A = matrix(o,magic(3));    % dynamic matrix
%           Phi = trans(A);            % calculate transition matrix
%
%           B = [1 1; 0 1; 1 0];
%           C = [1 1 0];
%           D = [1 0];
%
%           G = phi(A,B,C,D);          % calculate transfer matrix
%           G = phi(A,B,C);            % calculate transfer matrix @ D=0
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

   if (nargin == 1)
      oo = TransitionMatrix(A);
   elseif (nargin >= 3)
      [mi,ni] = size(B);               % input matrix sizes
      [mo,no] = size(C);               % output matrix sizes

      if (nargin < 4)
         D = zeros(mo,ni);
      end
      
      if (mi ~= m)
         error('output matrix (arg2) size mismatch');
      end
      if (no ~= n)
         error('input matrix (arg3) size mismatch');
      end
      if (mi ~= size(D,1) || no ~= size(D,2))
         error('direct matrix (arg4) size mismatch');
      end
      
      oo = TransferMatrix(A,B,C,D)
   end
end

%==========================================================================
% Transition Matrix
%==========================================================================

function Phi = TransitionMatrix(A)
   o = A;                              % for better readability
   [m,n] = size(A);
   
      % auxillary stuff

   s = ratio(o,[1 0]);                 % variable s
   I = matrix(o,eye(n));               % identity matrix
 
      % calc inv(s*I-A)

   sI = s*I;
   sIminusA = sI - A;
   Phi = inv(sIminusA);
end

%==========================================================================
% Transfer Matrix
%==========================================================================

function G = TransferMatrix(A,B,C,D)
   PHI = TransitionMatrix(A);

   PHIxB = PHI*B;
   G = C*PHIxB;
   
   if isa(D,'double')
      zero = all(F(:)== 0);
   else
      zero = iszero(D);
   end
   
   if (~zero)
      G = G + D;
   end
end
