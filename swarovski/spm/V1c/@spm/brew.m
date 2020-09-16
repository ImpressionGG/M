function oo = brew(o,varargin)         % SPM Brew Method               
%
% BREW   Brew data
%
%           oo = brew(o);              % brew all
%
%           oo = brew(o,'Eigen')       % brew eigen values
%           oo = brew(o,'Normalize')   % brew time scaled system
%           oo = brew(o,'Partial')     % brew partial matrices
%
%           oo = brew(p,'Trfd')        % brew double transfer matrix
%           oo = brew(p,'Trfr')        % brew rational transfer matrix
%           oo = brew(p,'Consd')       % brew double constrained trf matrix
%           oo = brew(p,'Consr')       % brew rational constrained trf mat.
%
%        
   [gamma,oo] = manage(o,varargin,@Brew,@Eigen,@Normalize,@Partial,...
                                  @Trfd,@Trfr,@Consd,@Consr);
   oo = gamma(oo);
end              

%==========================================================================
% Brew All
%==========================================================================

function oo = Brew(o)                  % Brew All                      
   oo = o;
   oo = Normalize(oo);                 % first normalize the system
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
% Partial and Normalizing
%==========================================================================

function oo = Partial(o)               % Normalize System              
   [A,B,C] = data(o,'A,B,C');

   n = floor(length(A)/2);
   i1 = 1:n;  i2 = n+1:2*n;
   
   A11 = A(i1,i1);  A12 = A(i1,i2);
   A21 = A(i2,i1);  A22 = A(i2,i2);
  
   B1 = B(i1,:);  B2 = B(i2,:);   
   C1 = C(:,i1);  C2 = C(:,i2);
  
   oo = var(o,'A11,A12,A21,A22',A11,A12,A21,A22);
   oo = var(oo,'B1,B2,C1,C2',B1,B2,C1,C2);
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
end
function oo = TrfDouble(o)             % Double Transition Matrix      
   refresh(o,{@plot,'About'});         % don't come back here!!!
   
   oo = current(o);
   oo = brew(oo,'Partial');            % brew partial matrices
   
      % get a1,a0 and M
      
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
   m = size(M,2);
   O = base(inherit(corinth,o));       % need to access CORINTH methods
   G = corinth(O,'matrix');

      % calculate psi(i) polynomials
      
   psi = [ones(n,1) a1(:) a0(:)];
   
   for (i=1:m)
      for (j=1:i)
         run = (j-1)*n+i; m = n*(n+1)/2;
         msg = sprintf('%g of %g: brewing G(%g,%g)',run,m,i,j);
         progress(o,msg,(run-1)/m*100);
 
            % calculate Gij
            
         mi = M(:,i)';  mj = M(:,j);
         Gij = trf(O,0);               % init Gij
         for (k=1:n)
            Gk = trf(O,mi(k)*mj(k),psi(k,:));
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
         
   progress(o);                        % complete!
   oo = cache(oo,'trfd.G',G);          % store in cache
   
      % store all transfer matrix elements into cache
      
   [m,n] = size(G);
   for (i=1:m)
      for (j=1:n)
         Gij = peek(G,i,j);
         sym = sprintf('G%g%g',i,j);
         oo = cache(oo,['trfd.',sym],Gij);
      end
   end
 
   for (k=1:n)
      Gk = trf(G,1,psi(k,:));
      sym = sprintf('G%g',k);
      oo = cache(oo,['trfd.',sym],Gk);
   end
    
   fprintf('Double Transfer Matrix\n');
   display(G);
end

function oo = Trfr(o)                  % Rational Transfer Matrix      
   message(o,'Brewing Rational Transfer Matrix ...');
   oo = TrfRational(o);
   cache(oo,oo);                       % hard refresh cache
end
function oo = TrfRational(o)           % Rational Transition Matrix    
   refresh(o,{@plot,'About'});         % don't come back here!!!
   
   oo = current(o);
   oo = brew(oo,'Partial');            % brew partial matrices
   
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
% Constrained Transfer Matrix
%==========================================================================

function oo = Consd(o)                 % Double Costrained Trf. Matrix 
   message(o,'Brewing Double Constrained Transfer Matrix ...');
   oo = ConstrainedDouble(o);

     % make cache segment as variables available
     
   [oo,bag,rfr] = cache(oo,'consd');   % get bag of cached variables
   tags = fields(bag);
   for (i=1:length(tags))
      tag = tags{i};
      oo = var(oo,tag,bag.(tag));      % copy cached variable to variables
   end
   
      % unconditional hard refresh of cache
   
   cache(oo,oo);                       % hard refresh cache
end
function oo = ConstrainedDouble(o)     % Double Constrained Trf Matrix 
   refresh(o,{@plot,'About'});         % don't come back here!!!
   
   oo = current(o);

      % calculate Hnn(s)
      
   G33 = cache(oo,'trfd.G33');
   Gnn = G33;                          % the same
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

