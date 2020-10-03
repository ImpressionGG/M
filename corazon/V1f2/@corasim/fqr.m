function [Gjw,om] = fqr(o,om,i,j)
%
% FQR  Frequency response of transfer function.
%
%		    Gjw = fqr(G,omega)
%		    Gjw = fqr(G,omega,i,j)
%
%      Auto omega:
%
%		    [Gjw,omega] = fqr(G)
%		    [Gjw,omega] = fqr(G,[],i,j)
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
%      Copyright(c): Bluenetics 2020
%
%      See also: CORASIM, SYSTEM, PEEK, TRIM, BODE
%
   if (nargin <= 1) || isempty(om)
      oml = opt(o,{'omega.low',1e-5});
      omh = opt(o,{'omega.high',1e5});
      points = opt(o,{'omega.points',1000});
      om = logspace(log10(oml),log10(omh),points);
   end

   switch o.type
      case {'strf','qtrf'}
         [num,den] = peek(o);
         jw = sqrt(-1)*om;
         Gjw = polyval(num,jw) ./ polyval(den,jw);
         
      case {'ztrf','dss'}
         [num,den] = peek(o);
         T = data(o,'T');
         expjw = exp(sqrt(-1)*om*T);
         Gjw = polyval(num,expjw) ./ polyval(den,expjw);

      case 'css'
         if (nargin < 3)
            i = 1;
         end
         if (nargin < 4)
            j = 1;
         end
         
         oo = Partition(o);
         if ismodal(oo)
            Gjw = Modal(o,om,i,j);
         else
            [num,den] = peek(o,i,j);
            jw = sqrt(-1)*om;
            Gjw = polyval(num,jw) ./ polyval(den,jw);
         end
         
      case {'modal'}
         [num,den] = peek(o);
         jw = sqrt(-1)*om;
         Gjw = polyval(num,jw) ./ polyval(den,jw);

      otherwise
         error('bad type');
   end
end

%==========================================================================
% Frequency Response of a Modal Form
%==========================================================================

function Gjw = Modal(oo,om,i,j)         % Frequency Rsp. of a Modal Form
%
% MODAL  Frequency response Gij(j*om) of a modal form refering to transfer
%        function Gij(s) (i-th output, j-th input)
%
   oo = Partition(o);
   if isempty(oo) || ~ismodal(oo)
      error('modal form expected');
   end
   
   [A21,A22,B2,C1,D] = var(oo,'A21,A22,B2,C1,D');
   a0 = -diag(A21);
   a1 = -diag(A22);
   
   if ~isequal(B2,C1')
      error('B2 does not match C1');
   end
   M = B2;
   
      % now since we have a1,a0 and M we can start calculating the transfer
      % matrix
   
   n = length(A21);
   m = size(B2,2);                     % number of inputs
   l = size(c1,1);                     % number of outputs
   
      % calculate psi(i) polynomials
      
   psi = [ones(n,1) a1(:) a0(:)];
   
      % calculate weight vector
      
   mi = C1(:,i)';  mj = B2(:,j);
   wij = (mi(:).*mj(:))';        % weight vector

   jw = sqrt(-1)*om;             % j*omega
   Gjw = 0*jom;                  % init Gjw
   for (k=1:n)
      psijw = polyval(psi(k,:),jw);
      Gjw = Gjw + wij(k) ./ psijw;
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

