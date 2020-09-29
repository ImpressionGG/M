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
                       @Step,@Ramp,...
                       @PhiDouble,@PhiRational,@TrfmDouble,@TrfmRational,...
                       @Quick,@Modal1,@Modal2,@Modal3,...
                       @MotionOverview,@MotionProfile,@MotionPaste);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Study Menu              
   %oo = mitem(o,'Transition Matrix');
   %ooo = mitem(oo,'Double',{@WithCuo,'PhiDouble'});
   %ooo = mitem(oo,'Rational',{@WithCuo,'PhiRational'});

   oo = mitem(o,'Transfer Matrix');
   ooo = mitem(oo,'Double',{@WithCuo,'TrfmDouble'});
   ooo = mitem(oo,'Rational',{@WithCuo,'TrfmRational'});   

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
   
   oo = mitem(o,'-');
   oo = mitem(o,'Arithmetics');
   ooo = mitem(oo,'Quick',{@Quick});

   oo = mitem(o,'Modal Form');
   ooo = mitem(oo,'Modal 1',{@Modal1});
   ooo = mitem(oo,'Modal 2',{@Modal2});
   ooo = mitem(oo,'Modal 3',{@Modal3});

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
   
   G = cache(o,'trfd.G');
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

