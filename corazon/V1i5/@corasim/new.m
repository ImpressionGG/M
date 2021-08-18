function oo = new(o,varargin)          % CORASIM New Method            
%
% NEW   New CORASIM object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(corasim,'Css')     % continuous state space
%           o = new(corasim,'Dss')     % discrete state space
%
%           o = new(corasim,'PT1')     % PT1 system
%           o = new(corasim,'Filter2') % order 2 filter
%           o = new(corasim,'Modal3')  % modal form (continuous, order 3)
%
%           o = new(corasim,'Motion100mm')
%           o = new(corasim,'Motion200mm')
%           o = new(corasim,'Motion100um')
%
%       See also: CORASIM, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Css,@Dss,@Modal3,@PT1,@Filter2,@PT3,...
                       @Trf23,@Rloc,...
                       @Motion100mm,@Motion200mm,@Motion100um,...
                       @Modal,@Menu,@ModalN);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu                    
   oo = mitem(o,'Continuous State Space (css)',{@Callback,'Css'},[]);
   oo = mitem(o,'Discrete State Space (dss)',{@Callback,'Dss'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Continuous PT1 System',{@Callback,'PT1'},[]);
   oo = mitem(o,'Continuous PT2 System,',{@Callback,'Filter2'},[]);
   oo = mitem(o,'Continuous PT3 System,',{@Callback,'PT3'},[]);
   oo = mitem(o,'Transfer Function 2/3,',{@Callback,'Trf23'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Order 3 Modal Form',{@Callback,'Modal3'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'100 mm Motion',{@Callback,'Motion100mm'},[]);
   oo = mitem(o,'200 mm Motion',{@Callback,'Motion200mm'},[]);
   oo = mitem(o,'100 um Motion',{@Callback,'Motion100um'},[]);
 
   oo = mitem(o,'-');
   oo = mitem(o,'Root Locus Demo');
   ooo = mitem(oo,'Root Locus 1/2',{@Callback 'Rloc'},'1/2');
   ooo = mitem(oo,'Root Locus 0/2',{@Callback 'Rloc'},'0/2');
   ooo = mitem(oo,'Root Locus 0/3',{@Callback 'Rloc'},'0/3');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Root Locus 4/6 (1)',{@Callback 'Rloc'},'4/6(1)');
   ooo = mitem(oo,'Root Locus 4/6 (2)',{@Callback 'Rloc'},'4/6(2)');
   ooo = mitem(oo,'Root Locus 4/6 (3)',{@Callback 'Rloc'},'4/6(3)');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Root Locus 6/6 (1)',{@Callback 'Rloc'},'6/6(1)');
   ooo = mitem(oo,'Root Locus 6/6 (2)',{@Callback 'Rloc'},'6/6(2)');
   ooo = mitem(oo,'Root Locus 6/6 (3)',{@Callback 'Rloc'},'6/6(3)');

   oo = mitem(o,'-');
   oo = mitem(o,'Large Modal Systems');
   ooo = mitem(oo,'1 Mode System',{@Callback  'ModalN'},2);
   ooo = mitem(oo,'2 Mode System',{@Callback  'ModalN'},2);
   ooo = mitem(oo,'5 Mode System',{@Callback  'ModalN'},5);
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'10 Mode System',{@Callback  'ModalN'},10);
   ooo = mitem(oo,'20 Mode System',{@Callback  'ModalN'},20);
   ooo = mitem(oo,'30 Mode System',{@Callback  'ModalN'},30);
   ooo = mitem(oo,'40 Mode System',{@Callback  'ModalN'},40);
   ooo = mitem(oo,'50 Mode System',{@Callback  'ModalN'},50);
   ooo = mitem(oo,'75 Mode System',{@Callback  'ModalN'},75);
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'100 Mode System',{@Callback  'ModalN'},100);
   ooo = mitem(oo,'200 Mode System',{@Callback  'ModalN'},200);
   ooo = mitem(oo,'300 Mode System',{@Callback  'ModalN'},300);
   ooo = mitem(oo,'400 Mode System',{@Callback  'ModalN'},400);
   ooo = mitem(oo,'500 Mode System',{@Callback  'ModalN'},500);
   ooo = mitem(oo,'750 Mode System',{@Callback  'ModalN'},750);
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'1000 Mode System',{@Callback  'ModalN'},1000);
 end
function oo = Callback(o)              % Launch Callback               
   mode = arg(o,1);
   arg2 = arg(o,2);
   oo = new(o,mode,arg2);
   oo = launch(oo,launch(o));          % inherit launch function
   paste(o,{oo});                      % paste object into shell
end

%==========================================================================
% New Dynamic System
%==========================================================================

function oo = Css(o)                   % New css object                
   oo = corasim('css');                % continuous state space
   oo.par.title = sprintf('Continuous State Space System (%s)',datestr(now));
   oo = system(oo,[0 1;0 0],[0;1],[1 0],0);
end
function oo = Dss(o)                   % New dss object                
   oo = corasim('dss');                % discrete state space
   oo.par.title = sprintf('Discrete State Space System (%s)',datestr(now));
   lambda = [-1 -2] + randn(1,2);
   oo = system(oo,diag(lambda),[1;1],[1 -2],0);
   oo = c2d(oo,0.1);
end
function oo = PT1(o)                   % New PT1 System                
   oo = system(corasim,{1,[1 1]});     % continuous PT1 system
   oo.par.title = sprintf('Continuous PT1 System (%s)',datestr(now));
   oo.par.comment = {'G(s) = 1/(s+1)'};
end
function oo = Filter2(o)               % New continuous order 2 filter 
   f = 10/2/pi;                        % band width 1.6 Hz
   om = 2*pi*f;                        % cut-off circular frequency
   zeta = 0.4;                         % damping   
   
   oo = system(corasim,{1,[om^2 2*zeta*om 1]});     % continuous trf
   oo.par.title = sprintf('Continuous Order 2 Filter (%s)',datestr(now));
   oo.par.comment = {sprintf('Bandwidth: f = %g Hz',o.rd(f,1)),...
                     sprintf('Damping: zetea = %g',zeta)};
end
function oo = PT3(o)                   % New PT3 System                
   oo = system(corasim,{1,[1 3 3 1]}); % continuous PT3 system
   oo.par.title = sprintf('Continuous PT3 System (%s)',datestr(now));
   oo.par.comment = {'G(s) = 1/(s+1)^3'};
end
function oo = Trf23(o)                 % New Transfer Function 2/3     
   den = mul(o,[1 1],[1 0.5 1]);
   oo = system(corasim,{[1 5 6],den}); % transfer function 2/3
   oo.par.title = sprintf('Transfer Function 2/3 (%s)',datestr(now));
   oo.par.comment = {'G(s) = 1/(s+1)^3'};
end
function oo = Modal3(o)                % New css Object in Modal Form  
   omega = [1 2 3]';
   zeta  = [0.1 0.1 0.1]';
   M = [1 -1 1]';
   N = [0 2 3]';
   
   a0 = omega.*omega;  a1 = 2*zeta.*omega;  n = length(omega);
   A = [zeros(n),eye(n); -diag(a0) -diag(a1)];
   B = [0*N; M];  C=[M' N'];  D = 1;
   
   oo = system(corasim,A,B,C,D);       % continuous state space (modal)
   oo.par.title = sprintf('Continuous State Space System (%s)',...
                          datestr(now));
   oo.par.comment = {'Modal Form',...
     'omega = [1 2 3], zeta = [0.1 0.1 0.1],  M = [1 -1 1],  N = [2 3 4]'};
end

%==========================================================================
% Root Locus Demo Object
%==========================================================================

function oo = Rloc(o)                  % Root Locus Demo Object        
   mode = arg(o,1);
   switch mode
      case '1/2'
         oo = trf(o,[1 1],[1 2 5]);    
         oo.par.title = sprintf('Root Locus Demo 1/2 (%s)',datestr(now));
         oo.par.comment = {'G(s) = (s + 1) / (s^2 + 2s + 5)'};
         
      case '0/2'
         oo = trf(o,1,[1 2 2]);    
         oo.par.title = sprintf('Root Locus Demo 0/2 (%s)',datestr(now));
         oo.par.comment = {'G(s) = 1 / (s^2 + 2s + 2)'};
         
      case '0/3'
         oo = trf(o,1,[1 2 2 0]);    
         oo.par.title = sprintf('Root Locus Demo 0/2 (%s)',datestr(now));
         oo.par.comment = {'G(s) = 1 / (s^3 + 2s^2 + 2s)'};
         
      case '4/6(1)'
         om = [1   3   5];  
         Om = [  2   4  ] 
         oo = Trf(o,om,Om,0.1,'Root Locus Demo 4/6 (1)');    

      case '4/6(2)'
         om = [1 2      5];
         Om = [    3 4   ] 
         oo = Trf(o,om,Om,0.1,'Root Locus Demo 4/6 (2)');    
         
      case '4/6(3)'
         om = [1   3  4  ]; 
         Om = [  2      5]         
         oo = Trf(o,om,Om,0.1,'Root Locus Demo 4/6 (3)');    

      case '6/6(1)'
         om = [1   3   5   ];  
         Om = [  2   4    6] 
         oo = Trf(o,om,Om,0.1,'Root Locus Demo 4/6 (1)');    

      case '6/6(2)'
         om = [  2   4   6];
         Om = [1   3   5  ] 
         oo = Trf(o,om,Om,0.1,'Root Locus Demo 4/6 (2)');    
         
      case '6/6(3)'
         om = [1   3   5   ];  
         Om = [  2   4    -6] 
         oo = Trf(o,om,Om,0.1,'Root Locus Demo 4/6 (2)');    
         
      otherwise
         error('bad mode');
   end
   
   function oo = Trf(o,om,Om,zeta,name)
     den = 1;
      for (i=1:length(om))
         qf = [1 [2*zeta om(i)]*om(i)];
         den = conv(den,qf);
      end

      num = 1;
      for (i=1:length(Om))
         qf = [1 [2*zeta Om(i)]*Om(i)];
         num = conv(num,qf);
      end
      
      oo = trf(o,num,den);    
      oo.par.title = sprintf('%s (%s)',name,datestr(now));

    end
end

%==========================================================================
% New Motion Object
%==========================================================================

function oo = Motion100mm(o)           % 100 mm Motion                 
   oo = corasim('motion');             % continuous state space
   oo.data.smax = 0.1;                 % 0.1 m
   oo.data.vmax = 1;                   % 1 m/s
   oo.data.amax = 10;                  % 10 m/s2
   oo.data.tj = 0.02;                  % 20 ms jerk time
   
   oo.data.tunit = 'ms';               % time unit
   oo.data.sunit = 'mm';               % stroke unit
   
   oo.par.title = sprintf('Motion 100 mm (%s)',datestr(now));
   oo.par.comment = {'vmax: 1m/s, amax: 10 m/s2, Tj = 20 ms'};
end
function oo = Motion200mm(o)           % 200 mm Motion                 
   oo = corasim('motion');             % continuous state space
   oo.data.smax = 0.2;                 % 200 mm
   oo.data.vmax = 1;                   % 1 m/s
   oo.data.amax = 10;                  % 10 m/s2
   oo.data.tj = 0.02;                  % 20 ms jerk time
   
   oo.data.tunit = 'ms';               % time unit
   oo.data.sunit = 'mm';               % stroke unit
   
   oo.par.title = sprintf('Motion 200 mm (%s)',datestr(now));
   oo.par.comment = {'vmax: 1m/s, amax: 10 m/s2, Tj = 20 ms'};
end
function oo = Motion100um(o)           % 100 um Motion                 
   oo = corasim('motion');             % continuous state space
   oo.data.smax = 100e-6;              % 100 um
   oo.data.vmax = 0.15e-3;             % 0.15 mm/s
   oo.data.amax = 1e-3;                % 10 m/s2
   oo.data.tj = 0.02;                  % 20 ms jerk time
   
   oo.data.tunit = 'ms';               % time unit
   oo.data.sunit = 'mm';               % stroke unit
   
   oo.par.title = sprintf('Motion 100 um (%s)',datestr(now));
   oo.par.comment = {'vmax: 0.15mm/s, amax: 1 mm/s2, Tj = 20 ms'};
end

%==========================================================================
% High Order
%==========================================================================

function oo = ModalN(o)                % Trf Object with N Modes       
   n = arg(o,1);
   
   %om = 1000; 
   om = 1;
   zeta = 0.1;
   k = 1e5^(1/n);
   
   a0 = om*om;
   a1 = 2*zeta*om;
   B = [0;1];  C = [1 0]; D = 0;
   oo = modal(o,a0,a1,B,C,D);
   
   for (i=2:n)
      om = k*om;                       % increment circular frequency                  
      a0 = om*om;
      a1 = 2*zeta*om;
      
      oi = modal(o,a0,a1,B,C,D);
      oo = oo + oi;
   end
      
   oo.par.title = sprintf('Modal System with %g Modes',n);
end

