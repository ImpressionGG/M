function [oo,L0,K0,f0,K180,f180] = contact(o,idx,A,B,C,D)
%
% CONTACT  Return free system with specified contact indices as CORASIM
%          state space object.
%
%             oo = contact(o)          % according to process.contact opt
%             oo = contact(o,0)        % center contact
%             oo = contact(o,-3)       % triple contact
%             oo = contact(o,idx)      % specfied contact indices
%             oo = contact(o,inf)      % multi contact
%
%          Calling syntax to avoid recursion during brew
%
%             oo = contact(o,idx,A,B,C,D)
%
%          fetch contact indices
%
%             idx = contact(o,nan);
%
%          Optionally can also calculate L0 transfer matrix in ss 
%          representation or stability margins and critical frequencies
%
%             [oo,L0] = contact(o,...)
%             [oo,L0,K0,f0,K180,f180] = contact(o,...)
%
%          Copyright(c): Bluenetics 2021
%
%          See also: SPM
%
   if (nargin < 2)
      idx = opt(o,{'process.contact',0});
   end
   
   if (nargin < 3)
      oo = brew(o,'Variation');        % apply system variation
      oo = brew(oo,'Normalize');       % normalize system
      oo = brew(oo,'Transform');       % coordinate transformation

      [A,B,C,D] = var(oo,'A,B,C,D');   % fetch brewed SPM matrices
   end
   
   oo = system(corasim,A,B,C,D,0,oscale(o));
   [n,no,ni] = size(oo);
   
   if (no ~= ni)
      error('number of inputs and outputs not matching');
   end
   N = no/3;  M = N;
   if (N ~= round(N))
      error('input/output number not a multiple of 3');
   end
   
   cdx = ContactIndices(o,N,idx);

   if (nargin == 2 && any(isnan(idx(:))))
      oo = cdx;
      return
   end
   
      % contact index (cdx) is either empty or indexing B-columns
      % and C-rows to be picked
      
   kdx = [];
   if ~isempty(cdx)
      for (i=1:N)
         if any(i==cdx)
            kdx = [kdx,(3*(i-1)+1):(3*(i-1)+3)];
         end
      end
      
      assert(~isempty(kdx));
      B = B(:,kdx);
      C = C(kdx,:);
      D = D(kdx,kdx);
      
      M = length(kdx)/3;               % overwrite
      
         % overwrite system with contact system
         
      oo = system(corasim,A,B,C,D,0,oscale(o));
   end
   oo = var(oo,'T0',oscale(o));
   
      % add matrices B_1,B_2,B_3 and C_1,C_2,C_3 to variables
      
      % get indices of 1-2-3 components

   idx1 = 1+3*(0:M-1);
   idx2 = 2+3*(0:M-1);
   idx3 = 3+3*(0:M-1);

   B_1 = B(:,idx1);  B_2 = B(:,idx2);  B_3 = B(:,idx3);
   C_1 = C(idx1,:);  C_2 = C(idx2,:);  C_3 = C(idx3,:);
   oo = var(oo,'B_1,B_2,B_3,C_1,C_2,C_3',B_1,B_2,B_3,C_1,C_2,C_3);
   oo = var(oo,'contact,index,idx1,idx2,idx3',cdx,kdx,idx1,idx2,idx3);
   
      % finally inherit options from shell
      
   oo = inherit(oo,o);
   
      % optionally calculate L0 transfer matrix as ss
      
   if (nargout >= 2)
      L0 = CalcL0(o,A,B_1,B_3,C_3);
      L0 = Reduce(L0);
   end 
   if (nargout >= 3)
      [K0,f0]=stable(o,L0);
      L0 = var(L0,'K0,f0',K0,f0);
   end
   if (nargout >= 5)
      L180 = L0;
      L180.data.B = -L180.data.B;
      L180.data.D = -L180.data.D;
      [K180,f180]=stable(o,L180);
      L0 = var(L0,'K180,f180',K180,f180);
   end
end
function cdx = ContactIndices(o,N,idx)
   if ~iscell(idx) && any(isnan(idx(:)))
      idx = opt(o,{'process.contact',0});
   end
   
   if iscell(idx)
      cdx = [];
      for (i=1:min(length(idx),N))
         if (idx{i} ~= 0)
            cdx(end+1) = i;
         end
      end
   elseif isinf(idx)
      cdx = 1:N;                       % multi contact
   elseif isequal(idx,0)               % center contact
      cdx = (N+1)/2;
      if (cdx ~= round(cdx))
         error('no center contact for even article number');
      end
   elseif (isa(idx,'double') && length(idx) == 1 && idx < 0)
      cdx = [];  
      idx = abs(idx);
      for (i=1:N)
         if rem(idx,2)
            cdx(end+1) = i;
         end
         idx = floor(idx/2);
      end
   else
      cdx = idx;
      if (any(cdx<1) || any(cdx>N))
         error('not all indices (arg2) in range');
      end
      
      if isempty(cdx)
         error('bad input arg');;
      end
   end
end
function L0 = CalcL0(o,A,B_1,B_3,C_3)                                  
      % system augmentation

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

   scale = oscale(o);
   digits = 0;
   brew = 'contact';

   L0 = system(corasim,A0,B0,C0,D0,0,scale);
   L0 = var(L0,[]);                    % clear all variables
   L0 = var(L0,'digits,V0,err,brew',digits,V0,err,brew);
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
   V0 = var(L0,'V0');
   Ierr = norm(-(C0/A0)*B0+D0-V0)/norm(V0);     % initial gain error
   
      % reduce system by transforming to diagonal and deleting those
      % state variables which are more or less not observable
      
   [V,AV] = eig(A0);                   % transform to diagonal form
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
   
   T = zeros(2*n,2*n);
   for (i=1:n)
      k = 2*(i-1) + 1;
      l1 = AS(k,k);
      l2 = AS(k+1,k+1);
      Ti = [-l2 1; -l1 1];
      if ( det(Ti) == 0 )
         if (imag(l1)== 0 && imag(l2)==0)
            Ti = eye(2);                     % recover for real eigenvalues
         else
            error('cannot transform');
         end
      end
      T(k:k+1,k:k+1) = Ti;
   end
   
   A = real(T\AS*T);  B = real(T\BS);   C = real(CS*T);  D = real(DS);
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
      
   L0 = system(L0,A,B,C,D);

      % provide some more variables
      
   L0 = var(L0,'A0,B0,C0,D0,V0',A0,B0,C0,D0,V0);
   L0 = var(L0,'observability',observability);   
   L0 = var(L0,'Ierr,Verr,Rerr,Serr,V0err',Ierr,Verr,Rerr,Serr,V0err);
end
