function oo = plot(o,varargin)         % SURGE Plot Method             
%
% PLOT   SURGE plot method
%
%           plot(o)                    % plot data
%
%        See also: SURGE, SHELL
%
   [gamma,oo] = manage(o,varargin,@Plot);
   oo = gamma(oo);
end

function Text(o,x,y,txt)                                               
   hdl = text(x,y,txt);
   set(hdl,'HorizontalAlignment','Left');
end

%==========================================================================
% Plot Functions
%==========================================================================

function o = Plot(o)                   % Default Plot                  
   switch type(o)
      case 'surge1'
         o = PlotSurge1(o);
      case 'surge2'
         o = PlotSurge2(o);
      case 'surge3'
         o = PlotAnalysis(o);
      case 'surge4'
         o = PlotAnalysis(o);
   end
end
function o = PlotSurge1(o)             % Leerlauf                      
    [t,x,u] = data(o,'t','x','y');
    sub = arg(o,1);
    
    umax = max(u);
    
    idx = find(u==umax);
    tm = mean(t(idx(1)));
    
    
    idx = find(u>=0.5*umax);
    t1 = min(t(idx));
    t2 = max(t(idx));
    
    Tw = t2-t1;
    Td = Tw;
    
    idx = find(u>=0.3*umax);
    t30 = t(idx(1));

    idx = find(u>=0.9*umax);
    t90 = t(idx(1));

    T = t90 - t30;
    Tf = 1.67*T;
    

    while (111)
       if (sub ~= 111)
          subplot(sub);
       end
       
       hdl = plot(t*1e6,u,'b');
       set(hdl,'LineWidth',2);

       hold on;
       hdl = plot([t1 t2]*1e6,[umax/2 umax/2],'ro'); 
       hdl = plot([t1 t2]*1e6,[umax/2 umax/2],'r'); 
       set(hdl,'LineWidth',2);

       plot([tm tm]*1e6,[0 umax],'k', tm*1e6,umax,'ko');

       title(sprintf('Surge - Leerlaufspannung: umax = %g V (Tf = %gus, Tw = %gus)',...
             o.rd(umax,0),o.rd(Tf*1e6,1),o.rd(Tw*1e6,1)));
       ylabel('U [V]');
       xlabel('time [us]');
       grid on;
       break;
    end
    
    o = var(o,'umax',umax);
    o = var(o,'Tf',Tf);
    o = var(o,'Td',Td);
end
function o = PlotSurge2(o)             % Kurzschluss                   
    [t,x,i] = data(o,'t','x','y');
    sub = arg(o,1);
    
    imax = max(i);
    idx = find(i==imax);
    tm = t(idx(1));
    
    idx = find(i>=0.1*imax);
    t10 = t(idx(1));

    idx = find(i>=0.9*imax);
    t90 = t(idx(1));

    Tr = t90 - t10;
    Tf = 1.25*Tr;                      % Tf should be 8us +- 20%
    
    idx = find(i>=0.5*imax);
    t1 = t(idx(1));
    t2 = t(idx(end));
    Tw = t2-t1;
    Td = 1.18*Tw;                      % Td should be 20us +-20%
    
    while (111)
       if (sub ~= 111)
          subplot(sub);
       end
       
       hdl = plot(t*1e6,i,'r');
       set(hdl,'LineWidth',2);

       hold on;
       plot(tm*1e6,imax,'ko');

       plot(t10*1e6,imax*0.1,'ko');
       plot(t90*1e6,imax*0.9,'ko');

       hdl = plot([t1 t2]*1e6,[imax/2 imax/2],'bo'); 
       hdl = plot([t1 t2]*1e6,[imax/2 imax/2],'b'); 
       set(hdl,'LineWidth',2);

       plot([tm tm]*1e6,[0 imax],'k', tm*1e6,imax,'ko');

       title(sprintf('Surge - Kurzschluss Strom: imax = %g A (Tf = %gus, Td = %gus)',...
             o.rd(imax,0),o.rd(Tf*1e6,1),o.rd(Td*1e6,1)));
       ylabel('i [A]');
       xlabel('time [us]');
       grid on;
       
       p = get(o,'parameter');
       Text(o,40,500,sprintf('Cc = %g uF',p.Cc*1e6));
       Text(o,40,420,sprintf('Rs1 = %g Ohm',p.R1));
       Text(o,40,340,sprintf('Rs2 = %g Ohm',p.R2));
       Text(o,40,260,sprintf('Rm  = %g Ohm',p.Rm));
       Text(o,40,180,sprintf('Lr  = %g uH',p.Lr*1e6));
       Text(o,40,100,sprintf('U0  = %g V',p.U0));
       
       break;
    end
    
    o = var(o,'imax',imax);
    o = var(o,'Tf',Tf);
    o = var(o,'Td',Td);
end

%==========================================================================
% Plot Detailed Analysis
%==========================================================================

function o = PlotAnalysis(o)           % Plot Detailed Analysis        

   [t,ip,up,ur,ud,wr,wd,u,pr,pd,ic] = Signals(o); 
   [Td,Tf,umax,tm,t1,t2] = PreProcess(o);

   PlotVoltages(o,231);
   PlotEnergy(o,232);
   PlotCurrent(o,233);                                         
   PlotTvs(o,223);                                         
   PlotResistor(o,224);                                         

   o = var(o,'umax',umax);
   o = var(o,'Tf',Tf);
   o = var(o,'Td',Td);

   function [t,ip,up,ur,ud,wr,wd,u,pr,pd,ic] = Signals(o)              
      [t,x,y] = data(o,'t','x','y');
      sub = arg(o,1);

      ip = y(1,:);                       % load current
      up = y(2,:);                       % load voltage
      ur = y(3,:);                       % resistor voltage
      ud = y(4,:);                       % diode voltage
      wr = y(5,:);                       % energy @ resistor
      wd = y(6,:);                       % energy @ diode
      
      if (size(y,1) >= 7)
         ic = y(7,:);
      else
         ic = 0*ip;
      end
      
      u = up;
      pr = ip.*ur;                       % power @ resistor
      pd = ip.*ud;                       % power @ diode
   end
   function [Td,Tf,umax,tm,t1,t2] = PreProcess(o)                      
      umax = max(u);

      idx = find(u==umax);
      tm = mean(t(idx(1)));


      idx = find(u>=0.5*umax);
      t1 = min(t(idx));
      t2 = max(t(idx));

      Tw = t2-t1;
      Td = Tw;

      idx = find(u>=0.3*umax);
      t30 = t(idx(1));

      idx = find(u>=0.9*umax);
      t90 = t(idx(1));

      T = t90 - t30;
      Tf = 1.67*T;
   end
   function PlotVoltages(o,sub)                                        
      subplot(sub);
       
      hdl = plot(t*1e6,up,'b');
      set(hdl,'LineWidth',2);

      hold on;
      hdl = plot(t*1e6,ur,'c');
      set(hdl,'LineWidth',2);

      hdl = plot(t*1e6,ud,'m');
      set(hdl,'LineWidth',2);

         % pulse duration
       
      hdl = plot([t1 t2]*1e6,[umax/2 umax/2],'ko'); 
      hdl = plot([t1 t2]*1e6,[umax/2 umax/2],'k'); 
      set(hdl,'LineWidth',1);
      Td = t2-t1;
       
      plot([tm tm]*1e6,[0 umax],'k', tm*1e6,umax,'ko');

         % text some data
         
      o = text(o,'',[0.3,0.9],10,'left','mid');
      o = text(o,sprintf('Umax: %g V',o.rd(umax,0)));
      o = text(o,sprintf('Tf: %g us',o.rd(Tf*1e6,1)));
      o = text(o,sprintf('Td: %g us',o.rd(Td*1e6,0)));
      
         % title & labels
          
      title(sprintf('Surge Spannung'));
      ylabel('b:up, c:ur, m:ud [V]');
      xlabel('time [us]');
      grid on;

      legend({'Surge','Resistor','TVS'},'Location','SouthWest');
   end
   function PlotEnergy(o,sub)                                          
      subplot(sub);
      hdl = plot(t*1e6,wr*1e3,'c');
      set(hdl,'LineWidth',2);
       
      hold on
      hdl = plot(t*1e6,wd*1e3,'m');
      set(hdl,'LineWidth',2);
       
      title(sprintf('Energy: %g mJ @ Resistor, %g mJ @ Diode',...
                      o.rd(wr(end)*1e3,0),o.rd(wd(end)*1e3,0)));
      xlabel('time [us]');
      ylabel('c:wr, m:wd [mJ]');
      grid on
      
         % draw legend
          
      Rp = get(o,'parameter.Rp');
      Cp = get(o,'parameter.Cp');
      tvs = get(o,'tvs');
      res = get(o,'resistor');
       
      o = text(o,'',[0.25,0.5],10,'left','mid');
      o = text(o,sprintf('%s',[tvs.kind,': ',tvs.name]));       
      set(work(o,'hdl'),'FontSize',14);
      o = text(o,'');
       
      o = text(o,sprintf('%s',['Res: ',res.name]));       
      set(work(o,'hdl'),'FontSize',14);
      o = text(o,'');

      o = text(o,sprintf('R = %g Ohm',Rp));
      o = text(o,sprintf('X2 = %g nF',Cp*1e9));

 
      legend({'Resistor','TVS'},'Location','SouthEast');
   end
   function PlotCurrent(o,sub)                                         
      subplot(sub);
      hdl = plot(t*1e6,ip,'r');
      set(hdl,'LineWidth',2);
       
      Ipmax = max(ip);
      idx = find(ip >= 0.5*Ipmax);
      t1 = t(idx(1));  t2 = t(idx(end));
      Td = t2-t1;
 
      hold on;
      hdl = plot(t*1e6,ic,'g');
      set(hdl,'LineWidth',1);
   
         % plot pulse duration 
          
      hold on;
      plot(t1*1e6,0.5*Ipmax,'ko', t2*1e6,0.5*Ipmax,'ko');
      hdl = plot([t1 t2]*1e6,0.5*Ipmax*[1 1],'k');
      set(hdl,'LineWidth',1);
       
         % plot nominal max current Ipp
          
      tvs = get(o,'tvs');
      Ippeff = tvs.Ipp * (tvs.Td0/Td)^tvs.kappa;
      
      if isequal(tvs.kind,'TVS')
         hdl = plot(t*1e6,0*t+tvs.Ipp,'k-.');
         set(hdl,'LineWidth',1);

         o = text(o,'',{get(gca,'xlim')*[0;1],tvs.Ipp},10,'right','top');
         o = text(o,sprintf('Ipp(10ms) = %g A  ',o.rd(tvs.Ipp,1)));

            % calculate and plot effective Ippeff

         hdl = plot(t*1e6,0*t+Ippeff,'k-.');
         set(hdl,'LineWidth',1);

         o = text(o,'',{get(gca,'xlim')*[0;1],Ippeff},10,'right','top');
         o = text(o,sprintf('Ipp(%gus) = %g A  ',o.rd(Td*1e6,0),o.rd(Ippeff,1)));

            % calculate and plot derated effective Ippeff

         Ippder = Ippeff*tvs.derate;

         hdl = plot(t*1e6,0*t+Ippder,'r-.');
         set(hdl,'LineWidth',1);

         o = text(o,'',{get(gca,'xlim')*[0;1],Ippder},10,'right','top');
         o = text(o,sprintf('%g%% Ipp(%gus) = %g A  ',...
                  o.rd(tvs.derate*100,0),o.rd(Td*1e6,0),o.rd(Ippder,1)));
         set(work(o,'hdl'),'Color',[1 0 0]);

         idx = find(ip>Ippder);
         plot(t(idx)*1e6,ip(idx),'ro');
      end
      
      xlim = get(gca,'xlim');
      ylim = get(gca,'ylim');
       
         % title & labels
          
      title(sprintf('Strom: Ipp = %g A (Td = %g us)',...
            o.rd(Ippeff,1),o.rd(Td*1e6,0)));
      xlabel('time [us]');
      ylabel('ip [A]');
      grid on
   end
   function PlotTvs(o,sub)                                             
      subplot(sub);
      hdl = plot(t*1e6,pd/1e3,'m');
      set(hdl,'LineWidth',2);
      hold on

         % calculate Td
          
      pdmax = max(pd);
      idx = find(pd >= 0.5*pdmax);
      t1 = t(idx(1));  t2 = t(idx(end));
      Td = t2-t1;

         % plot nominal max power Pmax
        
      tvs = get(o,'tvs');
      if isequal(tvs.kind,'TVS')
         tvs = get(o,'tvs');
         hdl = plot(t*1e6,0*t+tvs.Pmax/1e3,'k-.');
         set(hdl,'LineWidth',1);

         o = text(o,'',{get(gca,'xlim')*[0;1],tvs.Pmax/1e3},10,'right','top');
         o = text(o,sprintf('Pmax(10ms) = %g kW  ',o.rd(tvs.Pmax/1e3,1)));

            % calculate and plot effective Ippeff

         Pmaxeff = tvs.Pmax * (tvs.Td0/Td)^tvs.kappa;
         hdl = plot(t*1e6,0*t+Pmaxeff/1e3,'k-.');
         set(hdl,'LineWidth',1);

         o = text(o,'',{get(gca,'xlim')*[0;1],Pmaxeff/1e3},10,'right','top');
         o = text(o,sprintf('Pmax(%gus) = %g kW  ',...
                            o.rd(Td*1e6,0),o.rd(Pmaxeff/1e3,1)));

            % calculate and plot derated effective Ippeff

         Pmaxder = Pmaxeff*tvs.derate;

         hdl = plot(t*1e6,0*t+Pmaxder/1e3,'r-.');
         set(hdl,'LineWidth',1);

         o = text(o,'',{get(gca,'xlim')*[0;1],Pmaxder/1e3},10,'right','top');
         o = text(o,sprintf('%g%% Pmax(%gus) = %g kW  ',...
                   o.rd(tvs.derate*100,0),o.rd(Td*1e6,0),o.rd(Pmaxder/1e3,1)));
         set(work(o,'hdl'),'Color',[1 0 0]);

         idx = find(pd>Pmaxder);
         plot(t(idx)*1e6,pd(idx)/1e3,'mo');
      end
      
         % title & labels
          
      title(sprintf('Power @ %s %s',tvs.kind,tvs.name));
      xlabel('time [us]');
      ylabel('c:pr, m:pd [kW]');
      grid on
      %legend({'TVS'},'Location','SouthWest');
   end
   function PlotResistor(o,sub)                                        
      subplot(sub);
      tvs = get(o,'tvs');
      
      hdl = plot(t*1e6,pr/1e3,'c');
      set(hdl,'LineWidth',2);

      hold on

         % calculate Td
          
      prmax = max(pr);
      idx = find(pr >= 0.5*prmax);
      t1 = t(idx(1));  t2 = t(idx(end));
      Td = t2-t1;

         % plot nominal max power Pmax
          
      res = get(o,'resistor');
      hdl = plot(t*1e6,0*t+res.Pmax/1e3,'k-.');
      set(hdl,'LineWidth',1);
      
      o = text(o,'',{get(gca,'xlim')*[0;1],res.Pmax/1e3},10,'right','top');
      o = text(o,sprintf('Pmax(10ms) = %g kW  ',o.rd(res.Pmax/1e3,2)));

         % calculate and plot effective Ippeff

      Pmaxeff = res.Pmax * (res.Td0/Td)^res.kappa;
      hdl = plot(t*1e6,0*t+Pmaxeff/1e3,'k-.');
      set(hdl,'LineWidth',1);

      o = text(o,'',{get(gca,'xlim')*[0;1],Pmaxeff/1e3},10,'right','top');
      o = text(o,sprintf('Pmax(%gus) = %g kW',...
                         o.rd(Td*1e6,0),o.rd(Pmaxeff/1e3,1)));

         % calculate and plot derated effective Ippeff

      Pmaxder = Pmaxeff*res.derate;
       
      hdl = plot(t*1e6,0*t+Pmaxder/1e3,'r-.');
      set(hdl,'LineWidth',1);

      o = text(o,'',{get(gca,'xlim')*[0;1],Pmaxder/1e3},10,'right','top');
      o = text(o,sprintf('%g%% Pmax(%gus) = %g kW',...
                o.rd(tvs.derate*100,0),o.rd(Td*1e6,0),o.rd(Pmaxder/1e3,1)));
      set(work(o,'hdl'),'Color',[1 0 0]);
       
      idx = find(pr>Pmaxder);
      plot(t(idx)*1e6,pr(idx)/1e3,'co');
       
         % title & labels
          
      title(sprintf('Power @ Resistor %s',res.name));
      xlabel('time [us]');
      ylabel('c:pr, m:pd [kW]');
      grid on
      %legend({'Resistor'},'Location','SouthWest');
   end
end
