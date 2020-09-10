function oo = inv(o,M)
%
% INV    invert a matrix (or corinthian object)
%
%           M = matrix(o,magic(3))
%           InvM = inv(M)
%
%        Example:
%
%           o = base(corinth,100);
%           A = matrix(o,[1 3; 4 2]);
%           B = inv(A)                 % => [-1/5 3/10; 2/5 -1/10]
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH,POLY, MATRIX, DET
%
   switch o.type
      case 'number'
         [num,den,xpo] = peek(o);
         oo = poke(o,-xpo,den,num);
      case 'poly'
         o = ratio(o);
         [num,den,xpo] = peek(o);
         oo = poke(o,-xpo,den,num);
      case 'ratio'
         [num,den,xpo] = peek(o);
         oo = poke(o,-xpo,den,num);
      case 'matrix'
         oo = InvMatrix(o);                       
      otherwise
         error('internal')
   end
end

%==========================================================================
% Rational Matrix Inversion
%==========================================================================

function o = InvMatrix(o)              % Invert Rational Matrix        
   assert(type(o,{'matrix'}));
   M = o.data.matrix;

   [m,n] = size(M);
   if ( m~= n)
      error('quadratic matrix expected');
   end

   D = det(o,M);

   sgni = +1;
   for (i=1:m)
      sgn = sgni;
      for (j=1:n)
         Mij = M;                      % init: copy M
         Mij(i,:) = [];                % remove i-th row
         Mij(:,j) = [];                % remove j-th column

         Di = det(o,Mij);              % calculate i/j-th sub-determinant
         mji = sgn * Di;               % start calculating adjoint element
         mji = div(mji,D);             % divide by determinant

         MT{j,i} = mji;                % mind: transposed matrix
         sgn = -sgn;                   % alternating signs
      end
      sgni = -sgni;                    % alternating signs
   end

   o.data.matrix = MT;                 % inverted matrix

      % cancel and trim

   o.work.can = true;                  % all canceling already done!
   o.work.trim = true;                 % all trimming already done!
end

%==========================================================================
% Cast Corinthian Object To a Matrix of Rational Functions
%==========================================================================

function oo = Cast(o)                  % Cast to Rational Funct. Matrix
   switch o.type
      case 'number'
         num = poly(o);  den = poly(o,1);
         oo = ratio(o,num,den);        % ratio of two polynomials
         oo = Cast(oo);                % cast ratio to matrix
      case 'poly'
         num = o;  den = poly(o,1);
         oo = ratio(o,num,den);        % ratio of two polynomials
         oo = Cast(oo);                % cast ratio to matrix
      case 'ratio'
         oo = matrix(o,{o});           % cast ratio to matrix
      case 'matrix'
         oo = o;                       % easy :-)
      otherwise
         error('internal')
   end
end
