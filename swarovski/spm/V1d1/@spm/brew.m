function oo = brew(o,varargin)         % SPM Brew Method               
%
% BREW   Brew data
%
%           oo = brew(o);              % brew all
%
%           oo = brew(o,'Variation')   % brew sys variation (change data)
%           oo = brew(o,'Normalize')   % brew time scaled system
%           oo = brew(o,'System')      % brew system matrices
%
%           oo = brew(o,'Trf')         % brew transfer matrix
%           oo = brew(o,'Constrain')   % brew double constrained trf matrix
%           oo = brew(o,'Principal')   % brew principal transfer functions
%           oo = brew(o,'Inverse')     % brew inverse system
%           oo = brew(o,'Loop')        % brew loop analysis stuff
%           oo = brew(o,'Process')     % brew closed loop transfer fct
%
%           oo = brew(o,'Nyq')         % brew nyquist stuff
%
%        The following cache segments are here by managed:
%
%           'trf'                           % free system TRFs
%           'consd'                         % constrained system TRFs
%           'principal'                     % principal transfer functions
%           'loop'                          % loop transfer function
%           'process'                       % closed loop process 
%
%        Examples
%
%           oo = brew(o,'System')           % brew system matrices
%           [A,B,C,D] = var(oo,'A,B,C,D)    % system matrices
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
%        Dependency of cache segments
%
%                       variation   normalizing
%                             |        |
%                             v        v
%                        +-----------------+
%                        |      system     | A,B,C,D,a0,a1
%                        +-----------------+
%                             |        |
%                             v        v
%              +-----------------+  +-----------------+
%        L0(s) |    principal    |  |       trf       | G(s)
%              +-----------------+  +-----------------+
%                   |         |              |
%                   v         |              v
%       +-----------------+   |      +-----------------+
%       |     inverse     |   |      |     consd       | H(s)
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
   [gamma,oo] = manage(o,varargin,@Brew,@Variation,@Normalize,@System,...
                       @Trf,@Principal,@Inverse,...
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
      
   oo = var(o,'A,B,C,D,T0,a0,a1',A,B,C,D,T0,a0,a1);
end
function oo = System(o)                % System Matrices               
   oo = Variation(o);                  % apply system variation
   oo = Normalize(oo);                 % normalize system
   [A,B,C] = var(oo,'A,B,C');

   n = floor(length(A)/2);
   i1 = 1:n;  i2 = n+1:2*n;
   
   A11 = A(i1,i1);  A12 = A(i1,i2);
   A21 = A(i2,i1);  A22 = A(i2,i2);
  
   B1 = B(i1,:);  B2 = B(i2,:);   
   C1 = C(:,i1);  C2 = C(:,i2);
  
   if (norm(B2-C1') ~= 0)
      fprintf('*** warning: B2 differs from C1''!\n');
   end
   
   a0 = -diag(A21);  a1 = -diag(A22);
   omega = sqrt(a0);  zeta = a1./omega/2;
   
   oo = var(oo,'A11,A12,A21,A22',A11,A12,A21,A22);
   oo = var(oo,'B1,B2,C1,C2',B1,B2,C1,C2);
   oo = var(oo,'a0,a1,omega,zeta',a0,a1,omega,zeta);
end

%==========================================================================
% Transfer Matrix G(s)
%==========================================================================

function oo = Trf(o)                   % Double Transfer Matrix        
   progress(o,'Brewing Double Transfer Matrix ...');
   
   switch opt(o,{'trf.type','strf'})
      case 'modal'
         oo = TrfModal(o);
      case {'strf','szpk'}
         oo = TrfDouble(o);
      otherwise
         error('bad selection');
   end
      
      % unconditional hard refresh of cache
      
   cache(oo,oo);                       % hard refresh cache
   progress(o);                        % progress complete
end
function oo = OldTrfDouble(o)          % Double Transfer Matrix        
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
       
   if control(o,'verbose') > 0
      fprintf('Double Transfer Matrix\n');
      display(G);
   end
   
   function ok = HasModalForm(o)
      ok = isequal(A11,Z) && isequal(A12,I) && ...
              isequal(A21,-diag(a0)) && isequal(A22,-diag(a1));
   end
   function Modal(o)                   % Gij(s) For Modal Forms        
      psi = [ones(n,1) a1(:) a0(:)];

      for (i=1:m)
         for (j=1:i)
            run = (j-1)*n+i; m = n*(n+1)/2;
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,m,i,j);
            progress(o,msg,(run-1)/m*100);

               % calculate Gij

            mi = M(:,i)';  mj = M(:,j);
            wij = (mi(:).*mj(:))';        % weight vector
            W{i,j} = wij;                 % store as matrix element
            W{j,i} = wij;                 % symmetric matrix

            Gij = system(G,{[0],[1]});    % init Gij
            Gij = CancelG(o,Gij);         % set cancel epsilon
            
            for (k=1:n)
   %           Gk = trf(O,mi(k)*mj(k),psi(k,:));
               Gk = system(G,{wij(k),psi(k,:)});
               Gij = Gij + Gk;
            end

            if control(o,'verbose') > 0
               fprintf('G%g%g(s):\n',i,j)
               display(Gij);
            end

            Gij = set(Gij,'name',sprintf('G%g%g(s)',i,j));
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
   function Gs = CancelG(o,Gs)         % Set Cancel Epsilon            
      eps = opt(o,'cancel.G.eps');
      Gs = opt(Gs,'control.verbose',control(o,'verbose'));
      
      if ~isempty(eps)
         if isa(Gs,'corinth')
            Gs = touch(Gs);
         end
         Gs = opt(Gs,'eps',eps);
      end
   end
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
       
   if control(o,'verbose') > 0
      fprintf('Double Transfer Matrix\n');
      display(G);
   end
   
   function ok = HasModalForm(o)       % Has System a Modal Form       
      ok = isequal(A11,Z) && isequal(A12,I) && ...
              isequal(A21,-diag(a0)) && isequal(A22,-diag(a1));
   end
   function Modal(o)                   % Gij(s) For Modal Forms        
      psi = [ones(n,1) a1(:) a0(:)];

      for (i=1:m)
         for (j=1:i)
            run = (j-1)*n+i; m = n*(n+1)/2;
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,m,i,j);
            progress(o,msg,(run-1)/m*100);

               % calculate Gij

            mi = M(:,i)';  mj = M(:,j);
            wij = (mi(:).*mj(:))';        % weight vector
            W{i,j} = wij;                 % store as matrix element
            W{j,i} = wij;                 % symmetric matrix

            Gij = system(G,{[0],[1]});    % init Gij
            Gij = CancelG(o,Gij);         % set cancel epsilon
            
            for (k=1:n)
   %           Gk = trf(O,mi(k)*mj(k),psi(k,:));
               Gk = system(G,{wij(k),psi(k,:)});
               Gij = Gij + Gk;
            end

            if control(o,'verbose') > 0
               fprintf('G%g%g(s):\n',i,j)
               display(Gij);
            end

            if isequal(opt(o,{'trf.type','strf'}),'szpk')
               Gij = zpk(Gij);            % convert to ZPK
            end
            
            Gij = set(Gij,'name',sprintf('G%g%g(s)',i,j));
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
function oo = TrfModal(o)              % Modal Tranfer Matrix          
   oo = brew(o,'System');              % brew system matrices
   
      % get a1,a0 and M
      
   [a0,a1,B,C,D] = var(oo,'a0,a1,B,C,D');

      % calculate weight matrix and transfer matrix in modal form
      
   W = [];                             % init W
   G = matrix(corasim);                % init G
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
%            P  = cache(oo,'principal.P')      % P(s)
%            Q  = cache(oo,'principal.Q')      % Q(s)
%            Lp = cache(oo,'principal.Lp')     % Lp(s) := P(s)/Q(s)
%
   progress(o,'Brewing Principal Transfer Functions ...');
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

   if HasModalForm(o)
      [P,Q] = ModalPQ(o);  
   else
      [P,Q] = NormalPQ(o);
   end

   [P,Q,F0] = Normalize(oo,P,Q)        % calc normalized P(s)/Q(s)
   
   F0 = set(F0,'name','F0(s)');        % normalizing transfer function
   P = set(P,'name','P(s)');           % normalized P(s)
   Q = set(Q,'name','Q(s)');           % normalized Q(s)
   
   oo = o;
   oo = cache(oo,'principal.F0',F0);
   oo = cache(oo,'principal.P',P);
   oo = cache(oo,'principal.Q',Q);
                
   L0 = CalcL0(oo,P,Q);
   oo = cache(oo,'principal.L0',L0);

      % calc critical K and closed loop TRF
      
   K0 = stable(o,L0);
   L0 = CancelT(o,L0);                 % set cancel epsilon for T(s)
   if ~isinf(K0)
      S0 = 1/(1+K0*L0);                % closed loop sensitivity
      T0 = S0*K0*L0;                   % total TRF
   else                                % use K0 = 1 instead
      S0 = 1/(1+L0);                   % closed loop sensitivity
      T0 = S0*L0;                      % total TRF
   end
   
   S0 = set(S0,'name','S0(s)');
   T0 = set(T0,'name','T0(s)');
   
   oo = cache(oo,'principal.K0',K0);
   oo = cache(oo,'principal.S0',S0);
   oo = cache(oo,'principal.T0',T0);
   
      % unconditional hard refresh of cache
   
   cache(oo,oo);                       % hard refresh cache
   progress(o);                        % progress complete

      % done
      
   function ok = HasModalForm(o)       % Has System a Modal Form       
      ok = isequal(A11,Z) && isequal(A12,I) && ...
              isequal(A21,-diag(a0)) && isequal(A22,-diag(a1));
   end
   function [P,Q] = ModalPQ(o)         % P(s)/Q(s) For Modal Forms     
      psi = [ones(n,1) a1(:) a0(:)];

      for (i=1:m)
         for (j=1:i)
               % calculate Gij

            if ~((i==3 && j==1) || (i==3 && j==3))
               continue
            end
            
            mi = M(:,i)';  mj = M(:,j);
            wij = (mi(:).*mj(:))';        % weight vector
            W{i,j} = wij;                 % store as matrix element
            W{j,i} = wij;                 % symmetric matrix

            Gij = trf(corasim,0);         % init Gij
            Gij = CancelG(o,Gij);         % set cancel epsilon
            Gij = set(Gij,'name',o.iif(j==1,'P(s)','Q(s)'));
            
            for (k=1:n)
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
      V0 = fqr(Q,0);                      % gain of P

         % calculate normalizing factor F0(s)

      if (V0 == 0)
         F0 = zpk(Q,[],[],1);
      else
         [num,den] = peek(Q/V0);
         Vinf = num(1)/den(1);
         om0 = sqrt(abs(Vinf));
         F0 = V0/lf(Q,om0)/lf(Q,om0);   % normalizing factor
      end
      F0 = set(F0,'name','F0(s)');

         % calculate normalized principal transfer matrices

      P = P/F0;
      Q = Q/F0;
   end
   function L0 = CalcL0(o,P,Q)         % Calc L0(s)                    
   %
   % CALCL0    Calculate L0(s) = P(s)/Q(s)
   %
      P = CancelG(o,P);                   % set cancel epsilon
      Q = CancelL(o,Q);                   % set cancel epsilon

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
end

%==========================================================================
% Inverse System [Ai,Bi,Ci,Di]
%==========================================================================

function oo = Inverse(o)
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
   
   [oo,bag,rfr] = cache(o,'principal');% refresh principal cache segment
   
   L0 = cook(oo,'L0');
   Lmu = mu * L0;                      % Loop TRF under friction mu

      % store in 'loop' cache segment
      
   Lmu = set(Lmu,'name','Lmu(s)');
   oo = cache(oo,'loop.Lmu',Lmu);
   
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
   eps = opt(o,'cancel.G.eps');
   Gs = opt(Gs,'control.verbose',control(o,'verbose'));

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
