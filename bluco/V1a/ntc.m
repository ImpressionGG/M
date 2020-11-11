function oo = ntc(o,varargin)       % Ntc Studies                       
%
% NTC   NTC Studies plugin
%
%             ntc                   % launch NTC study shell
%             oo = ntc(o,func)      % call local ntc function
%
%          See also: CORAZON, PLUGIN, SAMPLE, SIMPLE
%
   if (nargin == 0)
      oo = ntc(corazon);
      return
   end
   
   [gamma,oo] = manage(o,varargin,@Menu,...
                       @WithCuo,@WithSho,@WithBsk,@New,@Simu,...
                       @Plot,@Stream,@Scatter,...
                       @Measurement,@Implementation,@Datasheet);
   oo = gamma(oo);
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
% Plugin Definitions
%==========================================================================

function oo = Menu(o)                  % Setup Rolldown Menu           
   o = Init(o);
   
   o = menu(o,'Begin');
   oo = menu(o,'File');
   oo = menu(o,'Edit');
   oo = View(o);
   oo = Ntc(o);                        % add Ntc menu items
   oo = menu(o,'Info');
   oo = menu(o,'Figure');
   oo = menu(o,'End');
end
function o = Init(o)                   % Init Object                   
   if isempty(get(o,'title')) && container(o)
      o = refresh(o,{'menu','About'}); % provide refresh callback
      o = set(o,'title','NTC Studies');
      o = set(o,'comment',...
              {'How to implement conversion of NTC measurements'});
      o = control(o,{'dark'},1);       % run in non dark mode
   end
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % use this mfile as launch function
end

%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % View Menu Setup               
%
% PLOT   Add some Plot menu items
%
   setting(o,{'view.approx'},0);       % single approximation
   oo = menu(o,'View');                % standard View menu
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Approximation',{},'view.approx');
   choice(ooo,{{'Single',0},{'Split',1}},{});
   
end

%==========================================================================
% Ntc Menu Items
%==========================================================================

function oo = Ntc(o)                   % Ntc Menu                      
%
% STUDY   Add some Study menu items
%
   oo = mhead(o,'Ntc');                % add Ntc rolldown menu header
   ooo = mitem(oo,'Measurement',{@WithCuo,'Measurement'});
   ooo = mitem(oo,'Implementation',{@WithCuo,'Implementation'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Data Sheet / Order 2',{@WithCuo,'Datasheet'},'2');
   ooo = mitem(oo,'Data Sheet / Order 3',{@WithCuo,'Datasheet'},'3');
   ooo = mitem(oo,'Data Sheet / Order 4',{@WithCuo,'Datasheet'},'4');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Data Sheet / Order 1/2',{@WithCuo,'Datasheet'},'1/2');
   ooo = mitem(oo,'Data Sheet / Order 1/3',{@WithCuo,'Datasheet'},'1/3');
end
function o = Measurement(o)            % Measurement of NTC            
   mV = [1252,964,822,696,654,593,553,531,468,412,397,376,367,351];
   T  = [  40, 52, 58, 60, 63, 70, 73, 75, 79, 82, 84, 86, 88, 90];
   
   a = polyfit(mV,T,2);               % fit second order poly
   x = 300:1400;
   y = polyval(a,x);
   
   Plot(o,111);
   
   function Plot(o,sub)
      subplot(o,sub);
      plot(o,mV,T,'r');  hold on;
      plot(o,x,y,'g');
      subplot(o);
   end
end
function o = Implementation(o)         % NTC Conversion Implementation 
   
      % from NCU15XH103F60RC datasheet we read ...
      
   T0 = Klv(25);                       % reference temperature 25°C
   Tds = Klv([  50   80   85  100]);   % datasheet temperatures [°C]
   Bds = [3380,3428,3434,3455];        % datasheet B-values
   
      % we can calculate resistor values and voltage percentage
      % at datasheet points
      
   R0 = 10000;
   Rds = R0 * exp(Bds.*(1./Tds-1/T0));
   Pds = 100*[Rds ./ (Rds+R0)];            % percent datasheet
   
      % calculate polynomial approximation of B
      
   b = polyfit(Tds,Bds,2);             % 2nd order approximation
   
      % calculate temperature for given resistor range
 
   deg = 25:100;
   
   T = Klv(deg);
   B = polyval(b,Klv(deg));
   
      % R(T) is the best we can know about NTC resistance dependent on T
      
   R = R0 * exp(B.*(1./T-1/T0));
   
      % voltage ratio
      
   percent = 100*[R ./ (R+R0)];
   
      % split up percentage range
      
   idx = 1:length(percent);

   idx1 = find(percent<30);
   idx2 = find(percent>=30);

      % final conversion polynomial - fit with milli degree Celsius
      
   a = polyfit(percent(idx),deg(idx)*1000,3);
   mdeg = polyval(a,percent);
      
   Display(a);
   PlotP(o,111);
   
   function PlotP(o,sub)               % Plot Percentage               
      subplot(o,sub);
      
      plot(o,percent,deg,'bc');
      hold on
      plot(o,Pds,Deg(Tds),'Kp');
      plot(o,percent,mdeg/1000,'c');
      if opt(o,'view.approx')
         plot(o,percent(idx1),mdeg1/1000,'yyyr');
         plot(o,percent(idx2),mdeg2/1000,'y');
      end
      
      for (i=1:length(a))
         txt = sprintf('a%g: %g',length(a)-i,a(i));
         hdl = text(30,90-i*5,txt);
         set(hdl,'color',o.color(o.iif(dark(o),'w','k')));
      end
      
      title('Conversion of Voltage Ratio to Temperature');
      xlabel('U/Uref [%]');
      ylabel('T [°C]');
      subplot(o);
   end
end
function o = Datasheet(o)              % Data Sheet Study              
%
% DATASHEET  NTC resistor (NCU15XH103F60RC) is in series with 10kOhm
%            resistor.
%
%            Thermistor equation:
%
%               1/T = 1/T0 + 1/B(T/T0) * ln(R/R0)
%            or
%               R = R0 * exp(B*[1/T - 1/T0])
%
   
      % from NCU15XH103F60RC datasheet we read ...
      
   T0 = Klv(25);                       % reference temperature 25°C
   Tds = Klv([  50   80   85  100]);   % datasheet temperatures [°C]
   Bds = [3380,3428,3434,3455];        % datasheet B-values
   
      % we can calculate resistor values and voltage percentage
      % at datasheet points
      
   R0 = 10000;
   Rds = R0 * exp(Bds.*(1./Tds-1/T0));
   Pds = 100*[Rds ./ (Rds+R0)];            % percent datasheet
   
      % calculate polynomial approximation of B
      
   b = polyfit(Tds,Bds,2);             % 2nd order approximation
   
      % calculate temperature for given resistor range
 
   deg = 25:100;
   
   T = Klv(deg);
   B = polyval(b,Klv(deg));
   
      % R(T) is the best we can know about NTC resistance dependent on T
      
   R = R0 * exp(B.*(1./T-1/T0));
   
      % voltage ratio
      
   percent = 100*[R ./ (R+R0)];
   
      % split up percentage range
      
   idx = 1:length(percent);

   idx1 = find(percent<30);
   idx2 = find(percent>=30);

      % final conversion polynomial - fit with milli degree Celsius
      
   mode = arg(o,1);
   switch mode
      case '2'
         a = polyfit(percent(idx),deg(idx)*1000,2);
         a1 = polyfit(percent(idx1),deg(idx1)*1000,2);
         a2 = polyfit(percent(idx2),deg(idx2)*1000,2);
         mdeg = polyval(a,percent);
         mdeg1 = polyval(a1,percent(idx1));
         mdeg2 = polyval(a2,percent(idx2));
      case '3'
         a = polyfit(percent(idx),deg(idx)*1000,3);
         a1 = polyfit(percent(idx1),deg(idx1)*1000,3);
         a2 = polyfit(percent(idx2),deg(idx2)*1000,3);
         mdeg = polyval(a,percent);
         mdeg1 = polyval(a1,percent(idx1));
         mdeg2 = polyval(a2,percent(idx2));
      case '4'
         a = polyfit(percent(idx),deg(idx)*1000,4);
         a1 = polyfit(percent(idx1),deg(idx1)*1000,4);
         a2 = polyfit(percent(idx2),deg(idx2)*1000,4);
         mdeg = polyval(a,percent);
         mdeg1 = polyval(a1,percent(idx1));
         mdeg2 = polyval(a2,percent(idx2));
      case '1/2'
         a = polyfit(percent(idx),1./(deg(idx)*1000),2);
         a1 = polyfit(percent(idx1),1./(deg(idx1)*1000),2);
         a2 = polyfit(percent(idx2),1./(deg(idx2)*1000),2);
         mdeg = 1./polyval(a,percent);
         mdeg1 = 1./polyval(a1,percent(idx1));
         mdeg2 = 1./polyval(a2,percent(idx2));
      case '1/3'
         a = polyfit(percent(idx),1./(deg(idx)*1000),3);
         a1 = polyfit(percent(idx1),1./(deg(idx1)*1000),3);
         a2 = polyfit(percent(idx2),1./(deg(idx2)*1000),3);
         mdeg = 1./polyval(a,percent);
         mdeg1 = 1./polyval(a1,percent(idx1));
         mdeg2 = 1./polyval(a2,percent(idx2));
   end
   Display(a);
   
   PlotB(o,2211);                      % plot B-values
   PlotR(o,2221);                      % plot resistance
   PlotP(o,2212);                      % plot percent
   PlotI(o,2222);                      % plot inverse T
   
   
   function PlotB(o,sub)               % Plot B-Values                 
      subplot(o,sub);
      
      plot(o,Deg(Tds),Bds,'pK');  hold on;
      
      plot(o,deg,B,'r');
      title('B-value over temperature');
      xlabel('T [°C]');
      ylabel('B');
      subplot(o);
   end
   function PlotR(o,sub)               % Plot Resistance               
      subplot(o,sub);
      
      plot(o,deg,R,'g');
      hold on;
      plot(o,Deg(Tds),Rds,'Kp');
      
      title('resistance over temperature');
      xlabel('T [°C]');
      ylabel('R [Ohm]');
      subplot(o);
   end
   function PlotP(o,sub)               % Plot Percentage               
      subplot(o,sub);
      
      plot(o,percent,deg,'bc');
      hold on
      plot(o,Pds,Deg(Tds),'Kp');
      plot(o,percent,mdeg/1000,'c');
      if opt(o,'view.approx')
         plot(o,percent(idx1),mdeg1/1000,'yyyr');
         plot(o,percent(idx2),mdeg2/1000,'y');
      end
      
      title('Voltage Ratio');
      xlabel('U/Uref [%]');
      ylabel('T [°C]');
      subplot(o);
   end
   function PlotI(o,sub)               % Plot inv(T)                   
      subplot(o,sub);
      
      plot(o,percent,1./deg,'b');
      hold on
      plot(o,percent,1./(mdeg/1000),'bc');
      plot(o,Pds,1./Deg(Tds),'Kp');
       
      title('Voltage Ratio');
      xlabel('U/Uref [%]');
      ylabel('1/T [°C]');
      subplot(o);
   end
end

%==========================================================================
% Helper
%==========================================================================

function T0 = Tnull                    % absolute zero temperature     
   T0 = -273.15;                       % absolute zero temperature
end
function Tdeg = Deg(Tklv)              % Convert to Centi Degrees      
   Tdeg = Tklv + Tnull;
end
function Tklv = Klv(Tdeg)              % Convert to Kelvin             
   Tklv = Tdeg - Tnull;
end
function Display(a)                    % Display Conversion Polynomial 
   fprintf('Conversion Polynomial\n');
   n = length(a) - 1;
   for (i=1:length(a))
      fprintf('   a%g: %g\n',n-i+1,a(i));
   end
end

