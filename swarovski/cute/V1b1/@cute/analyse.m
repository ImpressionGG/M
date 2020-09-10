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
                   @Level,@Sigma,@Cpk,@Thdr,@Elongation);
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
   
   itab = cache(oo,'cluster.itab');
   N = size(itab,1);
      
      % Cluster Algorithm
      
   oo = mitem(o,'Cluster');
   ooo = mitem(oo,'Level Clustering',{@WithCuo,'Level'});
   ooo = mitem(oo,'Sigma Clustering',{@WithCuo,'Sigma'});

      % Cpk & Harmonic Metrics
     
   oo = mitem(o,'Cpk');
   ooo = mitem(oo,'Cpk Algorithm',{@WithCuo,'Cpk'});
   oo = mitem(o,'Harmonic');
   ooo = mitem(oo,'THDR Algorithm',{@WithCuo,'Thdr'});
   
   oo = mitem(o,'-');
   oo = mitem(o,'Elongation');
   ooo = mitem(oo,'Elongation X',{@WithCuo,'Elongation','ax#'});
   ooo = mitem(oo,'Elongation Y',{@WithCuo,'Elongation','ay#'});
   ooo = mitem(oo,'Elongation Z',{@WithCuo,'Elongation','az#'});
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
function oo = WithBsk(o)               % Acting on the Basket          
%
% WITHBSK  Plot basket, or perform actions on the basket, screen clearing, 
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
% Cpk/Chk Algorithm
%==========================================================================

function oo = Cpk(o)                   % Cpk Algorithm                 
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   oo = Current(o);
   cpk(oo,'a');                        % show Cpk algorithm mechanics
end
function oo = Thdr(o)                  % THDR Algorithm                
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   oo = Current(o);
   thdr(oo);                           % THDR Cpk algorithm mechanics
end

%==========================================================================
% Velocity
%==========================================================================

function o = Elongation(o)             % Show Elongation Algorithm     
   if ~type(o,{'cut'})
      oo = plot(o,'About');
      return
   end
   
   sym = arg(o,1);
   t = cook(o,'t');
   a = cook(o,sym);
   
   velocity(o,a,t,sym);                % show velocity algorithm mechanics
end