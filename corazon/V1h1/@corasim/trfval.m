function Gs = trfval(o,s)              % Value of Transfer Function           
%
% TRFVAL  Value of transfer function at given complex argument s
%
%		       Gs = trfval(G,s)
%
%         Example 1: frequency response
%
%            G = trf(corasim,1,[4 2 1])
%            Gjw = trf(G,0.5*sqrt(-1))    % Gjw = 0 - 1i
%
%         Example 2: transfer function value at zeros
%
%            oo = system(corasim,[-2 -4; 1 0],[1;0],[1 1])
%            err = trfval(oo,-1);         % err = 5.5511e-17
%            err = trfval(oo,vpa(-1))     % err = 0 for VPA arithmetics
%
%      Options:
%         oscale             input argument scaling factor (default 1)
%
%      Copyright(c): Bluenetics 2021
%
%      See also: CORASIM, SYSTEM, PEEK, TRIM, BODE, FQR
%   
      % scale oinput arg
      
   S = s * opt(o,{'oscale',1});
   
      % continue with standard methods, depending on type

   switch o.type
      case {'css','dss'}
         [A,B,C,D] = system(o);
         Gs = 0*S;                     % setup dimension
         
         if (length(D) > 1)
            error('multi-I/O systems not supported');
         end
         
             % calculate according to G(s) = C*inv(s*I-A)*B + D
             
         I = eye(size(A));
         for (i=1:prod(size(S)))
            si = S(i);
            if isinf(si)
               Phi = 0*I;
            else
               Phi = inv(si*I-A);
            end
            Gs(i) = C*Phi*B + D;
         end
         
      case {'strf'}
         [num,den] = peek(o);
         Gs = polyval(num,S) ./ polyval(den,S);

      case {'szpk','qzpk'}
         [z,p,k] = zpk(o);
         
            % sort poles and zeros by abs value
            
         [~,idx] = sort(abs(z));
         z = z(idx);
         
         [~,idx] = sort(abs(p));
         p = p(idx);
         
         Gs = k * ones(size(S));
         
         nz = length(z);                % number of zeros
         np = length(p);                % number of poles
         
            % alternate multiplication and division
            
         for (i=1:max(nz,np))
            if (i <= nz)
               Gs = Gs .* (S - z(i));
            end
            if (i <= np)
               Gs = Gs ./ (S - p(i));
            end
         end
   end
end

%==========================================================================
% Frequency Response of a Modal Form
%==========================================================================

function Gjw = Modal(o,om,i,j)         % Frequency Rsp. of a Modal Form
%
% MODAL  Frequency response Gij(j*om) of a modal form refering to transfer
%        function Gij(s) (i-th output, j-th input)
%
%        Partial system:
%
%           z(k)` = v(k) + Bz(k,j)*u(j)
%           v(k)` = -a0(k)*z(k) - a1(k)*v(k) + Bv(k,j)'*u(j)
%           y(i,k) = Cz(i,k)*z(k) + Cv(i,k)*v(k)
%
%           y(i) = y(i,1) + ... + y(i,n) + D*u
%
%        Laplace Transformation:
%
%           s*Z(k) = V(k) + Bz(k,j)*U(j)
%           Z(k) = 1/s * [V(k) + Bz(k,j)*U(j)]
%
%           s*V(k) = -a0(k)*Z(k) - a1(k)*V(k) + Bv(k,j)*U(j)
%           Y(i,k) = Cz(i,k)*Z(k) + Cv(i,k)*V(k)
%
%        Substitute s*Z(k) = V(k) + Bz(k,j)*U(j)
%
%           s^2*V(k) = -a0(k)*[s*Z(k)] - s*a1(k)*V(k) + s*Bv(k,j)*U(j)
%           s^2*V(k) = -a0(k)*[V(k) + Bz(k,j)*U(j)] -
%                      - s*a1(k)*V(k) + s*Bv(k,j)*U(j)
%           [s^2 + a1(k)*s + a0(k)]*V(k) = [s*Bv(k,j) - a0(k)*Bz(k,j)]*U(j)
%
%           V(k) = [s*Bv(k,j)-a0(k)*Bz(k,j)] / [s^2+a1(k)*s+a0(k)] * U(j) 
%
%        Transfer function: V(k) = Fijk(s) * U(j)
%
%           Fijk(s) = [s*Bv(k,j)-a0(k)*Bz(k,j)] / [s^2+a1(k)*s+a0(k)]
%
%           Z(k) = 1/s * [V(k) + Bz(k,j)*U(j)] = 
%                = 1/s * [Fijk(s)*U(j) + Bz(k,j)*U(j)] = 
%                = [Fijk(s) + Bz(k,j)]/s * U(j)
%          
%           Y(i,k) = Cz(i,k)*Z(k) + Cv(i,k)*V(k) =
%                  = {Cz(i,k)/s*[Fijk(s) + Bz(k,j)]+Cv(i,k)*Fijk(s)} * U(j)
%
%        Transfer function: Y(i,k) = Gijk(s) * U(j)
%
%           Fijk(s) = [s*Bv(k,j)-a0(k)*Bz(k,j)] / [s^2+a1(k)*s+a0(k)]
%           Gijk(s) = Cz(i,k)/s * [Fijk(s) + Bz(k,j)] + Cv(i,k) * Fijk(s)
%
%        Total Transfer function
%                     n
%           Gij(s) = Sum{Gijk(s)} + D
%                    k=1
%
   if ~type(o,{'modal'})
      error('modal form expected');
   end
   
   [a0,a1,B,C,D] = data(o,'a0,a1,B,C,D');
   
   n = length(a0);  
   m = size(B,2);                      % number of inputs
   l = size(C,1);                      % number of outputs
   
   if (i < 1 || i > l)
      error('bad output index');
   end
   if (j < 1 || j > m)
      error('bad input index');
   end
   
   i1 = 1:n;  i2 = n+1:2*n;
   Bz = B(i1,:);  Bv = B(i2,:);
   Cz = C(:,i1);  Cv = C(:,i2); 
   
      % loop through all modes
      % Fijk(s) = [s*Bv(k,j)-a0(k)*Bz(k,j)] / [s^2+a1(k)*s+a0(k)]
      % Gijk(s) = Cz(i,k)/s * [Fijk(s) + Bz(k,j)] + Cv(i,k) * Fijk(s)
      %               n
      % Gij(s) = D + Sum{Gijk(s)}
      %              k=1
      
   jw = om*sqrt(-1);
   Gjw = D(i,j);                       % init value of frequency response
   
   for (k=1:n)      
      Fijk = [jw*Bv(k,j) - a0(k)*Bz(k,j)] ./ [jw.*jw + a1(k)*jw + a0(k)];
      Gijk = Cz(i,k)./jw .* [Fijk + Bz(k,j)] + Cv(i,k) * Fijk;
      Gjw = Gjw + Gijk;
   end
end

%==========================================================================
% Process Expression
%==========================================================================

function Gjw = Process(o,om,expr)      % Process Expression            
   op = expr{1};
   if o.is(op,{'+','-','*','/'})
      Gjw1 = Eval(o,om,expr{2});
      Gjw2 = Eval(o,om,expr{3});
   end
   
   switch op
      case '+'
         Gjw = Gjw1 + Gjw2;
      case '-'
         Gjw = Gjw1 - Gjw2;
      case '*'
         Gjw = Gjw1 .* Gjw2;
      case '/'
         Gjw = Gjw1 ./ Gjw2;
      case 'modal'
         oo = expr{2};  i = expr{3};  j = expr{4};
         Gjw = Modal(oo,om,i,j);
      otherwise
         error('unknown operation');
   end
end
function Gjw = Eval(o,om,oo)           % Evaluate Expression
   if iscell(oo)
      Gjw = Process(o,om,oo);
   elseif isa(oo,'corasim')
      Gjw = fqr(oo,om);
   else
      error('no idea how to evaluate');
   end
end

%==========================================================================
% Helper
%==========================================================================

function oo = Partition(o)             % Partition System Matrices     
   [A,B,C] = data(o,'A,B,C');

   n = floor(length(A)/2);
   if (2*n ~= length(A))
      oo = [];
      return
   end
   
   i1 = 1:n;  i2 = n+1:2*n;
   
   A11 = A(i1,i1);  A12 = A(i1,i2);
   A21 = A(i2,i1);  A22 = A(i2,i2);
  
   B1 = B(i1,:);  B2 = B(i2,:);   
   C1 = C(:,i1);  C2 = C(:,i2);
   
   M = B2;  a0 = -diag(A21);  a1 = -diag(A22);
   omega = sqrt(a0);  zeta = a1./omega/2;
   
   oo = var(o,'A11,A12,A21,A22',A11,A12,A21,A22);
   oo = var(oo,'B1,B2,C1,C2',B1,B2,C1,C2);
   oo = var(oo,'M,a0,a1,omega,zeta',M,a0,a1,omega,zeta);
end

