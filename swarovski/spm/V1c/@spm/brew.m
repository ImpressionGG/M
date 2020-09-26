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
%           oo = brew(p,'Trfd')        % brew double transfer matrix
%           oo = brew(p,'Trfr')        % brew rational transfer matrix
%           oo = brew(p,'Consd')       % brew double constrained trf matrix
%           oo = brew(p,'Consr')       % brew rational constrained trf mat.
%
%        
   [gamma,oo] = manage(o,varargin,@Brew,@Eigen,@Normalize,@Partition,...
                                  @Trfd,@Trfr,@Consd,@Consr);
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
   [A,B,C] = data(o,'A,B,C');

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
   
   oo = var(o,'A11,A12,A21,A22',A11,A12,A21,A22);
   oo = var(oo,'B1,B2,C1,C2',B1,B2,C1,C2);
   oo = var(oo,'M,a0,a1,omega,zeta',M,a0,a1,omega,zeta);
end
function oo = Normalize(o)             % Normalize System              
   T0 = opt(o,{'brew.T0',1e-3});       % normalization time constant

      % normalize system
      
   [A,B,C] = get(o,'system','A,B,C');

   n = floor(length(A)/2);
   i1 = 1:n;  i2 = n+1:2*n;
   
   A(i2,i1) = T0*T0*A(i2,i1);
   A(i2,i2) = T0*A(i2,i2);
   B(i2,:)  = T0*B(i2,:);
   C(:,i1) = C(:,i1)*T0;
   
      % refresh system
      
   oo = set(o,'system','A,B,C,T0',A,B,C,T0);
      
      % update simulation parameters
      
   oo = opt(oo,'simu.tmax',opt(o,'simu.tmax')/T0);
   oo = opt(oo,'simu.dt',opt(o,'simu.dt')/T0);
   
      % set time scale correction for plot routines
      
   oo = var(oo,'Kms',1/T0);
end

%==========================================================================
% Transfer Matrix
%==========================================================================

function oo = Trfd(o)                  % Double Transfer Matrix        
   message(o,'Brewing Double Transfer Matrix ...');
   oo = TrfDouble(o);
   
     % make cache segment as variables available
     
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
   
   function Modal(o)    
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
   function Normal(o)
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

            fprintf('G%g%g(s):\n',i,j)
            display(Gij);

            G = poke(G,Gij,i,j);          % lower half diagonal element
            if (i ~= j)
               G = poke(G,Gij,j,i);       % upper half diagonal element
            end
         end
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
% Constrained Transfer Matrix and Linear Subsystem
%==========================================================================

function oo = Consd(o)                 % Double Costrained Trf. Matrix 
   message(o,'Brewing Double Constrained Transfer Matrix ...');
   oo = ConstrainedDouble(o);          % brew H(s) matrix
   oo = LinearSubsys(oo);              % brew L(s) matrix
   
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
   Hnn = inv(Gnn);
   H33 = Hnn;

      % calculate Hnd(s) = [H31(s) H32(s)]
      
   G31 = cache(oo,'trfd.G31');
   G32 = cache(oo,'trfd.G32');
   H31 = (-1)*Hnn*G31;
   H32 = (-1)*Hnn*G32;
   
      % build Hnd(s) = [H31(s) H32(s)]
      
   Hnd = matrix(corinth,[0 0]);
   Hnd = poke(Hnd,H31,1,1);
   Hnd = poke(Hnd,H32,1,2);  

      % build Hdn(s) = [H13(s); H23(s)]

   G13 = cache(oo,'trfd.G13');
   G23 = cache(oo,'trfd.G23');
   H13 = G13*Hnn;
   H23 = G23*Hnn;
      
   Hdn = matrix(corinth,[0;0]);
   Hdn = poke(Hdn,H13,1,1);
   Hdn = poke(Hdn,H23,2,1);  

      % build Hdd(s) = [H11(s) H12(s); H21(s) H22(s)]

   G11 = cache(oo,'trfd.G11');
   G12 = cache(oo,'trfd.G12');
   G21 = cache(oo,'trfd.G21');
   G22 = cache(oo,'trfd.G22');

   H11 = G11 - G13*G31*H33;
   H12 = G12 - G13*G32*H33;
   H21 = G21 - G23*G31*H33;
   H22 = G22 - G23*G32*H33;
      
   Hdd = matrix(corinth,[0 0;0 0]);
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
      
   H = matrix(corinth,zeros(3));

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
end
function oo = LinearSubsys(o)          % Linear Sub-System             
   [oo,bag,rfr] = cache(o,o,'consd');
   
   H11 = cache(oo,'consd.H11');
   H12 = cache(oo,'consd.H12');
   H21 = cache(oo,'consd.H21');
   H22 = cache(oo,'consd.H22');
   H31 = cache(oo,'consd.H31');
   H32 = cache(oo,'consd.H32');
   
   s = trf(H11,[1 0],[1]);
   
   L11 = Cancel(o,s*H11);
   L12 = Cancel(o,s*H12);
   L21 = Cancel(o,s*H21);
   L22 = Cancel(o,s*H22);

   L31 = Cancel(o,H31);
   L32 = Cancel(o,H32);
   
      % store all partial constraine transfer functions in cache
      
   oo = cache(oo,'consd.L11',L11);
   oo = cache(oo,'consd.L12',L12);

   oo = cache(oo,'consd.L21',L21);
   oo = cache(oo,'consd.L22',L22);

   oo = cache(oo,'consd.L31',L31);
   oo = cache(oo,'consd.L32',L32);

      % assemble L(s) matrix
      
   L = matrix(corinth);
   L = poke(L,L11,1,1);
   L = poke(L,L12,1,2);
   L = poke(L,L21,2,1);
   L = poke(L,L22,2,2);
   L = poke(L,L31,3,1);
   L = poke(L,L32,3,2);

      % store L in cache
      
   oo = cache(oo,'consd.L',L);
   
   function Ls = Cancel(o,Ls)
      eps = opt(o,'cancel.L.eps');
      if ~isempty(eps)
         Ls = opt(Ls,'eps',eps);
      end
   end
end
