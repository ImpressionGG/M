function oo = analyse(o,varargin) % Object Analysis
%
% ANALYSE   Object analysis
%
%    Plenty of graphical analysis functions
%
%       analyse(o,'Menu')              % setup Analyse menu
%
%       oo = analyse(o,'Frequency')    % weird frequency analysis
%       oo = analyse(o,'Radius')       % ball radius analysis
%       oo = analyse(o,'Edge')         % cube edge analysis
%
%    See also: CORAZON, PLOT
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@Frequency,@Radius,@Edge);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Analyse Menu            
   oo = mitem(o,'Weird Frequency',{@Frequency});
        oo = opt(oo,'basket.type','weird','basket.collect','*');
        enable(oo,~isempty(basket(oo)));
   oo = mitem(o,'Ball Radius',{@Radius});
        oo = opt(oo,'basket.type','ball','basket.collect','*');
        enable(oo,~isempty(basket(oo)));
   oo = mitem(o,'Cube Edge Length',{@Edge});   
        oo = opt(oo,'basket.type','cube','basket.collect','*');
        enable(oo,~isempty(basket(oo)));

   oo = mitem(o,'-');
   plugin(o,'corazon/shell/Analyse'); % plug point
end

%==========================================================================
% Actual Analysis
%==========================================================================

function o = Frequency(o)              % Weird Frequency Analysis      
   refresh(o,o);                       % use this callback for refresh
   o = opt(o,'basket.type','weird');
   o = opt(o,'basket.collect','*');    % all traces in basket
   list = basket(o);
   
   if (isempty(list))
      message(o,'No weird objects in basket!');
   else
      hax = cls(o);
      G = [];
      for (i=1:length(list))
         oo = list{i};
         m = 25; n = length(oo.data.x);
         F = fft(oo.data.x + oo.data.y + oo.data.z + oo.data.w)/n;
         f = abs(F(1:length(1:m+1)));
         hdl = plot(hax,0:m,f);  hold on;
         set(hdl,'color',oo.par.color);  
         G = [G;f(:)'];
      end
      if (size(G,1) > 1)
         G = mean(G);
      end
      if opt(o,{'style.bullets',0})
         hdl = plot(hax,0:m,G,'g-', 0:m,G,'k.');
      else
         hdl = plot(hax,0:m,G,'g-');
      end
      lw = opt(o,{'style.linewidth',3});
      set(hdl,'linewidth',lw);
      title('Average Spectrum');
   end
end
function o = Radius(o)                 % Ball Radius Analysis          
   refresh(o,o);                       % use this callback for refresh
   hax = cls(o);
   
      % select basket list
      
   o = opt(o,'basket.collect','*');    % collect from all objects in basket
   o = opt(o,'basket.type','ball');    % filtered by 'ball' types  
   list = basket(o);
   
   if (isempty(list))
      message(o,'No ball objects in basket!');
   else
      for (i=1:length(list))
         oo = list{i};
         r(i) = oo.data.radius;
      end
      plot(o,1:length(r),r,'b', 1:length(r),r,'ko');
      
         % make pretty
         
      m = mean(r);  s = std(r);
      title(sprintf('Ball Radius (average %g,sigma %g)',m,s));
      set(hax,'xtick',1:length(r));
   end
end
function o = Edge(o)                   % Cube Edge Analysis            
   refresh(o,o);                       % use this callback for refresh
   o = opt(o,'basket.type','cube');
   o = opt(o,'basket.collect','*');    % all traces in basket
   list = basket(o);
   if (isempty(list))
      message(o,'No cube objects in basket!');
   else
      hax = cls(o);
      for (i=1:length(list))
         oo = list{i};
         a(i) = 2*oo.data.radius;
      end
      plot(hax,1:length(a),a,'b', 1:length(a),a,'k.');
      m = mean(a);  s = std(a);
      title(sprintf('Cube edge length (average %g,sigma %g)',m,s));
      set(hax,'xtick',1:length(a));
   end
end
