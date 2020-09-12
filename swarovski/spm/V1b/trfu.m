function oo = trfu(o,i,j)
%
% TRFU    Calculate i-j-th corinthian transfer function of a MIMO system
%
%            Gij = trfu(oo,i,j)             % calc i-j-th transfer function
%
%         Example
%            oo = system(spm,A,B,C,D)
%            Gij = trfct(oo,i,j)            % calc i-j-th transfer function
%
%         Note: Gij is a corinthian rational function object
%
%         Options:
%
%            double:         create a double arithmetic base transfer
%                            function
%
%         Copyright(c): Bluenetics 2020
%
%         See also: SPM
%
   oo = Partial(o);   
   oo = TrFu(oo,i,j);
end

%==========================================================================
% helpers
%==========================================================================

function oo = Partial(o)               % Partial Matrices of Modal Form
   [A,B,C,D] = get(o,'system','A,B,C,D');
   
   n = floor(length(A)/2);
   i1 = 1:n;  i2 = n+1:2*n;
      
      % get partial matrices of modal form
      
   A11 = A(i1,i1);  A12 = A(i1,i2);  B1 = B(i1,:);  C1 = C(:,i1);
   A21 = A(i2,i1);  A22 = A(i2,i2);  B2 = B(i2,:);  C2 = C(:,i2);
      
      % time transformation tau := t/T° => A° = A*T°, B° = B*T°
      
   T0 = 1e-3;                          % ms time
   A21 = T0*T0*A21;  A22 = T0*A22;
   B2 = T0*T0*B2;

      % check consistency

   err = 0;  I = eye(size(A11));
   err = err || any(any(A11~=0*I));
   err = err || any(any(A12~=I));
   err = err || any(any(B1~=0));
   err = err || any(any(C2~=0));

   if (err)
      error('Error: modal form matrix invariants violated!');
   end
   
   oo = var(o,'T0',T0);
   oo = var(oo,'A11,A12,A21,A22',A11,A12,A21,A22);
   oo = var(oo,'B1,B2,C1,C2',B1,B2,C1,C2);
end
function oo = TrFu(o,i,j)              % Transfer Function             
%
% TRFFCT   Calculate transfer function Gij(s) according to
%
%             Yi(s) = Gij(s) * Uj(s)
%
%          Calculation:
%
%             Gij(s) = C(i,:) * [(s*E-A) \ B(:,j)]
%
%          Or with partitioning system matrizes in a modal form:
%
%             A = [0 I; A21 A22]
%             B = [0; B2]        => B2 = [b1,b2,...,bl]     (l inputs)
%             C = [C1 0]         => C1 = [c1';c2';...;cm']  (m outputs)
%
   [A21,A22,B2,C1] = var(o,'A21,A22,B2,C1');
   n = length(A21);                    % n states
   [m,l] = size(C1*B2);                % m outputs, l inputs
   
   if (i < 0 || i > m)
      error('bad row index!');
   end
   if (j < 0 || j > l)
      error('bad column index!');
   end
   
      % pick i-th output matrix row and j-th input matrix column
      
   O = corinth;                        % corinthian 1e6 basis object
   Ci = matrix(O,C1(i,:));  
   Bj = matrix(O,B2(:,j));
   
      % pick A21 and A22 diagonals
      % remember that psi_i(s) := s^2 + a1(i)*s + a0(i)
      
   a1 = -diag(A21);   a0 = -diag(A22);
   
      % represent eta(s) = s^2 + k1*s + k0
      
   k1 = 0;  k0 = 0;
   eta = [1 k1 k0];                    % coeffs of eta(s) polynomial

      % represent psi_i(s) = s^2 + a1(i)*s + a0(i)
      % i.e.:     psi_i(s) = Psi(i,1)*s^2 + Psi(i,2)*s + Psi(i,3)
      
   Psi = [ones(size(a1)), a1, a0];
 
      % Now calculate transfer function Gij(s)
      % start with denominator: den(s) = prod(psi_i(s))
      
   den = poly(O,1);
   for (k=1:n)
      psi = poly(O,Psi(k,:));
      den = den*psi;
   end
   
      % numerator is the sum of Ci(k)*Bj(k) * den(s)/psi_k(s)
      
   num = 0;
   for (k=1:n)
      term = Ci(k)*Bj(k);
      term = peek(term,1,1);
      
      for (p=1:n)
         if (p == k)
            continue;                  % don't multiply with psi_k(s)
         end
         psi = poly(O,Psi(p,:));
         term = term * psi;
      end

      gap = zeros(1,length(term)-length(num));
      num = [gap, num];
      num = num + term;
   end
end
