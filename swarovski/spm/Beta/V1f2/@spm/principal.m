function L0 = principal(o,oo)
%
% PRINCIPAL Calculate a state space realization of principal transfer
%           system L0 (in terms of a CORASIM state space system)
%
%              L0 = principal(o)     % calc principal system L0
%              L0 = principal(o,oo)  % calc principal system L0 from oo
%
%           The system matrices [A0,B0,C0,D0] of L0 buiold the basis
%           for closed loop eigenvalue calculation. Given a feedback 
%           matrix K the closed loop dynamic matrix AK calculates
%
%              L0 = principal(o)              % principal system
%              [A0,B0,C0,D0] = var(L0,'A0,B0,C0,D0')
%              I = eye(size(D0))
%              AK = A0 - B0*K*inv(I+D0*K)*C0;
%
%           Theory:
%
%              x`= A0*x + B0*u
%              y = C0*x + D0*u
%              u = -K*y
%
%              y = C0*x + D0*(-K*y) 
%                => (I+D0*K)*y = C0*x 
%                => y = (I+D0*K)\C0*x  => u = -K*inv(I+D0*K)*C0*x
%
%              x'= A0*x + B0*(-K*inv(I+D0*K)*C0*x)
%              x'=[A0 - B0*K*inv(I+D0*K)*C0]*x
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, SYSTEM, CONTACT
%   
   if (nargin == 1)
      oo = system(o);
   end
   
   [A,B_1,B_3,C_3,T0] = var(oo,'A,B_1,B_3,C_3,T0');
   
   L0 = CalcL0(o,A,B_1,B_3,C_3,T0);
   L0 = Reduce(L0);
end

%==========================================================================
% Helper
%==========================================================================

function L0 = CalcL0(o,A,B_1,B_3,C_3,T0)                                  
      % system augmentation

if(0)
T0 = 10.^(-5:5);
for (k=1:length(T0))
   N0 = sqrtm(inv(C_3*T0(k)*A*T0(k)*B_3));
   M0 = sqrtm(-inv(C_3*inv(T0(k)*A)*T0(k)*B_3));

   C0 = M0*C_3 + N0*C_3*T0(k)*A;
   CQ = M0*C0 + N0*C0*T0(k)*A;    CP = CQ;
   DP = N0*C0*T0(k)*B_1;  DQ = N0*C0*T0(k)*B_3;
   BQ = T0(k)*B_3/DQ;     AQ = T0(k)*(A - BQ*CQ); 

   A0 = [T0(k)*A 0*A; BQ*CP AQ];  B0 = [T0(k)*B_1; BQ*DP];  
   C0 = [DQ\CP -DQ\CQ];     D0 = DQ\DP;
   
   [VV,~] = eig(A0);
   condi(k) = cond(VV);
end
logc = log10(condi)
end
   
   N0 = sqrtm(inv(C_3*A*B_3));
   M0 = sqrtm(-inv(C_3*inv(A)*B_3));

   C0 = M0*C_3 + N0*C_3*A;
   CQ = M0*C0 + N0*C0*A;    CP = CQ;
   DP = N0*C0*B_1;  DQ = N0*C0*B_3;
   BQ = B_3/DQ;     AQ = A - BQ*CQ; 

   A0 = [A 0*A; BQ*CP AQ];  B0 = [B_1; BQ*DP];  
   C0 = [DQ\CP -DQ\CQ];     D0 = DQ\DP;

      % calculate gain matrix of L0 system

   V00 = -(C0/A0)*B0 + D0;

      % calculate gain matrices of G31(s) and G33(s)

   C3overA = C_3/A;
   V_31 = C3overA * B_1;
   V_33 = C3overA * B_3;
   V_0 = V_33\V_31;

      % calculate for modal forms: 

   n = length(A)/2;  i1=1:n;  i2 = i1+n;
   assert(n==round(n));

   a0 = -diag(A(i2,i1));
   assert(norm(A(i2,i1)-diag(-a0))==0);

   V0 = CalcV0(o,a0,C_3(:,i1),B_1(i2,:),B_3(i2,:));

      % V00 = L0(0) must be same as V0 := V33\V31 = G33(0)\G31(0)

   err = norm(V0-V_0)/norm(V0);
   err = norm(V0-V00)/norm(V0);
   if (err > 1e-10)
      fprintf('*** warning: high deviation of V0 = L0(0): %g\n',err);
   end

   digits = 0;
   brew = 'contact';

   L0 = system(corasim,A0,B0,C0,D0,0,T0);
   L0 = var(L0,[]);                    % clear all variables
   L0 = var(L0,'digits,V0,err,brew,T0',digits,V0,err,brew,T0);
end
function V0 = CalcV0(o,a0,C3,B1,B3)                                    
%
% Method:
%
%    x`=v
%    v = A21*x + A22*v + B2*u   % A21 = diag(-a0); A22 = diag(-a1);
%    y = C1*x
%
%    G(s) = C1\(s^2*I-A22*s-A21)*B2
%    G(0) = C1\(-A21)*B2 = -C1*diag(1./a0)*B2
%      
   digs = opt(o,{'precision.V0',0});

   if (digs > 0)
      a0 = vpa(a0,digs);
      C3 = vpa(C3,digs);
      B1 = vpa(B1,digs);
      B3 = vpa(B3,digs);

      old = digits(digs);
   end

   C3ovrA21 = C3*diag(1./a0);
   V31 = -(C3ovrA21)*B1;
   V33 = -(C3ovrA21)*B3;
   V0 = V33\V31;

   if (digs > 0)
      digits(old);
   end
end
function L0 = Reduce(L0)                                               
   [A0,B0,C0,D0] = system(L0,'A,B,C,D');
   scale = data(L0,'scale');
   V0 = var(L0,'V0');
   Ierr = norm(-(C0/A0)*B0+D0-V0)/norm(V0);     % initial gain error
   
      % reduce system by transforming to diagonal and deleting those
      % state variables which are more or less not observable
      
   [V,AV] = eig(A0);                   % transform to diagonal form
   condi = cond(V);

if(0)   
   if (condi > 1e10)
      [V1,AV1] = eig(A0*1000);
       kilo = cond(V1)
      [V2,AV2] = eig(A0/1000);
       milli = cond(V2)
   end
end

   BV = V\B0;
   CV = C0*V;
   DV = D0;

   Verr = norm(-(CV/AV)*BV+DV-V0)/norm(V0);  % diagonal form error

      % examine observability of state variables by building the 
      % norm of each column vector of CV
      
   for (i=1:size(CV,2))
      w(i) = norm(CV(:,i));
   end
   
      % sort w and pick AR,BR,CR of reduced system
      
   [w,idx] = sort(w);
   n = length(w)/2;
   
   if (n ~= round(n))
      error('odd column size - cannot continue');
   end
   
   ndx = idx(1:n);                     % index of non observable SV     
   odx = idx(n+1:end);                 % indices of observable SV

   AR = AV(odx,odx);                   % observable dynamic matrix
   BR = BV(odx,:);
   CR = CV(:,odx);
   DR = DV;
   
   observability = norm(CV(:,ndx)) / norm(CV(:,odx));
   Rerr = norm(-(CR/AR)*BR+DR-V0)/norm(V0);   % gain error of observable
   
       % transform to Schur form
       
   [U,AS] = schur(AR);
   BS = U\BR;
   CS = CR*U;
   DS = DR;

   Serr = norm(-(CS/AS)*BS+DS-V0)/norm(V0);    % gain error of Schur form
   
      % transform to modal form
      
   n = length(AS)/2;
   if (n ~= round(n))
      error('odd column size - cannot continue');
   end
   
      % time transformation:  X(tau) = x(t/T0) 
      % x´= A*x + B*u          X´= (T0*A)*X + (T0*B)*U
      % y = C*x + D*u          Y = C*X + D*U

if(0)
   T0 = 10.^(-3:3);
   
   for (k=1:length(T0))
      T{k} = Tmatrix(AS,T0(k));
      condition(k) = cond(T{k});
   end
   [condi,idx] = sort(condition);  condi = condi(1);
   T = T{idx(1)};  T0 = T0(idx(1));
   
      % time normalization
      
   AS = T0*AS;  B0 = T0*BS;
end   
      % state transformation
      
   T = Tmatrix(AS);
   A = real(T\AS*T);  B = real(T\BS);   C = real(CS*T);  D = real(DS);

if(0)   
      % time denormalization
      
   A = A/T0;   B = B/T0;
end

   i1 = 2*(1:n)-1;  i2 = 2*(1:n); 
   
      % reorder states
      
   A = [A(i1,i1), A(i1,i2); A(i2,i1), A(i2,i2)];
   B = [B(i1,:); B(i2,:)];
   C = [C(:,i1), C(:,i2)];
   
      % balance input and output matrix
      
   nB = norm(B);  nC = norm(C);
   k = nB/sqrt(nB*nC);
   
   B = B/k;  C = C*k;

   V0err = norm(-(C/A)*B+D-V0)/norm(V0);   % gain error of modal form
   
      % store in cache segment
      
   L0 = system(L0,A,B,C,D,0,scale);

      % provide some more variables
      
   L0 = var(L0,'A0,B0,C0,D0,V0,T0',A0,B0,C0,D0,V0,scale);
   L0 = var(L0,'observability',observability);   
   L0 = var(L0,'Ierr,Verr,Rerr,Serr,V0err',Ierr,Verr,Rerr,Serr,V0err);
   
   function T = Tmatrix(AS,T0)
      if (nargin < 2)
         T0 = 1;
      end
      
      AS = T0*AS;
      
      N = length(AS);
      T = zeros(N,N);
      for (ii=1:N/2)
         kk = 2*(ii-1) + 1;
         l1 = AS(kk,kk);
         l2 = AS(kk+1,kk+1);
         Ti = [-l2 1; -l1 1];
         if ( det(Ti) == 0 )
            if (imag(l1)== 0 && imag(l2)==0)
               Ti = eye(2);                     % recover for real eigenvalues
            else
               error('cannot transform');
            end
         end
         T(kk:kk+1,kk:kk+1) = Ti;
      end
   end
end
