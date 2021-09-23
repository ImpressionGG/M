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
                       @Measurement,@Implementation4,@Implementation2x2,...
                       @Datasheet);
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
   ooo = mitem(oo,'Order-4 Implementation',{@WithCuo,'Implementation4'});
   ooo = mitem(oo,'Order-2x2 Implementation',{@WithCuo,'Implementation2x2'});
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
function o = Implementation4(o)        % NTC Conversion Implementation 
   
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
      
   order = 4;
   a = polyfit(percent(idx),deg(idx)*1000,order);
   if (order < 4)
      a = [0 a];
   end
   
   N = 14;
   a4 = a(1);  A4 = Ipar(a4);
   a3 = a(2);
   a2 = a(3);
   a1 = a(4);
   a0 = a(5);
   Display(a);
   
%  mdeg = polyval(a,percent);
   p = percent;                        % shorthand
   P = percent*1000;                   % milli percent
   %term1 = a4*p;
   %Term1 = Rshift(A4*P,2*N);
   mdeg = (((a4.*p + a3).*p + a2).*p  + a1).*p + a0;
      
   PlotP(o,111);
   
   function PlotP(o,sub)               % Plot Percentage               
      subplot(o,sub);
      
      plot(o,percent,deg,'bc');
      hold on
      plot(o,Pds,Deg(Tds),'Kp');
      plot(o,percent,mdeg/1000,'c');
      
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
   function y = Lshift(x,n)
      y = uint64(uint64(x) * 2^n);
   end
   function y = Rshift(x,n)
      y = uint64(uint64(x) / 2^n);
   end
   function p = Ipar(a)
      base = 2^N;
      p = uint64(a*base);
   end
end
function o = Implementation2x2(o)      % NTC Conversion Implementation 
%
%   2x2 Implementation
%
%       int32_t a11 = -1211 
%       int32_t a10 = 389645 
%       int32_t a21 = -262 
%       int32_t a20 = 130342
%       int32_t N0   = 1309
%
%       int32_t p = ((int32_t)1000*Vntc) / Vdd;
%       int32_t y1 = ((p + a11)*p + a10) >> 8;
%       int32_t y2 = (p + a21)*p + a20;
%       int32_t mdeg = (y1 * y2) / N0;
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
      
   permille = 1000*[R ./ (R+R0)];

      % final conversion polynomial - fit with milli degree Celsius
      
   order = 4;
   a = polyfit(permille,deg*1000,order);
   
       % calculate roots
       
   r = roots(a);
   r1 = r(1:2);
   r2 = r(3:4);
   
       % calculate splitted polynomials
       
   p1 = int32(poly(r1));
   p2 = int32(poly(r2));

   a11 = p1(2);  a10 = p1(3);
   a21 = p2(2);  a20 = p2(3);
   N0 = int32(1/a(1)/256);             % normalizing constant
   
      
   p = int32(permille);                % shorthand
   y1 = ((p + a11).*p + a10) / 256;    % right shift >>8
   y2 = (p + a21).*p + a20;
   y = y1 .* y2;
   mdeg = y / N0;                      % normalize
   
   
   PlotP(o,111);
   
   function PlotP(o,sub)               % Plot Percentage               
      subplot(o,sub);
      
      plot(o,permille,deg,'bc');
      hold on
      plot(o,Pds*10,Deg(Tds),'Kp');
      plot(o,permille,double(mdeg)/1000,'g');
      
      hdl(1) = text(300,85,sprintf('a11: %g',a11));
      hdl(2) = text(300,80,sprintf('a10: %g',a10));
      hdl(3) = text(300,75,sprintf('a21: %g',a21));
      hdl(4) = text(300,70,sprintf('a20: %g',a20));
      hdl(5) = text(300,65,sprintf('N0:  %g',N0));
      
      set(hdl,'color',o.iif(dark(o),'w','k'));
      
      title('Conversion of Voltage Ratio to Temperature');
      xlabel('U/Uref [1/1000]');
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

