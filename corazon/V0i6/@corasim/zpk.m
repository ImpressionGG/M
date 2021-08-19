function [z,p,k,T] = zpk(o,num,den,k,T)
%
% ZPK   Find zeros, poles and K-factor of a rational function
%
%          o = trf(corasim,[5 6],[1 2 3]);
%
%          [z,p,k] = zpk(o)
%          [z,p,k] = zpk(o,num,den)
%          [z,p,k] = zpk(o,poly)
%
%       From a rational transfer function in polynomial form
%
%                    (s-z1)(s-z2)...(s-zn)       num(s)
%          G(s) =  K ---------------------  =  ----------
%                    (s-p1)(s-p2)...(s-pn)       den(s)
%
%       Find zeros, poles and K-factor. Vector den specifies the coeffi-
%       cients of the denominator in descending powers of s.  Matrix num 
%       indicates the numerator coefficients with as many rows as there 
%       are outputs.  
%
%       The zero locations are returned in the columns of matrix Z, with 
%       as many columns as there are rows in NUM.  The pole locations are
%       returned in column vector P, and the gains for each numerator 
%       transfer function in vector K.
%
%       If o is a state space representation [A,B,C,D] of a MIMO system
%       with nu inputs and ny outputs then
%
%          [Z,p,K] = zpk(system(corasim,A,B,C,D))
%
%       returns Z as a ny x nu cell array with z{i,j} containing the zeros
%       of the i/j-th transfer function, p the (common) poles and K a
%       matrix of the K(i,j) factors.
%
%       Create ZPK objects
%
%          oo = zpk(o,num,den)
%          oo = zpk(o,poly)
%
%          oo = zpk(o,{i,j})           % i/j-th element of transfer matrix
%
%          oo = zpk(o,z,p,K)           % s-type ZPK (continuous)
%          oo = zpk(o,z,p,K,0)         % sameas above
%
%          oo = zpk(o,z,p,K,0)         % s-type ZPK (continuous)
%          oo = zpk(o,z,p,K,T)         % z-type ZPK (discrete)
%          oo = zpk(o,z,p,K,-T)        % q-type ZPK (discrete)
%
%          [z,p,K,T] = zpk(o)          % retriev poles/zeros, K and T
%
%          oo = zpk(o)                 % cast to ZPK type
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORASIM
%
   if (nargin == 2 && type(o,{'css','dss'}) && iscell(num))
      [A,B,C,D] = system(o);
      i = num{1};  j = num{2};
      o = system(o,A,B(:,j),C(i,:),D(i,j));
      z = zpk(o);   % i/j-th transfer function of a ss
      return
   end
   
   switch nargin
      case {0,1}
         if (nargout <= 1)             % cast to ZPK object
            if type(o,{'szpk','zzpk','qzpk'})
               oo = o;                 % nothing left to do
            elseif type(o,{'css','dss'})
               [A,B,C,D] = system(o);
               
               nu = size(B,2);  ny = size(C,1);
               if (ny ~= 1 || nu ~= 1) % MIMO system
                  z = {}; k = [];  
                  p = eig(A);          % heads-up calculation of poles
                  for (j = 1:nu)
                     [zj,p,kj] = Ss2zp(o,A,B,C,D,j,p);
                     k(1:ny,j) = kj;
                     
                     for(i=1:ny)
                        zij = zj(:,i);
                        idx = find(isinf(zij));

                            % remove infinite zeros

                        if ~isempty(idx)
                           zij(idx) = [];
                        end
                        
                        z{i,j} = zij;
                     end
                  end
               else % SISO system
                  [z,p,k] = Ss2zp(o,A,B,C,D,1);
                  idx = find(isinf(z));

                      % remove infinite zeros

                  if ~isempty(idx)
                     z(idx) = [];
                  end
               end
               
                   % compose new zpk object
                   
               oo = type(o,'szpk');
               oo.data.zeros = z;
               oo.data.poles = p;
               oo.data.K = k;
               oo.data.T = 0;
            else
               [num,den] = peek(o);    % first cast to ZPK object
               oo = zpk(o,num,den);
               oo.data.T = o.data.T;
            end
         else                          % nargout >= 2
            if type(o,{'szpk','zzpk','qzpk'})
               z = o.data.zeros;
               p = o.data.poles;
               k = o.data.K;
               T = o.data.T;
            elseif type(o,{'css','dss'})
               o = zpk(o);             % convert to zpk representation
               z = o.data.zeros;
               p = o.data.poles;
               k = o.data.K;
               T = o.data.T;
            else
               [num,den] = peek(o);
               [z,p,k] = Zpk(o,num,den);
               T = o.data.T;
            end
            return
         end
         
      case 2
         den = 1;
         [z,p,k] = Zpk(o,num,den);
         T = 0;
         
         if (nargout > 1)
            return
         end
         
         oo = Create(o,z,p,k,T);
      case 3
         [z,p,k] = Zpk(o,num,den);
         T = 0;

         if (nargout > 1)
            return
         end

         oo = Create(o,z,p,k,T);
         
      case 4
         z = num;  p = den;
         oo = Create(o,z,p,k,0);
         
      case 5
         z = num;  p = den;
         oo = Create(o,z,p,k,T);
         
      otherwise
         error('up to 5 input args expected');
   end
   
      % copy digits option to outarg

   z = opt(oo,'digits',opt(o,'digits'));
end

%==========================================================================
% Find Zeros, Poles and K-factor from num/den
%==========================================================================

function [z,p,k] = Zpk(o,num,den)      % Convert Num/Den to Zero/Pole/K            
   [num,den] = Trim(o,num,den);

   if ~isempty(den)
       coef = den(1);
   else
       coef = 1;
   end
   if coef == 0
      error('denominator has zero leading coefficients');
   end

      % remove leading columns of zeros from numerator
   
   if ~isempty(num)
       while(all(num(:,1)==0) && length(num) > 1)
           num(:,1) = [];
       end
   end
   [ny,np] = size(num);

      % poles
      
   p  = roots(den);

      % zeros and gain
      
   if any(any(isnan(num))) || any(any(isinf(num)))
      error('cannot handle NaNs or INFs');
   end
      
   k = zeros(ny,1);
   linf = inf;
   z = linf(ones(np-1,1),ones(ny,1));
   for i=1:ny
     zz = roots(num(i,:));
     if ~isempty(zz)
        z(1:length(zz),i) = zz;
     end
     ndx = find(num(i,:)~=0);
     if ~isempty(ndx)
        k(i,1) = num(i,ndx(1))./coef; 
     end
   end
end

%==========================================================================
% Find Zeros, Poles and K-factor from State Space Representation
%==========================================================================

function [z,p,k] = Ss2zp(o,a,b,c,d,iu,p)
%
%  SS2ZP	State-space to zero-pole conversion.
%	[Z,P,K] = SS2ZP(A,B,C,D,iu)  calculates the transfer function in
%	factored form:
%
%			     -1                (s-z1)(s-z2)...(s-zn)
%		H(s) = C(sI-A) B + D =  k ---------------------
%			                       (s-p1)(s-p2)...(s-pn)
%	of the system:
%		.
%		x = Ax + Bu
%		y = Cx + Du
%
%	from the iu'th input.  Vector P contains the pole locations of the
%	denominator of the transfer function.  The numerator zeros are
%	returned in the columns of matrix Z with as many columns as there are
%	outputs y.  The gains for each numerator transfer function are 
%	returned in column vector K.
%
%  Optionally poles can be provided as an additional argument to avoid
%  multiple eigenvalue calculation for MIMO systems
%
%     [z,p,k] = Ss2zp(o,A,B,C,D,iu,p)
%
      % pick relevant input
      
   b = b(:,iu);   % + 0*a(1,1);
   c = c + 0*a(1,1);
     
   if (all(b==0) && all(c==0))
      z = [];  p = [];  k = 0;
      return
   end
   
      % if we calculate with VPA arithmetics we have to make sure
      % that d is also of type VPA, otherwise k would result in a double

   d = d(:,iu) + 0*a(1,1);      % inherit VPA digits from a
      
      % Do poles first, they're easy
      
   if (nargin < 7)
      p = eig(a);
   end

      % now try zeros, they're harder
   
   [no,ns] = size(c);
   z = zeros(ns,no) + inf + 0*a(1,1);    % Set whole Z matrix to infinities
   
      % loop through outputs, finding zeros
      
   for i=1:no
      s1 = [a b;c(i,:) d(i)];
      s2 = diag([ones(1,ns) 0]);
      zv = Eig(s1,s2);
      
         % now put NS valid zeros into Z. There will always be at least one
         % NaN or infinity
         
      zv = zv((zv ~= nan)&(zv ~= inf));
      if length(zv) ~= 0
         z(1:length(zv),i) = zv;
      end
   end

      % finish up by finding gains using Markov parameters
      
   k = d;  CAn = c;
   while any(k==0)	% do until all k's are finished
      markov = CAn*b;
      i = find(k==0);
      k(i) = markov(i);
      CAn = CAn*a;
   end
end
%==========================================================================
% Helper
%==========================================================================

function s  = Eig(A,B)                 % Solve General Eigenvalue Problem
%
% EIG   Solve general eigenvalue problem
%
%       see: http://fourier.eng.hmc.edu/e161/lectures/algebra/node7.html
%
   if isa(A,'double') && isa(B,'double')
      s = eig(A,B);                   % use MATLAB builtin method
      return
   end
   
      % general eigenvalue problem: A*v = s*B*v
      % set: mu = 1/s => A*v = 1/mu*B*v => A*mu*v = B*v 
      % in case of det(A) ~= 0: A\B*v = mu*v, 
      % means mu=1/s are the eigenvalues of A\B
   
fprintf('zpk/Eig(): 1) calc det(A) ...\n');      
   if (det(A) == 0)
      error('cannot calculate generalized eigenvalues for singular A-matrix');
   end
   
fprintf('zpk/Eig(): 2) calc M = A\\B ...\n');      
   M = A\B;
fprintf('zpk/Eig(): 3) calc mu = eig(M) ...\n');      
   mu = eig(M);
   s = 1./mu;
end
function oo = Create(o,z,p,K,T)        % Create ZPK Object             
   if (T > 0)
      oo = corasim('zzpk');
   elseif (T < 0)
      oo = corasim('qzpk');
   else
      oo = corasim('szpk');
   end
   
   oo.data.zeros = z;
   oo.data.poles = p;
   oo.data.K = K;
   oo.data.T = T;
   
      % copy verbose option
      
   oo = control(oo,'verbose',control(o,'verbose'));
end
function [num,den] = Trim(o,num,den)
%
% TRIM Trim numerator and denominator to get equal length and perform 
%      consistency checks for proper transfer function.
%
%         [num,den] = Trim(o,num,den)
%
%   returns equivalent transfer function numerator and denominator where
%   length(numc) = LENGTH(den) if the transfer function num/den is proper,
%   otherwise causes an error.
%
   [nn,mn] = size(num);
   [nd,md] = size(den);

      % make sure DEN is a row vector, NUM is assumed to be in rows.
      
   if (nd > 1)
       error('denominator not a row vector');
   elseif (mn > md)
       %error('improper transfer function');
   end

     % make NUM and DEN lengths equal
   
   num = [zeros(nn,md-mn),num];
end
