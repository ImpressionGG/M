function oo = brew(o,varargin)         % SPM Brew Method               
%
% BREW   Brew data
%
%           oo = brew(o);              % brew all
%
%           oo = brew(o,'Variation')   % brew sys variation (change data)
%           oo = brew(o,'Normalize')   % brew time scaled system
%           oo = brew(o,'System')      % brew system matrices
%           oo = brew(o,'Critical');   % brew critical cache segment
%
%           oo = brew(o,'Trf')         % brew transfer matrix
%           oo = brew(o,'Constrain')   % brew double constrained trf matrix
%           oo = brew(o,'Principal')   % brew principal transfer functions
%           oo = brew(o,'Loop')        % brew loop analysis stuff
%           oo = brew(o,'Process')     % brew closed loop transfer fct
%
%           oo = brew(o,'Nyq')         % brew nyquist stuff
%
%        The following cache segments are managed by brew:
%
%           'critical'                      % critical quantities
%           'trf'                           % free system TRFs
%           'consd'                         % constrained system TRFs
%           'principal'                     % principal transfer functions
%           'inverse'                       % inverse system
%           'loop'                          % loop transfer function
%           'process'                       % closed loop process 
%
%        Examples
%
%           oo = brew(o,'System')           % brew system matrices
%           [A,B,C,D] = var(oo,'A,B,C,D)    % system matrices
%
%           oo = brew(o,'Multi')            % brew multi variable L0(s) rep.
%           Sys0 = cache(oo,'multi.Sys0)    % state space system of L0(s)
%
%           oo = brew(o,'Trf')              % brew free TRF cache segment
%           G = cache(oo,'trf.G');          % G(s)
%
%           oo = brew(o,'Constrain')        % brew constrained cache segm.
%           H = cache(oo,'consd.H');        % H(s)
%           L = cache(oo,'consd.L');        % L(s)
%    
%           oo = brew(o,'Pricipal');        % brew principal cache segment
%           P = cache(oo,'pricipal.P')      % P(s)
%           Q = cache(oo,'pricipal.Q')      % Q(s)
%           L0 = cache(oo,'pricipal.L0')    % L0(s) := P(s)/Q(s)
%
%           oo = brew(o,'Loop');            % brew loop cache segment
%           Lmu = cache(oo,'loop.Lmu');     % Lmu(s) = mu*L0(s)
%
%           oo = brew(o,'Process')
%           T = cache(oo,'process.T'); % get T(s)
%
%           oo = brew(o,'Setup')
%           K0K180 = cache(oo,'setup.K0K180')
%
%        Dependency of cache segments
%
%                  variation  normalize transform
%                          |      |      |
%                          v      v      v
%                        +-----------------+
%                        |      system     | A,B,C,D,a0,a1
%                        +-----------------+
%                         |              |
%                         v              v
%              +--------------+        +---------------+
%     L0,K0,f0 |   critical   |        |     setup     |
%              +--------------+        +---------------+
%
%
%        Legacy Dependency of cache segments
%
%                       variation   normalizing
%                             |        |
%                             v        v
%                        +-----------------+
%                        |      system     | A,B,C,D,a0,a1
%                        +-----------------+
%                         |   |        |  |
%              +----------+   |        |  +---------------+
%              |              |        |                  |
%              v              |        |                  v
%     +-----------------+     |        |         +-----------------+
%     |      setup      |     |        |         |       multi     | Sys0
%     +-----------------+     |        |         +-----------------+
%                             |        |                  |
%                             |        |                  v
%                             |        |         +-----------------+
%                             |        |         |     spectrum    | L0jw
%                             |        |         +-----------------+
%                             v        v
%              +-----------------+  +-----------------+
%        L0(s) |    principal    |  |       trf       | G(s)
%              +-----------------+  +-----------------+
%                   |         |              |
%                   v         |              v
%       +-----------------+   |      +-----------------+
%       |      setup      |   |      |     consd       | H(s)
%       +-----------------+   |      +-----------------+
%                             |       
%                             |           friction
%                             |              |
%                             |              v
%                             |      +-----------------+
%                             |      |    process      | mu
%                             |      +-----------------+
%                             |         | 
%                             v         v
%                         +-----------------+
%                         |      loop       | Lmu(s)
%                         +-----------------+
%                                  | 
%                                  v
%
%        Copyright(c): Bluenetics 2020
%
%        See also: SPM
%        
   [gamma,oo] = manage(o,varargin,@Brew,@Variation,@Normalize,@Transform,...
                       @System,@Trf,@Principal,@Multi,@Spectrum,@Setup,...
                       @Critical,...
                       @Constrain,@Consd,@Consr,@Process,@Loop,@Nyq);
   oo = gamma(oo);
end              

%==========================================================================
% Brew All
%==========================================================================

function oo = Brew(o)                  % Brew All Cache Segments       
   oo = current(o);
   switch oo.type
      case 'spm'
         oo = BrewSpm(oo);
         
      case 'pkg'
         package = get(oo,'package');
         if isempty(package)
            error('empty package ID');
         end
         
            % brew all data objects belonging to package except package
            
         o = pull(o);                  % make sure to have shell object
         assert(container(o));

         n = length(o.data);
         for (i=1:n)
            oi = o.data{i};
            progress(o,sprintf('brewing: %s',get(oi,{'title',''})),i/n*100);
            
            if isequal(package,get(oi,'package')) && ~type(oi,{'pkg'})
               oi = inherit(oi,o);     % inherit shell settings
               oi = opt(oi,'progress',0);    % disable progress details
               oi = BrewSpm(oi);
            end
            
               % at the end brew package object
         end
               
         progress(o,sprintf('brewing: %s',get(oo,{'title',''})),99);
         oo = opt(oo,'progress',0); % disable progress details
         %oo = Brew(oo);
         
         progress(o);                  % progress complete
         
      case 'shell'
         message(o,'Brewing not performed for shell object!',...
                   {'select package or data object!'});
         
      otherwise
         'ok';                         % ignore other types
   end
   
   function o = BrewSpm(o)
      o = cache(o,o,[]);               % clear cache hard

         % note that brewing function hard refreshes cache segment

      o = brew(o,'Trf');
      o = brew(o,'Constrain');
      o = brew(o,'Process');
   end
end
function oo = OldEigen(o)              % Brew Eigenvalues              
   oo = o;                             % copy to out arg
   A = data(oo,'A');
   
   ev = eig(A);                        % eigenvalues (EV)
   i = 1:length(ev);                   % EV index 
   x = real(ev);                       % real value
   y = imag(ev);                       % imag value
   [~,idx] = sort(abs(imag(ev)));
   
      % store calculated stuff in cache
      
   oo = cache(oo,'eigen.index',i);
   oo = cache(oo,'eigen.real',x(idx));
   oo = cache(oo,'eigen.imag',y(idx));
end

%==========================================================================
% System Matrices and Normalizing
%==========================================================================

function oo = Variation(o)             % System Variation              
   vom = opt(o,{'variation.omega',1}); % omega variation
   vzeta = opt(o,{'variation.zeta',1});% omega variation

   [A,B,C,D] = data(o,'A,B,C,D');

   n = floor(length(A)/2);
   i1 = 1:n;  i2 = n+1:2*n;
   
   A(i2,i1) = A(i2,i1) * vom;          % omega variation
   A(i2,i2) = A(i2,i2) * vzeta;        % zeta variation

   oo = data(o,'A,B,C,D',A,B,C,D);     % modify system
end
function oo = Normalize(o)             % Normalize System              
   T0 = opt(o,{'brew.T0',1});          % normalization time constant

      % normalize system (select T0 = 1e-3 for a good effect!)
      
   [A,B,C,D] = data(o,'A,B,C,D');

   n = floor(length(A)/2);
   i1 = 1:n;  i2 = n+1:2*n;
   
   A(i2,i1) = T0*T0*A(i2,i1);
   A(i2,i2) = T0*A(i2,i2);
   B(i2,:)  = T0*B(i2,:);
   C(:,i1) = C(:,i1)*T0;
   
   a0 = -diag(A(i2,i1));
   a1 = -diag(A(i2,i2));

      % refresh system
      
   oo = var(o,'A,B,C,D,T0,a0,a1,tscale',A,B,C,D,T0,a0,a1,T0);
end
function oo = Transform(o)             % coordinate transformation     
%
% TRANSFORM Transform coordinates by rotation around 3-axis (=z-axis)
%             by angle phi_p (process phi) plus phi_o (object specific 
%             phi depending on how SPM matrices are exported). 2nd input
%             arg (contact) ist the contact index.
%
%                 oo = Transform(o)
%                 [A,B,C,D] = var(o,'A,B,C,D')
%
%             We have:
%
%                [F1]   [ cos(phi)  sin(phi)   0]   [Fx]
%                [F2] = [-sin(phi)  cos(phi)   0] * [Fy]
%                [F3]   [   0          0       1]   [Fz]
%
%             For phi_p = 0 and phi_o = 90 we have phi = 90
%             and
%
%                [F1]   [   0   1   0]   [Fx]   [ Fy]
%                [F2] = [  -1   0   0] * [Fy] = [-Fx]
%                [F3]   [   0   0   1]   [Fz]   [ Fz]
%
%              Since
%                 F_123 = T*F_xyz and  y_123 = T*y_xyz
%
%                 x`     = A_xyz * x + B_xyz * F_xyz
%                 y_xyz  = C_xyz * x + D_xyz * F_xyz
%
%              we get:
%
%                 x´     = A_xyz * x + B_xyz * inv(T)*F_123
%                 y_123 = T*y_xyz = T*C_xyz * x + T*D_xyz*inv(T) * F_123
%
%              Thus we see:
%                 A_123 = A_xyz
%                 B_123 = B_xyz * inv(T)
%                 C_123 = T * C_xyz
%                 D_123 = T * D_xyz + inv(T)
%
   [B,C,D] = var(o,'B,C,D');
   
   M = size(B,2)/3;  N = size(C,1)/3;
   if (M ~= round(M) || N ~= round(N))
      error('input/output number must be multiple of 3');
   end
   if (M ~= N)
      error('same number of inputs and outputs expected');
   end

   assert(M==N);             % are the same
   
      % build-up total transformation matrix
      
   for (k=1:N)
      Tk = TransMatrix(o,k);
      
      idx = (1:3) + (k-1)*3;
      T(idx,idx) = Tk;
   end
   
      % transform system matrices (note: A is unchanged)
      
   invT = inv(T);
   if (norm(invT-T') == 0)
      invT = T';                       % no round-off errors!
   end
   
   B = B*invT;
   C = T*C;
   D = T*D*invT;
    
      % refresh variables
      
   oo = var(o,'B,C,D,N',B,C,D,N);

   function T = TransMatrix(o,k)                                 
   %
   % TRANSMATRIX Transform coordinates by rotation around 3-axis (=z-axis)
   %             by angle phi_p (process phi) plus phi_o (object specific 
   %             phi depending on how SPM matrices are exported). 2nd input
   %             arg (k) ist the contact index.
   %
   %                 T = Treansform(o,k)
   %
   %             We have:
   %
   %                [F1]   [ cos(phi)  sin(phi)   0]   [Fx]
   %                [F2] = [-sin(phi)  cos(phi)   0] * [Fy]
   %                [F3]   [   0          0       1]   [Fz]
   %
   %             For phi_p = 0 and phi_o = 90 we have phi = 90
   %             and
   %
   %                [F1]   [   0   1   0]   [Fx]   [ Fy]
   %                [F2] = [  -1   0   0] * [Fy] = [-Fx]
   %                [F3]   [   0   0   1]   [Fz]   [ Fz]
   %
   %              Since
   %                 F_123 = T*F_xyz and  y_123 = T*y_xyz
   %
   %                 x`     = A_xyz * x + B_xyz * F_xyz
   %                 y_xyz  = C_xyz * x
   %
   %              we get:
   %
   %                 x´     = A_xyz * x + B_xyz * inv(T)*F_123
   %                 y_123 = T*y_xyz = T*C_xyz * x
   %
   %              Thus we see:
   %                 B_123 = B_xyz * inv(T)
   %                 C_123 = T * C_xyz
   %  
      phi = getphi(o);
      rad = phi(k) * pi/180;           % total phi [rad]
         
      T = [
             cos(rad) sin(rad)  0
            -sin(rad) cos(rad)  0
                0        0      1
          ];
       
      if (rem(phi(k),90) == 0)
         T = round(T);
      end
   end
end
function oo = System(o)                % System Matrices               
   oo = Variation(o);                  % apply system variation
   oo = Normalize(oo);                 % normalize system
   oo = Transform(oo);                 % coordinate transformation
   
   [A,B,C,D,N] = var(oo,'A,B,C,D,N');  % N: number of articles

%  cidx = opt(o,{'process.contact',0});
   cidx = contact(o,nan);              % get contact indices   
   sys = contact(oo,cidx,A,B,C,D);     % calc free system regarding contact

      % expand cidx
      
   if isinf(cidx)
      cidx = 1:N;
   elseif isequal(cidx,0)
      mid = (N+1)/2;
      if (mid ~= round(mid))
         error('no triple contact for even article number');
      end
      cidx = mid;
   elseif isequal(cidx,-1)            % leading
      mid = (N+1)/2;
      if (mid ~= round(mid))
         error('no leading contact for even article number');
      end
      cidx = 1:mid;
   elseif isequal(cidx,-2)            % trailing
      mid = (N+1)/2;
      if (mid ~= round(mid))
         error('no trailing contact for even article number');
      end
      cidx = mid:N;
   elseif isequal(cidx,-3)
      mid = (N+1)/2;
      if (mid ~= round(mid))
         error('no triple contact for even article number');
      end
      cidx = [1,mid,N];
   end
   
      % for B1,B2 as well as C1,C2 we need idx0
   
   idx0 = [];
   for (i=1:length(cidx))
      idx0 = [idx0,3*(cidx(i)-1) + (1:3)];
   end
   
      % for B_1,B_2,B_3 as well as C_1,C_2,C_3 we need idx1,idx2,idx3
      
   idx1 = 3*(cidx-1) + 1;
   idx2 = 3*(cidx-1) + 2;
   idx3 = 3*(cidx-1) + 3;
   
   if (rem(N,2) ~= 1)
      error('number of articles on apparatus must be odd');
   end
   
      % continue regular calculations
      
   n = floor(length(A)/2);
   i1 = 1:n;  i2 = n+1:2*n;
   
   A11 = A(i1,i1);  A12 = A(i1,i2);
   A21 = A(i2,i1);  A22 = A(i2,i2);
  
   B1 = B(i1,idx0);  B2 = B(i2,idx0);   
   C1 = C(idx0,i1);  C2 = C(idx0,i2);
  
   if (norm(B2-C1') ~= 0)
      %fprintf('*** warning: B2 differs from C1''!\n');
   end
   
   a0 = -diag(A21);  a1 = -diag(A22);
   omega = sqrt(a0);  zeta = a1./omega/2;
   
      % state space representation of L0(s)
      
   N = floor(size(C,1)/3);
   B_1_ = B(:,idx1);  B_2_ = B(:,idx2);  B_3_ = B(:,idx3);
   C_1_ = C(idx1,:);  C_2_ = C(idx2,:);  C_3_ = C(idx3,:);
      
      % get C_j and B_i matrices and perform checks

   [B_1,B_2,B_3,C_1,C_2,C_3] = var(sys,'B_1,B_2,B_3,C_1,C_2,C_3');
   Checks(o);
   
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
      
   V0 = CalcV0(o,a0,C_3(:,i1),B_1(i2,:),B_3(i2,:));
   
      % V00 = L0(0) must be same as V0 := V33\V31 = G33(0)\G31(0)
      
   err = norm(V0-V_0)/norm(V0);
   err = norm(V0-V00)/norm(V0);
   if (err > 1e-10)
      fprintf('*** warning: high deviation of V0 = L0(0): %g\n',err);
   end
   
      % store as variables
   
   oo = var(oo,'A11,A12,A21,A22',A11,A12,A21,A22);
   oo = var(oo,'B1,B2,C1,C2',B1,B2,C1,C2);
   oo = var(oo,'a0,a1,omega,zeta',a0,a1,omega,zeta);
   
   oo = var(oo,'B_1,B_2,B_3,C_1,C_2,C_3',B_1,B_2,B_3,C_1,C_2,C_3);
   oo = var(oo,'N0,M0,AQ,BQ,CP,CQ,DP,DQ',N0,M0,AQ,BQ,CP,CQ,DP,DQ);
   oo = var(oo,'A0,B0,C0,D0,V0',A0,B0,C0,D0,V0);
   
   function V0 = CalcV0(o,a0,C3,B1,B3)
   %
   % Method:
   %
   %    x`=v
   %    v = A21*x + A22*v + B2*u
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
   function Checks(o)
      [A_,B_,C_,D_] = system(sys);
      B__ = [];   C__ = [];
      for (k=1:size(B_1_,2))
         B__ = [B__, B_1_(:,k),B_2_(:,k),B_3_(:,k)];
         C__ = [C__; C_1_(k,:);C_2_(k,:);C_3_(k,:)];
      end
      
      assert(norm(A_-A)==0);
      assert(norm(B_-B__)==0);
      assert(norm(C_-C__)==0);
      assert(norm(D_-C__*B__)==0);
           
      assert(norm(B_1_-B_1)==0);
      assert(norm(B_2_-B_2)==0);
      assert(norm(B_3_-B_3)==0);
      assert(norm(C_1_-C_1)==0);
      assert(norm(C_2_-C_2)==0);
      assert(norm(C_3_-C_3)==0);
   end
end

%==========================================================================
% Critical Quantities L0, K0, f0, K180, f180
%==========================================================================

function oo = Critical(o)
   o = with(o,'critical');
   [K0,f0,K180,f180,L0] = critical(o);
   
      % calculate L180
      
   L180 = L0;
   L180.data.B = -L180.data.B;
   L180.data.D = -L180.data.D;
   
      % store in critical cache segment
      
   oo = o;
   oo = cache(oo,'critical.L0',L0);
   oo = cache(oo,'critical.L180',L180);
   oo = cache(oo,'critical.K0',K0);
   oo = cache(oo,'critical.K180',K180);
   oo = cache(oo,'critical.f0',f0);
   oo = cache(oo,'critical.f180',f180);
   
      % unconditional hard refresh of cache
      
   cache(oo,oo);                       % hard refresh
end

%==========================================================================
% Setup
%==========================================================================

function oo = Setup(o)                 % Init Setup Cache Segment
   C = cook(o,'C');
   no = size(C,1)/3;
   n = 2^no-1;
   
   K0K180 = ones(n,2)*nan;
   f0f180 = ones(n,2)*nan;

   oo = o;
   oo = cache(oo,'setup.K0K180',K0K180);
   oo = cache(oo,'setup.f0f180',f0f180);

      % unconditional hard refresh of spectrum segment
      
   cache(oo,oo);                       % cache storeback to shell
end

%==========================================================================
% Multivariable Open Loop System
%==========================================================================

function oo = Multi(o)
   [A0,B0,C0,D0,V0] = cook(o,'A0,B0,C0,D0,V0');
   Ierr = norm(-(C0/A0)*B0+D0-V0)/norm(V0);     % initial gain error
   
      % reduce system by transforming to diagonal and deleting those
      % state variables which are more or less not observable
      
   [V,AV] = eig(A0);                   % transform to diagonal form
   BV = V\B0;
   CV = C0*V;
   DV = D0;

   Verr = norm(-(CV/AV)*BV+DV-V0)/norm(V0);  % diagonal form error

%  jw = CheckPoint(diag(AV),5);        % get 5 checkpoints
%  Ljw = trfval(sys,jw); 
   
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
%  ndx = idx(1:n+1);                   % index of non observable SV     
%  odx = idx(n+2:end);                 % indices of observable SV
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
      
   Sys0 = system(corasim,A,B,C,D);

   Sys0.data.A0 = A0;
   Sys0.data.B0 = B0;
   Sys0.data.C0 = C0;
   Sys0.data.D0 = D0;
   Sys0.data.V0 = V0;
   
   Sys0.data.observability = observability;
   
      % store gain errors
      
   Sys0.data.Ierr = Ierr;
   Sys0.data.Verr = Verr;
   Sys0.data.Rerr = Rerr;
   Sys0.data.Serr = Serr;
   Sys0.data.V0err = V0err;
   
      % calculate critical gain and frequency
      
   [K0,f0]=stable(o,Sys0);
   
      % change of cutting direction changes sign of B andD matrix
      
   Sys180 = Sys0;
   Sys180.data.B = -Sys180.data.B;
   Sys180.data.D = -Sys180.data.D;
   [K180,f180]=stable(o,Sys180);

      % store in cache and unconditional hard refresh of cache
      
   Sys0 = var(Sys0,'K0,f0,K180,f180',K0,f0,K180,f180);
   
   oo = o;
   oo = cache(oo,'multi.Sys0',Sys0);
   oo = cache(oo,'multi.K0',K0);
   oo = cache(oo,'multi.f0',f0);
   oo = cache(oo,'multi.K180',K180);
   oo = cache(oo,'multi.f180',f180);
      
   cache(oo,oo);                       % hard refresh cache
   progress(o);                        % progress complete   
   
   function jw = CheckPoint(s,n)       % get n check points
      om0 = abs(s);
      om1 = min(om0);
      om2 = max(om0);
      om = logspace(log10(om1),log10(om2),n);
      jw = sqrt(-1)*om;
   end
end
function oo = Spectrum(o)
%
% SPECTRUM  Calculate frequency responses L0ij(jw) according to
%
%              L0jw = C*inv(jw*I-A)*B + D
%
   o = with(o,{'spectrum'});
   l0 = lambda(o);
   
   oo = o;
   oo = cache(oo,'spectrum.l0',l0);    % store in cache
   
      % unconditional hard refresh of spectrum segment

   cache(oo,oo);                       % hard refresh of spectrum segment
return;   
   
   L0 = cook(o,'Sys0');
   [A,B,C,D] = system(L0,'A,B,C,D');
   
   [~,om] = fqr(L0);
   Om = om*oscale(o);
   
   kmax = length(om);
   
   [n,ni,no] = size(L0);
   L0jw = zeros(ni*no,length(Om));
   
   Lambda = zeros(max(ni,no),kmax);
   
   jI = 1i*eye(size(A));
   for (k=1:kmax)
      if (rem(k-1,100) == 0)
         progress(o,sprintf('%g of %g: calculate L0(jw) frequency response',...
                          k,kmax),k/kmax*100);
      end
      Ljwk = (C/(Om(k)*jI-A))*B + D;
      lam = eig(Ljwk);
      
      Ljw(:,k) = Ljwk(:);

      [~,idx] = sort(abs(lam),'descend');
      lam = lam(idx);
      Lambda(:,k) = lam(:);
   end
   
      % pack into a corasim object
      
   progress(o,'re-arranging ...');

   L0jw = matrix(corasim,[]);          % matrix of frequency responses
   L0jw.data.n = length(A);            % system order
   L0jw.data.omega = om;               % frequency matrix
   L0jw.data.oscale = oscale(o);
   L0jw.type = 'fqr';
   
   for (i=1:no)
      for (j=1:ni)
         k = (j-1)*no + i;
         L0jw.data.matrix{i,j} = Ljw(k,:);
      end
   end
   
   lamb = matrix(corasim,[]);
   lamb.data.n = length(A);            % system order
   lamb.data.omega = om;               % frequency matrix
   lamb.data.oscale = oscale(o);
   lamb.type = 'fqr';

   for (i=1:length(lam))
      lamb.data.matrix{i,1} = Lambda(i,:);
   end
   
   progress(o);
   
      % store in spectrum cache segment
      
   oo = o;
   oo = cache(oo,'spectrum.L0jw',L0jw);
   oo = cache(oo,'spectrum.lambda',lamb);
   
      % unconditional hard refresh of spectrum segment
      
   cache(oo,oo);                       % cache storeback to shell
end

%==========================================================================
% Transfer Matrix G(s)
%==========================================================================

function Gij = CalcGij(o,i,j)
%
% CALCGIJ   Calculate Gij(s) from a modal state space form represented 
%           as ZPK.
%
%              oo = brew(o,'System');
%              Gij = CalcGij(oo,i,j);
%
   trftype = opt(o,{'trf.type','szpk'});
   if ~isequal(trftype,'szpk')
      error('this kind of Gij(s) brewing is not selected');
   end
   if (i < 1 || i > 3)
      error('index i must be in range 1:3');
   end
   if (j < 1 || j > 3)
      error('index j must be in range 1:3');
   end
      
      % now since we have a1,a0 and M we can start calculating the transfer
      % matrix
   
   %n = length(a0);
   %m = size(M,2);

      % calculating Gij(s)
      
   [sys,psi,mi,mj] = Prepare(o,i,j);
   Gij = Calculate(o,i,j);   
      
   function [sys,psi,mi,mj] = Prepare(o,i,j)      
      [A,B1,B2,C1,C2,A11,A12,A21,A22] = var(o,'A,B1,B2,C1,C2,A11,A12,A21,A22');
      B = [B1;B2];  C = [C1,C2];  D = 0*C*B;
      a0 = -diag(A21);
      a1 = -diag(A22);
      %I = eye(length(a0));  Z = zeros(length(a0));
   
      if ~isequal(B2,C1')
         %error('B2 does not match C1');
         fprintf('*** warning: B2 does not match C1\n');
      end
      %M = B2;
      
      sys = system(corasim,A,B(:,j),C(i,:),D(i,j));
      psi = [1+0*a1(:) a1(:) a0(:)];
%     mi = M(:,i)';  mj = M(:,j); 
      mi = C1(i,:);  mj = B2(:,j); 
   end
   function Gij = Calculate(o,i,j)
      digs = opt(o,{'precision.G',0});
      
      if (digs == 0)
         wij = (mi(:).*mj(:))';     % weight vector
         psiw = [psi,wij(:)];

         Gij = zpk(sys);
      else
         sys = vpa(sys,digs);
         old = digits(digs);

         mi = vpa(mi,digs);
         mj = vpa(mj,digs);
         psi = vpa(psi,digs);
         wij = (mi(:).*mj(:))';     % weight vector
         psiw = [psi,wij(:)];

         Gij = zpk(sys);
         digits(old);
      end

      Gij.data.Zeros = Gij.data.zeros;
      Gij.data.Poles = Gij.data.poles;
      
      Gij.data.digits = digs;
      Gij.data.idx = [i j];
      
      Gij.data.psiw = psiw;

      Gij = CancelG(o,Gij);         % set cancel epsilon
      Gij = data(Gij,'brewed','CalcGij as Zpk');

      if control(o,'verbose') >= 2
         fprintf('G%g%g(s):\n',i,j)
         display(Gij);
      end

         % set name, store modal parameters in data and set 
         % green color option (indicating free system TRF)

      Gij = set(Gij,'name',sprintf('G%g%g(s)',i,j));
      Gij = opt(Gij,'color','g');
   end
end

function oo = Trf(o)                   % Double Transfer Matrix        
   progress(o,'Brewing Double Transfer Matrix ...');
   
   trftype = opt(o,{'trf.type','strf'});
   ctbox = opt(o,{'select.controltoolbox',0});
   
   switch trftype
      case 'modal'
         oo = TrfModal(o);
      case 'strf'
         oo = TrfDouble(o);
      case 'szpk'
         if (ctbox)
            oo = TrfCtbox(o);
         else
            oo = TrfZpk(o);
         end
      otherwise
         error('bad selection');
   end
      
      % unconditional hard refresh of cache
      
   cache(oo,oo);                       % hard refresh cache
   progress(o);                        % progress complete
end
function oo = TrfDouble(o)             % Double Transfer Matrix        
   oo = brew(o,'System');              % brew system matrices
   
      % get a1,a0 and M
      
   [A11,A12,A21,A22,B2,C1,D] = var(oo,'A11,A12,A21,A22,B2,C1,D');
   a0 = -diag(A21);
   a1 = -diag(A22);
   I = eye(length(a0));  Z = zeros(length(a0));
   
   if ~isequal(B2,C1')
      error('B2 does not match C1');
   end
   M = B2;
   
      % now since we have a1,a0 and M we can start calculating the transfer
      % matrix
   
   n = length(a0);
   m = size(M,2);
   G = matrix(corasim);
   psi = [1+0*a1(:) a1(:) a0(:)];
   W = [];
   
      % depending on modal form ...
     
   if HasModalForm(o)
      Modal(o);  
   else
      Normal(o);
   end
         
   progress(o);                        % complete!
   oo = cache(oo,'trf.G',G);           % store in cache
   oo = cache(oo,'trf.W',W);           % store in cache
   oo = cache(oo,'trf.psi',psi);       % store in cache
       
   if control(o,'verbose') > 0
      fprintf('Double Transfer Matrix\n');
      display(G);
   end
   
   function ok = HasModalForm(o)       % Has System a Modal Form       
      ok = isequal(A11,Z) && isequal(A12,I) && ...
              isequal(A21,-diag(a0)) && isequal(A22,-diag(a1));
   end
   function Modal(o)                   % Gij(s) For Modal Forms        
      for (i=1:m)
         for (j=1:i)
            run = (j-1)*n+i; mm = n*(n+1)/2;
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,mm,i,j);
            progress(o,msg,(run-1)/m*100);

               % calculate Gij

            mi = M(:,i)';  mj = M(:,j);
            wij = (mi(:).*mj(:))';        % weight vector
            W{i,j} = wij;                 % store as matrix element
            W{j,i} = wij;                 % symmetric matrix

            Gij = system(G,{[0],[1]});    % init Gij
            Gij = CancelG(o,Gij);         % set cancel epsilon
            
            for (k=1:n)
%              Gk = trf(O,mi(k)*mj(k),psi(k,:));
%              Gk = system(G,{wij(k),psi(k,:)});
               Gk = trf(G,wij(k),psi(k,:));
               Gij = Gij + Gk;
            end

            if control(o,'verbose') > 0
               fprintf('G%g%g(s):\n',i,j)
               display(Gij);
            end

            if isequal(opt(o,{'trf.type','strf'}),'szpk')
               Gij = zpk(Gij);            % convert to ZPK
            end

               % set name, store modal parameters in data and set 
               % green color option (indicating free system TRF)
               
            Gij = set(Gij,'name',sprintf('G%g%g(s)',i,j));
            Gij.data.psiw = [psi,wij(:)];
            Gij = opt(Gij,'color','g');

            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
      end
      
         % characteristic transfer functions
         
      Gpsi = set(matrix(corasim),'name','Gpsi[s]');
      for (k=1:size(psi,1))
         Gk = trf(Gpsi,1,psi(k,:));
         Gk = set(Gk,'name',sprintf('G_%g(s)',k));
         Gpsi = poke(Gpsi,Gk,k,1);
      end
      oo = cache(oo,'trf.Gpsi',Gpsi);  
   end
   function Normal(o)                  % Normal Gij(s) Calculation     
      %[AA,BB,CC,DD] = data(oo,'A,B,C,D');
      [AA,BB,CC,DD] = var(oo,'A,B,C,D');
       sys = system(corasim,AA,BB,CC,DD);
      
      for (i=1:n)
         for (j=1:i)
            run = (j-1)*n+i; m = n*(n+1)/2;
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,m,i,j);
            progress(o,msg,(run-1)/m*100);

               % calculate Gij

            [num,den] = peek(sys,i,j);
%           Gij = trf(O,num,den);         % Gij(s)
            Gij = system(G,{num,den});    % Gij(s)
            Gij = can(CancelG(o,Gij));
            
            fprintf('G%g%g(s):\n',i,j)
            display(Gij);

            Gij = set(Gij,'name',sprintf('G%g%g',i,j));
            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
      end
   end
end
function oo = TrfZpk(o)                % Zpk Based Transfer Matrix     
   oo = brew(o,'System');              % brew system matrices
        
   [G,W,psi] = Modal(oo);
         
   progress(o);                        % complete!
   oo = cache(oo,'trf.G',G);           % store in cache
   oo = cache(oo,'trf.W',W);           % store in cache
   oo = cache(oo,'trf.psi',psi);       % store in cache
       
   if (control(o,'verbose') >= 2)
      fprintf('Double Transfer Matrix\n');
      display(G);
   end
   
   function [G,W,psi] = Modal(o)       % Gij(s) For Modal Forms                    
      W = [];                          % init
      G = matrix(corasim);             % init
      
      B = var(o,'B');
      m = size(B,2);
      
      if (m > 3)
         fprintf('*** warning: calculating G(s) for multi contact\n');
         m = 3;
      end
      
      run = 0;
      for (i=1:m)
         for (j=1:i)
            run = run+1; mm = m*(m+1)/2;
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,mm,i,j);
            progress(o,msg,run/mm*100);

               % calculate Gij

            Gij = CalcGij(o,i,j);
            psi = Gij.data.psiw(:,1:3);
            wij = Gij.data.psiw(:,4)';
            W{i,j} = wij;                 % store as matrix element
            W{j,i} = wij;                 % symmetric matrix
            
            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
      end
      
      G.data.digits = Gij.data.digits;
      G = data(G,'brewed','TrfZpk');
      
         % characteristic transfer functions
         
      Gpsi = set(matrix(corasim),'name','Gpsi[s]');
      for (k=1:size(psi,1))
         Gk = trf(Gpsi,1,psi(k,:));
         Gk = set(Gk,'name',sprintf('G_%g(s)',k));
         Gpsi = poke(Gpsi,Gk,k,1);
      end
      oo = cache(oo,'trf.Gpsi',Gpsi);  
   end
   function OldModal(o)                % Old Gij(s) For Modal Forms    
      digs = opt(o,{'precision.G',0});
M=[]; B=[];C=[];  % make compiler happy      
      run = 0;
      for (i=1:m)
         for (j=1:i)
            run = run+1; mm = m*(m+1)/2;
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,mm,i,j);
            progress(o,msg,run/mm*100);

               % calculate Gij

            mi = M(:,i)';  mj = M(:,j);
 
            sys = system(corasim,A,B(:,j),C(i,:),D(i,j));
            if (digs == 0)
               wij = (mi(:).*mj(:))';     % weight vector
               psiw = [psi,wij(:)];

               Gij = zpk(sys);
            else
               sys = vpa(sys,digs);
               old = digits(digs);
               
               mi = vpa(mi,digs);
               mj = vpa(mj,digs);
               psi = vpa(psi,digs);
               wij = (mi(:).*mj(:))';     % weight vector
               psiw = [psi,wij(:)];
               
               Gij = zpk(sys);
               digits(old);
            end
 
            W{i,j} = wij;                 % store as matrix element
            W{j,i} = wij;                 % symmetric matrix
            
            Gij.data.digits = digs;
            Gij.data.idx = [i j];
            Gij = CancelG(o,Gij);         % set cancel epsilon
            Gij = data(Gij,'brewed','TrfZpk');
            
            if control(o,'verbose') >= 2
               fprintf('G%g%g(s):\n',i,j)
               display(Gij);
            end

               % set name, store modal parameters in data and set 
               % green color option (indicating free system TRF)
               
            Gij = set(Gij,'name',sprintf('G%g%g(s)',i,j));
            Gij.data.psiw = psiw;
            Gij = opt(Gij,'color','g');

            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
      end
      
      G.data.digits = digs;
      G = data(G,'brewed','TrfZpk');
      
         % characteristic transfer functions
         
      Gpsi = set(matrix(corasim),'name','Gpsi[s]');
      for (k=1:size(psi,1))
         Gk = trf(Gpsi,1,psi(k,:));
         Gk = set(Gk,'name',sprintf('G_%g(s)',k));
         Gpsi = poke(Gpsi,Gk,k,1);
      end
      oo = cache(oo,'trf.Gpsi',Gpsi);  
   end
end
function oo = TrfCtbox(o)              % Control Toolbox Trf. Matrix   
   oo = brew(o,'System');              % brew system matrices
   
      % get a1,a0 and M
      
   [A,B1,B2,C1,C2,A11,A12,A21,A22] = var(oo,'A,B1,B2,C1,C2,A11,A12,A21,A22');
   B = [B1;B2];  C = [C1,C2];  D = 0*C*B;
   a0 = -diag(A21);
   a1 = -diag(A22);
   I = eye(length(a0));  Z = zeros(length(a0));
   
   if ~isequal(B2,C1')
      error('B2 does not match C1');
   end
   M = B2;
   
      % now since we have a1,a0 and M we can start calculating the transfer
      % matrix
   
   n = length(a0);
   m = size(M,2);
   G = matrix(corasim);
   psi = [1+0*a1(:) a1(:) a0(:)];
   W = [];
   
      % depending on modal form ...
     
   Modal(o);
         
   progress(o);                        % complete!
   oo = cache(oo,'trf.G',G);           % store in cache
   oo = cache(oo,'trf.W',W);           % store in cache
   oo = cache(oo,'trf.psi',psi);       % store in cache
       
   if (control(o,'verbose') >= 2)
      fprintf('Double Transfer Matrix\n');
      display(G);
   end
   
   function Modal(o)                   % Gij(s) For Modal Forms        
      digs = opt(o,{'precision.G',0});
      if (digs == 0)
         sys = ss(A,B,C,D);
         Gs = zpk(sys);                % from control toolbox
      else
         sys = ss(vpa(A,digs),vpa(B,digs),vpa(C,digs),vpa(D,digs));
         old = digits(digs);
         Gs = zpk(sys);                % from control toolbox
         digits(old);
      end
      
      [z,p,k] = zpkdata(Gs);
      
      for (i=1:m)
         for (j=1:i)
            run = (j-1)*n+i; mm = n*(n+1)/2;
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,mm,i,j);
            progress(o,msg,(run-1)/m*100);

               % calculate Gij

            mi = M(:,i)';  mj = M(:,j);
            wij = (mi(:).*mj(:))';     % weight vector
            W{i,j} = wij;              % store as matrix element
            W{j,i} = wij;              % symmetric matrix

            Gij = zpk(G,z{i,j},p{i,j},k(i,j));
            
            Gij = CancelG(o,Gij);      % set cancel epsilon
            
            Gij = data(Gij,'idx',[i j]);
            Gij = data(Gij,'digits',digs);
            Gij = data(Gij,'brewed','TrfCtbox');
            
            if control(o,'verbose') >= 2
               fprintf('G%g%g(s):\n',i,j)
               display(Gij);
            end

               % set name, store modal parameters in data and set 
               % green color option (indicating free system TRF)
               
            Gij = set(Gij,'name',sprintf('G%g%g(s)',i,j));
            Gij.data.psiw = [psi,wij(:)];
            Gij = opt(Gij,'color','g');

            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
      end
     
      G = data(G,'brewed','TrfCtbox');
      G = data(G,'digits',digs);
      
         % characteristic transfer functions
         
      Gpsi = set(matrix(corasim),'name','Gpsi[s]');
      for (k=1:size(psi,1))
         Gk = trf(Gpsi,1,psi(k,:));
         Gk = set(Gk,'name',sprintf('G_%g(s)',k));
         Gpsi = poke(Gpsi,Gk,k,1);
      end
      oo = cache(oo,'trf.Gpsi',Gpsi);  
   end
end
function oo = TrfModal(o)              % Modal Tranfer Matrix          
   oo = brew(o,'System');              % brew system matrices
   
      % get a1,a0 and M
      
   [a0,a1,B,C,D] = var(oo,'a0,a1,B,C,D');

      % calculate weight matrix and transfer matrix in modal form
      
   W = [];                             % init W
   G = matrix(corasim);                % init G
   psi = [1+0*a1(:) a1(:) a0(:)];
   Modal(o);                           % calculate W and G in modal form
   Store(o);                           % store to cache
        
   if (control(o,{'verbose',0}) > 0)
      fprintf('Modal Transfer Matrix\n');
      display(G);
   end
   progress(o);                        % complete!
   
   function Modal(o)                   % Gij(s) For Modal Forms        
      n = length(a0);
      m = size(B,2);                   % number of inputs
      l = size(C,1);                   % number of outputs

      for (i=1:l)
         for (j=1:m)
            run = (i-1)*m+j; 
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,m*l,i,j);
            progress(o,msg,(run-1)/(m*l)*100);

               % calculate wij

            ci = C(i,1:n)';  bj = B(n+1:2*n,j);  
            wij = ci.*bj;                 % weight vector
            W{i,j} = wij;                 % store as matrix element

               % calculate Gij
               
            Gij = modal(corasim,a0,a1,B(:,j),C(i,:),D(i,j));
            Gij = data(Gij,'w',wij);
            Gij = set(Gij,'name',sprintf('G%g%g(s)',i,j));

            if (control(o,{'verbose',0}) > 0)
               fprintf('G%g%g(s):\n',i,j)
               display(trf(Gij));
            end

            G = poke(G,Gij,i,j);          % lower half diagonal element
         end
      end
   end
   function Store(o)                   % Store to Cache                
      
         % provide mode transfer matrices

      n = length(a0);
      for (k=1:n)
         psik = [1 a1(k) a0(k)];
         Gk = trf(G,1,psik);
         sym = sprintf('G_%g',k);
         oo = cache(oo,['trf.',sym],Gk);
      end

         % store G and W in cache

      oo = cache(oo,'trf.G',G);           % store in cache
      oo = cache(oo,'trf.W',W);           % store in cache
      oo = cache(oo,'trf.psi',psi);       % store in cache

         % store all transfer matrix elements into cache

      [l,m] = size(G);
      for (i=1:l)
         for (j=1:m)
            Gij = peek(G,i,j);
            sym = sprintf('G%g%g',i,j);
            oo = cache(oo,['trf.',sym],Gij);
         end
      end
   end
end

%==========================================================================
% Principal Transfer Functions P(s), Q(s) and P(s)/Q(s)
%==========================================================================

function oo = Principal(o)             % Calculate P(s) and Q(s)       
%
% PRINCIPAL  Brew 'principal' cache segment. Calculate the two important
%            transfer functions P(s) and Q(s) with 
%
%               P(s) := G31(s), Q(s) := G33(s)
%
%            oo = Principal(o)
%            G31  = cache(oo,'principal.G31')  % G31(s)
%            G33  = cache(oo,'principal.G33')  % G33(s)
%            P  = cache(oo,'principal.P')      % P(s)
%            Q  = cache(oo,'principal.Q')      % Q(s)
%            L0 = cache(oo,'principal.L0')     % L0(s) := P(s)/Q(s)
%
   progress(o,'Brewing Principal Transfer Functions ...');
   oo = brew(o,'System');              % brew system matrices
   
      % get a1,a0 and M
      
   [A11,A12,A21,A22,B2,C1,B,C,D] = var(oo,'A11,A12,A21,A22,B2,C1,B,C,D');
   a0 = -diag(A21);
   a1 = -diag(A22);
   I = eye(length(a0));  Z = zeros(length(a0));
   
   if ~isequal(B2,C1')
      %error('B2 does not match C1');
      fprintf('*** warning: B2 does not match C1\n');
   end
%  M = B2;
   
      % fetch G31 and G33 from cache or calculate
      
   [G31,G33] = G31G33(oo);
   
      % now since we have a1,a0 and M we can start calculating the transfer
      % matrix
   
   n = length(a0);
   m = size(B2,2);

   if HasModalForm(o)
      trftype = opt(o,{'trf.type','szpk'});
      if isequal(trftype,'szpk');
         [P,Q] = ZpkPQ(o); 
      else
         error('implementation restriction');
         [P,Q] = ModalTrfPQ(o); 
      end
   else
      [P,Q] = NormalPQ(o);
   end

   [P,Q,F0] = Normalize(oo,P,Q);       % calc normalized P(s)/Q(s)
   
   F0 = set(F0,'name','F0(s)');        % normalizing transfer function
   P = set(P,'name','P(s)');           % normalized P(s)
   Q = set(Q,'name','Q(s)');           % normalized Q(s)

      % calculate open loop transfer function
      
   L0 = CalcL0(o,G31,G33);
      
      % set expression based FQR, if enabled
      
   oo = FqrExpressions(oo);
   
      % store all stuff in cache
      
   oo = o;
   oo = cache(oo,'principal.G31',G31);
   oo = cache(oo,'principal.G33',G33);
   oo = cache(oo,'principal.F0',F0);
   oo = cache(oo,'principal.P',P);
   oo = cache(oo,'principal.Q',Q);
   oo = cache(oo,'principal.L0',L0);
   
      % unconditional hard refresh of cache
   
   cache(oo,oo);                       % hard refresh cache
   progress(o);                        % progress complete

      % done
      
   function [G31,G33] = G31G33(o)
      trf = work(o,'cache.trf');
      if isempty(trf)
         progress(o,'calculating G31(s) ...');
         G31 = CalcGij(o,3,1);
         progress(o,'calculating G33(s) ...');
         G33 = CalcGij(o,3,3);
      else
         G = cache(o,'trf.G');
         G31 = peek(G,3,1);
         G33 = peek(G,3,3);
      end
   end
   function ok = HasModalForm(o)       % Has System a Modal Form       
      ok = isequal(A11,Z) && isequal(A12,I) && ...
              isequal(A21,-diag(a0)) && isequal(A22,-diag(a1));
   end
   function [P,Q] = ModalTrfPQ(o)      % P(s)/Q(s) For Modal Forms     
      psi = [ones(n,1) a1(:) a0(:)];
      
      for (i=1:m)
         for (j=1:i)
               % calculate Gij

            if ~((i==3 && j==1) || (i==3 && j==3))
               continue
            end
            
%           mi = M(:,i)';  mj = M(:,j);
            mi = C1(i,:);  mj = B2(:,j);
            wij = (mi(:).*mj(:))';        % weight vector
            W{i,j} = wij;                 % store as matrix element
            W{j,i} = wij;                 % symmetric matrix

            Gij = trf(corasim,0);         % init Gij
            Gij = CancelG(o,Gij);         % set cancel epsilon
            Gij = set(Gij,'name',o.iif(j==1,'P(s)','Q(s)'));
            
               % also store modal representation in data
               
            Gij.data.psiw = [psi,wij(:)];
            
            for (k=1:n)
               if (n >= 50)
                  txt = sprintf('%d of %d: calculating G%d%d',k,n,i,j);
                  progress(o,txt,k/n*100);
               end
               
               Gk = trf(Gij,wij(k),psi(k,:));
               Gij = Gij + Gk;
            end

            if isequal(opt(o,{'trf.type','strf'}),'szpk')
               Gij = zpk(Gij);            % convert to ZPK
            end
            
            if control(o,'verbose') > 0
               fprintf('%s',get(Gij,'name'),i,j);
               display(Gij);
            end

               % assign to either P(s) or Q(s)

            if (j==1)
               P = Gij;                % P(s) = G31(s)
            else
               Q = Gij;                % Q(s) = G33(s)
            end
         end
         progress(o);                  % progress complete
      end
   end
   function [P,Q] = ZpkPQ(o)           % P(s)/Q(s) For Zpk Forms       
      %[G31,G33] = cook(o,'G31,G33');
      P = set(G31,'name','P(s)');
      Q = set(G33,'name','Q(s)');
   end
   function [P,Q] = ModalZpkPQ(o)      % P(s)/Q(s) For Modal Forms     
      psi = [ones(n,1) a1(:) a0(:)];

      for (i=1:m)
         for (j=1:i)
               % calculate Gij

            if ~((i==3 && j==1) || (i==3 && j==3))
               continue
            end
            
%           mi = M(:,i)';  mj = M(:,j);
            mi = C1(i,:);  mj = B2(:,j);
            wij = (mi(:).*mj(:))';        % weight vector
            W{i,j} = wij;                 % store as matrix element
            W{j,i} = wij;                 % symmetric matrix

%           Gij = trf(corasim,0);         % init Gij
            Gij = zpk(corasim,[],[],0);   % init Gij
            Gij = CancelG(o,Gij);         % set cancel epsilon
            Gij = set(Gij,'name',o.iif(j==1,'P(s)','Q(s)'));
            
            for (k=1:n)
               if (n >= 50)
                  txt = sprintf('%d of %d: calculating G%d%d',k,n,i,j);
                  progress(o,txt,k/n*100);
               end
               poles = roots(psi(k,:));
%              Gk = trf(Gij,wij(k),psi(k,:));
               Gk = zpk(Gij,[],poles,wij(k));
               Gij = Gij + Gk;
            end

            %if isequal(opt(o,{'trf.type','strf'}),'szpk')
            %   Gij = zpk(Gij);            % convert to ZPK
            %end
            
            if control(o,'verbose') > 0
               fprintf('%s',get(Gij,'name'),i,j);
               display(Gij);
            end

               % assign to either P(s) or Q(s)

            if (j==1)
               P = Gij;                % P(s) = G31(s)
            else
               Q = Gij;                % Q(s) = G33(s)
            end
         end
         progress(o);                  % progress complete
      end
   end
   function [P,Q] = NormalPQ(o)        % P(s)/Q(s) Normal Calculation  
      [AA,BB,CC,DD] = var(oo,'A,B,C,D');
      sys = system(corasim,AA,BB,CC,DD);
      
      for (i=1:n)
         for (j=1:i)
            run = (j-1)*n+i; m = n*(n+1)/2;
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,m,i,j);
            progress(o,msg,(run-1)/m*100);

               % calculate Gij

            [num,den] = peek(sys,i,j);
            Gij = system(G,{num,den});    % Gij(s)
            Gij = can(CancelG(o,Gij));
            Gij = set(Gij,'name',o.iif(j==1,'P(s)','Q(s)'));
            
            if control(o,'verbose') > 0
               fprintf('%s:\n',get(Gij,'name'),i,j)
               display(Gij);
            end

               % assign to either P(s) or Q(s)
               
            if (j==1)
               P = Gij;                % P(s) = G31(s)
            else
               Q = Gij;                % Q(s) = G33(s)
            end
         end
      end
   end
   function [P,Q,F0] = Normalize(o,P,Q)% Normalize P(s) and Q(s)       
%     V0 = fqr(Q,0);                   % gain of Q
      V0 = gain(Q);                    % gain of Q

         % calculate normalizing factor F0(s)

      if (V0 == 0)
         F0 = zpk(Q,[],[],1);
      else
         if type(Q,{'szpk'})
            Vinf = Q.data.K/V0;
         else
            [num,den] = peek(Q/V0);
            Vinf = num(1)/den(1);
         end
         om0 = sqrt(abs(Vinf));
         F0 = (1/lf(Q,om0)/lf(Q,om0)) * V0;   % normalizing factor
      end
      F0 = set(F0,'name','F0(s)');

         % calculate normalized principal transfer matrices

      P = P/F0;
      Q = Q/F0;
   end
   function L0 = CalcL0(o,G31,G33)     % Calc L0(s)                    
   %
   % CALCL0    Calculate L0(s) = P(s)/Q(s)
   %
      if ~type(G31,{'szpk'}) || ~type(G33,{'szpk'})
         error('cannot continue');
      end
      
      progress(o,'calculating L0(s) ...');
      L0 = G31;                        % zeros of L0(s) are zeros of G31(s)
      assert(all(G31.data.Poles==G33.data.Poles));
      
         % take over uncanceled Zeros!
         
      L0.data = [];
      L0.data.zeros = G31.data.Zeros;
      L0.data.poles = G33.data.Zeros;
      L0.data.K = G31.data.K / G33.data.K;
      L0.data.T = 0;
      L0.data.digits = data(G31,'digits');
      L0.data.brewed = data(G31,'brewed');
      L0.data.V0 = gain(G31)/gain(G33);
      
         % set name and store L(s) in 'loop' cache segment

      L0 = set(L0,'name','L0(s) = P(s)/Q(s)');

         % feasibility check and potential repair
         
      [z,p,K] = zpk(L0);
      if any(real(p) >= 0)
         fprintf(['*** warning: L0(s) seeming instable',...
                  ' => searching cancelation ...\n']); 
return
         eps = opt(o,{'cancel.L.eps',1e-7});
         epsi = logspace(log10(min(eps,0.1)),0,25);

         for(i=1:length(epsi))
            L0 = opt(L0,'eps',epsi(i));
            L0 = can(L0);
            [z,p,K] = zpk(L0);
            
            if all(real(p) < 0)
               fprintf('*** L0(s) cancel epsilon: %g\n',epsi(i));
               break;
            end
         end
      end
   end
   function L0 = OldCalcL0(o,P,Q)         % Calc L0(s)                    
   %
   % CALCL0    Calculate L0(s) = P(s)/Q(s)
   %
      P = CancelL(o,P);                   % set cancel epsilon
%     P = CancelG(o,P);                   % set cancel epsilon
      Q = CancelL(o,Q);                   % set cancel epsilon

      progress(o,'calculating L0(s) ...');
      L0 = P/Q;

      [z,p,K] = zpk(L0);
      if any(real(p) >= 0)
         fprintf(['*** warning: L0(s) seeming instable',...
                  ' => searching cancelation ...\n']); 

         eps = opt(o,{'cancel.L.eps',1e-7});
         epsi = logspace(log10(min(eps,0.1)),0,25);

         for(i=1:length(epsi))
            L0 = opt(L0,'eps',epsi(i));
            L0 = can(L0);
            if all(real(p) < 0)
               fprintf('*** L0(s) cancel epsilon: %g\n',epsi(i));
               break;
            end
         end
      end

         % set name and store L(s) in 'loop' cache segment

      L0 = set(L0,'name','L0(s) = P(s)/Q(s)');
   end
   function o = FqrExpressions(o)      % Set FQR Expressions           
      if ~isequal(opt(o,'select.fqr'),'expression')
         return                        % done if not enabled
      end
      
         % construct system in modal form
         
      sys = modal(corasim,a0,a1,B,C,D);% system in modal form
      
      P = data(P,'fqr',{'/' {'modal' sys 3 1} F0});
      Q = data(Q,'fqr',{'/' {'modal' sys 3 3} F0});
      L0 = data(L0,'fqr',{'/',P,Q})
   end
end

%==========================================================================
% Stability
%==========================================================================

function oo = Stability(o)             % Brew Stability Cache Segment  

end

%==========================================================================
% Inverse System [Ai,Bi,Ci,Di]
%==========================================================================

function oo = OldInverse(o)            % Brew Inverse Cache Segment    
%
% INVERSE  Calculate inverse system, i.e., find a state space
%          representation for inv(Q(s))
%
%    Theory/Part 1: Single Mode Transfer Function
%
%    - consider the modal differential equations of a single mode
%
%         x`= v
%         v`= -a0*x - a1*v + b0*u
%         y = c0*x
%
%    - Laplace transform
%
%         s*x = v   =>  x = v/s
%         s*v = -a0*x - a1*v + b0*u   |*s
%         y = c0*x
%     
%         s^2*v = a0*(s*x) + a1*s*v + b0*s*u    (remember: (s*x) = v
%         (s^2 + a1*s + a0)*v = b0*s*u
%         y = c0*v/s = c0/s * v
%
%    - Introduce psi(s) := s^2 + a1*s + a0
%
%         v = psi(s)\b0*s*u
%         y = c0/s * psi(s)\b0*s*u = (c0*b0)/psi(s) * u
%
%    - transfer function of a single mode
%
%         y(s) = G0(s) * u(s)
%
%                      b0*c0          b0*c0
%      with  G0(s) = --------- = -----------------                   (1)
%                      psi(s)     s^2 + a1*s + a0
%
%    Theory/Part 2: Invertible  Transfer Function of a Single Mode
%
%    - G0(s) is strictly proper, thus not invertible. We want extend G0(s)
%      by a factor K0*(s + w0)^2 such that the result
%
%         Q0(s) := G0(s) * K0*(s + w0)^2
%
%                    K0*b0*c0 * (s + w0)^2
%         Q0(s) = ---------------------------                        (2)
%                       s^2 + a1*s + a0
%
%      is invertible. Since K0 and w0 are parameters which can be chosen
%      freely we want to choose K0 and w0 to achieve
%
%         Q0(0) = 1,  Q0(inf) = 1                                    (3)
%
%      Consulting (2) we see
%
%         Q0(inf) = 1 = K0*b0*c0/1      =>  K0 = 1/(b0*c0)
%         Q0(0) = 1 = K0*b0*c0*w0^2/a0 = w0^2/a0  =>  w0 = sqrt(a0)
%
%    - this we get
%
%                    (s + w0)^2
%         Q0(s) = -----------------                                  (4)
%                  s^2 + a1*s + a0
%
%    - Try the following state space representation for Q0(s) and see how
%      the parameters have to be chosen to fulfill (2)
%
%         x`= v                                                      (5a)
%         v`= -a0*x - a1*v + u                                       (5b)
%         y = c1*x  + c2*v + d*u                                     (5c)
%
%    - Laplace transform
%
%         s*x = v   =>  x = v/s
%         s*v = -a0*x - a1*v + u   |*s
%         y = c1*x + c2*v + d*u 
%     
%         s^2*v = a0*(s*x) + a1*s*v + s*u    (remember: (s*x) = v
%         (s^2 + a1*s + a0)*v = s*u  => v = s/psi(s) * u
%         y = c1/s*v + c2*v + d*u = 1/s*(c1+c2*s)*v + d*u
%         
%         y = 1/s * (c1 + c2*s) * s/psi(s)*u + d*u              
%         y = [(c1 + c2*s)/psi(s) + d] * u
%
%         y(s) = Q(s) * u(s)
%
%                     c2*s + c1             c2*s + c1
%      with  Q(s) = ------------- + d = ----------------- + d
%                       psi(s)           s^2 + a1*s + a0
%
%         c1 + c2*s + d*(s^2 + a1*s + a0) =
%               = d*s^2 + (c2 + d*a1)*s + (c1 + d*a0)
%
%                    d*s^2 + (c2 + d*a1)*s + (c1 + d*a0)
%            Q(s) = -----------------------------------------        (6)
%                              s^2 + a1*s + a0
%
%    - by comparison with (2) we see that the denominators of (4) and (6) 
%      are already matching so we only have to match the numerators
%
%         d*s^2 + (c2 + d*a1)*s + (c1 + d*a0) = s^2 + 2*w0*s + w0^2
%
%      which means
%
%      (i)    d = 1                                                  (7a)
%      (ii)   c2 + d*a1 = 2*w0  =>  c2 = 2*w0 - a1                   (7b)
%      (iii)  c1 + d*a0 = w0^2  =>  c1 = w0^2 - a0                   (7c)
%            
%    - Conclusion: By choice of c1,c2 and accoding to (7a,7b,7c) we can
%      find a state space representation (5a,5b,5c) for the principal
%      transfer function (4) which is invertible.
%     
   assert(0);
end

%==========================================================================
% Constrained Transfer Matrix H(s)
%==========================================================================

function oo = Constrain(o)             % Brew Constrain Cache Segment  
   oo = Consd(o);                      % delegate
end
function oo = Consd(o)                 % Double Costrained Trf. Matrix 
   progress(o,'Brewing Double Constrained Transfer Matrix ...');
   oo = ConstrainedDouble(o);          % brew H(s) matrix
   oo = OpenLoop(oo);                  % brew L(s) matrix
   
     % make cache segment as variables available
     
   [oo,bag,rfr] = cache(oo,'consd');   % get bag of cached variables
   tags = fields(bag);
   for (i=1:length(tags))
      tag = tags{i};
      oo = var(oo,tag,bag.(tag));      % copy cached variable to variables
   end
   
      % unconditional hard refresh of cache
   
   cache(oo,oo);                       % hard refresh cache
   progress(o);                        % progress complete
end
function oo = ConstrainedDouble(o)     % Double Constrained Trf Matrix 
   oo = o;

      % fetch free system transfer matrices
            
   [G11,G12,G13] = cook(oo,'G11,G12,G13');
   [G21,G22,G23] = cook(oo,'G21,G22,G23');
   [G31,G32,G33] = cook(oo,'G31,G32,G33');
   
      % calculate H31(s), H32(s), H33(s)

   H33 = CancelH(o,inv(G33));
   H31 = CancelH(o,(-1)*H33*G31);
   H32 = CancelH(o,(-1)*H33*G32);

      % build Hdn(s) = [H13(s); H23(s)]

   H13 = CancelH(o,G13*H33);
   H23 = CancelH(o,G23*H33);
      
      % build Hdd(s) = [H11(s) H12(s); H21(s) H22(s)]

   H11 = CancelH(o,G11 - G13*G31*H33);
   H12 = CancelH(o,G12 - G13*G32*H33);
   H21 = CancelH(o,G21 - G23*G31*H33);
   H22 = CancelH(o,G22 - G23*G32*H33);
         
      % store all constrained transfer functions in constrained trf matrix
      % i.e. build H(s) = [Hdd(s) Hdn(s); Hnd(s) Hnn(s)]
      
   H = matrix(corasim);
   H = set(H,'name','H');

   H = poke(H,set(H11,'name','H11(s)'),1,1);
   H = poke(H,set(H12,'name','H12(s)'),1,2);
   H = poke(H,set(H13,'name','H13(s)'),1,3);
   
   H = poke(H,set(H21,'name','H21(s)'),2,1);
   H = poke(H,set(H22,'name','H22(s)'),2,2);
   H = poke(H,set(H23,'name','H23(s)'),2,3);
   
   H = poke(H,set(H31,'name','H31(s)'),3,1);
   H = poke(H,set(H32,'name','H32(s)'),3,2);
   H = poke(H,set(H33,'name','H33(s)'),3,3);
   
      % store H in cache
      
   oo = cache(oo,'consd.H',H);
end

%==========================================================================
% Loop Analysis Stuff
%==========================================================================

function oo = Loop(o)                  % Loop Analysis Stuff           
   progress(o,'Brewing Open Loop Transfer Function ...');
   mu = opt(o,{'process.mu',0.1});     % friction coefficient
      
   L0 = cook(o,'L0');
   Lmu = mu * L0;                      % Loop TRF under friction mu
   Lmu = set(Lmu,'name','Lmu(s)');
   
      % calc critical K and closed loop TRF
      
   cidx = opt(o,{'process.contact',0});
   o = with(o,'stability');
   algo = opt(o,{'algo','ss'});
   
   if (cidx < inf && isequal(algo,'trf'))
%     [K0,f0] = stable(o,L0);          % critical gain & frequency
      [K0,f0] = cook(o,'K0,f0');
   else
      Sys0 = cook(o,'Sys0');
      o = opt(o,'contact',cidx);
%     [K0,f0] = stable(o,Sys0,1);      % critical gain & frequency
      [K0,f0] = cook(o,'K0,f0');
   end
      
   L0 = CancelT(o,L0);                 % set cancel epsilon for T(s)
   if ~isinf(K0)
      S0 = 1/(1+K0*L0);                % closed loop sensitivity
      if type(L0,{'szpk'})
         S0 = zpk(S0);
      end
      T0 = S0*K0*L0;                   % total TRF
   else                                % use K0 = 1 instead
      S0 = 1/(1+L0);                   % closed loop sensitivity
      T0 = S0*L0;                      % total TRF
   end
   
   S0 = set(S0,'name','S0(s)');
   T0 = set(T0,'name','T0(s)');
   
      % store in cache
   
   %[oo,bag,rfr] = cache(o,'loop');    % refresh principal cache segment
   oo = o;
   oo = cache(oo,'loop.Lmu',Lmu);

%  oo = cache(oo,'loop.K0',K0);        % critical gain
%  oo = cache(oo,'loop.f0',f0);        % critical frequency

   oo = cache(oo,'loop.S0',S0);
   oo = cache(oo,'loop.T0',T0);
      
      % unconditional hard refresh of cache
   
   cache(oo,oo);                       % hard refresh cache
   progress(o);                        % progress complete
end

%==========================================================================
% Open Loop L(s)
%==========================================================================

function oo = OpenLoop(o)              % Open Loop Linear System       
   [oo,bag,rfr] = cache(o,o,'consd');
   
   H = cache(oo,'consd.H');
   H31 = peek(H,3,1);
   H32 = peek(H,3,2);
      
   L1 = CancelL(o,H31);
   L2 = CancelL(o,H32);
   
      % assemble L(s) matrix
      
   L = matrix(corasim);
   L = set(L,'name','L[s]');
   
   L = poke(L,set(L1,'name','L1'),1,1);
   L = poke(L,set(L2,'name','L2'),1,2);

      % store L in cache
      
   oo = cache(oo,'consd.L',L);
end

%==========================================================================
% Closed Loop T(s)
%==========================================================================

function oo = Process(o)               % Brew Process Segment          
   progress(o,'Brewing Closed Loop Transfer Function ...');
   oo = ClosedLoop(o);
      
      % unconditional hard refresh of cache
      
   cache(oo,oo);                       % hard refresh cache
   progress(o);                        % progress complete
end
function oo = ClosedLoop(o)            % Closed Loop Linear System     
   mu = opt(o,{'process.mu',0.1});     % friction coefficient
   s = system(corasim,{[1 0],[1]});    % differentiation trf
   s = CancelT(o,s);   

   oo = o;                             % open loop incorporating mu
   oo = Force(oo,mu);                  % calc force trf
   oo = Elongation(oo);                % calc elongation trf
   oo = Velocity(oo);                  % calc velocity trf
   oo = Acceleration(oo);              % calc acceleration trf
   
   function oo = Force(o,mu)           % Calc Force Transfer Function  
   %
   % These are the force transfer functions from Fc(s) to Fi(s):
   % Let Mu = [mu1,mu2]' = mu*[1 0]', then
   %
   %    Tf(s) = [Tf1(s),Tf2(s)]' = (I-Mu*[-G31(s),-G32(s)]/G33(s)) \ Mu
   %
   % means:
   %
   %    [ Tf1(s) ]   ([1    0]   [mu1]                       )   [mu1]
   %    [        ] = ([      ] + [   ]*[G31(s) G32(s)]/G33(s)) \ [   ]
   %    [ Tf2(s) ]   ([0    1]   [mu2]                       )   [mu2]
   %
   % in the linearized case we have Mu = [mu 0'] which leads to
   %
   %    [ Tf1(s) ]   ([1    0]   [ mu ]                       )   [ mu ]
   %    [        ] = ([      ] + [    ]*[G31(s) G32(s)]/G33(s)) \ [    ]
   %    [ Tf2(s) ]   ([0    1]   [ 0  ]                       )   [ 0  ]
   %
   %    [ Tf1(s) ]   ([1    0]   [ mu*G31(s) mu*G32(s) ]       )   [ mu ]
   %    [        ] = ([      ] + [                     ]/G33(s)) \ [    ]
   %    [ Tf2(s) ]   ([0    1]   [   0            0    ]       )   [  0 ]
   %
   %    [ Tf1(s) ]      ([1+mu*G31(s)/G33(s)  1+mu*G32(s)/G33(s)])   [ mu ]
   %    [        ] = inv([                                      ]) * [    ]
   %    [ Tf2(s) ]      ([        0                     1       ])   [ 0  ]
   %
   %    [ Tf1(s) ]          1            [  1  -1-mu*G32(s)/G33(s)]   [mu ]
   %    [        ] = ----------------- * [                        ] * [   ]
   %    [ Tf2(s) ]   1+mu*G31(s)/G33(s)  [  0   1+mu*G31(s)/G32(s)]   [ 0 ]
   %
   % finally we get:
   %
   %    [ Tf1(s) ]           mu            [ 1 ]   [1/(1+mu*G31(s)/G33(s))]
   %    [        ] = ------------------- * [   ] = [                      ]
   %    [ Tf2(s) ]   1 + mu*G31(s)/G33(s)  [ 0 ]   [           0          ]
   %
   % now we can read out:
   %
   %    Tf1(s) = mu / (1 + mu*G31(s)/G33(s) )
   %    Tf2(s) = 0
   %
   % as we defined 
   %  
   %    L0(s) := mu * G31(s)/G33(s)
   %
   % we can also write
   %
   %    Tf(s) = T0(s) := mu / (1 + L0(s))
   %
      [G31,G32,G33,H31,L0] = cook(o,'G31,G32,G33,H31,L0');

         % first way to calculate: T0 = mu / (1 + L0(s))
         
      L0 = CancelT(o,L0);              % set cancel epsilon
      T0 = mu / (1 + mu*L0);
         
         % additionally we calculate Tf1(s) = mu / (1 + mu*G31(s)/G33(s))
         % or Tf1(s) = mu*G33(s) / (G33(s) + mu*G31(s)) 
         
      Tf1 = mu*G33 / (G33 + mu*G31);
      Tf2 = 0*Tf1;
      
         % make a cross check
         
      Terr = Tf1 - T0;
      dBerr = 20*log10(abs(fqr(Terr)));
      if max(dBerr) >= -200
         fprintf('*** warning: Tf1(s) - bad numerical conditions\n');
         %beep
      end

      Tf = set(matrix(corasim),'name','Tf[s]');
      Tf = poke(Tf,Tf1,1,1);
      Tf = poke(Tf,Tf2,2,1);

      oo = cache(o,'process.Tf',Tf);
   end
   function oo = Elongation(o)         % Calc Elongation Transfer Fct. 
      [Tf1,Tf2] = cook(o,'Tf1,Tf2');
      
      if (0)
         [H11,H12,H21,H22] = cook(o,'H11,H12,H21,H22');
      else
         [H11,H12,H21,H22] = cook(o,'G11,G12,G21,G22');
      end

      Ts1 = H11*Tf1 + H12*Tf2;
      Ts2 = H21*Tf1 + H22*Tf2;

      Ts = set(matrix(corasim),'name','Ts[s]');
      Ts = poke(Ts,Ts1,1,1);
      Ts = poke(Ts,Ts2,2,1);

      oo = cache(o,'process.Ts',Ts);
   end
   function oo = Velocity(o)           % Calc Velocity Transfer Fct.   
      [Ts1,Ts2] = cook(o,'Ts1,Ts2');

      Tv1 = Ts1 * s;
      Tv2 = Ts2 * s;

      Tv = set(matrix(corasim),'name','Tv[s]');;
      Tv = poke(Tv,Tv1,1,1);
      Tv = poke(Tv,Tv2,2,1);

      oo = cache(o,'process.Tv',Tv);
   end
   function oo = Acceleration(o)       % Calc Acceleration Trf         
      [Tv1,Tv2] = cook(o,'Tv1,Tv2');

      Ta1 = Tv1 * s;
      Ta2 = Tv2 * s;

      Ta = set(matrix(corasim),'name','Ta[s]');
      Ta = poke(Ta,Ta1,1,1);
      Ta = poke(Ta,Ta2,2,1);

      oo = cache(o,'process.Ta',Ta);
   end
end

%==========================================================================
% Nyquist Stuff
%==========================================================================

function oo = Nyq(o)                   % Brew Nyquist Stuff            
   o = with(o,'nyq');                  % unwrap nyquist options
   
   oo = current(o);
   oo = brew(oo,'System');             % brew system matrices
   
      % get a1,a0 and B,C,D
      
   [a0,a1,B,C,D] = var(oo,'a0,a1,B,C,D');
   
      % setup G31 transfer system
      
   G31 = modal(corasim,a0,a1,B(:,1),C(3,:),D(3,1));
   G31 = set(G31,'name','G31');
   
      % setup G33 transfer system
      
   G33 = modal(corasim,a0,a1,B(:,3),C(3,:),D(3,3));
   G33 = set(G33,'name','G33');
   
      % get omega set
      
   oscale = opt(o,{'brew.T0',1});
   [~,omega] = fqr(inherit(G33,o));
   
   G31jw = fqr(G31,omega*oscale);
   G33jw = fqr(G33,omega*oscale); 
   L0jw = G31jw./G33jw;
   
      % store in cache
      
   oo = cache(oo,'nyq.G31',G31);
   oo = cache(oo,'nyq.G33',G33);
   oo = cache(oo,'nyq.omega',omega);
   oo = cache(oo,'nyq.L0jw',L0jw);  
end

%==========================================================================
% Helper
%==========================================================================

function Gs = CancelG(o,Gs)            % Set Cancel Epsilon for G(s)   
   digs = opt(o,{'precision.G',0});
   eps = opt(o,'cancel.G.eps');
   Gs = opt(Gs,'control.verbose',control(o,'verbose'),'digits',digs);

   if ~isempty(eps)
      if isa(Gs,'corinth')
         Gs = touch(Gs);
      end
      Gs = opt(Gs,'eps',eps);
   end
end
function Hs = CancelH(o,Hs)            % Set Cancel Epsilon for H(s)   
   eps = opt(o,'cancel.H.eps');
   Hs = opt(Hs,'control.verbose',control(o,'verbose'));

   if ~isempty(eps)
      Hs = opt(Hs,'eps',eps);
   end
end
function Ls = CancelL(o,Ls)            % Set Cancel Epsilon            
   eps = opt(o,'cancel.L.eps');
   Ls = opt(Ls,'control.verbose',control(o,'verbose'));

   if ~isempty(eps)
      Ls = opt(Ls,'eps',eps);
   end
end
function Ts = CancelT(o,Ts)            % Set Cancel Epsilon            
   eps = opt(o,'cancel.T.eps');
   Ts = opt(Ts,'control.verbose',control(o,'verbose'));
   if ~isempty(eps)
      Ts = opt(Ts,'eps',eps);
   end
end
