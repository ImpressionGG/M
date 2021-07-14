function [Gjw,om,dB] = fqr(o,om,i,j)   % Frequency Response            
%
% FQR  Frequency response of transfer function to given omega, where pro-
%      vided omega arg is scaled with 'oscale' factor (option, default 1)
%
%		    [Gjw,~,dB] = fqr(G,omega)
%		    [Gjw,~,dB] = fqr(G,omega,i,j)
%
%      Auto omega:
%
%		    [Gjw,omega] = fqr(G)         % also return (unscaled) omega range
%		    [Gjw,omega] = fqr(G,[],i,j)  % indexed TRF matrix FQR
%
%	    Calculation of complex frequency response of a transfer function 
%      G(s) = num(s(/den(s) (omega may be a vector argument).
%	    The calculations depend on the type as follows:
%
%		     fqr(Gs,omega):  Gs(j*omega)		      (s-domain)
%		     fqr(Hz,omega):  Hz(exp(j*omega*Ts))	(z-domain)
%		     fqr(Gq,Omega):  Gq(j*Omega)		      (q-domain)
%
%      Remarks: system representations in modal form are computed in a 
%      special way to achieve good numerical results for high system orders
%
%          oo = system(o,A,B,C,D)      % let oo be a modal form
%          Fjw = rsp(oo,om,i,j)        % frequency response of Gij(j*om)
%
%      Expression based FQR calculation:
%
%         P = data(P,'fqr',{'/' {'modal' o 3 1} F0});
%         Q = data(Q,'fqr',{'/' {'modal' o 3 3} F0});
%         L0 = data(L0,'fqr',{'/',P,Q})
%         Gjw = fqr(L0,om)
%
%      Supported operators for expression based FQR operation
%
%         'modal'            FQR of modal system representation
%         '+'                sum
%         '-'                difference
%         '*'                product
%         '/'                division
%
%      Create an 'fqr' typed system
%
%         G = fqr(corasim,omega,{Gjw})
%         G = fqr(corasim,omega,{G11jw,G12jw;G21jw,G22jw})
%
%      Options:
%         input              input index (default 1)
%         output             output index (default 1)
%         oscale             omega scaling factor (default 1)
%
%      Copyright(c): Bluenetics 2020
%
%      See also: CORASIM, SYSTEM, PEEK, TRIM, BODE, TRFVAL
%
   if (nargin >= 3 && iscell(i))       % create 'fqr'  typed system
      matrix = i;
      
         % optionally pre-process matrix
         
      if (length(matrix) == 1)
         m11 = matrix{1,1};            % THE one & only matrix element
         if (size(m11,1) > 1)          % has it multiple rows?
            for (i=1:size(m11,1))
               matrix{i,1} = m11(i,:); % convert into multiple row matrix
            end
         end
      end
      
      Gjw = System(o,om,matrix);
      return
   end
   
   if (nargin <= 1) || isempty(om)
      oml = opt(o,{'omega.low',1e-5});
      omh = opt(o,{'omega.high',1e5});
      points = opt(o,{'omega.points',1000});
      om = logspace(log10(oml),log10(omh),points);
   end
   
      % scale omega 
      
   oscale = opt(o,{'oscale',1});
   Om = om * oscale;
   
      % first check whether frequency response is expression based.
      % if so this overrules all standard methods
      
   expr = data(o,'fqr');
   if ~isempty(expr)
      Gjw = Process(o,Om,expr);
      if (nargout >= 3)
         dB = 20*log10(abs(Gjw));
      end
      return
   end
   
      % continue with standard methods, depending on type

   jw = 1i*Om;                         % use scaled omega !!!
   switch o.type
      case {'strf','qtrf'}
         [num,den] = peek(o);
         Gjw = polyval(num,jw) ./ polyval(den,jw);
         
      case {'ztrf','dss'}
         [num,den] = peek(o);
         T = data(o,'T');
         expjw = exp(jw*T);
         Gjw = polyval(num,expjw) ./ polyval(den,expjw);

      case {'szpk','qzpk'}
         [z,p,k] = zpk(o);
         
            % sort poles and zeros my abs value
            
         [~,idx] = sort(abs(z));
         z = z(idx);
         
         [~,idx] = sort(abs(p));
         p = p(idx);
         
         Gjw = k * ones(size(jw));
         
         nz = length(z);                % number of zeros
         np = length(p);                % number of poles
         
            % alternate multiplication and division
            
         for (i=1:max(nz,np))
            if (i <= nz)
               Gjw = Gjw .* (jw - z(i));
            end
            if (i <= np)
               Gjw = Gjw ./ (jw - p(i));
            end
         end

      case 'css'
         if (nargin < 3)
            i = 1;
         end
         if (nargin < 4)
            j = 1;
         end
         
         oo = Partition(o);
         if ismodal(oo)
            Gjw = Modal(o,Om,i,j);
         else
            [num,den] = peek(o,i,j);
            Gjw = polyval(num,jw) ./ polyval(den,jw);
         end
         
      case {'modal'}
         i = opt(o,{'output',1});
         j = opt(o,{'input',1});
         Gjw = Modal(o,Om,i,j);        % frequency response of modal Gij(s)
         
      case {'psiw'}
         [psi,W,D] = data(o,'psi,W,D');
         Gjw = psion(o,psi,Om,W) + D;
      
      case 'fqr'
         Omega = data(o,'omega') * oscale;
         if length(o.data.matrix) > 1
            error('cannot handle MIMO systems');
         end
         
         if (length(Omega) == length(Om) && all(Omega==Om))
            Gjw = o.data.matrix{1,1};
         else
            Gjw = o.data.matrix{1,1};
            
                % complex interpolation makes big errors
                % so we have to do separate interpolation of phase
                % and magnitude
                
%           Gjw = interp1(Omega,Gjw,Om);   % does not work interpolate

            mag = abs(Gjw);  phi = angle(Gjw);
            mag = interp1(Omega,mag,Om);
            phi = interp1(Omega,phi,Om);
            Gjw = mag .* exp(1i*phi);
         end
         
      otherwise
         error('bad type');
   end
   
      % calculate |G(jw)| in dB if requested as out arg 3
      
   if (nargout >= 3)
      dB = 20*log10(abs(Gjw));
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
% Create FQR Typed System
%==========================================================================

function oo = System(o,om,matrix)
   assert(iscell(matrix));
   if (size(om,1) ~= 1)
      error('row vector expected for omega (arg2)');
   end
   
      % check dimensions
      
   N = length(om);
   [m,n] = size(matrix);
   for (i=1:m)
      for (j=1:n)
         if ~all(size(om)==size(matrix{i,j}))
            error('size mismatch (arg2,arg3)');
         end
      end
   end
   
      % create FQR typed corasim object

   oo = type(corasim,'fqr');
   oo.data.omega = om;
   oo.data.matrix = matrix;
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

