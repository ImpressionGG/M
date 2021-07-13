function oo = system(o,cdx)
%
% SYSTEM  Create a CORASIM state space system from an SPM object according
%         to selected contact points.
%
%            oo = system(o,cdx)     % system due to contact indices
%            oo = system(o)         % system due to 'process.contact' opts
%
%         All calculations are live and without consultation of the cache!
%         (takes about 20...100ms for an order 200 system)
%
%         1) retrieve open loop SPM system matrices after variation, time
%         normalization, coordinate transformation and contact based se-
%         lection
%
%            oo = system(o,cdx)     % system due to contact indices
%            [A,B,C,D] = var(oo,'A,B,C,D');   % system matrices
%            T0 = var(oo,'T0');               % scaling constant
%
%         2) Retrieve basis matrices for L0(s and lambda(s) calculation,
%         and subsequent critical quantities (K0,f0,K180,f180) calculation
%
%            oo = system(o,cdx)     % system due to contact indices
%            [A,B_1,B_3,C_3] = var(oo,'A,B_1,B_3,C_3');
%
%            Phi(s) = inv(s*I-A)
%            G31(s) = C_3*Phi(s)*B_1
%            G33(s) = C_3*Phi(s)*B_3
%            L0(s)  = G33(s)\G31(s)
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, CONTACT, CONSTRAIN
%
   if ~type(o,{'spm'})
      oo = [];
      return
   end
   
   if (nargin < 2)                     % then retrieve contact indices
      cdx = opt(o,{'process.contact',inf});
   end
   
   oo = Variation(o);                  % apply system variation
   oo = Normalize(oo);                 % normalize system
   oo = Transform(oo);                 % coordinate transformation
   
   [A,B,C,D] = var(oo,'A,B,C,D');      % get transformed system matrices
   oo = contact(oo,cdx,A,B,C,D);       % calc free system regarding contact 
   
   oo = inherit(oo,o);                 % inherit options
end

%==========================================================================
% Helper
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

