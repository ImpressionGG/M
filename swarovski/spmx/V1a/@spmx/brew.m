function oo = brew(o,varargin)         % SPMX Brew Method               
%
% BREW   Brew data
%
%           oo = brew(o);                   % brew all
%
%           oo = brew(o,'Eigen')            % brew eigen values
%           oo = brew(o,'Normalize')        % brew time scaled system
%           oo = brew(o,'Partial')          % brew partial matrices
%           oo = brew(p,'Trfm')             % brew transfer matrix
%
%        
   [gamma,oo] = manage(o,varargin,@Brew,@Eigen,@Normalize,@Partial,...
                                  @Trfm,@TrfMatrix);
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

function oo = TrfMatrix(o)             % Transfer Matrix               
   [A,B,C] = get(o,'system','A,B,C');
   n = length(A)/2;  [m,l] = size(C*B);
   
   for (i=1:m)
      for (j=1:l)
         Gij = trffct(o,i,j);
         G{i,j} = Gij;
Gij = set(trf(Gij{1},Gij{2}),'title',sprintf('G%d%d(s)',i,j));
can(Gij)
      end
   end
   oo = var(o,'G',G);
end
function oo = Trfm(o)             % Transfer Matrix               
   oo = PhiDouble(o);
   cache(oo,oo);
end
function oo = PhiDouble(o)             % Rational Transition Matrix    
   refresh(o,{@menu,'About'});         % don't come back here!!!
   
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
         numi = num(i,:);
         p = poly(O,numi);             % numerator polynomial
         q = poly(O,den);              % denominator polynomial
         
         Gij = ratio(O,1);
         Gij = poke(Gij,p,q);          % Gij not canceled and trimmed
         
         fprintf('G%g%g(s):\n',i,j)
         display(Gij);
         
         G = poke(G,Gij,i,j);
         
         numtag = sprintf('num_%g_%g',i,j);
         oo = cache(oo,['trfm.',numtag],numi);

         dentag = sprintf('den_%g_%g',i,j);
         oo = cache(oo,['trfm.',dentag],den);
      end
   end
   
   oo = cache(oo,'trfm.G',G);          % store in cache
   
   fprintf('Transfer Matrix (calculated using double)\n');
   display(cache(oo,'trfm.G'));
end
