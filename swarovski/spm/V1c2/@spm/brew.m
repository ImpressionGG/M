function oo = brew(o,varargin)         % SPM Brew Method               
%
% BREW   Brew data
%
%           oo = brew(o);              % brew all
%
%           oo = brew(o,'Eigen')       % brew eigen values
%           oo = brew(o,'Normalize')   % brew time scaled system
%           oo = brew(o,'Partition')     % brew partial matrices
%
%           oo = brew(o,'Trfd')        % brew double transfer matrix
%           oo = brew(o,'Trfr')        % brew rational transfer matrix
%           oo = brew(o,'Consd')       % brew double constrained trf matrix
%           oo = brew(o,'Consr')       % brew rational constrained trf mat.
%
%           oo = brew(o,'Process')     % brew closed loop transfer fct
%
%        Examples
%
%           oo = brew(o,o,'trfd')
%           G = cache(oo,'trfd.G');    % get G(s)
%
%           oo = brew(o,o,'consd')
%           H = cache(oo,'consd.H');   % get H(s)
%           L = cache(oo,'consd.L');   % get L(s)
%
%           oo = brew(o,o,'process')
%           T = cache(oo,'process.T'); % get T(s)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: SPM
%        
   [gamma,oo] = manage(o,varargin,@Brew,@Eigen,@Normalize,@Partition,...
                                  @Trfd,@Trfr,@Consd,@Consr,@Process);
   oo = gamma(oo);
end              

%==========================================================================
% Brew All
%==========================================================================

function oo = Brew(o)                  % Brew All                      
   oo = o;
   oo = Normalize(oo);                 % first normalize the system
   oo = Eigen(oo);                     % brew eigenvalues
   oo = Trfd(oo);
   oo = Consd(oo);
end
function oo = Eigen(o)                 % Brew Eigenvalues              
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
% Partition and Normalizing
%==========================================================================

function oo = Partition(o)             % Partition System              
   %[A,B,C] = data(o,'A,B,C');
   oo = Normalize(o);
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
   
   M = B2;  a0 = -diag(A21);  a1 = -diag(A22);
   omega = sqrt(a0);  zeta = a1./omega/2;
   
   oo = var(oo,'A11,A12,A21,A22',A11,A12,A21,A22);
   oo = var(oo,'B1,B2,C1,C2',B1,B2,C1,C2);
   oo = var(oo,'M,a0,a1,omega,zeta',M,a0,a1,omega,zeta);
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
   
      % refresh system
      
   %oo = data(o,'A,B,C,D',A,B,C,D);
   oo = var(o,'A,B,C,D,T0',A,B,C,D,T0);
     
      % update simulation parameters
      
   %oo = opt(oo,'simu.tmax',opt(o,'simu.tmax')/T0);
   %oo = opt(oo,'simu.dt',opt(o,'simu.dt')/T0);
   
      % set time scale correction for plot routines
      
   %oo = var(oo,'Kms',1/T0);
end

%==========================================================================
% Transfer Matrix G(s)
%==========================================================================

function oo = Trfd(o)                  % Double Transfer Matrix        
   message(o,'Brewing Double Transfer Matrix ...');
   oo = TrfDouble(o);
   
     % make cache segment variables available
     
   [oo,bag,rfr] = cache(oo,'trfd');    % get bag of cached variables
   tags = fields(bag);
   for (i=1:length(tags))
      tag = tags{i};
      oo = var(oo,tag,bag.(tag));      % copy cached variable to variables
   end
   
      % unconditional hard refresh of cache
      
   cache(oo,oo);                       % hard refresh cache
   cls(o);
end
function oo = TrfDouble(o)             % Double Transition Matrix      
   refresh(o,{@plot,'About'});         % don't come back here!!!
   
   oo = current(o);
   oo = brew(oo,'Partition');            % brew partial matrices
   
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
   
   n = length(A21);
   m = size(M,2);
   %O = base(inherit(corinth,o));       % need to access CORINTH methods
   %G = corinth(O,'matrix');
   G = matrix(corasim);
   W = [];
   
      % depending on modal form ...
     
   if isequal(A11,Z) && isequal(A12,I) && ...
              isequal(A21,-diag(a0)) && isequal(A22,-diag(a1))
      psi = [ones(n,1) a1(:) a0(:)];
      Modal(o);
      
      for (k=1:length(psi))
         Gk = trf(G,1,psi(k,:));
         sym = sprintf('G_%g',k);
         oo = cache(oo,['trfd.',sym],Gk);
      end
   else
      Normal(o);
   end
         
   progress(o);                        % complete!
   oo = cache(oo,'trfd.G',G);          % store in cache
   oo = cache(oo,'trfd.W',W);          % store in cache
   
      % store all transfer matrix elements into cache
      
   [m,n] = size(G);
   for (i=1:m)
      for (j=1:n)
         Gij = peek(G,i,j);
         sym = sprintf('G%g%g',i,j);
         oo = cache(oo,['trfd.',sym],Gij);
      end
   end
     
   fprintf('Double Transfer Matrix\n');
   display(G);
   
   function Modal(o)                   % Gij(s) For Modal Forms        
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
            for (k=1:n)
   %           Gk = trf(O,mi(k)*mj(k),psi(k,:));
               Gk = system(G,{wij(k),psi(k,:)});
               Gij = Gij + Gk;
            end

            fprintf('G%g%g(s):\n',i,j)
            display(Gij);

            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
      end
   end
   function Normal(o)                  % Normal Gij(s) Calculation     
      [AA,BB,CC,DD] = data(oo,'A,B,C,D');
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

            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
      end
   end
   function Gs = CancelG(o,Gs)         % Set Cacel Epsilon             
      eps = opt(o,'cancel.G.eps');
      if ~isempty(eps)
         if isa(Gs,'corinth')
            Gs = touch(Gs);
         end
         Gs = opt(Gs,'eps',eps);
      end
   end
end
function oo = OldTrfDouble(o)          % Double Transition Matrix      
   refresh(o,{@plot,'About'});         % don't come back here!!!
   
   oo = current(o);
   oo = brew(oo,'Partition');            % brew partial matrices
   
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
   
   n = length(A21);
   m = size(M,2);
   O = base(inherit(corinth,o));       % need to access CORINTH methods
   G = corinth(O,'matrix');
   W = [];
   
      % depending on modal form ...
     
   if isequal(A11,Z) && isequal(A12,I) && ...
              isequal(A21,-diag(a0)) && isequal(A22,-diag(a1))
      psi = [ones(n,1) a1(:) a0(:)];
      Modal(o);
      
      for (k=1:length(psi))
         Gk = trf(G,1,psi(k,:));
         sym = sprintf('G_%g',k);
         oo = cache(oo,['trfd.',sym],Gk);
      end
   else
      Normal(o);
   end
         
   progress(o);                        % complete!
   oo = cache(oo,'trfd.G',G);          % store in cache
   oo = cache(oo,'trfd.W',W);          % store in cache
   
      % store all transfer matrix elements into cache
      
   [m,n] = size(G);
   for (i=1:m)
      for (j=1:n)
         Gij = peek(G,i,j);
         sym = sprintf('G%g%g',i,j);
         oo = cache(oo,['trfd.',sym],Gij);
      end
   end
     
   fprintf('Double Transfer Matrix\n');
   display(G);
   
   function Modal(o)                   % Gij(s) For Modal Forms        
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

            Gij = trf(O,0);               % init Gij
            for (k=1:n)
   %           Gk = trf(O,mi(k)*mj(k),psi(k,:));
               Gk = trf(O,wij(k),psi(k,:));
               Gij = Gij + Gk;
            end

            fprintf('G%g%g(s):\n',i,j)
            display(Gij);

            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
      end
   end
   function Normal(o)                  % Normal Gij(s) Calculation     
      [AA,BB,CC,DD] = data(oo,'A,B,C,D');
      sys = system(corasim,AA,BB,CC,DD);
      
      for (i=1:n)
         for (j=1:i)
            run = (j-1)*n+i; m = n*(n+1)/2;
            msg = sprintf('%g of %g: brewing G(%g,%g)',run,m,i,j);
            progress(o,msg,(run-1)/m*100);

               % calculate Gij

            [num,den] = peek(sys,i,j);
            Gij = trf(O,num,den);         % Gij(s)
            Gij = can(CancelG(o,Gij));
            
            fprintf('G%g%g(s):\n',i,j)
            display(Gij);

            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
      end
   end
   function Gs = CancelG(o,Gs)         % Set Cacel Epsilon             
      eps = opt(o,'cancel.G.eps');
      if ~isempty(eps)
         if isa(Gs,'corinth')
            Gs = touch(Gs);
         end
         Gs = opt(Gs,'eps',eps);
      end
   end
end

function oo = Trfr(o)                  % Rational Transfer Matrix      
   message(o,'Brewing Rational Transfer Matrix ...');
   oo = TrfRational(o);
   cache(oo,oo);                       % hard refresh cache
end
function oo = TrfRational(o)           % Rational Transition Matrix    
   refresh(o,{@plot,'About'});         % don't come back here!!!
   
   oo = current(o);
   oo = brew(oo,'Partition');            % brew partial matrices
   
   %[A21,A22,B2,C1,D] = var(oo,'A21,A22,B2,C1,D');
   
   [A,B,C,D] = data(oo,'A,B,C,D');
   
   [n,m] = size(B);  [l,~] = size(C);

   O = base(inherit(corinth,o));       % need to access CORINTH methods
   G = matrix(O,zeros(l,m));

   for (j=1:m)                         % j indexes B(:,j) (columns of B)
      [num,den] = ss2tf(A,B,C,D,j);
      assert(l==size(num,1));
      for (i=1:l)
         run = (j-1)*m+i;
         msg = sprintf('%g of %g: brewing G(%g,%g)',run,l*m,i,j);
         progress(o,msg,(run-1)/(l*m)*100);
         
         numi = num(i,:);
         p = poly(O,numi);             % numerator polynomial
         q = poly(O,den);              % denominator polynomial
         
         Gij = ratio(O,1);
         Gij = poke(Gij,p,q);          % Gij not canceled and trimmed
         
         fprintf('G%g%g(s):\n',i,j)
         display(Gij);
         
         G = poke(G,Gij,i,j);
         
         numtag = sprintf('num_%g_%g',i,j);
         oo = cache(oo,['trfr.',numtag],numi);

         dentag = sprintf('den_%g_%g',i,j);
         oo = cache(oo,['trfr.',dentag],den);
      end
      progress(o);                     % complete!
   end
   
   oo = cache(oo,'trfr.G',G);          % store in cache
   
   fprintf('Transfer Matrix (calculated using ratio)\n');
   display(cache(oo,'trfr.G'));
end

%==========================================================================
% Constrained Transfer Matrix H(s)
%==========================================================================

function oo = Consd(o)                 % Double Costrained Trf. Matrix 
   message(o,'Brewing Double Constrained Transfer Matrix ...');
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
   cls(o);
end
function oo = ConstrainedDouble(o)     % Double Constrained Trf Matrix 
   refresh(o,{@plot,'About'});         % don't come back here!!!
   
   oo = current(o);

      % calculate Hnn(s)
      
   G33 = cache(oo,'trfd.G33');
   Gnn = G33;                          % the same
%  Hnn = inv(Gnn) * trf(Gnn,[1],[1 0 0]);
   Hnn = CancelH(o,inv(Gnn));
   H33 = Hnn;

      % calculate Hnd(s) = [H31(s) H32(s)]
      
   G31 = cache(oo,'trfd.G31');
   G32 = cache(oo,'trfd.G32');
   H31 = CancelH(o,(-1)*Hnn*G31);
   H32 = CancelH(o,(-1)*Hnn*G32);
   
      % build Hnd(s) = [H31(s) H32(s)]
      
   Hnd = matrix(corasim);
   Hnd = poke(Hnd,H31,1,1);
   Hnd = poke(Hnd,H32,1,2);  

      % build Hdn(s) = [H13(s); H23(s)]

   G13 = cache(oo,'trfd.G13');
   G23 = cache(oo,'trfd.G23');
   H13 = CancelH(o,G13*Hnn);
   H23 = CancelH(o,G23*Hnn);
      
   Hdn = matrix(corasim);
   Hdn = poke(Hdn,H13,1,1);
   Hdn = poke(Hdn,H23,2,1);  

      % build Hdd(s) = [H11(s) H12(s); H21(s) H22(s)]

   G11 = cache(oo,'trfd.G11');
   G12 = cache(oo,'trfd.G12');
   G21 = cache(oo,'trfd.G21');
   G22 = cache(oo,'trfd.G22');

   H11 = CancelH(o,G11 - G13*G31*H33);
   H12 = CancelH(o,G12 - G13*G32*H33);
   H21 = CancelH(o,G21 - G23*G31*H33);
   H22 = CancelH(o,G22 - G23*G32*H33);
      
   Hdd = matrix(corasim);
   Hdd = poke(Hdd,H11,1,1);
   Hdd = poke(Hdd,H12,1,2);  
   Hdd = poke(Hdd,H21,2,1);
   Hdd = poke(Hdd,H22,2,2);  
   
      % store all partial constraine transfer functions in cache
      
   oo = cache(oo,'consd.H11',H11);
   oo = cache(oo,'consd.H12',H12);
   oo = cache(oo,'consd.H13',H13);

   oo = cache(oo,'consd.H21',H21);
   oo = cache(oo,'consd.H22',H22);
   oo = cache(oo,'consd.H23',H23);

   oo = cache(oo,'consd.H31',H31);
   oo = cache(oo,'consd.H32',H32);
   oo = cache(oo,'consd.H33',H33);
 
      % build H(s) = [Hdd(s) Hdn(s); Hnd(s) Hnn(s)]
      
   H = matrix(corasim);

   H = poke(H,H11,1,1);
   H = poke(H,H12,1,2);
   H = poke(H,H13,1,3);
   
   H = poke(H,H21,2,1);
   H = poke(H,H22,2,2);
   H = poke(H,H23,2,3);
   
   H = poke(H,H31,3,1);
   H = poke(H,H32,3,2);
   H = poke(H,H33,3,3);
   
      % store H in cache
      
   oo = cache(oo,'consd.H',H);

   function Hs = CancelH(o,Hs)
      eps = opt(o,'cancel.H.eps');
      if ~isempty(eps)
         Hs = opt(Hs,'eps',eps);
      end
   end
end

%==========================================================================
% Open Loop L(s)
%==========================================================================

function oo = OldOpenLoop(o)           % Old Open Loop Linear System   
   [oo,bag,rfr] = cache(o,o,'consd');
   
   H11 = cache(oo,'consd.H11');
   H12 = cache(oo,'consd.H12');
   H21 = cache(oo,'consd.H21');
   H22 = cache(oo,'consd.H22');
   H31 = cache(oo,'consd.H31');
   H32 = cache(oo,'consd.H32');
   
   s = trf(H11,[1 0],[1]);
   
   L11 = CancelL(o,H11);
   L12 = CancelL(o,H12);
   L21 = CancelL(o,H21);
   L22 = CancelL(o,H22);

   L31 = CancelL(o,s*H11);
   L32 = CancelL(o,s*H12);
   L41 = CancelL(o,s*H21);
   L42 = CancelL(o,s*H22);

   L51 = CancelL(o,H31);
   L52 = CancelL(o,H32);
   
      % store all partial constraine transfer functions in cache
      
   oo = cache(oo,'consd.L11',L11);
   oo = cache(oo,'consd.L12',L12);

   oo = cache(oo,'consd.L21',L21);
   oo = cache(oo,'consd.L22',L22);

   oo = cache(oo,'consd.L31',L31);
   oo = cache(oo,'consd.L32',L32);

   oo = cache(oo,'consd.L41',L41);
   oo = cache(oo,'consd.L42',L42);

   oo = cache(oo,'consd.L51',L51);
   oo = cache(oo,'consd.L52',L52);

      % assemble L(s) matrix
      
   L = matrix(corasim);
   
   L = poke(L,L11,1,1);
   L = poke(L,L12,1,2);

   L = poke(L,L21,2,1);
   L = poke(L,L22,2,2);
   
   L = poke(L,L31,3,1);
   L = poke(L,L32,3,2);
   
   L = poke(L,L41,4,1);
   L = poke(L,L42,4,2);
   
   L = poke(L,L51,5,1);
   L = poke(L,L52,5,2);

      % store L in cache
      
   oo = cache(oo,'consd.L',L);
   
   function Ls = CancelL(o,Ls)
      eps = opt(o,'cancel.L.eps');
      if ~isempty(eps)
         Ls = opt(Ls,'eps',eps);
      end
   end
end
function oo = OpenLoop(o)              % Open Loop Linear System       
   [oo,bag,rfr] = cache(o,o,'consd');
   
   H31 = cache(oo,'consd.H31');
   H32 = cache(oo,'consd.H32');
      
   L1 = CancelL(o,H31);
   L2 = CancelL(o,H32);
   
      % store all partial constraine transfer functions in cache
      
   oo = cache(oo,'consd.L1',L1);
   oo = cache(oo,'consd.L2',L2);

      % assemble L(s) matrix
      
   L = matrix(corasim);
   
   L = poke(L,L1,1,1);
   L = poke(L,L2,1,2);

      % store L in cache
      
   oo = cache(oo,'consd.L',L);
   
   function Ls = CancelL(o,Ls)         % Set cancel Epsilon            
      eps = opt(o,'cancel.L.eps');
      if ~isempty(eps)
         Ls = opt(Ls,'eps',eps);
      end
   end
end

%==========================================================================
% Closed Loop T(s)
%==========================================================================

function oo = Process(o)               % Brew Process Segment          
   message(o,'Brewing Closed Loop Transfer Function ...');
   oo = ClosedLoop(o);
   
     % make cache segment variables available
     
   [oo,bag,rfr] = cache(oo,'process'); % get bag of cached variables
   tags = fields(bag);
   for (i=1:length(tags))
      tag = tags{i};
      oo = var(oo,tag,bag.(tag));      % copy cached variable to variables
   end
   
      % unconditional hard refresh of cache
      
   cache(oo,oo);                       % hard refresh cache
   cls(o);
end
function oo = OldClosedLoop(o)         % Old Closed Loop Linear System 
%
%          F       Fn         +----+     F1               +-----+  y1_1
%        ----->o------------->| mu |---------*-----*----->| L11 |------>
%              ^ +            +----+         |     |      +-----+
%              |                             |     |
%              |            +--------+   F1  |     |      +-----+  y2_1
%              |     +------| L51(s) |<------+     *----->| L21 |------>
%              |     |      +--------+             |      +-----+
%              | dFn v                             |
%              +-----o                             |      +-----+ dy1/dt_1    
%                    ^                             *----->| L31 |------>
%                    |      +--------+  F2=0       |      +-----+
%                    +------| L52(s) |<--------    |
%                           +--------+             |      +-----+ dy2/dt_1 
%                                                  *----->| L41 |------>
%                                                         +-----+
%
   oo = o;
   return
   
   
   L1 = cook(oo,'L1');   
   mu = opt(o,{'process.mu',0.1});     % friction coefficient
   
      % calculate S1(s) = mu / (1 - mu*L1(s))

   L1 = CanEpsT(o,L1);                 % set cancel epsilon
   S1 = mu / (1 - mu*L1);              % closed loop sensitivity
   S2 = 0*S1;
   
   S = matrix(corasim);
   S = poke(S,S1,1,1);
   S = poke(S,S2,2,1);
   
      % differentiator transfer function
      
   s = system(S,{[1 0],[1]});

   T11 = S1 * L11;
   T21 = S1 * L21;
   T31 = S1 * L31;
   T41 = S1 * L41;
   T51 = T31 * s;
   T61 = T41 * s;
   T71 = S1 * L51;
   
   T12 = S2 * L12;
   T22 = S2 * L22;
   T32 = S2 * L32;
   T42 = S2 * L42;
   T52 = T32 * s;
   T62 = T42 * s;
   T72 = S2 * L52;
   
   T = matrix(corasim);
   
   T = poke(T,T11,1,1);
   T = poke(T,T21,2,1);
   T = poke(T,T31,3,1);
   T = poke(T,T41,4,1);
   T = poke(T,T51,5,1);
   T = poke(T,T61,6,1);
   T = poke(T,T71,7,1);

   T = poke(T,T12,1,2);
   T = poke(T,T22,2,2);
   T = poke(T,T32,3,2);
   T = poke(T,T42,4,2);
   T = poke(T,T52,5,2);
   T = poke(T,T62,6,2);
   T = poke(T,T72,7,2);
   
      % store S and T in cache 
      
   oo = cache(oo,'process.S',S);
   oo = cache(oo,'process.T',T);
   
   oo = Force(oo);                     % calc force trf
   oo = Elongation(oo);                % calc elongation trf
   oo = Velocity(oo);                  % calc velocity trf
   oo = Acceleration(oo);              % calc acceleration trf
   
   function oo = Force(o)              % Calc Force Transfer Function  
      G31 = cache(o,'trfd.G31');
      G32 = cache(o,'trfd.G32');
      G33 = cache(o,'trfd.G33');

      Tf1 = mu*G33 / (G33 + mu*G31);
      Tf2 = 0*Tf1;

      Tf = matrix(corasim);
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
      Ts2 = H21*Tf1 + H22*Tf2

      Ts = matrix(corasim);
      Ts = poke(Ts,Ts1,1,1);
      Ts = poke(Ts,Ts2,2,1);

      oo = cache(o,'process.Ts',Ts);
   end
   function oo = Velocity(o)           % Calc Velocity Transfer Fct.   
      [Ts1,Ts2] = cook(o,'Ts1,Ts2');

      Tv1 = Ts1 * s;
      Tv2 = Ts2 * s;

      Tv = matrix(corasim);
      Tv = poke(Tv,Tv1,1,1);
      Tv = poke(Tv,Tv2,2,1);

      oo = cache(o,'process.Tv',Tv);
   end
   function oo = Acceleration(o)       % Calc Acceleration Trf         
      [Tv1,Tv2] = cook(o,'Tv1,Tv2');

      Ta1 = Tv1 * s;
      Ta2 = Tv2 * s;

      Ta = matrix(corasim);
      Ta = poke(Ta,Ta1,1,1);
      Ta = poke(Ta,Ta2,2,1);

      oo = cache(o,'process.Ta',Ta);
   end

   function Gs = CanEpsT(o,Gs)         % Set Cancel Epsilon            
      eps = opt(o,'cancel.T.eps');
      if ~isempty(eps)
         Gs = opt(Gs,'eps',eps);
      end
   end
end
function oo = ClosedLoop(o)            % Closed Loop Linear System     
   mu = opt(o,{'process.mu',0.1});     % friction coefficient
   s = system(corasim,{[1 0],[1]});    % differentiation trf
   s = CanEpsT(o,s);
   
   oo = Force(o);                      % calc force trf
   oo = Elongation(oo);                % calc elongation trf
   oo = Velocity(oo);                  % calc velocity trf
   oo = Acceleration(oo);              % calc acceleration trf
   
   function oo = Force(o)              % Calc Force Transfer Function        
      G31 = cache(o,'trfd.G31');
      G32 = cache(o,'trfd.G32');
      G33 = cache(o,'trfd.G33');

      Tf1 = mu*G33 / (G33 + mu*G31);
      Tf2 = 0*Tf1;

      Tf = matrix(corasim);
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
      Ts2 = H21*Tf1 + H22*Tf2

      Ts = matrix(corasim);
      Ts = poke(Ts,Ts1,1,1);
      Ts = poke(Ts,Ts2,2,1);

      oo = cache(o,'process.Ts',Ts);
   end
   function oo = Velocity(o)           % Calc Velocity Transfer Fct.   
      [Ts1,Ts2] = cook(o,'Ts1,Ts2');

      Tv1 = Ts1 * s;
      Tv2 = Ts2 * s;

      Tv = matrix(corasim);
      Tv = poke(Tv,Tv1,1,1);
      Tv = poke(Tv,Tv2,2,1);

      oo = cache(o,'process.Tv',Tv);
   end
   function oo = Acceleration(o)       % Calc Acceleration Trf         
      [Tv1,Tv2] = cook(o,'Tv1,Tv2');

      Ta1 = Tv1 * s;
      Ta2 = Tv2 * s;

      Ta = matrix(corasim);
      Ta = poke(Ta,Ta1,1,1);
      Ta = poke(Ta,Ta2,2,1);

      oo = cache(o,'process.Ta',Ta);
   end
   function Gs = CanEpsT(o,Gs)         % Set Cancel Epsilon            
      eps = opt(o,'cancel.T.eps');
      if ~isempty(eps)
         Gs = opt(Gs,'eps',eps);
      end
   end
end
