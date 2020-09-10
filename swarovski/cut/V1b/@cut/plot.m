function oo = plot(o,varargin)
%
% PLOT  Plot data of a CUT object
%
%          plot(o,'Stream')    % stream plot
%          plot(o,'FftLin')       % fast fourier transform
%
%
%       Special plot modes
%
%          plot(o,"Vx")
%          plot(o,"UxUyVxVy")
%
%       See also: CUT, SODE, HEUN
%
   [gamma,oo] = manage(o,varargin,@Stream,@FftLin,@FftLog,@Vx,@UxUyVxVy);
   oo = gamma(oo);
end

%==========================================================================
% stream plot
%==========================================================================

function o = Plot(o)                   % Core Plotting                 
%
% PLOT   Core plot routine, plotting xy-data, controlled by menu setting
%        object's config options
%
%    Option Settings:
%       bullets:  flag 0/1 indicating to draw also black bullets
%       limits:   y-limits
%       xscale:   x scale factor
%       yscale:   y scale factor for drift deviation
%       ascale:   y scale factor for absolute plots
%       biasmode: bias mode (defines bias yes/no)
%      
%    Config Settings
%       sub:      subplot number
%       color:    color setting
%
%  o = modes(o);                       % provide plotting modes

   hold off;                           % to clear screen
   color = @o.color;                   % shorthand
   
   bullets = opt(o,{'bullets',0});     % option bullets
   lwid = opt(o,{'linewidth',1});      % option line width
   
   xscale = opt(o,{'scale.xscale',1}); % x-scaling factor
   yscale = opt(o,{'yscale',1});       % y-scaling: drift,deviation
   ascale = opt(o,{'ascale',1});       % y-scaling: absolute

   [overlays,bias] = opt(o,'overlays','bias');
%
% plot mode always comes with the arg list
%
   plotmode = PlotMode(o);             % plot mode
%
% overlay mode
%
   overlay = opt(o,{'mode.overlay',0});
%
% determine the proper y scaling factor
%
   if isequal(bias,'abs1000')          % conversion to mm?
      yscale = ascale;
   end
%   
% Let's go: unpack plot option and fetch the x vector
%
   o = cook(o);                        % pre-process
   x = cook(o,':',plotmode);           % get x-vector
   x = xscale * x;                     % and get x scaled
%
% clear screen if current plots are not held
%
   held = ishold;                      % current graphics held?
   if ~ishold
      cls(o);                          % clear screen
   end
%   
% plot all y vectors into proper subplots
%
   caraplot = @corazito.plot;          % short hand
   
   hdl = var(o,'hdl');                 % add to collected plot handles
   nmax = subplot(o,inf);
   if (nmax == 0)
      message(o,'No plots are configured!','Select signals (View>Signal)!');
      return
   end
   
      % depending on overlay mode we select 1st or k-th subplot
     
   for (k = 1:nmax)                    % do with all subplots
      if (~overlay)
         subplot(o,k);                 % only in non-overlay mode
      end
      
      tokens = config(o,{k});          % get tokens for k-th subplot
      categories = [];
      
      for (i=1:length(tokens))
         [sym,sub,col,cat] = config(o,tokens{i});
         [y,yf] = cook(o,sym,plotmode);% data to be plotted

         if isempty(y)
            y = 0*x;  yf = 0*x;
         else
            y = yscale*y;  yf = yscale*yf;
         end

         if isempty(x)
            x = 1:length(y);           % if empty x
         end

         %special = {'ensemble','condensate','deviation'};
         %if isequal(plotmode,special) && size(y,1) > 1
         %   col = '';                  % no special color
         %end

         [col,width,ltyp] = color(col);
         lwid = lwid + (width-1);
         
         if isempty(yf)
            if o.is(plotmode,'fftlog')
               idx = find(x>=100);
               h = loglog(x(idx)',y(idx)');
               corazito.color(h,col);
            else
               h = caraplot(x',y',{col,lwid,ltyp});
            end
         else
            h = caraplot(x',y',{col,lwid,ltyp}); 
            hold on;
            hdl = [hdl;h(:)];          % collect handles
            h = caraplot(x',yf',{col,lwid,ltyp});
         end
         hold on;
         hdl = [hdl;h(:)];             % collect handles

         if (bullets)
            if (bullets > 0) 
               bcol = col;
            else
               bcol = 'k';
            end
%           h = caraplot(x',y',{col,lwid,ltyp});
            h = caraplot(x',y',{bcol,lwid,['.']});
            hdl = [hdl;h(:)];          % collect handles
         end
         if (bullets && ~isempty(yf))
            if (bullets < 0) bcol = col; else bcol = 'k'; end
            h = caraplot(x',yf',{bcol,lwid,[ltyp,'.']});
            hdl = [hdl;h(:)];          % collect handles
         end
         
            % store category
            
         idx = find(cat == categories);
         if isempty(idx)
            categories(end+1) = cat;
         end
      end
      
      xlim = [min(x(:)),max(x(:))];
      if (diff(xlim) == 0) 
         xlim = [xlim(1)-1,xlim(2)+1];
      end
      if ~isempty(xlim)
         set(gca,'xlim',xlim,'box','on');
      end
      
         % set spec limits
         
      if (length(categories) == 1)
         [spec,limit,unit] = category(o,cat);
         xlim = get(gca,'xlim');
         plot(xlim,spec(1)*[1 1],'k--');
         plot(xlim,spec(2)*[1 1],'k--');
         plot(xlim,4*spec(1)*[1 1],'k-.');
         plot(xlim,4*spec(2)*[1 1],'k-.');
         if (~isempty(limit) && prod(limit) ~= 0)
            set(gca,'ylim',limit);
         end
      end
      
         % handle grid setting

      if opt(o,{'view.grid',false})
         grid on;
      else
         grid off;
      end
   end
%
% Restore graphics hold state
%
   if (held)
      hold on
   else
      hold off
   end
   
   o.work.var.hdl = hdl;               % refresh plot handles
end
function o = PlotBasket(o,mode)        % Plot All Objects in Basket    
   refresh(o,{@plot,mode});
   
   list = basket(o);
   cls(o);
   
   for (i=1:length(list))
      oo = list{i};
      switch type(oo)
          case 'pkg'
             menu(oo,'About');  
          case {'cul','cutlog2'}
             oo = arg(oo,{mode});
             Plot(oo);
          otherwise
              error(['bad object type: ',type(oo)]);
      end
   end
end
function mode = PlotMode(o)            % Extract Plot Mode             
   mode = lower(arg(o,1));
end

%==========================================================================
% stream plot
%==========================================================================

function oo = Stream(o)                % Plot Stream                   
   oo = PlotBasket(o,'Stream');
end
function oo = FftLin(o)                % Plot Fft Linear       
   refresh(o,o);                       % redirect to here for refresh
   
   %oo = PlotBasket(o,'FftLin');
   oo = current(o);
   f = cook(oo,':','fftlin');
   Y = cook(oo,'ay','fftlin');

   t = cook(oo,':');
   ax = cook(oo,'ax');
   ay = cook(oo,'ay');
   az = cook(oo,'az');
   
   [kr,cr] = thdr(oo,t,ay);
   
      % plot
      
   cls(o);
   
      % total FFT
   
   subplot(211);
   plot(corazon(o),f,Y,'ggk');
   set(gca,'xlim',[900,1100]);
   title(title(oo));
   xlabel('f [Hz] (total frequency range)');
   ylabel('|Ay(jw)|');
   
      % closeup FFT
      
   subplot(212);
   plot(corazon(o),f,Y,'ggk');
   set(gca,'xlim',[min(f),max(f)]);
   title(sprintf('FFT (harmonic distortion: %g, credibility: %g %%)',...
                  o.rd(kr,2),cr));
   xlabel('f [Hz] (close up)');
   ylabel('|Ay(jw)|');

      % set figure title
      
   title(oo);                          % set figure title
end
function oo = FftLog(o)                % Plot Fft Logarithmic          
   oo = PlotBasket(o,'FftLog');
end

%==========================================================================
% Plotting
%==========================================================================

function hdl = Title(str)              %                               
   hdl = title(str);
   set(hdl,'fontsize',12),
end
function hdl = Xlabel(str)             %                               
   hdl = xlabel(str);
   set(hdl,'fontsize',12),
end
function hdl = Ylabel(str)             %                               
   hdl = ylabel(str);
   set(hdl,'fontsize',12),
end
function PlotPlot(t,x,colors,labels)   %                               
   if (nargin < 3)
      colors = {'r','b','g','c','m','y','k'}
   end
   
   if (nargin >= 4)
      clf
   end
   
   [m,n] = size(x);
   for (i=1:m)
      col = colors{1+rem(i-1,length(colors))};
      hdl = plot(t,x(i,:),col);
      hold on;
      set(hdl,'linewidth',1);
   end
   set(gca,'fontsize',12)
   
   if (nargin >= 4)
      hdl = legend(labels,'location','northeast');
      set(hdl,'fontsize',12);
   end
end
   
%==========================================================================
% micron display
%==========================================================================

function [x,unit] = Micron(x)          % discriminate  um display      
   micron = all(all(abs(x([1,2],:))<=0.001));
   if (micron)
      fac = 1e6;  unit = '[um]';
   else 
      fac = 1e3;  unit = '[mm]';
   end 
   x(1,:) = fac*x(1,:);
   x(2,:) = fac*x(2,:);
end

%==========================================================================
% plot ux, uy, vx, vy 
%==========================================================================

function UxUyVxVy(o)                                                   
   p = get(o,"parameter");
   t  = data(o,"t"); 
   x = data(o,"x");

   [x,unit] = Micron(x);  % discriminate whether micron display

   subplot(221);
   Plot(t,x(1,:),{'r'});
   hdl = Ylabel(['Magnitude ux ',unit]);
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   set(gca,"xlim",[min(t),max(t)]);
   
   subplot(222);
   Plot(t,x(2,:),{'m'});
   hdl = Ylabel(['Magnitude uy',unit]);
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   hdl = Title(sprintf('Fn = %g',p.Fn));
   set(hdl,'fontsize',12),
   set(gca,"xlim",[min(t),max(t)]);

   subplot(223);
   Plot(t,x(3,:),{'b'});
   hdl = Ylabel('Velocity vx [m/s]');
   hold on;
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   hdl=Title(sprintf('v = %g m/s',p.v));
   set(hdl,'fontsize',12),
   plot(t,0*t+p.v,'r')
   set(gca,"xlim",[min(t),max(t)]);

   subplot(224);
   Plot(t,x(4,:),{'g'});
   hdl = Ylabel('Velocity vy [m/s]');
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   hdl = Title(sprintf('mu = %g',p.mu));
   set(hdl,'fontsize',12),   
   set(gca,"xlim",[min(t),max(t)]);
end

%==========================================================================
% plot vx 
%==========================================================================

function Vx(o)
   p = get(o,"parameter");
   t  = data(o,"t");         % time vector
   s  = data(o,"s");         % system indicator 
   x = data(o,"x");          % state vector
   
   [x,unit] = Micron(x);  % discriminate whether micron display

   Plot(t,x(3,:),{'b'});
   hdl = Ylabel('Velocity vx [m/s]');
   hold on;
   set(gca,'fontsize',18)
   set(hdl,'fontsize',12),
   hdl=Title(sprintf('v = %g m/s',p.v));
   set(hdl,'fontsize',12),
   plot(t,0*t+p.v,"r")
   if (isequal(type(o),"sode"))
      plot(t,o.dat.s,"k");
   end
   plot(0*t,0*t+p.v,"r");
   set(gca,"xlim",[min(t),max(t)]);
end

