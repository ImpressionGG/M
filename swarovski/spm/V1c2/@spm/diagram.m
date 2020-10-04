function o = diagram(o,varargin)                                       
%
% DIAGRAM   Plot diagram
%
%              diagram(o,'Force','F1',t,F1,sub)       % force 1
%              diagram(o,'Elongation','x2',t,x2,sub)  % elongation 2
%              diagram(o,'Acceleration','a1',t,a1,sub)% acceleration 1
%              diagram(o,'Mode','x4',t,x4,sub)        % mode plot (mode 4)
%              diagram(o,'Orbit','y2(y1)',y1,y2,sub)  % orbit plot
%
%              diagram(o,'Trf','G11',G11,sub)         % transfer function
%              diagram(o,'Weight','G12',w12,sub)      % weight vector
%              diagram(o,'Step','G11',G11,sub)        % elon. step response
%              diagram(o,'Vstep','L11',L11,sub)       % velocity step rsp.
%              diagram(o,'Astep','Ta1',Ta1,sub)       % accel. step rsp.
%              diagram(o,'FStep','L51',L51,sub)       % force step response
%              diagram(o,'Rloc','G11',G11,sub)        % root locus
%              diagram(o,'Bode','G11',G11,sub)        % bode diagram
%              diagram(o,'Calc','L1',L1,sub)          % calculation diagram
%
%           Copyright(c): Bluenetics 2020
%
%           See also: SPM, PLOT
%
   [gamma,oo] = manage(o,varargin,@Force,@Elongation,@Acceleration,...
                       @Mode,@Orbit,@Trf,@Weight,...
                       @Step,@Vstep,@Astep,@Fstep,@Bode,@Rloc,@Calc);
   oo = gamma(oo);
end

%==========================================================================
% Force
%==========================================================================

function o = Force(o)                  % Force Diagram                 
   o = with(o,'scale');                % unwrap scale options
   o = opt(o,'yscale',1,'yunit','N');
 
   sym = arg(o,1);
   t = arg(o,2);
   F = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,t,F,'yyr');
   
   Epilog(o,['Force ',sym],sym);
end

%==========================================================================
% Elongation, Velocity, Acceleration
%==========================================================================

function o = Elongation(o)             % Elongation Diagram            
   o = with(o,'scale');                % unwrap scale options
   
   sym = arg(o,1);
   t = arg(o,2);
   y = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,t,y,'g');
   
   Epilog(o,['Elongation ',sym],sym);
end
function o = Acceleration(o)           % Acceleration Diagram          
   o = with(o,'scale');                % unwrap scale options
   o = opt(o,'yscale',opt(o,'ascale'));
   o = opt(o,'yunit',opt(o,'aunit'));
   
   sym = arg(o,1);
   t = arg(o,2);
   y = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   col = opt(o,{'color','r'});
   plot(o,t,y,col);
   
   Epilog(o,['Acceleration ',sym],sym);
end

%==========================================================================
% Mode
%==========================================================================

function o = Mode(o)                   % Mode Diagram                  
   o = with(o,'scale');                % unwrap scale options
 
   colors = {'r','y','bc','m','gc','rw','yw','bcw','mw','gcw',...
             'rk','yk','bck','mk','gck'};
   
       % consult 'some magic' to generate unique color index
       
   sym = arg(o,1);
   idx = 1 + rem(sum(sym)-sum('x1')+10*length(colors),length(colors));
   col = colors{idx};
   
   t = arg(o,2);
   x = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   if (size(x,1) == 1)
      plot(o,t,x,col);
   else
      plot(t,x);
   end
   
   Epilog(o,['Mode ',sym],sym);
end

%==========================================================================
% Orbit Diagram
%==========================================================================

function o = Orbit(o)                  % Orbit Diagram                 
   o = with(o,'scale');                % unwrap scale options
   o = opt(o,'xscale',opt(o,'yscale'));% copy y-scaling factor
   o = opt(o,'xunit',opt(o,'yunit'));  % copy y-unit
   
   sym = arg(o,1);
   ya = arg(o,2);
   yb = arg(o,3);
   sub = o.either(arg(o,4),[1 1 1]);
   
   subplot(o,sub);
   plot(o,ya,yb,'g');
   
   try
      sym1 = sym(4:5);
      sym2 = sym(1:2);
   catch
      sym1 = 'ya';  sym2 = 'yb';
   end
  
   Epilog(o,['Orbit ',sym2,' (',sym1,')'],sym1,sym2);
end

%==========================================================================
% Transfer & Weight Function Diagram
%==========================================================================

function o = Trf(o)                    % Transfer Function Diagram     
   sym = arg(o,1);
   tit = [sym,': Transfer Function'];  % default title
   G = arg(o,2);
   sub = o.either(arg(o,3),111);       % subplot ID
   tit = o.either(arg(o,4),tit);       % title
   
   
   if isequal(sub,111)
      o = opt(o,'subplot',sub,'pitch',0.4);
      G = opt(G,'maxlen',200);
   elseif isequal(sub,311) || isequal(sub,3111) 
      o = opt(o,'subplot',sub,'pitch',2);
      G = opt(G,'maxlen',200);
   else
      o = opt(o,'subplot',sub,'pitch',2);
   end
   
   comment = [{' '},display(G)];
   message(o,tit,comment);
   axis off;
end
function o = Weight(o)                 % Weight Function Diagram       
   weightdb = opt(o,{'weight.db',1});  % show weight in dB
   
   sym = arg(o,1);
   w = arg(o,2);
   dB = 20*log10(abs(w));              % weight in decibels
   
   sub = o.either(arg(o,3),[1 1 1]);
   
   o = opt(o,'subplot',sub);
   
   small = opt(o,{'weight.small',1e-3});
   small = small*max(abs(w));
   idx = find(abs(w)<small);
   
   n = 1:length(w);
   if ~isempty(idx)
      ww = w(idx);  nn = n(idx);  db = dB(idx);
      if weightdb
         plot(o,nn,db,'|K', nn,db,'Ko');
      else
         plot(o,nn,ww,'|K', nn,ww,'Ko');
      end
      hold on;
   end
   
   idx = find(abs(w)>=small);
   if ~isempty(idx)
      ww = w(idx);  nn = n(idx);  db = dB(idx);
      if weightdb
         plot(o,nn,db,'|r', nn,db,'ro');
      else
         plot(o,nn,ww,'|r', nn,ww,'ro');
      end
      hold on;
   end
   
   Xtick(o);                           % set pretty xticks
   
   title('Modal Weights');
   xlabel('Mode Number');
   if weightdb
      ylabel([sym,'  [dB]']);
   else
      ylabel(sym);
   end
   
   function Xtick(o)                   % Set Pretty Xticks             
      nw = length(w);
      if (nw < 20)
         set(gca,'Xtick',1:nw);
      elseif (nw < 40)
         set(gca,'Xtick',2:2:nw);
      else
         delta = round(nw/20);
         switch delta
            case {3,4}
               delta = 5;
            case {6,7,8,9}
               delta = 10;
            case {11,12,13,14}
               delta = 15;
            otherwise
               delta = ceil(delta/5)*5;
         end

         set(gca,'Xtick',delta:delta:nw);
      end
   end
end

%==========================================================================
% Elongation/Velocity Step Response Diagram
%==========================================================================

function o = Step(o)                   % Elongation Step Response      
   o = Scaling(o);                     % manage scaling factors
   
   sym = arg(o,1);
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);
   
   G = set(G,'name',sym); 
   G = inherit(G,o);
   G = arg(G,{});                      % clear args
   
   if isempty(opt(G,'color'))
      if isequal(sym(1),'H')
         G = opt(G,'color','m');
      elseif isequal(sym(1),'L')
         G = opt(G,'color','yyr');
      else
         G = opt(G,'color','g.');
      end
   end
   
   if length(num(G)) > length(den(G))
      G = system(G,{0,1});
   end
   
   subplot(o,sub);
   step(G);
   
   title(sprintf('%s - Step Response',sym));
   ylabel(['y  [',opt(o,{'yunit','1'}),']']);

   subplot(o);                         % subplot done!
end
function o = Vstep(o)                  % Velocity Step Response        
   o = Scaling(o);                     % manage scaling factors
   o = opt(o,'yscale',opt(o,'vscale'));
   o = opt(o,'yunit',opt(o,'vunit'));
   
   sym = arg(o,1);
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);
   
   G = set(G,'name',sym); 
   G = inherit(G,o);
   
   if isempty(opt(G,'color'))
      if o.is(sym(2:3),{'11','12','21','22'})
         G = opt(G,'color','bc');
      elseif isequal(sym(1),'L')
         G = opt(G,'color','yyr');
      else
         G = opt(G,'color','g.');
      end
   end
   subplot(o,sub);
   step(G);
   ylabel(['dy/dt [',opt(o,{'yunit','1'}),']']);

   subplot(o);                         % subplot done!
end
function o = Astep(o)                  % Acceleration Step Response    
   o = Scaling(o);                     % manage scaling factors
   o = opt(o,'yscale',opt(o,'ascale'));
   o = opt(o,'yunit',opt(o,'aunit'));
   
   sym = arg(o,1);
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);
   
   G = set(G,'name',sym); 
   G = inherit(G,o);
   
   if isempty(opt(G,'color'))
      G = opt(G,'color','r');
   end
   subplot(o,sub);
   step(G);
   ylabel(['dy2/dt2 [',opt(o,{'yunit','1'}),']']);

   subplot(o);                         % subplot done!
end
function o = Fstep(o)                  % Force Step Response           
   o = Scaling(o);                     % manage scaling factors
   o = opt(o,'yscale',opt(o,'fscale'));
   o = opt(o,'yunit',opt(o,'funit'));
   
   sym = arg(o,1);
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);
   
   G = set(G,'name',sym); 
   G = inherit(G,o);
   
   if isempty(opt(G,'color'))
      if o.is(sym(2:3),{'11','12','21','22'})
         G = opt(G,'color','bc');
      elseif isequal(sym(1),'L')
         G = opt(G,'color','yyr');
      else
         G = opt(G,'color','g.');
      end
   end
   subplot(o,sub);
   step(G);
   ylabel(['F [',opt(o,{'yunit','1'}),']']);

   subplot(o);                         % subplot done!
end

%==========================================================================
% Bode Diagram
%==========================================================================

function o = Bode(o)                   % Bode Diagram                  
   o = Scaling(o);                     % manage scaling factors
   
   sym = arg(o,1);
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);

   [num,den] = peek(G);
   oo = system(inherit(corasim,o),{num,den});   
   oo = set(oo,'name',sym); 
   
   if isempty(opt(oo,'color'))
      oo = opt(oo,'color','r');
   end
   
   subplot(o,sub);
   
   bode(oo);
   title([sym,': Bode Diagram']);

   subplot(o);                         % subplot done!
end

%==========================================================================
% Root Locus Diagram
%==========================================================================

function o = Rloc(o)                   % Root Locus Diagram            
   sym = arg(o,1);
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);
   
   o = opt(o,'subplot',sub);
   G = set(G,'name',sym); 

   subplot(o,sub);
   p = roots(den(G));                  % poles
   col = o.iif(dark(o),'yx','gx');
   plot(corazon(o),real(p),imag(p),col);
   hold on;

   z = roots(num(G));                  % zeros
   oo = corazon(o);
   col = o.iif(dark(o),'yo','go');
   plot(oo,real(z),imag(z),col);
   hold on;
   
   center = sum(real([p(:);z(:)]))/(length(p)+length(z));
   title(sprintf('%s: Poles/ Zeros - Re(z) <= %g,  Re(p) <= %g',...
          sym,o.rd(max(real(z)),1), o.rd(max(real(p)),1)) );
   
   t = 0:1/10:100;
   K = 10.^t - 1;
      
   for (i=1:length(p))
      plot(o,[center real(p(i))],[0 imag(p(i))],'r');
      hold on
   end
   for (i=1:length(z))
      plot(o,[center real(z(i))],[0 imag(z(i))],'cb');
      hold on
   end
   
   xlim = get(gca,'Xlim');
   xlim = [xlim(1) max(xlim(2),abs(xlim(1)))];
   set(gca,'Xlim',xlim);
   
   plot(o,[0 0],get(gca,'Ylim'),'K1-.');
   subplot(o);                         % subplot done!
end

%==========================================================================
% Calculation Diagram
%==========================================================================

function o = Calc(o)                   % Calculation Diagram           
   sym = arg(o,1);
   G = arg(o,2);
   sub = o.either(arg(o,3),[1 1 1]);

   switch sym
      case {'L(s)','L1(s)','L2(s)'}
         comment = ...
            {'L(s)  =  [ L1(s), L2(s) ]  =  HD(s)  =  [ H31(s), H32(s) ]',...
             ' ','L1(s)  =  H31(s)  =  -G31(s) / G33(s)',...
             'L2(s)  =  H32(s)  =  -G32(s) / G33(s)'};
      otherwise
         comment = {};
   end
   
   message(opt(o,'subplot',sub,'fontsize.comment',12,'pitch',2),...
       sprintf('Calculation of %s',sym),comment);
    
   axis off;
end

%==========================================================================
% Helper
%==========================================================================

function o = Epilog(o,tit,sym1,sym2)   % Epilog Tasks for Diagrams     
   title(tit);
   
   if (nargin == 3)
      xlabel(['time [',opt(o,{'xunit','?'}),']']);
      ylabel([sym1,' [',opt(o,{'yunit','?'}),']']);
   elseif (nargin == 4)
      xlabel([sym1,' [',opt(o,{'xunit','?'}),']']);
      ylabel([sym2,' [',opt(o,{'yunit','?'}),']']);
   end
   
   grid(o);
   heading(o);
end
function o = Scaling(o)                % Manage Scaling Factors        
%
% SCALING  Manage scaling factors with respect to time normalizing. Also
%          unwrap simu options, scale options and Bode options
%
   T0 = opt(o,{'brew.T0',1});
   
      % modify simu options
      
   o = with(o,'simu');
   [tmax,dt] = opt(o,'tmax,dt');
   tmax = tmax/T0;  dt = dt/T0;        % reduce simulation timing
   o = opt(o,'tmax,dt',tmax,dt);
   
         % modify scale options
      
   o = with(o,'scale');
   xscale = opt(o,{'xscale',1});
   xscale = xscale*T0;                 % blow-up displayed time
   o = opt(o,'xscale',xscale);
 
   o = with(o,'bode');
   fscale = opt(o,{'fscale',1});
   fscale = fscale*T0;
   o = opt(o,'fscale',fscale);
end
