function oo = mosfet(o,varargin)     % Do Some Studies
%
% STUDY   Several studies
%
%       oo = mosfet(o,'Menu')     % setup mosfet menu
%
%       oo = mosfet(o,'New',n)    % new MOSFET object
%
%    See also: BLUCO, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,@WithSho,@WithBsk,...
                      @New,@OnOffTime,@OnTime,@OffTime,@CissRdson,...
                      @QgCiss,@RdsonTpcb,@Spectrum);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)
   oo = mitem(o,'Transition Time');
   ooo = mitem(oo,'Overview',{@WithCuo,'OnOffTime'},[]);
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'On-Time',{@WithCuo,'OnTime'},[]);
   ooo = mitem(oo,'Off-Time',{@WithCuo,'OffTime'},[]);
   
   oo = mitem(o,'Tradeoff');
   ooo = mitem(oo,'Ciss versus Rdson',{@WithCuo,'CissRdson'},[]);
   ooo = mitem(oo,'Qg versus Ciss',{@WithCuo,'QgCiss'},[]);
   oo = mitem(o,'Rdson');
   ooo = mitem(oo,'Rdson = f(Tpcb)',{@WithCuo,'RdsonTpcb'},[]);

   oo = mitem(o,'Spectrum');
   ooo = mitem(oo,'5 us',{@WithCuo,'Spectrum'},[5e-6]);
   ooo = mitem(oo,'10 us',{@WithCuo,'Spectrum'},[10e-6]);
   ooo = mitem(oo,'20 us',{@WithCuo,'Spectrum'},[20e-6]);
   ooo = mitem(oo,'50 us',{@WithCuo,'Spectrum'},[50e-6]);
   ooo = mitem(oo,'100 us',{@WithCuo,'Spectrum'},[100e-6]);
   ooo = mitem(oo,'200 us',{@WithCuo,'Spectrum'},[200e-6]);
   ooo = mitem(oo,'500 us',{@WithCuo,'Spectrum'},[500e-6]);
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
% Transition Time Study
%==========================================================================

function oo = New(o)
   number = arg(o,1);
   
   n = [];
   oo = bluco('mosfet');
   switch number
      case 1
          oo.par.title = 'FCD360N65S3R0';
          oo.par.rating = '360mR/18nC';
          oo.par.supplier = 'On Semi';
          oo.par.color = 'g';
          
          oo.data.Toff = [38 35 38];
          oo.data.Ton = [125 142 189];
          oo.data.Tpcb = [30 62 80];
          oo.data.Rdson = 0.62;
          oo.data.Ciss = 730e-12;
          oo.data.Qg = 18e-9;
          oo.data.Vds = 650;
          oo.data.Id = 10;
          oo.data.price = 0.473;
          oo.data.quantity = 5e3;
                          
      case 2
          oo.par.title = 'IPD70R360P7S';
          oo.par.rating = '300mR/16.4nC';
          oo.par.supplier = 'IFX';
          oo.par.color = 'r';

          oo.data.Toff = [12 12 13];
          oo.data.Ton = [40 58 69];
          oo.data.Tpcb = [42 66 71];
          oo.data.Rdson = 0.57;
          oo.data.Ciss = 517e-12;
          oo.data.Qg = 16.4e-9;
          oo.data.Vds = 700;
          oo.data.Id = 12.5;
          oo.data.price = 0.311;
          oo.data.quantity = 10e3;
          n = 1;

      case 3
          oo.par.title = 'STD16N60M6';
          oo.par.rating = '260mR/16.7nC';
          oo.par.supplier = 'ST';
          oo.par.color = 'bcc';
          
          oo.data.Toff = [6 7 14 8];
          oo.data.Ton = [53 68 59 63];
          oo.data.Tpcb = [42 59 57 80];
          oo.data.Rdson = 0.53;
          oo.data.Ciss = 575e-12;
          oo.data.Qg = 16.7e-9;
          oo.data.Vds = 600;
          oo.data.Id = 12;
          oo.data.price = 0.52;
          oo.data.quantity = 5e3;

      case 4
          oo.par.title = 'STD13N60M6';
          oo.par.rating = '320mR/13nC';
          oo.par.supplier = 'ST';
          oo.par.color = 'bbc';

          oo.data.Toff = [25 25];
          oo.data.Ton = [120 93];
          oo.data.Tpcb = [80 65];
          oo.data.Rdson = 0.67;
          oo.data.Ciss = 509e-12;
          oo.data.Qg = 13e-9;
          oo.data.Vds = 600;
          oo.data.Id = 10;
          oo.data.price = 0.658;
          oo.data.quantity = 5e3;
          
      case 5
          oo.par.title = 'IPS80R600P7';
          oo.par.rating = '510mR/20nC';
          oo.par.supplier = 'IFX';
          oo.par.color = 'rk';

          oo.data.Toff = [11 11];
          oo.data.Ton = [85 58];
          oo.data.Tpcb = [80 58];
          oo.data.Rdson = 0.99;
          oo.data.Ciss = 570e-12;
          oo.data.Qg = 20e-9;
          oo.data.Vds = 800;
          oo.data.Id = 8;
          oo.data.price = 0.516;
          oo.data.quantity = 10e3;
          
      case 6
          oo.par.title = 'IPD60R180P7S';
          oo.par.rating = '180mR/25nC';
          oo.par.supplier = 'IFX';
          oo.par.color = 'rm';

          oo.data.Toff = [28 27];
          oo.data.Ton = [144 120];
          oo.data.Tpcb = [80 67];
          oo.data.Rdson = 0.31;
          oo.data.Ciss = 1081e-12;
          oo.data.Qg = 25e-9;
          oo.data.Vds = 600;
          oo.data.Id = 11;
          oo.data.price = 0.53;
          oo.data.quantity = 10e3;

          oo.data.f_Rdson_Tpcb.Pload = [152 200 250 300 325 352 375]; 
          oo.data.f_Rdson_Tpcb.Rdson = [0.3 0.3 0.31 0.315 0.33 0.347 0.357]; 
          oo.data.f_Rdson_Tpcb.Tpcb  = [ 54  55  60   65    72   81    86]; 
          oo.data.f_Rdson_Tpcb.duty =  [ 1    1   1    1     1    1     1]; 
          oo.data.f_Rdson_Tpcb.Ploss = [0.29 0.49 0.8 1.13 1.38 1.73  1.99]; 
   end
  
      % polynomial approximation of Ton/Toff
      
   oo.par.number = number;
   if isempty(n)
      n = length(oo.data.Tpcb) - 1;
   end
   n = 1;   % overwrite
   
   oo.par.polyToff = polyfit(oo.data.Tpcb,oo.data.Toff,n);
   oo.par.polyTon  = polyfit(oo.data.Tpcb,oo.data.Ton,n);
   
   oo = inherit(oo,o);
end
function o = OnOffTime(o)
   PlotTon(o,1311);
   PlotToff(o,1312);
   Legend(o,1313);
   
   function PlotTon(o,sub)
      subplot(o,sub);
      
      for (number=1:6)
         oo = mosfet(o,'New',number);
         
         col = get(oo,'color');
         Tpcb = data(oo,'Tpcb');
         Ton = data(oo,'Ton');

         delta = max(Tpcb) - min(Tpcb);
         T_pcb = min(Tpcb)-delta/5:max(Tpcb)+0.2*delta;

         T_on = polyval(oo.par.polyTon,T_pcb);
         plot(o,T_pcb,T_on,[col,'3']);
         hold on
         
         plot(o,Tpcb,Ton,[oo.par.color,'o']);
         hold on;
      end
      
      title('Transition On-Time (Ton)');
      xlabel('PCB Temperature [deg C]');
      ylabel('Ton [us]');
      set(gca,'xlim',[40 90]);
      subplot(o);                      % subplot done
   end
   function PlotToff(o,sub)
      subplot(o,sub);
      
      for (number=1:6)
         oo = mosfet(o,'New',number);
         
         col = get(oo,'color');
         Tpcb = data(oo,'Tpcb');
         Toff = data(oo,'Toff');

         delta = max(Tpcb) - min(Tpcb);
         T_pcb = min(Tpcb)-delta/5:max(Tpcb)+0.2*delta;

         T_off = polyval(oo.par.polyToff,T_pcb);
         plot(o,T_pcb,T_off,[col,'3']);
         hold on
         
         plot(o,Tpcb,Toff,[oo.par.color,'o']);
         hold on;
      end
      
      title('Transition Off-Time (Ton)');
      xlabel('PCB Temperature [deg C]');
      ylabel('Toff [us]');
      set(gca,'xlim',[40 90]);
      subplot(o);                      % subplot done
   end
 end
function o = OnTime(o)
   for (number=1:6)
       oo = mosfet(o,'New',number);
       PlotTon(oo,[3 2 number]);
   end

   function PlotTon(o,sub)
      subplot(o,sub);
      
      col = get(o,'color');
      Tpcb = data(o,'Tpcb');
      Ton = data(o,'Ton');
      Toff = data(o,'Toff');
      
      delta = max(Tpcb) - min(Tpcb)
      T_pcb = min(Tpcb)-delta/5:max(Tpcb)+0.2*delta;
      
      T_on = polyval(o.par.polyTon,T_pcb);
      plot(o,T_pcb,T_on,[col,'3']);

      hold on
      plot(o,Tpcb,Ton,'Kp');
      hold on;
 
      title(sprintf('#%g: %s (%s)',get(o,'number'),get(o,'title'),...
                    get(o,{'supplier',''})));
      xlabel('PCB Temperature [deg C]');
      ylabel('Ton [us]');
      set(gca,'xlim',[40 90],'ylim',[0 200]);
      subplot(o);                      % subplot done
   end
end
function o = OffTime(o)
   for (number=1:6)
       oo = mosfet(o,'New',number);
       PlotToff(oo,[3 2 number]);
   end

   function PlotToff(o,sub)
      subplot(o,sub);
      
      col = get(o,'color');
      Tpcb = data(o,'Tpcb');
      Toff = data(o,'Toff');
      
      delta = max(Tpcb) - min(Tpcb)
      T_pcb = min(Tpcb)-delta/5:max(Tpcb)+0.2*delta;
      
      T_off = polyval(o.par.polyToff,T_pcb);
      plot(o,T_pcb,T_off,[col,'3']);

      hold on
      plot(o,Tpcb,Toff,'Kp');
      hold on;
 
      title(sprintf('#%g: %s (%s)',get(o,'number'),get(o,'title'),...
                    get(o,{'supplier',''})));
      xlabel('PCB Temperature [deg C]');
      ylabel('Toff [us]');
      set(gca,'xlim',[40 90],'ylim',[0 40]);
      subplot(o);                      % subplot done
   end
end
function o = CissRdson(o)
   for (i=1:6)
      oo = mosfet(o,'New',i);
      Qg(i) = oo.data.Qg;
      Rdson(i) = oo.data.Rdson;
      Ciss(i) = oo.data.Ciss;
      col{i} = oo.par.color;
   end
   
   Rdson(1) = Rdson(1)*0.995;
   
   PlotCissRdson(o,1211);
   PlotTchar(o,2212);
   Legend(o,2222,0.5);
   
   function PlotCissRdson(o,sub)
      subplot(o,sub);
      
      for (i=1:length(Rdson))
         plot(o,Rdson(i),Ciss(i)*1e12,[col{i},'po']);    
         hold on;
         plot(o,[0, Rdson(i) Rdson(i)],[Ciss(i),Ciss(i),0]*1e12,col{i});
      end
      
      for (i=100:100:700)
         Tchar = i*1e-12;
         R_dson = 0.01:0.01:1;
         C_iss = Tchar ./ R_dson;
         plot(o,R_dson,C_iss*1e12,'kw1');
         hold on;
      end
      
      set(gca,'xlim',[0 1],'ylim',[0 1200]);
      title('Dependency Ciss = f(Rdson)');
      xlabel('Rdson [Ohm]');
      ylabel('Ciss [pF]');
      subplot(o);                      % done
   end
   function PlotTchar(o,sub)
      subplot(o,sub);
      
      Tchar = Rdson .* Ciss;
      for (i=1:length(Tchar))
         plot(o,i,Tchar(i)*1e12,[col{i},'op|']);
         hold on;
      end
      
      title(sprintf('Characteristic Time Tchar := Rdson*Ciss'));
      xlabel('MOSFET [#]');
      ylabel('Tchar [ps]');
      subplot(o);                      % done
   end
end
function o = QgCiss(o)
   for (i=1:6)
      oo = mosfet(o,'New',i);
      Qg(i) = oo.data.Qg;
      Rdson(i) = oo.data.Rdson;
      Ciss(i) = oo.data.Ciss;
      col{i} = oo.par.color;
   end
   
   PlotQgCiss(o,1211);
   Legend(o,1212);
   
   function PlotQgCiss(o,sub)
      subplot(o,sub);
      
      for (i=1:length(Qg))
         plot(o,Qg(i)*1e9,Ciss(i)*1e12,[col{i},'op']);
         hold on;
         plot(o,[0, Qg(i) Qg(i)]*1e9,[Ciss(i),Ciss(i),0]*1e12,col{i});
      end
      
      fit = polyfit([0 Qg],[0 Ciss],1);
      fit(end) = 0;
      Q_g = 0:30;
      plot(o,Q_g,polyval(fit,Q_g),'m');
      
      title(sprintf('Dependency Ciss = K*Qg (K = %g)',o.rd(fit(1),1)));
      xlabel('Qg [nC]');
      ylabel('Ciss [pF]');
      subplot(o);                      % done
   end
end
function o = RdsonTpcb(o)
   oo = mosfet(o,'New',6);
   
   PlotRdsonTpcb(oo,111);
   heading(o,[oo.par.title,' (Bluco-813)']);
   
   function PlotRdsonTpcb(o,sub)
      subplot(o,sub);
      
      f = o.data.f_Rdson_Tpcb;
      Rdson = f.Rdson;
      Tpcb = f.Tpcb;
      
      fit = polyfit(Tpcb,Rdson,2);
      
      plot(o,Tpcb,Rdson,'Kop');
      hold on;
      
      T_pcb = 40:90;
      R_dson = polyval(fit,T_pcb);
      Rdson80 = polyval(fit,80);
      plot(o,T_pcb,R_dson,'m');
      
      title(sprintf('Rdson = f(Tpcb) - Rdson(80) = %g Ohm',o.rd(Rdson80,3)));
      ylabel('Rdson [Ohm]');
      xlabel('Tpcb [grdC]');
      
      subplot(o);
   end
end
function o = Spectrum(o)
   T = arg(o,1)/4.4;
   
   t= (0:0.05:5000)*1e-6;
   t0 = mean(t);

   u1 =  1 ./ (1 + exp(+(t-t0)/T));
   i1 =  1 - 1 ./ (1 + exp(+(t-t0)/T));
   p1 = u1 .* i1;

   i2 =  min([ones(size(t));exp(+(t-t0)/(T*2))]);
   u2 =  1 - i2;
   p2 = u2 .* i2;
   
      % FFT
  
   [f1,Y1] = fft(o,t,p1);
   [f2,Y2] = fft(o,t,p2);
   
   
   PlotP1(o,2211);
   PlotP2(o,2221);
   PlotFft(o,122);
   
   function PlotP1(o,sub)
      subplot(o,sub);
      o = opt(o,'xscale',1e6);

      idx1 = max(find(u1>=0.9*max(u1)));
      idx2 = min(find(u1<=0.1*max(u1)));
      dt = t(idx2) - t(idx1);
      
      plot(o,t,p1,'g');
      hold on
      
      plot(o,t,u1,'bc');
      plot(o,t,i1,'r');
      
      title(sprintf('Ton/off: %g us',o.rd(1e6*dt,2)));
      xlabel('time [us]');
      subplot(o);
   end
   function PlotP2(o,sub)
      subplot(o,sub);
      o = opt(o,'xscale',1e6);

      idx1 = max(find(u2>=0.9*max(u2)));
      idx2 = min(find(u2<=0.1*max(u2)));
      dt = t(idx2) - t(idx1);
      
      plot(o,t,u2,'bc');
      hold on
      
      plot(o,t,i2,'r');
      plot(o,t,p2,'ryyy');
      
      title(sprintf('Ton/off: %g us',o.rd(1e6*dt,2)));
      xlabel('time [us]');
      subplot(o);
   end
   function PlotFft(o,sub)
      subplot(o,sub);
      
      dB1 = 10*log10(Y1);
      dB2 = 10*log10(Y2);

      dBmax = max([dB1,dB2]);
      
      plot(o,log10(f1),dB1,'g');
      hold on
      plot(o,log10(f2),dB2,'ryyy');
      
      title(sprintf('FFT: max: %g dB',o.rd(dBmax,1)));
      xlabel('frequency [MHz]');
      subplot(o);
   end
end

%==========================================================================
% Helper
%==========================================================================

function Legend(o,sub,dy)
   if (nargin < 3)
      dy = 0.3;
   end
   
   subplot(o,sub);
   col = o.color(o.iif(dark(o),'w','k'));

   for (number=1:6)
      y = 7-number;
      oo = mosfet(o,'New',number);
      plot(o,[0.5 1.5],y*[1 1],[oo.par.color,'3']);
      hold on;

      hdl = text(2,y,[sprintf('#%g: ',number),oo.par.title,...
                  ' ',oo.par.rating]);
      set(hdl,'color',col);

      y = y - dy;
      hdl = text(2,y,...
         sprintf('Q_{G}: %g nC, C_{ISS}: %g pF, R_{DSON}: %g Ohm',...
         oo.data.Qg*1e9,oo.data.Ciss*1e12,oo.data.Rdson));
      set(hdl,'color',col);

      axis off
   end

   set(gca,'xlim',[0 10],'ylim',[0 7]);
   subplot(o);
end
