function oo = simu(o,varargin)         % Simulation                    
%
% SIMU  Simulation
%
%    See also: SURGE, HEUN, SURGE1
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,@Simu,@TvsDiagram);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                                                  
   oo = mitem(o,'Total Analysis',{@Callback,'Simu'},'Last');
   oo = mitem(o,'TVS Diagram',{@Callback,'TvsDiagram'},[]);

   oo = mitem(o,'-');
   oo = ResistorMenu(o);
   oo = TvsMenu(o);
   oo = PhaseMenu(o);
   oo = OperatingVoltageMenu(o);
   oo = X2Menu(o);
      
   oo = mitem(o,'-');
   oo = mitem(o,'Leerlauf',{@Callback,'Simu'},'Leerlauf');
   oo = mitem(o,'Kurzschluss',{@Callback,'Simu'},'Kurzschluss');
   oo = mitem(o,'LL & KS',{@Callback,'Simu'},'Both');
   
   oo = mitem(o,'-');
   oo = mitem(o,'Optimize',{@Callback,'Simu'},'Optimize');
        enable(oo,0);
end
function oo = ResistorMenu(o)                                          
   setting(o,{'resistor'},'R100Ohm');
   
   oo = mitem(o,'Widerstand',{},'resistor');
        choice(oo,{...
                   {'AS08J1000ET (100 Ohm)','AS08J1000ET'},...
                   {'AS12J1000ET (100 Ohm)','AS12J1000ET'},...
                   {'AS25J1000ET (100 Ohm)','AS25J1000ET'},...
                   {},...
                   {'2xAS25J1000ET (50 Ohm)','AS25J1000ETx2'},...
                   {'3xAS25J1000ET (33 Ohm)','AS25J1000ETx3'},...
                   {'2xAS25J22R0ET (44 Ohm)','AS25J22R0ETx2'},...
                   {'2xAS25J15R0ET (30 Ohm)','AS25J15R0ETx2'},...
                   {'2xAS25J10R0ET (20 Ohm)','AS25J10R0ETx2'},...
                   {},...
                   {'AS08J22R0ET (22 Ohm)','AS08J22R0ET'},...
                   {'AS12J22R0ET (22 Ohm)','AS12J22R0ET'},...
                   {'AS25J22R0ET (22 Ohm)','AS25J22R0ET'},...
                   {},...
                   {'AS25J15R0ET (15 Ohm)','AS25J15R0ET'},...
                   {'AS25J10R0ET (10 Ohm)','AS25J10R0ET'},...
                   {},...
                   {'1  Ohm','R1Ohm'},...
                   {'22 Ohm','R22Ohm'},{'27 Ohm','R27Ohm'},...
                   {'33 Ohm','R33Ohm'},{'47 Ohm','R47Ohm'},...
                   {'56 Ohm','R56Ohm'},{'68 Ohm','R68Ohm'},...
                   {'82 Ohm','R82Ohm'},{'100 Ohm','R100Ohm'}},{});
end
function oo = TvsMenu(o)                                               
   setting(o,{'TVS'},'1.5SMC440CA');
   
   oo = mitem(o,'TVS Diode',{},'TVS');
        choice(oo,{{'1.5SMC350CA ###','1.5SMC350CA'},...
                   {'1.5SMC400CA',    '1.5SMC400CA'},...
                   {'1.5SMC440CA !!!','1.5SMC440CA'},...
                   {'1.5SMC480CA',    '1.5SMC480CA'},...
                   {},...
                   {'P6SMB400A ###',  'P6SMB400A'},...
                   {'P6SMB440A !!!',  'P6SMB440A'},...
                   {'P6SMB480A',      'P6SMB480A'},...
                   {},...
                   {'2x 1.5SMC220A',  '2x 1.5SMC220A'},...
                   {},...
                   {'SMDJ300CA',      'SMDJ300CA'},...
                   {},...
                   {'DV250K3225 (SMT MOV)', 'DV250K3225'},...
                   },{});
end
function oo = PhaseMenu(o)                                             
   setting(o,{'Ug'},358);
   
   oo = mitem(o,'Phase',{},'Ug');
        choice(oo,{{'0°',0},{'90°',358}},{});
end
function oo = OperatingVoltageMenu(o)                                  
   setting(o,{'Vin'},650);
   
   oo = mitem(o,'Operating Voltage',{},'Vin');
        choice(oo,{{'Max. 650 V (-40°C < Tj < 125°C',650},...
                   {'Max. 700 V (Tj = 25°C)',700}},{});
end
function oo = X2Menu(o)                                                
   setting(o,{'Cp'},47e-9);
   
   oo = mitem(o,'X2 Capacitor',{},'Cp');
        choice(oo,{{'Off',0},{},{'47nF',47e-9},{'100nF',100e-9},...
                   {'220nF',220e-9},{'330nF',330e-9},{'1 uF',1e-6}},{});
end
function oo = Callback(o)                                              
   refresh(o,o);                       % remember to refresh here
   oo = current(o);                    % get current object
   cls(o);                             % clear screen
   simu(oo);
end

%==========================================================================
% Simu
%==========================================================================

function o = Parameter(o,vario)                                        
   if (nargin < 2)
      vario = [1 1 1 1 1 1];
   end
      
   o = tvsdiode(o,'1');
   o = resistor(o,'R100Ohm');
   p.Rp = get(o,'resistor.Rp');            % resistor value
   
   p.Rk = 0.001;                      % [Ohm]
   p.Ck = 18e-6;                      % [F]
   p.Cp = 47e-9;                      % [F]
   p.Ug = opt(o,{'Ug',358});          % [V]   (230V*sqrt(2)*1.1)
   
      % original parameter set
      
   p.Cc = vario(1)*7.76e-6;           % [F]
   p.R1 = vario(2)*14.8;              % [Ohm]
   p.R2 = vario(3)*23.3;              % [Ohm]
   p.Rm = vario(4)*0.98;              % [Ohm]
   p.Lr = vario(5)*9.74e-6;           % [H]
   p.U0 = vario(6)*1074;              % [V]

      % revised parameter set
      
   p.Cc = vario(1)*7.38e-6;           % [F]
   p.R1 = vario(2)*14.8;              % [Ohm]
   p.R2 = vario(3)*24.5;              % [Ohm]
   p.Rm = vario(4)*1.01;              % [Ohm]
   p.Lr = vario(5)*10.4e-6;           % [H]
   p.U0 = vario(6)*1071;              % [V]

   o = set(o,'parameter',p);
end
function o = Optimize(o)                                               
   o = set(o,'simu.tmax',100e-6);
   o = set(o,'simu.dt',1e-9);

      % nominal run
      
   o1 = type(o,'surge1');
   o1 = set(o1,'model',@surge1);   %% Leerlauf
   o1 = heun(o1);
   o1 = plot(o1,'Plot',211);

   o2 = type(o,'surge2');
   o2 = set(o2,'model',@surge2);   %% Leerlauf
   o2 = heun(o2);
   o2 = plot(o2,'Plot',212);
   
   qnom = [
              1000
              1.2e-6
              50e-6
              500
              8e-6
              20e-6
          ];
       
   q0 = [
          var(o1,'umax');
          var(o1,'Tf');
          var(o1,'Td');
          var(o2,'imax');
          var(o2,'Tf');
          var(o2,'Td');
       ];
    
   epsi = 0.001;
   
   for (j=1:6)
      vario = ones(1,6);
      vario(j) = 1 + epsi;

      o1 = Parameter(o1,vario);
      o1 = heun(o1);
      o1 = plot(o1,'Plot',211);

      o2 = Parameter(o2,vario);
      o2 = heun(o2);
      o2 = plot(o2,'Plot',212);
      
      q1 = [
          var(o1,'umax');
          var(o1,'Tf');
          var(o1,'Td');
          var(o2,'imax');
          var(o2,'Tf');
          var(o2,'Td');
       ];
    
       dq = (q1 - q0);
       Q(:,j) = dq;
   end
   
   dq = (q0-qnom);
   lambda = inv(Q)*dq*epsi;
   vario = 1 + lambda;
   
   cls(o);
   p = get(o,'parameter');

   p.Cc = vario(1)*p.Cc;           % [F]
   p.R1 = vario(2)*p.R1;           % [Ohm]
   p.R2 = vario(3)*p.R2;           % [Ohm]
   p.Rm = vario(4)*p.Rm;           % [Ohm]
   p.Lr = vario(5)*p.Lr;           % [H]
   p.U0 = vario(6)*p.U0;           % [V]
 
   o = set(o,'parameter',p);

   o1 = type(o,'surge1');
   o1 = set(o1,'model',@surge1);   %% Leerlauf
   o1 = heun(o1);
   o1 = plot(o1,'Plot',211);

   o2 = type(o,'surge2');
   o2 = set(o2,'model',@surge2);   %% Leerlauf
   o2 = heun(o2);
   o2 = plot(o2,'Plot',212); 
end
function o = Simu(o)                                                   
   mode = arg(o,1);
   
   o = Parameter(o);
   
   o = set(o,'simu.tmax',100e-6);
   o = set(o,'simu.dt',0.2e-8);
   
   cls(o);
   switch mode
      case 'Leerlauf'
         o = set(o,'model',@surge1);   %% Leerlauf
         oo = type(o,'surge1');
         oo = heun(oo);
         plot(oo,'Plot',111);
      case 'Kurzschluss'
         oo = type(o,'surge2');
         oo = set(oo,'model',@surge2);   %% Kurzschluss
         oo = heun(oo);
         plot(oo,'Plot',111);
      case 'Both'
         o = set(o,'model',@surge1);   %% Leerlauf
         oo = type(o,'surge1');
         oo = heun(oo);
         plot(oo,'Plot',211);

         ooo = type(o,'surge2');
         ooo = set(ooo,'model',@surge2);   %% Leerlauf
         ooo = heun(ooo);
         plot(ooo,'Plot',212);
      case 'Optimize'
         for (j=1:10)
            o = Optimize(o);
         end
%        simu(o,'Callback','Simu','Both');
      case 'Last'
         tvs = opt(o,'TVS');
         res = opt(o,'resistor');
         
         o = resistor(o,res);
         Rp = get(o,'resistor.Rp');
         Ug = opt(o,'Ug');
         Cp = opt(o,'Cp');

         o = set(o,'simu.tmax',150e-6);
         o = set(o,'simu.dt',1e-7);

         if (Cp == 0)
            o = set(o,'model',@surge3);   %% Leerlauf
            oo = type(o,'surge3');
         else
            o = set(o,'model',@surge4);   %% Leerlauf
            oo = type(o,'surge4');
         end
         
         oo = tvsdiode(oo,tvs);
         oo = set(oo,'parameter.Rp',Rp);
         oo = set(oo,'parameter.Cp',Cp);
         oo = set(oo,'parameter.Ug',Ug);
         oo = heun(oo);
         plot(oo,'Plot',111);
   end
   
end

%==========================================================================
% TVS Diodes
%==========================================================================

function PlotTvs(o)                                                    
   tvs = get(o,'tvs');

   u = -tvs.Uclamp:tvs.Uclamp/200:tvs.Uclamp;
   i = tvsdiode(o,u);
   
   Ibmin = tvsdiode(o,tvs.Ubmin);
   Ibmax = tvsdiode(o,tvs.Ubmax);
   
      % plot I = f(U)
      
   hdl = plot(u,i,'r');
   set(hdl,'LineWidth',3);
   hold on;
   

   Vin = opt(o,'Vin');

   o = text(o,'',[0.3,0.9],10,'left');
   o = text(o,sprintf('%s: %s',tvs.kind,tvs.name));
   set(work(o,'hdl'),'FontSize',16)
   o = text(o,'');
   o = text(o,sprintf('Pmax: %g W',o.rd(tvs.Pmax,0)));
   o = text(o,sprintf('Ipp: %g A',o.rd(tvs.Ipp,1)));
   o = text(o,sprintf('Vrwm: %g V',o.rd(tvs.Vrwm,0)));
   o = text(o,sprintf('Ubreak: %g ... %g V',o.rd(tvs.Ubmin,0),o.rd(tvs.Ubmax,0)));
   o = text(o,sprintf('Ibreak: %g ... %g uA',o.rd(Ibmin*1e6,0),o.rd(Ibmax*1e6,0)));
   o = text(o,sprintf('Uclamp: %g V',o.rd(tvs.Uclamp,0)));
   o = text(o,'');
   o = text(o,sprintf('Ucrit: %g V',o.rd(Vin,0)));
   
      % plot grid voltage
   
   ylim = get(gca,'ylim');
   Ugmax = 230*sqrt(2);
   phi = -pi:pi/100:pi;
   plot(Ugmax*sin(phi),phi*ylim(2)/pi,'b');
   plot(1.1*Ugmax*sin(phi),phi*ylim(2)/pi,'b-.');
   
      % plot Vrwm

   hdl = plot(0*ylim+tvs.Vrwm,ylim,'g-.',...
               0*ylim-tvs.Vrwm,ylim,'g-.');
   set(hdl,'LineWidth',1);

      % plot max clamping voltage

   hdl = plot(0*ylim+tvs.Uclamp,ylim,'r-.',...
               0*ylim-tvs.Uclamp,ylim,'r-.');
   set(hdl,'LineWidth',1);

      % plot max operating voltage

   hdl1 = plot(0*ylim+Vin,ylim,'k-.');
   hdl2 = plot(0*ylim-Vin,ylim,'k-.');
   set([hdl1(:);hdl2(:)],'LineWidth',1);

      % inverse function test
      
   plot(tvsdiode(o,{i}),i,'y:');   % inverse function test

      % plot axes
      
   plot([0 0],get(gca,'ylim'),'k');
   plot(get(gca,'xlim'),[0 0],'k');
   
      % plot break points
      
   plot(tvs.Ubmin,Ibmin,'ko', -tvs.Ubmin,-Ibmin,'ko');
   plot(tvs.Ubmax,Ibmax,'ko', -tvs.Ubmax,-Ibmax,'ko');

   % title and labels
      
   title(sprintf('%s Characteristics',tvs.kind));
   ylabel('Current I [A]');
   xlabel('Voltage U [V]');
   grid on
   
   legend({'I = f(U)','Grid Voltage','Grid Voltage +10%',...
           '+Vrwm (reverse working max. voltage)',...
           '-Vrwm (reverse working max. voltage)',...
           'Positive max. Clamping Voltage',...
           'Negative max. Clamping Voltage',...
           'Positive max. Operating Voltage',...
           'Negative max. Operating Voltage',...
           },'Location','SouthEast');
end
function o = TvsDiagram(o)                                               
   tvs = opt(o,'TVS');
   o = tvsdiode(o,tvs);
   PlotTvs(o);
end

