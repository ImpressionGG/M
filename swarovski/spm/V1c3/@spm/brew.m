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
%           oo = brew(o,'Trf')         % brew transfer matrix
%           oo = brew(o,'Constrain')   % brew double constrained trf matrix
%           oo = brew(o,'Process')     % brew closed loop transfer fct
%
%           oo = brew(o,'Nyq')         % brew nyquist stuff
%
%        Examples
%
%           oo = brew(o,'Trf')
%           G = cache(oo,'trd.G');     % get G(s)
%
%           oo = brew(o,'Constrain')
%           H = cache(oo,'consd.H');   % get H(s)
%           L = cache(oo,'consd.L');   % get L(s)
%
%           oo = brew(o,'Process')
%           T = cache(oo,'process.T'); % get T(s)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: SPM
%        
   [gamma,oo] = manage(o,varargin,@Brew,@Eigen,@Normalize,@Partition,...
                       @Trf,@Constrain,@Consd,@Consr,@Process,@Nyq);
   oo = gamma(oo);
end              

%==========================================================================
% Brew All
%==========================================================================

function oo = OldBrew(o)               % Brew All                      
   oo = o;
   oo = Normalize(oo);                 % first normalize the system
   oo = Eigen(oo);                     % brew eigenvalues
   oo = Trfd(oo);
   oo = Consd(oo);
end
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
function oo = Partition(o)             % Partition System              
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
      case 'strf'
         oo = TrfDouble(o);
      otherwise
         error('bad selection');
   end
      
      % unconditional hard refresh of cache
      
   cache(oo,oo);                       % hard refresh cache
   progress(o);                        % progress complete
end
function oo = TrfDouble(o)             % Double Transfer Matrix        
   oo = brew(o,'Partition');           % brew partial matrices
   
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
function oo = TrfModal(o)              % Modal Tranfer Matrix          
%  refresh(o,{@plot,'About'});         % don't come back here!!!
   
   %oo = current(o);
   oo = brew(o,'Partition');          % brew partial matrices
   
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

   function Hs = CancelH(o,Hs)         % Set Cancel Epsilon for H(s)   
      eps = opt(o,'cancel.H.eps');
      Hs = opt(Hs,'control.verbose',control(o,'verbose'));

      if ~isempty(eps)
         Hs = opt(Hs,'eps',eps);
      end
   end
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
function Ls = CancelL(o,Ls)            % Set Cancel Epsilon            
   eps = opt(o,'cancel.L.eps');
   Ls = opt(Ls,'control.verbose',control(o,'verbose'));

   if ~isempty(eps)
      Ls = opt(Ls,'eps',eps);
   end
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

   oo = L0(o);                         % open loop incorporating mu
   oo = Force(oo);                     % calc force trf
   oo = Elongation(oo);                % calc elongation trf
   oo = Velocity(oo);                  % calc velocity trf
   oo = Acceleration(oo);              % calc acceleration trf
   
   function oo = L0(o)                 % Calc L0(s)                     
   %
   % L0   Calculate L0(s)
   %      Remember:
   %         H31(s) = - G31(s)/G33(s)
   %         L1(s)  = H31(s)
   %         L0(s)  = -mu*H31(s) = mu * G31(s)/G33(s)
   %
      [G31,G33] = cook(o,'G31,G33');
      mu = opt(o,{'process.mu',0.1});     % friction coefficient

      G31 = CancelL(o,G31);
      
         % calculate L0(s) = -mu*L1(s)
      
      L0 = mu * G31/G33;
      L0 = set(L0,'name','L0(s)');
   
         % store L in cache
      
      oo = cache(o,'process.L0',L0);
   end
   function oo = Force(o)              % Calc Force Transfer Function  
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
      mu = opt(o,{'process.mu',0.1});     % friction coefficient

      [G31,G32,G33,H31,L0] = cook(o,'G31,G32,G33,H31,L0');

         % first way to calculate: T0 = mu / (1 + L0(s))
         
      L0 = CancelT(o,L0);                 % set cancel epsilon
      T0 = mu / (1 + L0);
         
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
   function Ts = CancelT(o,Ts)         % Set Cancel Epsilon            
      eps = opt(o,'cancel.T.eps');
      Ts = opt(Ts,'control.verbose',control(o,'verbose'));
      if ~isempty(eps)
         Ts = opt(Ts,'eps',eps);
      end
   end
end

%==========================================================================
% Nyquist Stuff
%==========================================================================

function oo = Nyq(o)                   % Brew Nyquist Stuff            
   o = with(o,'nyq');                  % unwrap nyquist options
   
   oo = current(o);
   oo = brew(oo,'Partition');          % brew partial matrices
   
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
