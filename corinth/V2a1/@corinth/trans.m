function oo = trans(A,B,C,D)
%
% PHI    calculate transition matrix or transfer matrix according to given
%        dynamic matrix or system matrices
%
%           Phi = trans(A)             % calculate transition matrix
%
%           G = trans(A,B,C,D);        % calculate transfer matrix
%           G = trans(A,B,C);          % calculate transfer matrix @ D=0
%
%        There is an efficient form to calculate the transition matrix or 
%        transfer matrix of a modal form
%        a system in modal form
%
%           Phi = trans(a0,a1)
%
%           a = matrix(o,[a1;a0])      % 
%           G = trans(a,B2,C1,D)       % transfer matrix for modal form
%           G = trans(a,B2,C1)         % transfer matrix for modal form,D=0
%
%        where the modal form is a set of system matrices A,B,C,D of an
%        order N multivariable system with m inputs and l outputs (A: NxN,
%        B: Nxm, C: lxN, D: lxm) having the following structure:
%
%           A = [0*I,I;-dg(a1),-dg(a0)]% a1,a0: n x 1, I = eye(n), n := N/2
%           B = [0*B2; B2]             % B2: n x m             (dg = @diag)
%           C = [C1, 0*C1]             % C1: l x n
%           D                          % D:  l x m
%
%        The complex eigenfrequencies of a modal form satisfy the charac-
%        teristic equation
%
%           psi(s) = psi_1(s) * psi_2(s) * ... * psi_n(s)     (n = N/2)
%
%        where
%
%                    psi_i(s) := s^2 + a1(i)*s + a0(i)
%
%        Comparing to a standard quadratic factor
%
%                    1 + 2*zeta * (s/omega) + (s/omega)^2
%
%        which relates to 
%
%                    s^2 + 2*zeta(i)*omega(i) * s + omega(i)^2 = 0
%
%        from which we read out:
%
%           a0(i) = omega(i)^2               =>  a0 = omega .* omega
%           a1(i) = 2*zeta(i)*omega(i)       =>  a1 = 2*zeta .* omega
%
%        Example 1:
%
%           A = matrix(o,magic(3));    % dynamic matrix
%           Phi = trans(A);            % calculate transition matrix
%
%           B = [1 1; 0 1; 1 0];
%           C = [1 1 0];
%           D = [1 0];
%
%           G = trans(A,B,C,D);        % calculate transfer matrix
%           G = trans(A,B,C);          % calculate transfer matrix @ D=0
%
%        Example 2:
%
%           omega = [1 2 3]';          % eigen (circular) frequencies
%           zeta = [0.1 0.15 0.12]';   % dampings
%
%           a0 = omega.*omega;         % a0 = [1 4 9]'
%           a1 = 2*zeta.*omega;        % a1 = [0.2 0.6 0.72 ]
%
%           a = matrix(o,[a1;a0]);
%           Phi = trans(a);            % calculate transition matrix
%
%           B2 = matrix(o,[1; -0.5; 0.5];
%           C1 = matrix(o,[1  2 -1]);
%           D = 0;
%
%           G = trans(a,B2,C1,D);      % calculate transfer matrix
%           G = trans(a,B2,C1);        % calculate transfer matrix @ D=0
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, DET, INV
%
   o = A;                              % some lines are better readable
   [m,n] = size(A);
   if (m > 0 && n == 1)
      if (rem(m,2) > 0)
         error('length of [a1;a0] (arg1) must be an even number');
      end
      N = m;  n = N/2;  m = n;
   elseif (m ~= n)
      error('1-column or quadratic matrix expected for arg1');
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
   
   if (m == n)
      Phi = Regular(A);
   else
      Phi = Modal(A);
   end
   
   function Phi = Regular(A)           % Regular Transition Matrix Calc
      s = ratio(o,[1 0]);              % variable s
      I = matrix(o,eye(n));            % identity matrix

         % calc inv(s*I-A)

      sI = s*I;
      sIminusA = sI - A;
      Phi = inv(sIminusA);
   end
   function Phi = Modal(a)             % Modal Transition Matrix Calc
      N = prod(size(a));
      assert(rem(N,2)==0);             % n must be even
      n = N/2;
            
         % calculate psi{i} = s^2 + a1*s + a0
         
      Psi = matrix(o,zeros(n,1));      % init matrix dimensions
      psi = poly(o,[1 1 1]);           % init poly dimensions
      
      for (i=1:n)
         a1 = peek(a,i);               % a1{i} = 2*zeta(i)*omega(i)
         a0 = peek(a,i+n);             % a0{i} = omega(i)^2
         
         psi = poke(psi,a0,0);
         psi = poke(psi,a1,1);
         
            % now: psi(s) = s^2 + a1{i}*s + a0{i}
            
         Psi = poke(Psi,psi,i,1);
      end
      
         % now we have Psi matrix with characteristic partial polynomials
         
      Phi = Psi;       % preliminary ############
   end
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
