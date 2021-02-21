function oo = study(o,varargin)        % Do Some Studies
%
% STUDY   Several studies
%
%       oo = study(o,'Menu')           % setup study menu
%
%       oo = study(o,func)             % call local study function
%
%    See also: SPM, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,@WithSho,@WithBsk,...
                       @Step,@Ramp,@Transform,...
                       @PhiDouble,@PhiRational,...
                       @TrfmDouble,@TrfmRational,@TrfmInversion,...
                       @Quick,@Modal1,@Modal2,@Modal3,@Bilinear,...
                       @MagniCheck,...
                       @MotionOverview,@MotionProfile,@MotionPaste);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Study Menu              
   if ~setting(o,{'study.menu',1})
      visible(o,0);
      oo = o; return
   end

   oo = mitem(o,'Transfer Matrix');
   ooo = mitem(oo,'Double',{@WithCuo,'TrfmDouble'});
   ooo = mitem(oo,'Rational',{@WithCuo,'TrfmRational'});   
   ooo = mitem(oo,'Inversion',{@WithCuo,'TrfmInversion'});   

   oo = mitem(o,'Transformation');
   ooo = mitem(oo,'Eigenvalues',{@WithCuo,'Transform','EV'});
   ooo = mitem(oo,'ZPK Pole Quality',{@WithCuo,'Transform','ZpkSsPole'});
   ooo = mitem(oo,'ZPK Zero Quality',{@WithCuo,'Transform','ZpkSsZero'});
   
   oo = mitem(oo,'-');
   oo = mitem(o,'Step Response');
   ooo = mitem(oo,'Force Step F1',{@WithCuo,'Step'},1);
   ooo = mitem(oo,'Force Step F2',{@WithCuo,'Step'},2);
   ooo = mitem(oo,'Force Step F3',{@WithCuo,'Step'},3);
   oo = mitem(o,'Ramp Response');
   ooo = mitem(oo,'Force Ramp F1',{@WithCuo,'Ramp'},1);
   ooo = mitem(oo,'Force Ramp F2',{@WithCuo,'Ramp'},2);
   ooo = mitem(oo,'Force Ramp F3',{@WithCuo,'Ramp'},3);
   
   oo = mitem(o,'-');
   oo = mitem(o,'A,B,C,D');
   ooo = mitem(oo,'Inspect B',{@InspectB});
   ooo = mitem(oo,'Canonic',{@Canonic});
   oo = mitem(o,'Normalizing')
   ooo = mitem(oo,'Magnitude Check',{@WithCuo,'MagniCheck'});
   
   oo = mitem(o,'-');
   oo = mitem(o,'Arithmetics');
   ooo = mitem(oo,'Quick',{@Quick});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Modal Add',{@ModalAdd});
   ooo = mitem(oo,'Modal Mul',{@ModalMul});

   oo = mitem(o,'Modal Form');
   ooo = mitem(oo,'Modal 1',{@Modal1});
   ooo = mitem(oo,'Modal 2',{@Modal2});
   ooo = mitem(oo,'Modal 3',{@Modal3});
 
   oo = mitem(o,'Bilinear');
   ooo = mitem(oo,'L0(s) Pole Transformation',{@WithCuo,'Bilinear'},'P');
   ooo = mitem(oo,'L0(s) Zero Transformation',{@WithCuo,'Bilinear'},'Z');
   
   oo = mitem(o,'-');
   oo = mitem(o,'Motion');
   ooo = mitem(oo,'Motion Overview',{@WithCuo,'MotionOverview'});
   ooo = mitem(oo,'Motion Profile',{@WithCuo,'MotionProfile'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Paste Motion Object',{@WithCuo,'MotionPaste'});
end

%==========================================================================
% Launch Callbacks
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% WITHSHO General callback for operation on shell object
%         with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   gamma = eval(['@',mfilename]);
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
  end
  dark(o);                            % do dark mode actions
end
function oo = WithBsk(o)               % 'With Basket' Callback        
%
% WITHBSK  Plot basket, or perform actions on the basket, screen clearing, 
%          current object pulling and forwarding to executing local func-
%          tion, reporting of irregularities and dark mode support
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
 
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end

%==========================================================================
% Transfer Matrix
%==========================================================================

function o = OldPhiDouble(o)           % Rational Transition Matrix    
   G = cache(o,'trfm.G');
   disp(G);
   
   Gij = peek(G,1,1);
   Gij = opt(Gij,'maxlen',200);
   str = display(Gij);
   
   comment = {};
   for (i=1:size(str,1))
      comment{i} = str(i,:);
   end
   message(o,'Transferfunction G(1,1)',comment);
end
function o = VeryOldPhiDouble(o)       % Rational Transition Matrix    
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
         oo = cache(oo,['brew.',numtag],numi);

         dentag = sprintf('den_%g_%g',i,j);
         oo = cache(oo,['brew.',dentag],den);
      end
   end
   
   oo = cache(oo,'brew.G',G);          % store in cache
   cache(oo,oo);                       % cache store back to shell
   
   fprintf('Transfer Matrix (calculated using double)\n');
   display(var(oo,'G'));
end
function o = OldPhiRational(o)         % Double Transition Matrix      
   message(o,'PhiRational: not yet implemented');
end

function o = TrfmDouble(o)             % Double Transfer Matrix        
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   G = cook(o,'G');
   disp(G);
   
   Gij = peek(G,1,1);
   Gij = opt(Gij,'maxlen',200);
   str = display(Gij);
   
   comment = {};
   for (i=1:size(str,1))
      comment{i} = str(i,:);
   end
   message(o,'Transfer Function G(1,1)',comment);
end
function o = TrfmRational(o)           % Rational Transfer Matrix      
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   G = cache(o,'trfr.G');
   disp(G);
   
   Gij = peek(G,1,1);
   Gij = opt(Gij,'maxlen',200);
   str = display(Gij);
   
   comment = {};
   for (i=1:size(str,1))
      comment{i} = str(i,:);
   end
   message(o,'Transfer Function G(1,1)',comment);
end
function o = TrfmInversion(o)          % Invers. Based Transfer Matrix 
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
      % calculate G31(s)
      
   [A,B,C,C_3,B_1,CP,DP,N0,M0] = cook(o,'A,B,C,C_3,B_1,CP,DP,N0,M0');
   poles = eig(A);
   
      % invert system for calculation of zeros

   Ai = A - B_1*inv(DP)*CP;
   zeros = eig(Ai);
   
      % use control toolbox
   
   S = ss(A,B_1,C_3,0);
   G = zpk(S);
   [z,p,k] = zpkdata(G);
   z = z{1};  p = p{1};   
end

%==========================================================================
% Transformation
%==========================================================================

function o = Transform(o)
   oo = current(o);
   [A,B,C,D,omega] = cook(oo,'A,B,C,D,omega');
   n = length(A)/2;
   
   mode = arg(o,1);
   switch mode
      case 'EV'
         EvQuality(o);
      case 'ZpkSsPole'
         ZpkSsPoleQuality(o);
      case 'ZpkSsZero'
         ZpkSsZeroQuality(o);
   end
         
   function o = EvQuality(o)
         % check eigenvalue quality with double arithmetics

      s = eig(A);
      om = reshape(sort(abs(s)),2,n);
      err = om(1,:)' - omega;

      txt1 = sprintf('eigenvalue quality of double arithmetics: err = %g',...
                     norm(err));

         % check eigenvalue quality with VPA arithmetics

      s = eig(vpa(A,32));
      om = reshape(sort(abs(s)),2,n);
      err = om(1,:)' - omega;

      txt2 = sprintf('eigenvalue quality of VPA 32 digit arithmetics: err = %g',...
                     norm(err));

         % check eigenvalue quality with VPA arithmetics

      s = eig(vpa(A,64));
      om = reshape(sort(abs(s)),2,n);
      err = om(1,:)' - omega;

      txt3 = sprintf('eigenvalue quality of VPA 64 digit arithmetics: err = %g',...
                     norm(err));

         % report results

      o = opt(o,'fontsize.comment',12);
      message(o,'Numeric Quality',{txt1,txt2,txt3});

      heading(cuo);
   end
   function o = ZpkSsPoleQuality(o)

      % check pole quality with double arithmetics

      G31 = cook(o,'G31');
      [z,p,k] = zpk(G31);
      
      om = reshape(sort(abs(p)),2,n);
      err = om(1,:)' - omega;

      txt1 = sprintf('G31 pole quality of double arithmetics: err = %g',...
                     norm(err));
      fprintf('%s\n',txt1);
                  
         % check pole quality with VPA 32 digit arithmetics

      digits(32);
      AA = vpa(A);  B1 = vpa(B(:,1));  C3 = vpa(C(3,:));
      G31 = zpk(system(corasim,AA,B1,C3));
      [z,p,k] = zpk(G31);
      
      om = reshape(sort(abs(p)),2,n);
      err = om(1,:)' - omega;

      txt2 = sprintf('G31  pole quality of VPA 32 digit arithmetics: err = %g',...
                     norm(err));
      fprintf('%s\n',txt2);

         % check pole quality with VPA 64 digit arithmetics

      digits(64);
      AA = vpa(A);  B1 = vpa(B(:,1));  C3 = vpa(C(3,:));
      G31 = zpk(system(corasim,AA,B1,C3));
      [z,p,k] = zpk(G31);

      om = reshape(sort(abs(p)),2,n);
      err = om(1,:)' - omega;

      txt3 = sprintf('G31 pole quality of VPA 64 digit arithmetics: err = %g',...
                     norm(err));
      fprintf('%s\n',txt3);

                  % report results

      o = opt(o,'fontsize.comment',12);
      message(o,'Numeric Pole Quality of ZpkSs Transformation',{txt1,txt2,txt3});

      digits(32);
      heading(cuo);
   end
   function o = ZpkSsZeroQuality(o)
                  
         % check zero quality with double arithmetics
                  
      AA = A;  B1 = B(:,1);  C3 = C(3,:);
      oo = system(corasim,AA,B1,C3);
      G31 = zpk(oo);
      [z,p,k] = zpk(G31);
      
          % start with a double based zero check
          
      err = trfval(oo,z);
      txt3 = sprintf('G31 zero quality of double arithmetics (double based check): err = %g',...
                     norm(err));
      fprintf('%s\n',txt3);

          % repeat check VPA based
          
      digits(32);
      err = trfval(oo,vpa(z));
   
      txt4 = sprintf('G31 zero quality of double arithmetics (VPA 32 based check): err = %g',...
                     norm(err));
      fprintf('%s\n',txt4);
                  
         % check zero quality with VPA 32 arithmetics
                  
      digits(32);
      AA = vpa(A);  B1 = vpa(B(:,1));  C3 = vpa(C(3,:));
      oo = system(corasim,AA,B1,C3);
      G31 = zpk(oo);
      [z,p,k] = zpk(G31);
      err = trfval(oo,z);
      err = trfval(oo,vpa(z,64));
   
      txt5 = sprintf('G31 zero quality of VPA 32 digit arithmetics: err = %g',...
                     norm(err));
      fprintf('%s\n',txt5);

         % check zero quality with VPA 64 arithmetics
            
      digits(64);
      AA = vpa(A);  B1 = vpa(B(:,1));  C3 = vpa(C(3,:));
      oo = system(corasim,AA,B1,C3);
      G31 = zpk(oo);
      [z,p,k] = zpk(G31);
      err = trfval(oo,z);
      err = trfval(oo,vpa(z,64));
   
      txt6 = sprintf('G31 zero quality of VPA 64 digit arithmetics: err = %g',...
                     norm(err));
      fprintf('%s\n',txt6);

      digits(128);
      AA = vpa(A);  B1 = vpa(B(:,1));  C3 = vpa(C(3,:));
      oo = system(corasim,AA,B1,C3);
      G31 = zpk(oo);
      [z,p,k] = zpk(G31);
      err = trfval(oo,z);
      err = trfval(oo,vpa(z,64));
   
      txt7 = sprintf('G31 zero quality of VPA 128 digit arithmetics: err = %g',...
                     norm(err));
      fprintf('%s\n',txt7);

                  % report results

      o = opt(o,'fontsize.comment',12);
      message(o,'Numeric Zero Quality of ZpkSs Transformation',...
                {txt3,' ',txt4,txt5,txt6,txt7});

      digits(32);
      heading(cuo);
   end
end

%==========================================================================
% Step/Ramp Responses
%==========================================================================

function o = Step(o)                   % Step Response                 
   plot(o,'Step',arg(o,1));            % forward to plot mmethod
end
function o = Ramp(o)                   % Ramp Response                 
   plot(o,'Ramp',arg(o,1));            % forward to plot mmethod
end

%==========================================================================
% Data Inspection
%==========================================================================

function o = InspectB(o)               % System Matrix Inspection      
   o = sho;
   if length(o.data) < 2
      message(o,'At least 2 Objects to be loaded!');
      return
   end
   
   o1 = o.data{1};
   [A,B,C,D] = data(o1,'A,B,C,D');
   B2 = B(4:end,:);  B2(1,2) = 0;  B2(2,1) = 0;
   
   o2 = o.data{2};
   [AA,BB,CC,DD] = data(o2,'A,B,C,D');
   BB2 = BB(4:end,:);  BB2(1,2) = 0;  BB2(2,1) = 0;
   
   K = 1e11;
   B2_1=round(K*B2),B2_2=round(K*BB2) 
end
function o = Canonic(o)                % Transform to Canonic Form     
%
% CANONIC  transform any system to Schur form and thebn to 1st and second
%          canonical form. All systems have the same treansfer matrix:
%
%                              5 s + 2        
%             G(s)  =   ----------------------
%                         s^2 + 0.8 s + 4.16  
%
   om = 2;  zeta = 0.1;
   
      % Rational form (complex eigen values)
      
   Ar = [-2*zeta 1; -1 -2*zeta]*om;
   Br = [1;2];  Cr = [1 2];  Dr = 0;
   
   or = system(corasim,Ar,Br,Cr,Dr);
   fprintf('Real form\n');
   display(or)
   display(trf(set(or,'name','Initial')));
      
      % transform to controllable canonic form
      
   Qc = [Br Ar*Br];
   I = eye(size(Ar));
   t = (I(end,:)/Qc)';
   Tc = [t'; t'*Ar];
   
   Ac = Tc*Ar/Tc;  Bc = Tc*Br;  Cc = Cr/Tc;  Dc = Dr; 
   
   oc = system(corasim,Ac,Bc,Cc,Dc);
   fprintf('Canonical controllable form\n');
   display(oc)
   display(trf(set(oc,'name','Control')));
end
function o = MagniCheck(o)             % Magnitude Check               
   T0 = 1.0;   
   oo = opt(o,'brew.T0',T0);
   oo = cache(oo,oo,[]);               % clear cache hard
%  L0 = cook(oo,'Sys0');
   [sys,L0] = contact(oo);

   A0 = data(L0,'A');
   s = eig(A0);
   center = abs(mean(real(s)));   
   om = logspace(round(log10(center*1e-1)),round(log10(center*1e3)),1000);

   PlotEig(o,2211);
   PlotMagni(o,2212);

      % normalizing constant T0=1e-3
   
   T0 = 1e-3;
   oo = opt(o,'brew.T0',T0);
   oo = cache(oo,oo,[]);               % clear cache hard
%  L0 = cook(oo,'Sys0');
   [sys,L0] = contact(oo);
   
   PlotEig(o,2221);
   PlotMagni(o,2222);                  % magnitude plot of scaled system

   function PlotEig(o,sub)
      subplot(o,sub);

      [A0,B0,C0,D0] = data(L0,'A,B,C,D');
      s = eig(A0);
      center = abs(mean(real(s)));
      
      plot(o,real(s),imag(s),'rrwp');
      set(gca,'xlim',center*[-3 +3]);
      title('Eigenvalues of L0 System');
      subplot(o);
   end
   function PlotMagni(o,sub)
      subplot(o,sub);

      [A0,B0,C0,D0] = data(L0,'A,B,C,D');
      s = eig(A0);
      center = abs(mean(real(s)));
      
      oo = with(oo,'bode');
      Om = om*T0;
      Ljw = 0*om;  I = eye(size(A0));
      for (k=1:length(om))
         Ljwk = C0*inv(1i*Om(k)*I-A0)*B0 + D0;
         Ljw(k) = Ljwk(1);
      end
      set(semilogx(om,20*log10(abs(Ljw)),'y'),'color',o.color('yyr'),'linewidth',1);
      subplot(o);
   end
end

%==========================================================================
% Arithmetics
%==========================================================================

function o = Quick(o)                  % Quick Arithmetics Study       
   RandInt;                            % reset random seed
   O = base(corinth,10);
   
      % prepare numbers
      
   N = 1000;  M = 20;
   for (i=1:N)
      X{i} = RandDigits(O,M);
      Y{i} = RandDigits(O,M);
   end

      % corinthian add benchmark
      
   tic
   for (i=1:N)
      Z{i} = add(O,X{i},Y{i});
      assert(isequal(Z{i},Z{i}));
   end
   fprintf('corinthian add benchmark: %g us\n',toc/N*1e6);
   
      % quick add benchmark
      
   tic
   for (i=1:N)                         % generate numbers
      S{i} = qadd(O,X{i},Y{i});
      assert(isequal(S{i},Z{i}));
   end
   fprintf('quick add benchmark: %g us\n',toc/N*1e6);
   
       % corinthian sub benchmark
      
   tic
   for (i=1:N)
      Z{i} = sub(O,X{i},Y{i});
      assert(isequal(Z{i},Z{i}));
   end
   fprintf('corinthian sub benchmark: %g us\n',toc/N*1e6);
   
      % quick sub benchmark
      
   tic
   for (i=1:N)                         % generate numbers
      S{i} = qsub(O,X{i},Y{i});
      assert(isequal(S{i},Z{i}));
   end
   fprintf('quick sub benchmark: %g us\n',toc/N*1e6);
   
      % corinthian mul benchmark
      
   tic
   for (i=1:N)
      Z{i} = mul(O,X{i},Y{i});
      assert(isequal(Z{i},Z{i}));
   end
   fprintf('corinthian mul benchmark: %g us\n',toc/N*1e6);
   
      % quick mul benchmark
      
   tic
   for (i=1:N)                         % generate numbers
      S{i} = Qmul(O,X{i},Y{i});
      assert(isequal(Z{i},S{i}));
   end
   fprintf('quick mul benchmark: %g us\n',toc/N*1e6);

   % test done!
      
   fprintf('All Quick operations successful :-)\n');
   
   function oo = Qadd(o,x,y)           % Quick Addition                
      b = o.data.base;
      nx = length(x);  
      ny = length(y);  
      n = 1+max(nx,ny);
      
      x = [zeros(1,n-nx),x];
      y = [zeros(1,n-ny),y];
      
      %abacus = [x; y];
      
      while (any(y~=0))
         x = x+y;
         y = (x >= b);
         x = x - y*b;
         y = [y(2:end), 0];
         %abacus = [abacus; nan*x; x; y];        
      end
         
      idx = find(x~=0);
      if ~isempty(idx)
         x(1:idx(1)-1) = [];
      end
      oo = x;
   end
   function z = Qmul(o,x,y)
      sgn = +1;
      if any(x < 0)
         x = -x;  sgn = -sgn;
      end      
      if any(y < 0)
         y = -y;  sgn = -sgn;
      end
      
      z = conv(x,y);
      z = sgn * qtrim(o,z);
   end
   function x = Qtrim(o,x)             % Quick Trim                    
      b = o.data.base;      
      c = floor(x/b);                  % carry
      
      while any(c)                     % while any non processed carry
         x = [0 x-c*b];                % selective subtract carry*base
         c = [c 0];                    % left shift carry 
         x = x + c;                    % add shifted carry to result
         c = floor(x/b);               % calculate new carry
      end

      idx = find(x~=0);
      if ~isempty(idx)
         x(1:idx(1)-1) = [];
      end
   end
   function y = Digitize(o,x)          % Digitize Number               
      b = o.data.base;

      y = [];
      while (x ~= 0)
         y(end+1) = rem(x,b);
         x = floor(x/b);
      end
      y = y(length(y):-1:1);
   end
   function z = RandDigits(o,m)        % Random Digits Generator       
      z = [];
      for (jj=1:m)
         xpo = RandInt(8);
         w = RandInt(10^xpo);
         z = [z Digitize(o,w)];
      end
   end
   function s = RandSign               % Random Sign                   
      if (randn >= 0)
         s = +1;
      else
         s = -1;
      end
   end
end
function o = ModalAdd(o)               % Add 2 Modal Systems           
   O = corasim;
   G1 = trf(O,1,[1 0 4]);
   G2 = trf(O,1,[1 0 9]);
   
   [p1,q1] = peek(G1);
   [p2,q2] = peek(G2);
   
   o1 = modal(G1,p1,q1);
   o2 = modal(G2,p2,q2);
   
   [A1,B1,C1,D1] = system(o1);
   [A2,B2,C2,D2] = system(o2);
   
   n1 = length(A1)/2;
   n2 = length(A2)/2;
   a0 = [var(o1,'a0'); var(o2,'a0')];
   a1 = [var(o1,'a1'); var(o2,'a1')];
   
   B = [B1(n1+1:2*n1); B2(n2+1:2*n2)];
   C = [C1(1:n1) C2(1:n2)];
   
   A = [zeros(n1+n2), eye(n1+n2); -diag(a0), -diag(a1)];
   B = [0*B; B]; C = [C, 0*C];  D = D1+D2;
   
   oo = system(O,A,B,C,D);
end
function o = ModalMul(o)               % Mul 2 Modal Systems           
%
%  x1' = A1*x1 + B1*u
%  y1  = C1*x1 + D1*u
%
%  x2' = A2*x2 + B2*y1 = A2*x2 + B2*(C1*x1 + D1*u)
%  y2  = C2*x2 + D2*y1 = C2*x2 + D2*(C1*x1 + D1*u) 
%  
%  x2' = (B2*C1)*x1 + A2*x2 + B2*D1*u
%  y2  = (D2*C1)*x1 + C2*x2 + D2*D1*u 
%  
%  Partial system:
%
%     z1' = (d+j*w)*z1 + b1'*u
%     z2' = (d-j*w)*z2 + b2'*u
%     y = c1*z1 + c2*z2 + d*u
%
%  Assert: z1 = x1 + j*x2, z2 = x1 - j*x2, u = Re{u}, Im{b1'} = -Im{b2'}
%
%  thus: x1 = Re{z1} = Re{z2}, x2 = Im{z1} = -Im{z2}
%
%     x1' = Re{z1'} = Re{(d+j*w) * (x1+j*x2) + b1'*u}
%         = d*x1 - w*x2 + Re{b1'}*u
%
%     x2' = Im{z1'} = Im{(d+j*w) * (x1+j*x2) + b1'*u}
%         = d*x2 + w*x1 + Im{b1'}*u
%
%     y = c1*(x1+j*x2) + c2*(x1-j*x2) + d*u
%
%  alternatively:
%
%     x1' = Re{z2'} = Re{(d-j*w) * (x1-j*x2) + b2'*u}
%         = d*x1 - w*x2 + Re{b2'}*u
%         = d*x1 - w*x2 + Re{b1'}*u
%
%     x2' = -Im{z2'} = -Im{(d-j*w) * (x1-j*x2) + b1'*u}
%         = d*x2 + w*x1 - Im{b2'}*u
%         = d*x2 + w*x1 + Im{b1'}*u
%
%  Now substitute: z := z1 + z2,  v := -j*(z1 - z2)
%
%     z' = z1' + z2' = (d+j*w)*z1 + (d-j*w)*z2 + (b1'+b2')*u =
%                    = d*(z1+z2) + j*w*(z1-z2) + 2*Re{b1'}*u
%                 z' = d*z - w*v + 2*Re{b1'}*u
%
%     v' = -j*(z1'-z2') = -j*(d+j*w)*z1 + j*(d-j*w)*z2 - j*(b1'-b2')*u =
%                       = w*(z1+z2) - j*d*(z1-z2) + 2*Im{b1'}*u
%                 v' = w*z + d*v + 2*Im{b1'}*u
%
% At least we have a system with real coefficients :-)
%
%                 z' = d*z - w*v + bz'*u    with bz := 2*Re{b1}
%                 v' = w*z + d*v + bv'*u    with bv := 2*Im{b1}
%
% Transfer function
%
%    s*z = d*z - w*v + bz'*u  => (s-d)*z = -w*v + bz'*u
%    s*v = w*z + d*v + bv'*u  => s2*v = 
%
   O = corasim;
   G1 = trf(O,1,[1 1 4]);
%  G2 = trf(O,1,[1 1 9]);
   G2 = trf(O,1,[1 1 4]);
   
   [p1,q1] = peek(G1);
   [p2,q2] = peek(G2);
   
   o1 = modal(G1,p1,q1);
   o2 = modal(G2,p2,q2);
   
   [A1,B1,C1,D1] = system(o1);
   [A2,B2,C2,D2] = system(o2);
   
   n1 = length(A1)/2;
   n2 = length(A2)/2;
   a0 = [var(o1,'a0'); var(o2,'a0')];
   a1 = [var(o1,'a1'); var(o2,'a1')];
   
   Bv = [B1(n1+1:2*n1); B2(n2+1:2*n2)]; 
   Cz = [C1(1:n1) C2(1:n2)]; 
   Az = B2(n2+1:2*n2)*C1(1:n1);
   A21 = Az*[0 0; 1 0] - diag(a0);
   A22 = -diag(a1);
   
   A = [zeros(n1+n2), eye(n1+n2); A21, A22];
   B = [0*Bv; Bv]; C = [Cz, 0*Cz];  D = D1+D2;
   
   oo = system(O,A,B,C,D);
   
      % diagonalization:  x = V*z => z = inv(V)*x = W*x with W := inv(V)
      %
      %    x' = A*x + B*u
      %    z' = W*x'= W*A*x + W*B*u
      %
      %    z' = W*A*V*z + W*B*u
      %    y = C*x + D*u = C*V*z + D*u
      %
      %    z' = Q*z + W*B*u   with Q := W*A*V
      %    y  = C*V*z + D*u
      
   [V,Dg] = eig(A);
   err = norm(Dg-diag(diag(Dg)));
   
   W = inv(V);
   Dg = W*A*V;
   err = norm(Dg-diag(diag(Dg)));
end

%==========================================================================
% Modal Representation
%==========================================================================

function o = Modal1(o)                 % Modal Representation 1        
%
% MODAL1   Modal form of the following transfer function
%
%                     p(s)        4          16          20 s^2 + 100 
%             G(s) = ------ = --------- + --------- = -------------------
%                     q(s)     s^2 + 4     s^2 + 9     s^4 + 13 s^2 + 36
%
   num = [20 0 100];  den = [1 0 13 0 36];
   
   oo = inherit(corasim,o);
   oo = modal(oo,num,den);
   oo
end
function o = Modal2(o)                 % Modal Representation 2        
   s = @(a)a(2)/2 + sqrt(-a(3)+a(2)^2/4);

      % set simulation parameters ...
      
   o = opt(o,'simu.tmax',10,'simu.dt',0.001); 

      % define characteristic factors and M matrix
      
   psi1 = [1 0.4 4];  psi2 = [1 0.6 9];  psi3 = [1 0.8 16];
   M = [2 3 4]';

      % calculate numerator and denominator
      
   p1 = M(1)^2 * conv(psi2,psi3);      % p1(s) = M(1)^2 * psi2(s)*psi3(s)
   p2 = M(2)^2 * conv(psi1,psi3);      % p2(s) = M(2)^2 * psi1(s)*psi3(s)
   p3 = M(3)^2 * conv(psi1,psi2);      % p3(s) = M(3)^2 * psi1(s)*psi2(s)
   
   num = p1 + p2 + p3;                 % num(s) = p1(s) + p2(s) + p3(s)
   den = conv(psi1,conv(psi2,psi3));   % den(s) = psi1(s)*psi2(s)*psi3(s)
   
      % create transfer function system 1
      
   o1 = system(corasim,{num,den});
   o1 = step(inherit(o1,o));           % simulate step responses
   [t1,y1]=var(o1,'t,y');              % simulation results

      % plot results of system 1
      
   cls(o);
   plot(o,t1,y1,'r');
   hold on;
   subplot(o);
   
      % calculate & plot characteristic transfer functions
      
   Characteristic1(o);                 % characteristic trf version 1
   Characteristic2(o);                 % characteristic trf version 2
   
      % modal representation
      
   o2 = modal(corasim,num,den);
   o2 = step(inherit(o2,o));           % simulate step responses
   [t2,y2] = var(o2,'t,y');            % simulation results
         
   plot(o,t2,y2,'bc-.');
   
   function Characteristic1(o)         % Char Transfer Functions       
      o_1 = system(corasim,{M(1)^2,psi1});
      o_1 = step(inherit(o_1,o));      % simulate step responses
      [t_1,~,y_1]=var(o_1,'t,x,y,u');  % simulation results

      o_2 = system(corasim,{M(2)^2,psi2});
      o_2 = step(inherit(o_2,o));      % simulate step responses
      [t_2,~,y_2]=var(o_2,'t,x,y,u');  % simulation results

      o_3 = system(corasim,{M(3)^2,psi3});
      o_3 = step(inherit(o_3,o));      % simulate step responses
      [t_3,~,y_3]=var(o_3,'t,x,y,u');  % simulation results
      
      plot(o,t_1,y_1,'ggwwww5');
      plot(o,t_2,y_2,'gbwwww5');
      plot(o,t_3,y_3,'gcwwww5');
      
         % plot overal step response
         
      plot(o,t_1,y_1+y_2+y_3,'y5');
   end
   function Characteristic2(o)         % Char Transfer Functions       
      O_1 = system(corasim,{p1,den});
      O_1 = step(inherit(O_1,o));      % simulate step responses
      [T_1,Y_1]=var(O_1,'t,y');        % simulation results

      O_2 = system(corasim,{p2,den});
      O_2 = step(inherit(O_2,o));      % simulate step responses
      [T_2,Y_2]=var(O_2,'t,y');        % simulation results

      O_3 = system(corasim,{p3,den});
      O_3 = step(inherit(O_3,o));      % simulate step responses
      [T_3,Y_3]=var(O_3,'t,y');        % simulation results
      
      plot(o,T_1,Y_1,'bk-.');
      plot(o,T_2,Y_2,'bk-.');
      plot(o,T_3,Y_3,'bk-.');
   end
end
function o = Modal3(o)                 % Modal Representation 3        
   o1 = new(corasim,'Modal');          % modal system representation
   o1.par.system.D = 0;                % make system strictly proper
   
      % set simulation parameters ...
      
   o = opt(o,'simu.tmax',10,'simu.dt',0.001); 

      % step response of modal form system ...
   
   o1 = step(inherit(o1,o));           % simulation @ inherit simu param's
   [t1,x1,y1,u1]=var(o1,'t,x,y,u');    % simulation results
      
      % make a new system based on numerator/denominator
      
   [num,den] = peek(o1);               % peek numerator/denominator
   o2 = system(corasim,{num,den});
   o2 = step(inherit(o2,o));           % simulation @ inherit simu param's
   [t2,x2,y2,u2]=var(o1,'t,x,y,u');    % simulation results
   
      % let's check whether simulation results are the same
      
   err = norm(y2-y1);
   if (err ~= 0)
      error('differing simulation results');
   end      
   
      % create a modal system using corasim/modal method
      % the system in modal form is created from num/den
      
   o3 = modal(corasim,num,den);
end

%==========================================================================
% Bilinear Transformation
%==========================================================================

function o = Bilinear(o)  
   mode = arg(o,1);
   L0 = cook(o,'L0');
   [zeros,poles,k] = zpk(L0);
   
   col = {'r','g','m','bc','yyr'};
   
   Om0 = [10 20 100 1000];
   for (i=1:length(Om0))
      switch mode
         case 'P'
            z = (Om0(i)+poles) ./ (Om0(i)-poles);
         case 'Z'
            z = (Om0(i)+zeros) ./ (Om0(i)-zeros);
      end
      subplot(o,121);
      plot(o,1:length(z),abs(z),[col{i},'1']);
      hold on;
      subplot(o);
      
      subplot(o,122);
      plot(o,real(z),imag(z),[col{i},'p']);
      hold on
      plot(o,real(z.^200),imag(z.^200),[col{i},'p']);
      set(gca,'DataAspectRatio',[1 1 1]);
      subplot(o);
   end
end

%==========================================================================
% Motion Overview
%==========================================================================

function o = MotionOverview(o)         % Motion Overview               
   [smax,vmax,amax,tj] = opt(with(o,'motion'),'smax,vmax,amax,tj');
   oo = inherit(corasim,o);
   oo = data(oo,'smax,vmax,amax,tj',smax,vmax,amax,tj);
   oo = data(oo,'tunit,sunit','s','mm');
   oo.par.title = 'Motion Overview';
   motion(oo,'Overview');
end
function o = MotionProfile(o)          % Plot Motion Profile           
   oo = inherit(type(corasim,'motion'),o);
   oo = data(oo,opt(o,'motion'));
   plot(oo);
end
function o = MotionPaste(o)            % Paste Motion Object           
   refresh(o,{@plot,'About'});         % prevent infinite recursion
   oo = inherit(type(corasim,'motion'),o);
   oo = data(oo,opt(o,'motion'));
   oo.par.title = sprintf('Motion Object (%s)',datestr(now));
   paste(o,{oo});
end

%==========================================================================
% Helper
%==========================================================================

function r = RandInt(n)                % Random Integer Number         
%
% RAND   Random number generation
%
%           r = Rand(6)                % random numbers in range 1..6
%           Rand                       % reset random seed
%
   if (nargin == 0)
      rng(0);                          % set random seed to zero
   else
      r = ceil(n*rand);
   end
end

% stability:
%
% x`= v
% v`= A21*x + A22*v + B*u
% y = C1*x + D
% u = mu*y
%
% L0 = P/Q
% T0 = L0/(1+L0)

% idea: closed loop EV  (not so good)
%
% x`=Ax+Bu
% y =Cx
% u = -Ky
%
% x`=Ax-BKCx = (A-BKC)*x
%
% s = eig(A)
% eig(kI+A) = k+s
% eig(A-kI) = s-k
% eig(A-I) = s-1
% eig(A-F) = eig(F*(F\A-I)) 

