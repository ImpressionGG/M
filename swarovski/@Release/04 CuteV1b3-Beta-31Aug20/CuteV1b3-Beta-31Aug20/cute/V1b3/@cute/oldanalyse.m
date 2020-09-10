function oo = analyse(o,varargin)                                      
%
% ANALYSE Analyse a CUTE object
%
%            analyse(o,'Setup')       % setup menu
%            analyse(o,'AnimationXY') % animate XY oscillation
%            analyse(o,'Sound')       % play sound of 'measurement data'
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CUTE, PLOT, COOK, BREW
%
   [gamma,oo] = manage(o,varargin,@Menu,@WithSho,@WithCuo,@Basket,...
                   @OvwMagnitude,...
                   @Bias,@Cockpit,@Evolution,@Plot,...
                   @Orbit,@Magnitude,@Helix,@Play,@AnimationXY,...
                   @AnimationHV,@AnimationHVplus,@AnimationKolben3D,...
                   @Level,@Sigma,@Cpk,@Thdr,@Sound);
   oo = gamma(oo);
end

%==========================================================================
% Menu
%==========================================================================

function oo = Menu(o)                  % Plot Stream                   
   switch type(current(o))
      case 'cut'
         MenuCut(o);
      case 'spm'
         MenuSpm(o);
   end
   oo = o;
end
function oo = MenuCut(o)               % Setup Analyse Cut Menu        
   oo = Current(o);

   %rotate = opt(o,{'select.rotate',0});
   %if (get(oo,{'rotated',inf}) ~= rotate)
   %   oo = Current(obrew(oo,'All');             % pre-process
   %   oo = set(oo,'rotated',rotate);
   %   current(o,oo);                   % update pre-processed cuo
   %end
   
   itab = cache(oo,'cluster.itab');
   N = size(itab,1);
   
      % Overview
      
   oo = mitem(o,'Overview');
   ooo = mitem(oo,'Magnitude',{@WithSho,'OvwMagnitude'});

   
   oo = Select(o);
   
      % Separator
      
   oo = mitem(o,'-');

      % Overview
      
   oo = mitem(o,'Overview');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Acceleration X',{@analyse,'Plot'},'Ax');
   ooo = mitem(oo,'Acceleration Y',{@analyse,'Plot'},'Ay');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Velocity X',{@analyse,'Plot'},'Vx');
   ooo = mitem(oo,'Velocity Y',{@analyse,'Plot'},'Vy');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Elongation X',{@analyse,'Plot'},'Sx');
   ooo = mitem(oo,'Elongation Y',{@analyse,'Plot'},'Sy');
   
      % Helix
      
   oo = mitem(o,'Helix');
   ooo = mitem(oo,'Kappl Acceleration',{@analyse,'Helix'},'A');
   ooo = mitem(oo,'Kappl Velocity',{@analyse,'Helix'},'V');
   ooo = mitem(oo,'Kappl Elongation',{@analyse,'Helix'},'S');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Kolben Acceleration',{@analyse,'Helix'},'B');

   %oo = mitem(o,'Play');
   %ooo = mitem(oo,'Acceleration',{@analyse,'Play'},'A');
   
      % Orbit
   
   oo = mitem(o,'Orbit');
   ooo = mitem(oo,'Acceleration X/Y',{@analyse,'Orbit'},'A');
   ooo = mitem(oo,'Velocity X/Y',{@analyse,'Orbit'},'V');
   ooo = mitem(oo,'Elongation X/Y',{@analyse,'Orbit'},'S');
   
      % Separator
      
   oo = mitem(o,'-');

      % Animation
      
   oo = mitem(o,'Animation');
   ooo = mitem(oo,'XY Kappl',{@analyse,'AnimationXY'});
   ooo = mitem(oo,'HV Kappl',{@analyse,'AnimationHV'});
   ooo = mitem(oo,'HV Kappl & Kolben',{@analyse,'AnimationHVplus'});
   ooo = mitem(oo,'XYZ Kolben 3D',{@analyse,'AnimationKolben3D'});

      % Separator
      
   oo = mitem(o,'-');

      % Cluster Algorithm
      
   oo = mitem(o,'Cluster');
   ooo = mitem(oo,'Level Clustering',{@WithCuo,'Level'});
   ooo = mitem(oo,'Sigma Clustering',{@WithCuo,'Sigma'});

      % Cpk & Chk Calculation
     
   oo = mitem(o,'Cpk');
   ooo = mitem(oo,'Cpk Algorithm',{@WithCuo,'Cpk'});
   oo = mitem(o,'Harmonic');
   ooo = mitem(oo,'THDR Algorithm',{@WithCuo,'Thdr'});

      % Separator
      
   oo = mitem(o,'-');

       % Sound
       
   oo = mitem(o,'Sound',{@analyse,'Sound'});

      % Test
   
   oo = mitem(o,'Test');
   ooo = mitem(oo,'Bias X',{@analyse,'Bias'},'RawX');
   ooo = mitem(oo,'Bias Y',{@analyse,'Bias'},'RawY');
end
function oo = MenuSpm(o)               % Setup Analyse Spm Menu        
   oo = mitem(o,'Eigenfrequency',{@EigenFrequency});
   oo = mitem(o,'Free System');
   ooo = mitem(oo,'Settling',{@FreeSystemResponse});
   ooo = mitem(oo,'FFT',{@FreeSystemFft});

   oo = mitem(o,'Constrained System');
   ooo = mitem(oo,'Constant Position',{@ConstantResponse});
   ooo = mitem(oo,'Ramping Position', {@RampingResponse});
   
   function o = EigenFrequency(o)                                      
      oo = current(o);
      A = oo.par.system.A;
      fprintf('Eigenfrequencies\n');
      s = eig(A);
      
      s = s(1:2:length(s)-1);
      [~,idx] = sort(imag(s));
      s = s(idx);
      
      for (i=1:length(s))
         si = s(i);
         om = imag(si);
         f = om/2/pi;
         delta = -real(si);
         T = 1/delta;
         if (f < 1000)
            fprintf('   f%g = %g Hz, T%g = %g ms\n',i,round(f),i,round(T*1000)); 
         else
            fprintf('   f%g = %g kHz, T%g = %g ms\n',i,round(f)/1000,i,round(T*1000)); 
         end
      end
   end
   function o = FreeSystemResponse(o)                                  
      oo = current(o);
      model = get(oo,'model');
      x0 = model(oo,[]);
      [A1,A2,B,C] = model(oo);
      Fn = get(oo,'parameter.Fn');
      
      oo = csim(oo,'Free');
      
      cls(o);
      subplot(311);
      plot(oo.data.t,1000*oo.data.y(1,:),'r');
      title(sprintf('Auslenkung y1(t) bei sprunghafter Normalkraft Fn = %g N',Fn));
      ylabel('y1 (�)');
      
      subplot(312);
      plot(oo.data.t,1000*oo.data.y(2,:),'g');
      title(sprintf('Auslenkung y2(t) bei sprunghafter Normalkraft Fn = %g N',Fn));
      ylabel('y2 (�)');

      subplot(313);
      plot(oo.data.t,1000*oo.data.y(3,:),'b');
      title(sprintf('Auslenkung y3(t) bei sprunghafter Normalkraft Fn = %g N',Fn));
      ylabel('y3 (�)');
      xlabel('t (s)');
   end
   function o = FreeSystemFft(o)                                       
      oo = current(o);
      model = get(oo,'model');
      x0 = model(oo,[]);
      [A1,A2,B,C] = model(oo);
      Fn = get(oo,'parameter.Fn');
      
      oo = csim(oo);
      
      cls(o);
      fft(o,oo.data.t,oo.data.y*1000);
      title(sprintf('FFT von y(t) bei sprunghafter Normalkraft Fn = %g N',Fn));
      ylabel('y (�)');
      xlabel('f (Hz)');
   end
   function o = ConstantResponse(o)                                    
      oo = current(o);
      model = get(oo,'model');
      x0 = model(oo,[]);
      [A1,A2,B,C] = model(oo);
      Fn = get(oo,'parameter.Fn');
      
      oo = csim(oo,'Constant');
      
      cls(o);
      subplot(311);
      plot(oo.data.t,1000*oo.data.y(1,:),'r');
      title(sprintf('Auslenkung y1(t) bei sprunghafter Normalkraft Fn = %g N',Fn));
      ylabel('y1 (�)');
      
      subplot(312);
      plot(oo.data.t,1000*oo.data.y(2,:),'g');
      title(sprintf('Auslenkung y2(t) bei sprunghafter Normalkraft Fn = %g N',Fn));
      ylabel('y2 (�)');

      subplot(313);
      plot(oo.data.t,1000*oo.data.y(3,:),'b');
      title(sprintf('Auslenkung y3(t) bei sprunghafter Normalkraft Fn = %g N',Fn));
      ylabel('y3 (�)');
      xlabel('t (s)');
   end
   function o = RampingResponse(o)                                     
      oo = current(o);
      model = get(oo,'model');
      x0 = model(oo,[]);
      [A1,A2,B,C] = model(oo);
      vs = get(oo,'parameter.vs');
      
      oo = csim(oo,'Ramp');
      
      cls(o);
      subplot(311);
      plot(oo.data.t,1000*oo.data.y(1,:),'r');
      title(sprintf('Auslenkung y1(t) bei Rampe y3 = vs*t (vs = %g m/s)',vs));
      ylabel('y1 (�)');
      
      subplot(312);
      plot(oo.data.t,1000*oo.data.y(2,:),'g');
      title(sprintf('Auslenkung y2(t) bei Rampe y3 = vs*t (vs = %g m/s)',vs));
      ylabel('y2 (�)');

      subplot(313);
      plot(oo.data.t,1000*oo.data.y(3,:),'b');
      title(sprintf('Ueberpruefung der Rampe y3 = vs*t (vs = %g m/s)',vs));
      ylabel('y3 (�)');
      xlabel('t (s)');
   end
end
function oo = Select(o)                % Analyse/Select Menu           
   setting(o,{'analyse.select.signal'},'All');
   setting(o,{'analyse.select.scaling'},'same');
   setting(o,{'animation.delta'},0.005);
   setting(o,{'analyse.filter.type'},'order4');
   setting(o,{'analyse.filter.bandwidth'},150);
   setting(o,{'analyse.filter.kind'},10);
   
   setting(o,{'analyse.spec.good'},25);
   setting(o,{'analyse.spec.bad'},100);

   if (0)
      setting(o,{'select.facette'},0);
      oo = current(o);
      %idx = cluster(oo);
      %n = size(idx,1);
      oo = cache(oo,'cluster');        % refresh cluster cache segment
      itab = cache(oo,'cluster.itab');
      n = size(itab,1);

      oo = mseek(sho,{'Select'});
      ooo = mhead(oo,'Facette',{},'select.facette');
      list = {{'Total',0},{'Compact',-1},{}};
      for (i=1:n)
         list{end+1} = {sprintf('Facette #%d',i),i};
      end
      choice(ooo,list,{});
   end
   
      % Parameter menu
      
   oo = mhead(o,'Parameter');
   
      % Signal
      
   ooo = mitem(oo,'Signal',{},'analyse.select.signal');
   choice(ooo,{{'All','All'},{'Acceleration X','Ax'}},{});

      % Scaling
      
   ooo = mitem(oo,'Scaling',{},'analyse.select.scaling');
   choice(ooo,{{'Same','same'},{'Individual','individual'}},{});

      % Filter
      
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Filter Type',{},'analyse.filter.type');
   choice(ooo,{{'Order 3 B/F','order3'},{'Order 4 Low Pass','order4lp'},...
               {'Order 4 High/Low Pass','order4'},{'Comb','comb'},{'Parabolic','parabolic'}},{});
   ooo = mitem(oo,'Filter Bandwidth [Hz]',{},'analyse.filter.bandwidth');
   choice(ooo,[1 2 5 10 20 30 40 50 75 100 150 200 300 500 750 1000 1250 1500],{});
   ooo = mitem(oo,'Filter Kind',{},'analyse.filter.kind');
   choice(ooo,[1 10 25 50 75 100 125 150 200:100:800 ],{});

      % Animation
      
   ooo = mitem(oo,'-');   
   ooo = mitem(oo,'Animation');
   oooo = mitem(ooo,'Speed',{},'animation.delta');
   choice(oooo,{{'Slow',0.001},{'Medium',0.005},{'Fast',0.05}},{});
   ooo = mitem(oo,'-');
   
end

%=========================================================================
% General Callback and Acting on Basket
%=========================================================================

function oo = WithSho(o)               % General Shell Object Callback 
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
function oo = WithCuo(o)               % General Callback              
%
% WITHCUO    A general callback with refresh function redefinition, screen
%            clearing, current object pulling and forwarding to executing
%            local function, reporting of irregularities, dark mode support
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
function oo = Basket(o)                % Acting on the Basket          
%
% BASKET  Plot basket, or perform actions on the basket, screen clearing, 
%         current object pulling and forwarding to executing local func-
%         tion, reporting of irregularities and dark mode support
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
function oo = Current(o)                                               
   oo = current(o);
   switch type(oo)
      case 'cut'
         'OK';
      case 'pkg'
         menu(oo,'About');
         oo = [];
         return
      otherwise
         oo = [];
         return
   end
   
   [oo,bag,rf] = cache(oo,oo,'brew'); % hard refresh of brew cache segment
end

%==========================================================================
% Helper
%==========================================================================

function oo = Diagram(o,mode,x,y,sub)                                  
%
% DIAGRAM   Draw Diagram in given subplot
%
%              Diagram(o,mode,x,y,sub)
%              Diagram(o,'Ax',t,ax,[2 1 1])
%
%           with mode:
%              'Ax','Ay','Az'  Acceleration x,y,z
%              'Vx','Vy','Vz'  Velocity     x,y,z
%              'Sx','Sy','Sz'  Elongation   x,y,z
%              'Axy'           acceleration x/y plot
%              'Vxy'           velocity x/y plot
%              'Sxy'           elongation x/y plot
%
   lw = opt(o,{'style.linewidth',1});
   epilog = opt(o,'epilog');
   
   switch mode
      case 'Ax'
         tit = 'Acceleration X';  ylab = 'ax [g]';  col = 'r';
         xy = 0;  kind = 'a';  cat = 1;
      case 'Ay'
         tit = 'Acceleration Y';  ylab = 'ay [g]';  col = 'r'; 
         xy = 0;  kind = 'a';  cat = 1;
      case 'Az'
         tit = 'Acceleration Z';  ylab = 'az [g]';  col = 'r';
         xy = 0;  kind = 'a';  cat = 1;
      case 'Ar'
         tit = sprintf('Acceleration Magnitude (amax = %g g)',round(max(y)));    
         ylab = 'a [g]';  col = 'r'; xy = 0;  kind = 'a';  cat = 1;
      
      case 'Br'
         tit = sprintf('Kolben Acceleration Magnitude (amax = %g g)',round(max(y)));    
         ylab = 'b [g]';  col = 'rrk'; xy = 0;  kind = 'b';  cat = 1;
      case 'Cr'
         tit = sprintf('Correlation of Kolben-Kappl Acceleration Magnitudes',round(max(y)));    
         ylab = 'b [g]';  col = 'rrk'; xy = 0;  kind = 'b';  cat = 1;
         
         
      case 'Vx'
         tit = 'Velocity X';      ylab = 'vx [mm/s]';  col = 'b';
         xy = 0;  kind = 'v';  cat = 3;
      case 'Vy'
         tit = 'Velocity Y';      ylab = 'vy [mm/s]';  col = 'b';
         xy = 0;  kind = 'v';  cat = 3;
      case 'Vz'
         tit = 'Velocity Z';      ylab = 'vz [mm/s]';  col = 'b';
         xy = 0;  kind = 'v';  cat = 3;
      case 'Vr'
         tit = sprintf('Velocity Magnitude (vmax = %g mm/s)',round(max(y)));    
         ylab = 'v [mm/s]';  col = 'b'; xy = 0;  kind = 'v';  cat = 3;
      case 'Sx'
         tit = 'Elongation X';    ylab = 'sx [um]';  col = 'g';
         xy = 0;  kind = 's';  cat = 5;
      case 'Sy'
         tit = 'Elongation Y';    ylab = 'sy [um]';  col = 'g';
         xy = 0;  kind = 's';  cat = 5;
      case 'Sz'
         tit = 'Elongation Z';    ylab = 'sz [um]';  col = 'g';
         xy = 0;  kind = 's';  cat = 5;
      case 'Sr'
         tit = sprintf('Elongation Magnitude (smax = %g um)',round(max(y)));    
         ylab = 's [um]';  col = 'g'; xy = 0;  kind = 's';  cat = 5;

      case 'Axy'
         tit = 'Acceleration Orbit'; 
         xlab = 'ax [g]';     ylab = 'ay [g]';     col = 'r';
         xy = 1;  kind = 'A';  cat = 1;
      case 'AXY'
         x0 = mean(x);  y0 = mean(y);
         amax = round(sqrt(max((x-x0).^2+(y-y0).^2)));
         tit = o.iif(sub(3)==1,epilog,sprintf('amax = %g g',amax)); 
         epilog = '';
         xlab = 'ax [g]';     ylab = 'ay [g]';     col = 'r';
         xy = 1;  kind = 'A';  cat = 1;
         
      case 'Vxy'
         tit = 'Velocity Orbit'; 
         xlab = 'vx [mm/s]';  ylab = 'vy [mm/s]';  col = 'b';
         xy = 1;  kind = 'V';  cat = 3;
      case 'VXY'
         x0 = mean(x);  y0 = mean(y);
         vmax = round(sqrt(max((x-x0).^2+(y-y0).^2)));
         tit = o.iif(sub(3)==1,epilog,sprintf('vmax = %g mm/s',vmax)); 
         epilog = '';
         xlab = 'vx [mm/s]';  ylab = 'vy [mm/s]';  col = 'b';
         xy = 1;  kind = 'V';  cat = 3;
         
      case 'Sxy'
         tit = 'Elongation Orbit'; 
         xlab = 'sx [um]';    ylab = 'sy [um]';    col = 'g';
         xy = 1;  kind = 'S';  cat = 5;
      case 'SXY'
         x0 = mean(x);  y0 = mean(y);
         smax = round(sqrt(max((x-x0).^2+(y-y0).^2)));
         tit = o.iif(sub(3)==1,epilog,sprintf('smax = %g um',smax)); 
         epilog = '';
         xlab = 'sx [um]';    ylab = 'sy [um]';    col = 'g';
         xy = 1;  kind = 'S';  cat = 5;
   end
   
   subplot(sub(1),sub(2),sub(3));
   o.color(plot(x,y),col,lw);
   
      % set background color and grid
      
   set(gca,'color',o.iif(dark(o),0,1)*[1 1 1]);
   grid(o);
   dark(o,'Axes');
   
   o = opt(o,'kind',kind);
   
   spec(o,mode,all(y>=0));
   
   if (xy)
      xlabel(xlab);
      set(gca,'DataAspectratio',[1 1 1]);
      maxi = max(max(abs(x)),max(abs(y)))+0.1;
      hold on;
      plot(maxi*[-1 1],maxi*[-1 1],'w.');
   else
      set(gca,'xlim',[min(x),max(x)]);
   end
   ylabel(ylab);
   
   if ~isempty(epilog)
      title([tit,' ',epilog]);
   else
      title(tit);
   end
   oo = o;
end
function SpecLimits(o,positive)                                        
   %good = opt(o,{'analyse.spec.good',25});
   %bad  = opt(o,{'analyse.spec.bad',100});
   
   spec = opt(o,{'spec',1});
   if (~spec)
      return     % don't show spec limits
   end
   
   kind = opt(o,{'kind',''});
   switch kind
      case {'A','a'}
         [spec,limit,unit] = category(o,1);
      case {'V','v'}
         [spec,limit,unit] = category(o,3);
      case {'S','s'}
         [spec,limit,unit] = category(o,5);
      otherwise
         return
   end
   good = max(spec);
   bad = good*4;
   
   if (kind == upper(kind))          % circular
      phi = 0:pi/100:2*pi;
      hold on;
      plot(good*cos(phi),good*sin(phi),'k');
      plot(bad *cos(phi), bad*sin(phi),'k');
      plot([0 0],bad*[-1.2 1.2],'k');
      plot(bad*[-1.2 1.2],[0 0],'k');

      if (length(limit) > 0 && prod(limit) ~= 0)
         set(gca,'xlim',limit, 'ylim',limit);
      end
      set(gca,'DataaspectRatio',[1 1 1])
   else
      xlim = get(gca,'xlim');
      plot(xlim,+good*[1 1],'k-');
      plot(xlim,-good*[1 1],'k-');
      plot(xlim, +bad*[1 1],'k-');
      plot(xlim, -bad*[1 1],'k-');
      
      if (nargin >=2 && positive)
         limit(1) = -0.0001;
      end
      if (length(limit) > 0 && prod(limit) ~= 0)
         set(gca,'ylim',limit);
      end
   end
end

%==========================================================================
% Overview / Helix
%==========================================================================

function o = OvwMagnitude(o)           % Overview Magnitude            
   tree = select(o);
   
      % determine max number of objects per package
      
   n = length(tree);  m = 0;
   for (i=1:n)
      branch = tree{i};
      m = max(m,length(branch));
   end
   
      % plot overview
      
   for (j=1:n)
      branch = tree{j};
      for (i=1:length(branch))
         oo = inherit(branch{i},o);
         
         k = (i-1)*n + j;
         if (i==1)                     % package object
            PlotPackage(oo,[m,n,k]);
         else
            PlotMagnitude(oo,[m,n,k])
         end
         shg(o);  pause(0.05);         % show graphics & pause
      end
   end
   
   function PlotPackage(oo,sub)        % Plot a Package Objevt         
      subplot(sub(1),sub(2),sub(3));
      
      hdl = text(0,0,get(oo,{'title',''}));
      set(hdl,'Horizontal','center','vertical','mid');
      set(hdl,'Color',o.color(o.iif(dark(o),'w','k')));
      
      n = sub(2);                      % number of columns
      if (n <= 3)
         ftsz = 14;
      else
         ftsize = 12;
      end
         
      set(hdl,'FontSize',ftsz);
      axis off;
      set(gca,'xlim',[-1 1],'ylim',[-1 1]);
      dark(o,'Axis');
   end
   function PlotMagnitude(oo,sub)      % Plot Magnitude                
      t  = cook(oo,':');
      ax = cook(oo,'ax');
      ay = cook(oo,'ay');
      az = cook(oo,'az');
      ar = sqrt(ax.*ax+ay.*ay+az.*az);
      diagram(oo,'Ar',t,ar,sub);   
   end
end


function oo = Plot(o)                  % plot any                      
   uscore = util(o,'uscore');
   mode = arg(o,1);
   
   refresh(o,o);
   oo = Current(o);
   
   t = cook(oo,':','stream');
   
   switch mode
      case 'Ax'
         y = cook(oo,'ax','stream');
         tit = sprintf('Acceleration X (max %g g)',round(max(abs(y))));
         diagram = 'Ax';
      case 'Ay'
         y = cook(oo,'ay','stream');
         tit = sprintf('Acceleration Y (max %g g)',round(max(abs(y))));
         diagram = 'Ay';
      case 'Vx'
         y = cook(oo,'vx','stream');
         tit = sprintf('Velocity X (max %g mm/s)',round(max(abs(y))));
         diagram = 'Vx';
      case 'Vy'
         y = cook(oo,'vy','stream');
         tit = sprintf('Velocity Y (max %g mm/s)',round(max(abs(y))));
         diagram = 'Vy';
      case 'Sx'
         y = cook(oo,'sx','stream');
         tit = sprintf('Elongation X (max %g um)',round(max(abs(y))));
         diagram = 'Sx';
      case 'Sy'
         y = cook(oo,'sy','stream');
         tit = sprintf('Elongation Y (max %g um)',round(max(abs(y))));
         diagram = 'Sy';
      otherwise
         return
   end         

   cls(o);
   
      % x plots

   Diagram(oo,diagram,t,y,[1 1 1]);
   title(tit);
   
   txt0 = uscore(get(oo,'title'));
   txt1 = sprintf('nick: %s',get(oo,'nick'));
   txt2 = sprintf('kappl: %s',get(oo,'kappl'));
   txt3 = sprintf('lage: %g (angle %d�)',get(oo,'lage'),round(get(oo,'angle')));
   xlabel([txt0,', ',txt1,', ',txt2,', ',txt3]);
end
function oo = Helix(o)                 % helix plot                    
   mode = arg(o,1);
   refresh(o,o);
   cls(o);
   
   oo = Current(o);   
   if isempty(oo)
      return
   end
   
   t = cook(oo,':','stream');
   
   switch mode
      case 'A'
         ax = cook(oo,'ax','stream');
         ay = cook(oo,'ay','stream');
         helix(oo,'Plot',t,ax,ay);
         kind = 'Kappl Acceleration';
      case 'V'
         vx = cook(oo,'vx','stream');
         vy = cook(oo,'vy','stream');
         helix(oo,'Plot',t,vx,vy);
         kind = 'Kappl Velocity';
      case 'S'
         sx = cook(oo,'sx','stream');
         sy = cook(oo,'sy','stream');
         helix(oo,'Plot',t,sx,sy);
         kind = 'Kappl Elongation';
      case 'B'
         ax = cook(oo,'ax','stream');
         ay = cook(oo,'ay','stream');
         az = cook(oo,'az','stream');
         helix(oo,'Plot',t,ax,ay);

         bx = cook(oo,'bx','stream');
         by = cook(oo,'by','stream');
         bz = cook(oo,'by','stream');
         a = sqrt(ax.*ax+ay.*ay+az.*az);
         b = sqrt(bx.*bx+by.*by+bz.*bz);
         helix(oo,'Magnitude',t,50*b,5*sin(100*t).*b);
         kind = 'Kolben Acceleration';
   end
   
   Legend(oo,kind);
   view(30,15);
end
function oo = Play(o)                  % helix plot                    
   mode = arg(o,1);
   refresh(o,o);
   cls(o);
   
   oo = Current(o);   
   t = cook(oo,':','stream');
   
   switch mode
      case 'A'
         ax = cook(oo,'ax','stream');
         ay = cook(oo,'ay','stream');
         play(oo,t,ax,ay);
         kind = 'Acceleration';
      case 'V'
         vx = cook(oo,'vx','stream');
         vy = cook(oo,'vy','stream');
         helix(oo,t,vx,vy);
         kind = 'Velocity';
      case 'S'
         sx = cook(oo,'sx','stream');
         sy = cook(oo,'sy','stream');
         helix(oo,t,sx,sy);
         kind = 'Elongation';
   end
   
   tit = [kind,' (',underscore(o,get(cuo,'title')),')'];
   hdl=text(0,0,max(get(gca,'zlim')),tit); 
   set(hdl,'color','w', 'HorizontalAlignment','center')
   view(30,15);
end
function oo = Orbit(o)                 % X/Y Orbit Plot                
   mode = arg(o,1);
   
   refresh(o,o);
   oo = Current(o);
   cls(o);
      
      % x/y plots

   switch mode
      case 'A'
         ax = cook(oo,'ax','stream');
         ay = cook(oo,'ay','stream');
         Diagram(oo,'Axy',ax,ay,[1 1 1]);
   
      case 'V'
         vx = cook(oo,'vx','stream');
         vy = cook(oo,'vy','stream');
         Diagram(oo,'Vxy',vx,vy,[1 1 1]);
   
      case 'S'
         sx = cook(oo,'sx','stream');
         sy = cook(oo,'sy','stream');
         Diagram(oo,'Sxy',sx,sy,[1 1 1]);
   end
end
function oo = Legend(o,kind)           % Plot Helix Legend             
   zmax = max(get(gca,'zlim'));
   tit = [kind,' (',underscore(o,get(o,'title')),')'];
   hdl1 = text(0,0,1.05*zmax,[tit,' - ',get(o,{'package',''})]); 
   dsc = sprintf('Station: %s, Kappl: %s, Vcut = %g m/s, Vseek = %g mm/s',...
                 get(o,{'station',''}),get(o,{'kappl',''}),...
                 get(o,{'vcut',0}),get(o,{'vseek',0}));
   hdl2 = text(0,0,1.00*zmax,dsc); 
   hdl3 = [];
   
   lage = get(o,'lage');
   if o.is(lage) && isa(lage,'double')
      facettes = get(o,sprintf('facette%g',lage));
      fidx = opt(o,'select.facette');
      if (length(facettes) > 0 && o.is(fidx))
         ftxt = sprintf(', Facette: %g',1);
         switch fidx
            case {0,-1}
               for (i=2:length(facettes))
                  ftxt = [ftxt,sprintf('-%g',i)];
               end
         end
      end
      hdl3 = text(0,0,0.95*zmax,[sprintf('Lage: %g',lage),ftxt]); 
   end
   
   set([hdl1(:);hdl2(:);hdl3(:)],'color','w', 'HorizontalAlignment','center')
end

%==========================================================================
% Animation
%==========================================================================

function oo = AnimationXY(o)           % XY Animation                  
   mode = arg(o,1);
   
   oo = current(o);
   
   t = data(oo,'t');
   ax = data(oo,'ax');
   ay = data(oo,'ay');
   
   cls(o);
   
   hax1 = subplot(3,2,1);
   plot(t,ax,'r');
   hold on;
   
   hax2 = subplot(3,2,3);
   plot(t,ay,'g');
   hold on;
   
   interval = min(t) + [0 0.005];

   hax3 = subplot(6,2,9);
   plot(t,ax,'r');
   hold on;
   hdl3 = plot(hax3,interval(1),0,'bo');
   ylim3 = get(hax3,'ylim');
   
   hax4 = subplot(6,2,11);
   plot(t,ay,'g');
   hold on;
   hdl4 = plot(hax4,interval(1),0,'bo');
   ylim4 = get(hax4,'ylim');

   lim(1) = min(ylim3(1),ylim4(1));
   lim(2) = max(ylim3(2),ylim4(2));
   lim = lim/2;
   
   set(hax1,'ylim',lim);
   set(hax2,'ylim',lim);
   
   hax = subplot(1,2,2);
   idx = find(t >= interval(1) & t <= interval(2)); 
   hdl = plot(ax(idx),ay(idx));
   hold on;
   set(hax,'xlim',lim,'ylim',lim);
   set(hax,'DataAspectRatio',[1,1,1]);
   xlabel('Ax (g)');
   ylabel('Ay (g)');
   
   set(gcf,'WindowButtonDownFcn','terminate(sho)');
   timer(o,0.01);
   while (~stop(o) && interval(1) < max(t))
      set(hax1,'xlim',interval);
      set(hax2,'xlim',interval);
      
      delta = opt(o,'animation.delta');
      if ~isempty(idx)
         if (max(abs(ax(idx))) < lim(2)/10 && max(abs(ay(idx))) < lim(2)/10)
             delta = delta * 10;
         end
      end      
      interval = interval + delta;
      idx = find(t >= interval(1) & t <= interval(2)); 

      delete(hdl);
      hdl = plot(hax,ax(idx),ay(idx),'b');
      
         % show current time with a circle in axes 3 & 4
         
      delete(hdl3);
      hdl3 = plot(hax3,interval(1),0,'bo');
      delete(hdl4);
      hdl4 = plot(hax4,interval(1),0,'bo');
      
      drawnow;
      %pause(0.00001);
   end
   set(gcf,'WindowButtonDownFcn','');
end
function oo = AnimationHV(o)           % Horizontal/Vertical Animation 
   mode = arg(o,1);
   
   oo = current(o);
   
   lage = get(oo,{'lage','Nan'});
   angle = get(oo,{'angle',NaN});
   if isnan(angle)
      message(o,'Unable to extract processing angle!');
      return
   end
   phi = angle*pi/180;                 % convert to radians
   
   t = data(oo,'t');
   ax = data(oo,'ax');
   ay = data(oo,'ay');
   
      % convert to horizontal/vertical coordinates
   
   Ax = ax*sin(phi);
   Ay = ay;
   Az = ax*cos(phi);

   cls(o);
   
   hax1 = subplot(4,2,1);
   plot(t,Ax,'r');
   hold on;
   
   hax2 = subplot(4,2,3);
   plot(t,Ay,'g');
   hold on;
   
   interval = min(t) + [0 0.005];

   hax3 = subplot(8,2,11);
   plot(t,Ax,'r');
   hold on;
   hdl3 = plot(hax3,interval(1),0,'bo');
   ylim3 = get(hax3,'ylim');
   ylabel('ax (g)');
   
   hax4 = subplot(8,2,13);
   plot(t,Ay,'g');
   hold on;
   hdl4 = plot(hax4,interval(1),0,'bo');
   ylim4 = get(hax4,'ylim');
   ylabel('ay (g)');

   hax5 = subplot(8,2,15);
   plot(t,Az,'b');
   hold on;
   hdl5 = plot(hax5,interval(1),0,'bo');
   ylim5 = get(hax5,'ylim');
   ylabel('az (g)');

   lim(1) = min(ylim3(1),ylim4(1));
   lim(2) = max(ylim3(2),ylim4(2));
   lim = lim/2;
   
   set(hax1,'ylim',lim);
   set(hax2,'ylim',lim);
   
      % X/Y plane
      
   haxy = subplot(2,2,4);
   idx = find(t >= interval(1) & t <= interval(2)); 
   hdlxy = plot(Ay(idx),Ax(idx));
   hold on;
   title(sprintf('Horizontal Oscillation (Lage %g)',lage))
   xlabel('Ay (g)');
   ylabel('Ax (g)');
   set(haxy,'xlim',lim,'ylim',lim);
   set(haxy,'DataAspectRatio',[1,1,1]);

      % Y/Z plane
      
   hayz = subplot(2,2,2);
   idx = find(t >= interval(1) & t <= interval(2)); 
   hdlyz = plot(Ay(idx),Az(idx));
   hold on;
   title(sprintf('Vertical Coupling (angle = %g�)',angle))
   xlabel('Ay (g)');
   ylabel('Az (g)');
   set(hayz,'xlim',lim,'ylim',lim);
   set(hayz,'DataAspectRatio',[1,1,1]);

      % let's go ...
      
   set(gcf,'WindowButtonDownFcn','terminate(sho)');
   timer(o,0.01);
   while (~stop(o) && interval(1) < max(t))
      set(hax1,'xlim',interval);
      set(hax2,'xlim',interval);
      
      delta = opt(o,'animation.delta');
      if ~isempty(idx)
         if (max(abs(Ax(idx))) < lim(2)/10 && max(abs(Ay(idx))) < lim(2)/10)
             delta = delta * 10;
         end
      end
      interval = interval + delta;
      idx = find(t >= interval(1) & t <= interval(2)); 

         % update X/Y plane and Y/Z plane
         
      delete(hdlxy);
      hdlxy = plot(haxy,Ay(idx),Ax(idx),'b');

      delete(hdlyz);
      hdlyz = plot(hayz,Ay(idx),Ax(idx),'b');

         % show current time with a circle in axes 3 & 4
         
      delete(hdl3);
      hdl3 = plot(hax3,interval(1),0,'bo');
      delete(hdl4);
      hdl4 = plot(hax4,interval(1),0,'bo');
      delete(hdl5);
      hdl5 = plot(hax5,interval(1),0,'bo');
      
      drawnow;
      %pause(0.00001);
   end
   set(gcf,'WindowButtonDownFcn','');
end
function oo = AnimationHVplus(o)       % Kolben plus Kappl Animation   
   mode = arg(o,1);
   
   oo = current(o);
   
   lage = get(oo,{'lage','Nan'});
   angle = get(oo,{'angle',NaN});
   if isnan(angle)
      message(o,'Unable to extract processing angle!');
      return
   end
   phi = angle*pi/180;                 % convert to radians
   
   t = data(oo,'t');
   ax = data(oo,'ax');
   ay = data(oo,'ay');

   bx = data(oo,'bx');
   by = data(oo,'by');
   bz = data(oo,'bz');
   
      % convert to horizontal/vertical coordinates
   
   Ax = ax*sin(phi);
   Ay = ay;
   Az = ax*cos(phi);

   cls(o);
   
   hax1 = subplot(5,3,1);
   plot(t,Ax,'r');
   hold on;
   
   hax2 = subplot(5,3,4);
   plot(t,Ay,'g');
   hold on;
   
   interval = min(t) + [0 0.005];

      % Kappl accelerations
      
   hax3 = subplot(10,3,13);
   plot(t,Ax,'r');
   hold on;
   hdl3 = plot(hax3,interval(1),0,'bo');
   ylim3 = get(hax3,'ylim');
   ylabel('ax (g)');
   
   hax4 = subplot(10,3,16);
   plot(t,Ay,'g');
   hold on;
   hdl4 = plot(hax4,interval(1),0,'bo');
   ylim4 = get(hax4,'ylim');
   ylabel('ay (g)');

   hax5 = subplot(10,3,19);
   plot(t,Az,'b');
   hold on;
   hdl5 = plot(hax5,interval(1),0,'bo');
   ylim5 = get(hax5,'ylim');
   ylabel('az (g)');

      % Kolben accelerations

   hax6 = subplot(10,3,22);
   corazito.plot(hax6,t,bx,'rk');
   hold on;
   hdl6 = plot(hax6,interval(1),0,'bo');
   ylim6 = get(hax6,'ylim');
   ylabel('bx (g)');
   
   hax7 = subplot(10,3,25);
   corazito.plot(hax7,t,by,'gk');
   hold on;
   hdl7 = plot(hax7,interval(1),0,'bo');
   ylim7 = get(hax7,'ylim');
   ylabel('by (g)');

   hax8 = subplot(10,3,28);
   corazito.plot(hax8,t,bz,'bk');
   hold on;
   hdl8 = plot(hax8,interval(1),0,'bo');
   ylim8 = get(hax8,'ylim');
   ylabel('bz (g)');

      % Limits
      
   lim1(1) = min([ylim3(1),ylim4(1),ylim5(1)]);
   lim1(2) = max([ylim3(2),ylim4(2),ylim5(2)]);
   lim1 = lim1/2;
   
   set(hax1,'ylim',lim1);
   set(hax2,'ylim',lim1);

   lim2(1) = min([ylim6(1),ylim7(1),ylim8(1)]);
   lim2(2) = max([ylim6(2),ylim7(2),ylim8(2)]);
   lim2 = lim2/2;
   

      % X/Y plane Kappl
      
   haxy1 = subplot(2,3,2);
   idx = find(t >= interval(1) & t <= interval(2)); 
   hdlxy1 = plot(Ay(idx),Ax(idx));
   hold on;
   title(sprintf('Kappl/Horizontal (Lage %g)',lage))
   xlabel('Ay (g)');
   ylabel('Ax (g)');
   set(haxy1,'xlim',lim1,'ylim',lim1);
   set(haxy1,'DataAspectRatio',[1,1,1]);

      % Y/Z plane Kappl
      
   hayz1 = subplot(2,3,5);
   idx = find(t >= interval(1) & t <= interval(2)); 
   hdlyz1 = plot(Ay(idx),Az(idx));
   hold on;
   title(sprintf('Vertical Coupling (angle = %g�)',angle))
   xlabel('Ay (g)');
   ylabel('Az (g)');
   set(hayz1,'xlim',lim1,'ylim',lim1);
   set(hayz1,'DataAspectRatio',[1,1,1]);

      % X/Y plane Kolben
      
   haxy2 = subplot(2,3,3);
   idx = find(t >= interval(1) & t <= interval(2)); 
   hdlxy2 = plot(by(idx),bx(idx));
   hold on;
   title(sprintf('Kolben/Transversal (Lage %g)',lage))
   xlabel('by (g)');
   ylabel('bx (g)');
   set(haxy2,'xlim',lim2,'ylim',lim2);
   set(haxy2,'DataAspectRatio',[1,1,1]);

      % Y/Z plane Kappl
      
   hayz2 = subplot(2,3,6);
   idx = find(t >= interval(1) & t <= interval(2)); 
   hdlyz2 = plot(by(idx),bz(idx));
   hold on;
   title(sprintf('Vertical Coupling (angle = %g�)',angle))
   xlabel('Ay (g)');
   ylabel('Az (g)');
   set(hayz2,'xlim',lim2,'ylim',lim2);
   set(hayz2,'DataAspectRatio',[1,1,1]);

      % let's go ...
      
   set(gcf,'WindowButtonDownFcn','terminate(sho)');
   timer(o,0.01);
   while (~stop(o) && interval(1) < max(t))
      set(hax1,'xlim',interval);
      set(hax2,'xlim',interval);
      
      delta = opt(o,'animation.delta');
      if ~isempty(idx)
         if (max(abs(Ax(idx))) < lim1(2)/10 && max(abs(Ay(idx))) < lim1(2)/10)
             delta = delta * 10;
         end
      end
      interval = interval + delta;
      idx = find(t >= interval(1) & t <= interval(2)); 

         % update X/Y plane and Y/Z plane
         
      delete(hdlxy1);
      hdlxy1 = plot(haxy1,Ay(idx),Ax(idx),'b');

      delete(hdlyz1);
      hdlyz1 = plot(hayz1,Ay(idx),Az(idx),'b');

      delete(hdlxy2);
      hdlxy2 = plot(haxy2,by(idx),bx(idx),'b');

      delete(hdlyz2);
      hdlyz2 = plot(hayz2,by(idx),bz(idx),'b');

         % show current time with a circle in axes 3/4/5 & 6/7/8
         
      delete(hdl3);
      hdl3 = plot(hax3,interval(1),0,'bo');
      delete(hdl4);
      hdl4 = plot(hax4,interval(1),0,'bo');
      delete(hdl5);
      hdl5 = plot(hax5,interval(1),0,'bo');
      
      delete(hdl6);
      hdl6 = plot(hax6,interval(1),0,'ro');
      delete(hdl7);
      hdl7 = plot(hax7,interval(1),0,'ro');
      delete(hdl8);
      hdl8 = plot(hax8,interval(1),0,'ro');

      drawnow;
      %pause(0.00001);
   end
   set(gcf,'WindowButtonDownFcn','');
end
function oo = AnimationKolben3D(o)     % Kolben 3D animation           
   mode = arg(o,1);
   
   oo = current(o);
   
   lage = get(oo,{'lage','Nan'});
   angle = get(oo,{'angle',NaN});
   if isnan(angle)
      message(o,'Unable to extract processing angle!');
      return
   end
   phi = angle*pi/180;                 % convert to radians
   
   t = data(oo,'t');
   ax = data(oo,'ax');
   ay = data(oo,'ay');

   bx = data(oo,'bx');
   by = data(oo,'by');
   bz = data(oo,'bz');
   
      % convert to horizontal/vertical coordinates
   
   Ax = ax*sin(phi);
   Ay = ay;
   Az = ax*cos(phi);

   cls(o);
   
   hax1 = subplot(4,2,1);
   plot(t,Ax,'r');
   hold on;
   
   hax2 = subplot(4,2,3);
   plot(t,Ay,'g');
   hold on;
   
   interval = min(t) + [0 0.005];

      % Kolben accelerations

   hax6 = subplot(8,2,11);
   corazito.plot(hax6,t,bx,'rk');
   hold on;
   hdl6 = plot(hax6,interval(1),0,'bo');
   ylim6 = get(hax6,'ylim');
   ylabel('bx (g)');
   
   hax7 = subplot(8,2,13);
   corazito.plot(hax7,t,by,'gk');
   hold on;
   hdl7 = plot(hax7,interval(1),0,'bo');
   ylim7 = get(hax7,'ylim');
   ylabel('by (g)');

   hax8 = subplot(8,2,15);
   corazito.plot(hax8,t,bz,'bk');
   hold on;
   hdl8 = plot(hax8,interval(1),0,'bo');
   ylim8 = get(hax8,'ylim');
   ylabel('bz (g)');

      % Limits
   lim1 = [min(Ax),max(Ax)];
   lim2 = [min(Ay),max(Ay)];
   
   set(hax1,'ylim',lim1);
   set(hax2,'ylim',lim2);

   lim2(1) = min([ylim6(1),ylim7(1),ylim8(1)]);
   lim2(2) = max([ylim6(2),ylim7(2),ylim8(2)]);
   lim2 = lim2*0.75;
   
      % X/Y/Z 3D Kolben
      
   haxyz = subplot(1,2,2);
   idx = find(t >= interval(1) & t <= interval(2)); 
   hdlxyz1 = plot3(bx(idx),by(idx),bz(idx));
   hdlxyz2 = plot3(bx(idx),by(idx),0*bz(idx));
   hold on;
   title(sprintf('Kolben/Transversal (Lage %g)',lage))
   xlabel('bx (g)');
   ylabel('by (g)');
   zlabel('bz (g)');
   set(haxyz,'xlim',lim2,'ylim',lim2,'zlim',lim2);
   set(haxyz,'DataAspectRatio',[1,1,1]);

      % let's go ...
      
   set(gcf,'WindowButtonDownFcn','terminate(sho)');
   timer(o,0.01);
   
   [az,el] = view(haxyz);
   hdl = [];
   while (~stop(o) && interval(1) < max(t))
      set(hax1,'xlim',interval);
      set(hax2,'xlim',interval);
      
      delta = opt(o,'animation.delta');
      if ~isempty(idx)
         if (max(abs(Ax(idx))) < lim1(2)/10 && max(abs(Ay(idx))) < lim1(2)/10)
             delta = delta * 10;
         end
      end
      interval = interval + delta;
      idx = find(t >= interval(1) & t <= interval(2)); 

         % update X/Y/Z 3D
         
      delete(hdlxyz2);
      hdlxyz2 = plot3(haxyz,bx(idx),by(idx),0*bz(idx)+lim2(1),'y');
      
      delete(hdl);
      for (i=1:11:length(idx))
         hdl(i) = plot3(bx(idx(i))*[1 1],by(idx(i))*[1 1],[lim2(1) bz(idx(i))],'y');
      end
      delete(hdlxyz1);
      hdlxyz1 = plot3(haxyz,bx(idx),by(idx),bz(idx),'b');
      set(hdlxyz1,'linewidth',3),

      view(haxyz,interval(1)*100,el);
      
         % show current time with a circle in axes 3/4/5 & 6/7/8
               
      delete(hdl6);
      hdl6 = plot(hax6,interval(1),0,'ro');
      delete(hdl7);
      hdl7 = plot(hax7,interval(1),0,'ro');
      delete(hdl8);
      hdl8 = plot(hax8,interval(1),0,'ro');

      drawnow;
      %pause(0.00001);
   end
   set(gcf,'WindowButtonDownFcn','');
end

%==========================================================================
% Cluster Algorithm
%==========================================================================

function oo = Level(o)                 % Level Cluster Analysis        
   oo = opt(o,'show',1);               % show graphics
   oo = cluster(oo,'Level');           % plot cluster algorithm mechanics
end
function oo = Sigma(o)                 % Sigma Cluster Analysis        
   oo = opt(o,'show',1);               % show graphics
   oo = cluster(oo,'Sigma');           % plot cluster algorithm mechanics
end

%==========================================================================
% Cpk Algorithm
%==========================================================================

function oo = Cpk(o)                   % Cpk Algorithm                 
   oo = Current(o);
   cpk(oo,'a');                        % show Cpk algorithm mechanics
end
function oo = Thdr(o)                  % THDR Algorithm                 
   oo = Current(o);
   thdr(oo);                           % THDR Cpk algorithm mechanics
end
%==========================================================================
% Sound / Test
%==========================================================================

function o = Sound(o)                                                  
   amp=10;
   fs=10000;  % sampling frequency
   duration=10;
   freq=400;
   
   oo = current(o);
   if type(oo,{'cut'})
      t = data(oo,'t');
      ax = data(oo,'ax')/10;
      ay = data(oo,'ay')/10;
      sound(ax+ay);
   end
end
function oo = Bias(o)                  % plot velocity and elongation  
   refresh(o,o);
   mode = arg(o,1);
   
   oo = Current(o);
   oo = opt(oo,'coordinate',mode);
   t = cook(oo,'t','stream');
   
   switch mode
      case 'RawX'
         ax = cook(oo,'ax','stream');
         velocity(oo,ax,t);
      case 'RawY'
         ay = cook(oo,'ay','stream');
         velocity(oo,ay,t);
   end
end
