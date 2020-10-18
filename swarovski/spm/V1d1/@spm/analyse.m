function oo = analyse(o,varargin)      % Graphical Analysis            
%
% ANALYSE   Graphical analysis
%
%    Plenty of graphical analysis functions
%
%       analyse(o)                % analyse @ opt(o,'mode.analyse')
%
%       oo = analyse(o,'menu')    % setup Analyse menu
%       oo = analyse(o,'Surf')    % surface plot
%       oo = analyse(o,'Histo')   % display histogram
%
%    See also: SPM, PLOT, STUDY
%
   [gamma,o] = manage(o,varargin,@Err,@Menu,@WithCuo,@WithSho,@WithBsk,...
                      @Trf,@TfOverview,...
                      @LmuDisp,@LmuRloc,@LmuStep,@LmuBode,@LmuNyq,...
                      @LmuBodeNyq,@Overview,...
                      @Margin,@Rloc,@Nyquist,@OpenLoop,@Calc,...
                      @AnalyseRamp,@NormRamp,...
                      @BodePlots,@StepPlots,@PolesZeros,...
                      @EigenvalueCheck);
   oo = gamma(o);                 % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Analyse Menu            
   oo = OpenLoopMenu(o);               % add Open Loop menu
   oo = ClosedLoopMenu(o);             % add Closed Loop menu

   ooo = mitem(oo,'-'); 
   oo = Stability(o);                  % add stability menu

   ooo = mitem(oo,'-'); 
   oo = Force(o);                      % add Force menu
   oo = Acceleration(o);               % add Acceleration menu
   oo = Velocity(o);                   % add Velocity menu
   oo = Elongation(o);                 % add Elongation menu
   
   oo = mitem(o,'-');
   %oo = CriticalMenu(o);
   oo = mitem(o,'Normalized System');
   %enable(ooo,type(current(o),types));
   ooo = mitem(oo,'Force Ramp @ F2',{@WithCuo,'NormRamp'},2);
   
   oo = Checks(o);
end
function oo = OpenLoopMenu(o)          % Open Loop Menu                
   oo = mitem(o,'Open Loop');
   ooo = mitem(oo,'Overview',{@WithCuo,'OpenLoop','Lmu',1,'bcc'});
   ooo = mitem(oo,'Lmu(s)',{@WithCuo,'LmuDisp'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Poles/Zeros',{@WithCuo,'LmuRloc'});
   ooo = mitem(oo,'Step Response',{@WithCuo,'LmuStep'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Bode Plot',{@WithCuo,'LmuBode'});
   ooo = mitem(oo,'Nyquist Plot',{@WithCuo,'LmuNyq'});
   ooo = mitem(oo,'Bode/Nyquist',{@WithCuo,'LmuBodeNyq'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Calculation',{@WithCuo,'Calc','L0',1,'bcc'});
end
function oo = ClosedLoopMenu(o)        % Closed Loop Menu              
   oo = mitem(o,'Closed Loop');
   ooo = mitem(oo,'Bode Plots',{@WithCuo,'BodePlots'});
   ooo = mitem(oo,'Step Responses',{@WithCuo,'StepPlots'});
   ooo = mitem(oo,'Poles & Zeros',{@WithCuo,'PolesZeros'});
end
function oo = Stability(o)             % Closed Loop Stability         
   oo = mitem(o,'Stability');
   ooo = mitem(oo,'Stability Margin',{@WithCuo,'Margin'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Nyquist',{@WithCuo,'Nyquist'});
   ooo = mitem(oo,'Root Locus',{@WithCuo,'Rloc'});
   ooo = mitem(oo,'-');
%   ooo = mitem(oo,'Open Loop L0(s)',{@WithCuo,'OpenLoop','L0',1,'bc'});
end
function oo = Force(o)                 % Closed Loop Force Menu        
   oo = mitem(o,'Force');
   sym = 'Tf';  sym1 = 'Tf1';  sym2 = 'Tf2';  col = 'yyyr';  

   ooo = mitem(oo,'Overview',{@WithCuo,'Overview',sym1,sym2,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Tf(s)',{@WithCuo,'Trf',sym,0,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Tf1(s)',{@WithCuo,'Trf',sym1,1,col});
   ooo = mitem(oo,'Tf2(s)',{@WithCuo,'Trf',sym2,2,col});
end
function oo = Acceleration(o)          % Closed Loop Acceleration Menu 
   oo = mitem(o,'Acceleration');
   sym = 'Ta';  sym1 = 'Ta1';  sym2 = 'Ta2';  col = 'r';

   ooo = mitem(oo,'Overview',{@WithCuo,'Overview',sym1,sym2,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Ta(s)',{@WithCuo,'Trf',sym,0,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Ta1(s)',{@WithCuo,'Trf',sym1,1,col});
   ooo = mitem(oo,'Ta2(s)',{@WithCuo,'Trf',sym2,2,col});
end
function oo = Velocity(o)              % Closed Loop Velocity Menu     
   oo = mitem(o,'Velocity');
   sym = 'Tv';  sym1 = 'Tv1';  sym2 = 'Tv2';  col = 'bc';  

   ooo = mitem(oo,'Overview',{@WithCuo,'Overview',sym1,sym2,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Tv(s)',{@WithCuo,'Trf',sym,0,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Tv1(s)',{@WithCuo,'Trf',sym1,1,col});
   ooo = mitem(oo,'Tv2(s)',{@WithCuo,'Trf',sym2,2,col});
end
function oo = Elongation(o)            % Closed Loop Elongation Menu   
   oo = mitem(o,'Elongation');
   sym = 'Ts';  sym1 = 'Ts1';  sym2 = 'Ts2';  col = 'g';  

   ooo = mitem(oo,'Overview',{@WithCuo,'Overview',sym1,sym2,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Ts(s)',{@WithCuo,'Trf',sym,0,col});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Ts1(s)',{@WithCuo,'Trf',sym1,1,col});
   ooo = mitem(oo,'Ts2(s)',{@WithCuo,'Trf',sym2,2,col});
end
function oo = Checks(o)                % Checks Menu                   
   oo = mitem(o,'Checks');
   ooo = mitem(oo,'Eigenvalues',{@WithCuo,'EigenvalueCheck'});
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
   if ~type(oo,{'spm'})
      plot(oo,'About');
      return
   end
   
      % refresh caches
      
%  [oo,bag,rfr] = cache(oo,oo,'trf');  % transfer function cache segment
%  [oo,bag,rfr] = cache(oo,oo,'consd');% constrained trf cache segment
%  [oo,bag,rfr] = cache(oo,oo,'process'); % process cache segment
   
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   else
      dark(oo);                        % do dark mode actions
   end
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

function o = Err(o)                    % Error Handler                 
   error('bad mode');
end

%==========================================================================
% Stability
%==========================================================================

function o = Margin(o)                 % Stability Margin              
   stable(o);
end
function o = Rloc(o)                   % Root Locus                    
   o = with(o,'rloc');
   o = with(o,'style');
   
   sym = 'L1';
   L1 = cook(o,sym);   
   [num,den] = peek(L1);
   
   mu = opt(o,{'process.mu',0.1});
   
   oo = system(inherit(corasim,o),{-mu*num,den});
   
   subplot(o,111);
   rloc(oo);
   title(sprintf('Root Locus %s(s) - mu = %g',sym,mu));
   
   heading(o);
end
function oo = Nyquist(o)               % Nyquist Stability Analysis    
   o = with(o,{'style','bode','nyq'});
   mu = opt(o,{'process.mu',0.1});
   
   Lmu = cook(o,'Lmu');
      
   diagram(o,'Bode','',Lmu,2211);
   diagram(o,'Stability','',Lmu,2221);
   oo = diagram(o,'Nyq','',Lmu,1212);
   
   Verbose(o,Lmu);   
   heading(o);
end

%==========================================================================
% Open Loop
%==========================================================================

function o = OpenLoop(o)               % L(s) Open Loop                
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   o = with(o,{'bode','simu','rloc'});

   sym = arg(o,1);
   idx = arg(o,2);
   
   oo = cook(o,sym);
   
   if (idx == 0)
      diagram(o,'Trf','',oo,111);
   else
      title = [sym,': Open Loop Transfer Function'];
      diagram(o,'Trf', '',oo,3111,title);
      diagram(o,'Step','',oo,3221);
      diagram(o,'Rloc','',oo,3222);
      diagram(o,'Bode','',oo,3231);
      diagram(o,'Nyq','',oo,3232);
   end
   
   Verbose(o,oo);   
   heading(o);
end
function o = Calc(o)                   % Calculation of L(s)           
   sym = arg(o,1);
   idx = arg(o,2);
   col = arg(o,3);
   
   G31 = cook(o,'G31');
   G33 = cook(o,'G33');
   L0 = cook(o,'L0');
   
   diagram(o,'Calc','L0(s)',L0,4312);

   diagram(o,'Bode','',G31,4321);
   diagram(o,'Step','',G31,4322);
   diagram(o,'Rloc','',G31,4323);

   diagram(o,'Bode','',G33,4331);
   diagram(o,'Step','',G33,4332);
   diagram(o,'Rloc','',G33,4333);
   
   diagram(o,'Bode','',L0,4441);
   diagram(o,'Step','',L0,4342);
   diagram(o,'Rloc','',L0,4343);
           
   heading(o);
end

function o = LmuDisp(o)                % Display Transfer Function     
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');   
   diagram(o,'Trf','',Lmu,1111);      
   
   Verbose(o,Lmu);
   heading(o);
end
function o = LmuRloc(o)                % Poles/Zeros of Lmu(s)         
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Rloc','',Lmu,1111);  
   
   heading(o);
end
function o = LmuStep(o)                % Step Response Plot            
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Step','',Lmu,1111);  
   
   heading(o);
end
function o = LmuBode(o)                % Bode Plot                     
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Bode','',Lmu,1111);      
   
   heading(o);
end
function o = LmuNyq(o)                 % Nyquist Plot                  
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Nyq','',Lmu,1111);      

   heading(o);
end
function o = LmuBodeNyq(o)             % Bode/Nyquist Plot             
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   Lmu = cook(o,'Lmu');         
   diagram(o,'Bode','',Lmu,1211);      
   diagram(o,'Nyq','',Lmu,1212);      


   heading(o);
end

%==========================================================================
% Closed Loop
%==========================================================================

function o = BodePlots(o)              % Closed Loop Bode Plots        
   [Tf1,Tf2] = cook(o,'Tf1,Tf2');
   
   o = opt(o,'color','yyr');
   diagram(o,'Bode','Tf1(s)',Tf1,[4 2 1 1]);
   diagram(o,'Bode','Tf2(s)',Tf2,[4 2 1 2]);

   [Ts1,Ts2] = cook(o,'Ts1,Ts2');
   
   o = opt(o,'color','g');
   diagram(o,'Bode','Ts1(s)',Ts1,[4 2 2 1]);
   diagram(o,'Bode','Ts2(s)',Ts2,[4 2 2 2]);
   
   [Tv1,Tv2] = cook(o,'Tv1,Tv2');
   
   o = opt(o,'color','bc');
   diagram(o,'Bode','Tv1(s)',Tv1,[4 2 3 1]);
   diagram(o,'Bode','Tv2(s)',Tv2,[4 2 3 2]);

   [Ta1,Ta2] = cook(o,'Ta1,Ta2');
   
   o = opt(o,'color','r');
   diagram(o,'Bode','Ta1(s)',Ta1,[4 2 4 1]);
   diagram(o,'Bode','Ta2(s)',Ta2,[4 2 4 2]);
   
   heading(o);
end
function o = StepPlots(o)              % Closed Loop Step Plots        
   o = with(o,'simu');
   
   [Tf1,Tf2] = cook(o,'Tf1,Tf2');
   o = opt(o,'color','yyr');
   diagram(o,'Fstep','Tf1(s)',Tf1,4211);
   diagram(o,'Fstep','Tf2(s)',Tf2,4212);

   [Ts1,Ts2] = cook(o,'Ts1,Ts2');
   o = opt(o,'color','g');
   diagram(o,'Step','Ts1(s)',Ts1,4221);
   diagram(o,'Step','Ts2(s)',Ts2,4222);
   
   [Tv1,Tv2] = cook(o,'Tv1,Tv2');
   o = opt(o,'color','bc');
   diagram(o,'Vstep','Tv1(s)',Tv1,4231);
   diagram(o,'Vstep','Tv2(s)',Tv2,4232);
   
   
   [Ta1,Ta2] = cook(o,'Ta1,Ta2');
   o = opt(o,'color','r');
   diagram(o,'Astep','Ta1(s)',Ta1,4241);
   diagram(o,'Astep','Ta2(s)',Ta2,4242);
   
   heading(o);
end
function o = PolesZeros(o)             % Closed Loop Poles & Zeros     
   o = with(o,'simu');
   
   [Tf1,Tf2] = cook(o,'Tf1,Tf2');
   o = opt(o,'color','yyr');
   diagram(o,'Rloc','Tf1(s)',Tf1,4211);
   diagram(o,'Rloc','Tf2(s)',Tf2,4212);

   [Ts1,Ts2] = cook(o,'Ts1,Ts2');
   o = opt(o,'color','g');
   diagram(o,'Rloc','Ts1(s)',Ts1,4221);
   diagram(o,'Rloc','Ts2(s)',Ts2,4222);
   
   [Tv1,Tv2] = cook(o,'Tv1,Tv2');
   o = opt(o,'color','bc');
   diagram(o,'Rloc','Tv1(s)',Tv1,4231);
   diagram(o,'Rloc','Tv2(s)',Tv2,4232);
   
   
   [Ta1,Ta2] = cook(o,'Ta1,Ta2');
   o = opt(o,'color','r');
   diagram(o,'Rloc','Ta1(s)',Ta1,4241);
   diagram(o,'Rloc','Ta2(s)',Ta2,4242);
   
   heading(o);
end

%==========================================================================
% Closed Loop Force
%==========================================================================

function o = Overview(o)               % Closed Loop Overview          
   o = with(o,'bode');
   o = with(o,'simu');
   o = with(o,'rloc');
   
   sym1 = arg(o,1)
   sym2 = arg(o,2)
   col = arg(o,3);

   o = opt(o,'color',col);
   o1 = cook(o,sym1);
   o2 = cook(o,sym2);
   
   sym1 = [sym1,'(s)'];
   sym2 = [sym2,'(s)'];
   
   diagram(o,'Bode',sym1,o1,3211);
   diagram(o,'Bode',sym2,o2,3212);

   diagram(o,'Fstep',sym1,o1,3221);
   diagram(o,'Fstep',sym2,o2,3222);

   diagram(o,'Rloc',sym1,o1,3231);
   diagram(o,'Rloc',sym2,o2,3232);

   heading(o);
end
function o = Trf(o)                    % Transfer Function             
   o = with(o,'bode');
   o = with(o,'simu');
   o = with(o,'rloc');

   sym = arg(o,1);
   idx = arg(o,2);
   col = arg(o,3);
   
   oo = cook(o,sym);
   o = opt(o,'color',col);
   sym = [sym,'(s)'];
   oo = set(oo,'name',sym);
   
   if (idx == 0)
      diagram(o,'Trf',sym,oo,111);
   else
      diagram(o,'Trf', sym,oo,3111);
      diagram(o,'Bode',sym,oo,3221);
      diagram(o,'Rloc',sym,oo,3222);
      diagram(o,'Step',sym,oo,3131);
   end
   
   display(oo);
   heading(o);
end

%==========================================================================
% Normalized System
%==========================================================================

function o = NormRamp(o)               % Normalized System's Force Ramp
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
      % fetch some simulation parameters
      
   index = arg(o,1);                   % get force component index
   Fmax = opt(o,{'Fmax',100});

      % transform system
      
   o = brew(o,'Normalize');
   [A,B,C,D]=get(o,'system','A,B,C,D');% for debug

   oo = type(corasim(o),'css');        % cast and change type
   t = Time(oo);
   u = RampInput(oo,t,index,Fmax);
   
   oo = sim(oo,u,[],t);
   PlotY(oo);
   
   heading(o,sprintf('Analyse Force Ramp: F%g->y - %s',index,Title(o)));
end

%==========================================================================
% Checks
%==========================================================================

function o = EigenvalueCheck(o)       % Check Numeric Quality of EVs   
   [a0,a1,A] = cook(o,'a0,a1,A');
      
   if Vpa(o)                           % use variable precision arithmetic?
      a1 = vpa(a1);  a0 = vpa(a0);
      
      s1 = -a1/2 + sqrt(a1.*a1-a0);
      s2 = -a1/2 - sqrt(a1.*a1-a0);
      sm = [s1(:);s2(:)];                 % EVs from modal form
      
      A = vpa(A);                      % convert matrix to MPA
      eps = 1e-30;
      s = eig(A);
      
      sm = double(sm);
      s = double(s);                   % convert back to double precision
   else
      s1 = -a1/2 + sqrt(a1.*a1-a0);
      s2 = -a1/2 - sqrt(a1.*a1-a0);
      sm = [s1(:);s2(:)];                 % EVs from modal form

      s = eig(A);
   end
   
      % calculate differences
      
   n = length(s);
   [sm,s] = Sort(o,sm,s);              % sort eigenvalues
   ds = sm - s;
   
   dr = abs(ds);  dx = real(ds);  dy = imag(ds);
   
   PlotE(o,2211);
   PlotS(o,2221);

   PlotR(o,3212);
   PlotX(o,3222);
   PlotY(o,3232);
   
   heading(o);
   
   function PlotS(o,sub)               % Plot Radial (Absolute) Devi.  
      subplot(o,sub);
      plot(o,real(s),imag(s),'yyyyyro');
      hold on
      plot(o,real(sm),imag(sm),'rx');
      title(sprintf('Eigenvalues in Complex Plane'));
      ylabel('imag(s)');
      xlabel('real(s)');
      subplot(o);                      % subplot complete
   end
   function PlotE(o,sub)               % Plot Relative Error
      subplot(o,sub);
      e = abs(ds) ./ abs(s);
      maxe = max(e);
      plot(o,1:n,e,'r', 1:n,e,'Ko');
      title(sprintf('Relative Error: max %g',maxe));
      ylabel('e = abs(ds) / abs(s)');
      xlabel('Eigenvalue Index');
      subplot(o);                      % subplot complete
   end
   function PlotR(o,sub)               % Plot Radial (Absolute) Devi.
      subplot(o,sub);
      maxr = max(abs(dr));
      plot(o,1:n,dr,'yyyyyr', 1:n,dr,'Ko');
      title(sprintf('Absolute Deviation: max %g',maxr));
      ylabel('abs(ds)');
      xlabel('Eigenvalue Index');
      subplot(o);                      % subplot complete
   end
   function PlotX(o,sub)               % Plot Real Deviation           
      subplot(o,sub);
      maxx = max(abs(dx));
      plot(o,1:n,dx,'bc', 1:n,dx,'Ko');
      title(sprintf('Real Deviation: max %g',maxx));
      ylabel('real(ds)');
      xlabel('Eigenvalue Index');
      subplot(o);                      % subplot complete
   end
   function PlotY(o,sub)               % Plot Imaginary Deviation      
      subplot(o,sub);
      
      maxy = max(abs(dy));
      plot(o,1:n,dy,'g', 1:n,dy,'Ko');
      title(sprintf('Imaginary Deviation: max %g',maxy));
      ylabel('imag(ds)');
      xlabel('Eigenvalue Index');
      subplot(o);                      % subplot complete
   end
   function [sm,s] = Sort(o,sm,s)      % Sort Eigenvalues              

         % first sort by real value

      [~,idx] = sort(real(sm));
      sm = sm(idx);

      [~,idx] = sort(real(s));
      s = s(idx);

         % finally bubble sort on the imaginary part

      dirty = 1;                          % init to start loop
      while (dirty)
         dirty = 0;
         for (i=1:n-1)
            same = real(sm(i)) == real(sm(i+1));
            if (same && imag(sm(i)) > imag(sm(i+1)))
               tmp = sm(i);  sm(i) = sm(i+1);  sm(i+1) = tmp;   % swap
               dirty = 1;
            end

            same = real(s(i)) <= real(s(i+1));
            if (same && imag(s(i)) > imag(s(i+1)))
               tmp = s(i);  s(i) = s(i+1);  s(i+1) = tmp;       % swap
               dirty = 1;
            end
         end
      end
      
         % finally sort step by step
         
      for (i=1:n)
         smi = sm(i);
         delta = abs(s-smi);
         
         idx = find(delta == min(delta));
         idx = idx(1);
         err(i) = delta(idx);
         
         ss(i,1) = s(idx);             % sorted s
         s(idx) = [];
      end
      s = ss;                          % copy back
   end
end
function ok = Vpa(o)                   % use var precision arithmetics?
   digs = opt(o,'select.digits');
   if isempty(digs)
      ok = false;
   else
      digits(digs);
      ok = true;
   end
end

%==========================================================================
% Helper
%==========================================================================

function title = Title(o)              % Get Object Title              
   title = get(o,{'title',[class(o),' object']});
   
   dir = get(o,'dir');   
   idx = strfind(dir,'@');
   if ~isempty(dir)
      [package,typ,name] = split(o,dir(idx(1):end));
      title = [title,' - [',package,']'];
   end
end
function t = Time(o)                   % Get Time Vector               
   T = opt(o,{'simu.dt',0.00005});
   tmax = opt(o,{'simu.tmax',0.01});
   t = 0:T:tmax;
end
function oo = Corasim(o)               % Convert To Corasim Object     
   oo = type(cast(o,'corasim'),'css');
   [A,B,C,D] = data(o,'A,B,C,D');
   oo = system(oo,A,B,C,D);
end
function u = StepInput(o,t,index,Fmax) % Get Step Input Vector         
%
% STEPINPUT   Get step input vector (and optional time vector)
%
%                u = StepInput(o,t,index)
%                u = StepInput(o,t,index,Fmax)
%
   if (nargin < 4)
      Fmax = 1;
   end
   
   [~,m] = size(o);                   % number of inputs

   if (index > m)
      title = sprintf('Output #%g not supported!',index);
      comment = {sprintf('number of outputs: %g',m)};
      message(o,title,comment);
      error(title);
      return
   end

   I = eye(m);
   u = Fmax * I(:,index)*ones(size(t));
end
function u = RampInput(o,t,index,Fmax) % Get Ramp Input Vector         
%
% RAMPINPUT   Get ramp input vector (and optional time vector)
%
%                u = RampInput(o,t,index)
%                u = RampInput(o,t,index,Fmax)
%
   if (nargin < 4)
      Fmax = max(t);
   end
   
   [~,m] = size(o);                   % number of inputs
   
   if (index > m)
      title = sprintf('Output #%g not supported!',index);
      comment = {sprintf('number of outputs: %g',m)};
      message(o,title,comment);
      error(title);
      return
   end
   
   I = eye(m);
   u = I(:,index)*t * Fmax/max(t);
end
function Verbose(o,G)                  % Verbose Tracing of TFF        
   if (control(o,'verbose') > 0)
      G = opt(G,'detail',true);
      display(G);
   end
end

