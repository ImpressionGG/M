function oo = study(o,varargin)        % Simulation Menu               
%
% STUDY  Manage Study menu
%
%           study(o,'Setup');          % Setup Study menu
%           P = study(o,'Plant');      % get plant transfer function
%
%        See also: GACO, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Plant,@TrfDisp,@StepPlot,...
                                  @BodePlot,@Signal);
   oo = gamma(oo);
end

%==========================================================================
% Setup Study Menu
%==========================================================================

function o = Setup(o)                  % Setup Simulation Menu         
   Register(o);
   
   oo = mhead(o,'Study');
   ooo = mitem(oo,'Plant Bode Plot',{@BodePlot 'Plant'});
   ooo = mitem(oo,'Open Loop Bode Plot',{@BodePlot 'OpenLoop'});
   ooo = mitem(oo,'Closed Loop Bode Plot',{@BodePlot 'ClosedLoop'});
   ooo = mitem(oo,'Closed Loop Step Response',{@StepPlot 'ClosedLoop'});
   
   ooo = mitem(oo,'-');

   ooo = mitem(oo,'Plant');
   oooo = mitem(ooo,'Transfer Function',{@TrfDisp 'Plant'});
   oooo = mitem(ooo,'Step Response',{@StepPlot 'Plant'});
   oooo = mitem(ooo,'Bode Plot',{@BodePlot 'Plant'});
   
   ooo = mitem(oo,'Controller');
   oooo = mitem(ooo,'Transfer Function',{@TrfDisp 'Controller'});
   oooo = mitem(ooo,'Step Response',{@StepPlot 'Controller'});
   oooo = mitem(ooo,'Bode Plot',{@BodePlot 'Controller'});

   ooo = mitem(oo,'Open Loop');
   oooo = mitem(ooo,'Transfer Function',{@TrfDisp 'OpenLoop'});
   oooo = mitem(ooo,'Step Response',{@StepPlot 'OpenLoop'});
   oooo = mitem(ooo,'Bode Plot',{@BodePlot 'OpenLoop'});
   
   ooo = mitem(oo,'Closed Loop');
   oooo = mitem(ooo,'Transfer Function',{@TrfDisp 'ClosedLoop'});
   oooo = mitem(ooo,'Step Response',{@StepPlot 'ClosedLoop'});
   oooo = mitem(ooo,'Bode Plot',{@BodePlot 'ClosedLoop'});
   
   ooo = mitem(oo,'-');
   
   ooo = PlantParameters(oo);
   ooo = ControllerParameters(oo);
end
function o = Register(o)               % Register Some Stuff           
   o = Config(type(o,'trigo'));        % register 'trigo' configuration
   o = Config(type(o,'expo'));         % register 'expo' configuration
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% Configuration
%==========================================================================

function o = Config(o)                 % Install a Configuration       
   mode = arg(o,1);
   mode = o.iif(isempty(mode),type(o),mode);
   
   o = config(o,[]);                   % set all sublots to zero
   o = config(o,'');                   % configure defaults for time
   o = subplot(o,'layout',1);          % layout with 1 subplot column   
   o = category(o,1,[-2 2],[0 0],'µ'); % setup category 1
   o = category(o,2,[-2 2],[0 0],'µ'); % setup category 2
   
   switch type(o)
      case 'expo'
         colx = 'm';  coly = 'c';
      otherwise
         colx = 'r';  coly = 'b';
   end
   switch mode
      case {'ConfigX'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
      case {'ConfigY'}
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      case {'ConfigXY'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      otherwise
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{2,coly});   % configure 'y' for 2nd subplot
   end
   change(o,'config',o);               % change config, rebuild & refresh
end
function o = Signal(o)                 % Simu Specific Signal Menu                   
%
% SIGNAL   The Sinal function is responsible for both setting up the 
%          'Signal' menu head and the subitems which are dynamically 
%          depending on the type of the current object
%
   switch active(o);                   % depending on active type
      case {'trigo','expo'}
         oo = mitem(o,'X',{@Config,'ConfigX'});
         oo = mitem(o,'Y',{@Config,'ConfigY'});
         oo = mitem(o,'X/Y',{@Config,'ConfigXY'});
         oo = mitem(o,'X and Y',{@Config,'ConfigXandY'});
   end
end

%==========================================================================
% Study
%==========================================================================

function oo = Plant(o)                 % Plant Transfer Function       
   m0 = opt(o,'study.m0');
   m1 = opt(o,'study.m1');
   m2 = opt(o,'study.m2');
   c1 = opt(o,'study.c1');
   c2 = opt(o,'study.c2');
   d1 = opt(o,'study.d1');
   d2 = opt(o,'study.d2');
   n  = opt(o,'study.integrators');
   
   om1 = sqrt(c1/m0);  f1 = om1/2/pi;
   om2 = sqrt(c2/m1);  f2 = om2/2/pi;
   m12 = m1*m2/(m1+m2);
   
   P = 1/trf.lf(10)/trf.lf;
   
   G1 = trf(-1,[m0 d1 c1]);
   G2 = trf([m2,d2,c2],[m1*m2, d2*(m1+m2), c2*(m1+m2)]);
   
   for (i=1:n)
      G2 = G2 * trf(1,[1 0]);
   end
         
   P = 1e6*(G2 - G1);
   
   oo = set(P,'title','Plant');
   oo = set(oo,'comment',{sprintf('Frequencies: f1 = %g, f2 = %g',f1,f2)});
   oo = opt(oo,'scale',opt(o,'scale'));
   oo = with(oo,'scale');
end
function oo = Controller(o)            % Controller Transfer Function  
   K  = opt(o,'study.K');
   Ti = opt(o,'study.Ti');
   Td = opt(o,'study.Td');
   N  = opt(o,'study.N');
   
   if (Td == 0)
      R = K*[1 + trf(1,[Ti 0])];
   else
      R = K*[1 + trf(1,[Ti 0]) + trf([Td 0],[Td/N 1])];
   end
   
   txt1 = sprintf('Gain: K = %g',K);
   txt2 = sprintf('Integration: Ti = %g',Ti);
   txt3 = sprintf('Differentiation: Td = %g',Td);
   txt4 = sprintf('Realisation: N = %g',N);
   
   oo = set(R,'title','Controller');
   oo = set(oo,'comment',{txt1,txt2,txt3,txt4});
   
   oo = opt(oo,'scale',opt(o,'scale'));
   oo = with(oo,'scale');
end
function oo = OpenLoop(o)              % Open Loop Transfer Function   
   P = Plant(o);
   R = Controller(o);
   L = R*P;
   oo = L;

   oo = opt(oo,'scale',opt(o,'scale'));
   oo = with(oo,'scale');
end
function oo = ClosedLoop(o)            % Closed Loop Transfer Function 
   P = Plant(o);
   R = Controller(o);
   L = R*P;
   T = loop(L);
   oo = T;

   oo = opt(oo,'scale',opt(o,'scale'));
   oo = with(oo,'scale');
end
function oo = TransferFunction(o)      % Fetch Proper Transfer Function
   mode = arg(o,1);
   switch mode
      case 'Plant'
         oo = Plant(o);
      case 'Controller'
         oo = Controller(o);
      case 'ClosedLoop'
         oo = ClosedLoop(o);
      case 'OpenLoop'
         oo = OpenLoop(o);
      otherwise
         error('bad mode!');
   end
end

function oo = TrfDisp(o)               % Display Transfer Function     
   refresh(o,o);
   oo = TransferFunction(o);
   dsp(oo);
end
function oo = StepPlot(o)              % Plot Step Response            
   refresh(o,o);
   oo = TransferFunction(o);
   cls(o);
   axes(oo,'Time');
   stp(oo);
end
function oo = BodePlot(o)              % Draw Bode Plot                
   refresh(o,o);
   oo = TransferFunction(o);
   cls(o);
   axes(oo,'Bode');
   oo = bode(oo);
end

%==========================================================================
% Parameters
%==========================================================================

function oo = PlantParameters(o)       % Parameters Sub Menu           
   setting(o,{'study.m0'},2000);
   setting(o,{'study.m1'},20);
   setting(o,{'study.m2'},40);
   setting(o,{'study.c1'},30000*30*40);
   setting(o,{'study.c2'},15000*25*25);
   setting(o,{'study.d1'},300000);
   setting(o,{'study.d2'},6000);
   setting(o,{'study.integrators'},2);
   
   oo = mitem(o,'Plant Parameters');
   ooo = mitem(oo,'Baseframe Mass [kg]','','study.m0'); 
         charm(ooo,{});
   ooo = mitem(oo,'Gantry Mass 1 [kg]','','study.m1'); 
         charm(ooo,{});
   ooo = mitem(oo,'Gantry Mass 2 [kg]','','study.m2'); 
         charm(ooo,{});
   ooo = mitem(oo,'Spring Constant c1 [N/m]','','study.c1'); 
         charm(ooo,{});
   ooo = mitem(oo,'Spring Constant c2 [N/m]','','study.c2'); 
         charm(ooo,{});
   ooo = mitem(oo,'Damping Constant d1 [Ns/m]','','study.d1'); 
         charm(ooo,{});
   ooo = mitem(oo,'Damping Constant d2 [Ns/m]','','study.d2'); 
         charm(ooo,{});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Number of Integrators','','study.integrators');
         choice(ooo,[0 1 2],{});
end
function oo = ControllerParameters(o)  % Parameters Sub Menu           
   setting(o,{'study.K'},1);
   setting(o,{'study.Ti'},0.01);
   setting(o,{'study.Td'},40);
   setting(o,{'study.N'},10);
   
   oo = mitem(o,'Controller Parameters');
   ooo = mitem(oo,'Gain K','','study.K'); 
         charm(ooo,{});
   ooo = mitem(oo,'Integration Ti','','study.Ti'); 
         charm(ooo,{});
   ooo = mitem(oo,'Differentiation Td','','study.Td'); 
         charm(ooo,{});
   ooo = mitem(oo,'Realization N','','study.N'); 
         charm(ooo,{});
end

