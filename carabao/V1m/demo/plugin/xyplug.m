function oo = xyplug(o,varargin)       % XY-Plugin Manager             
%
% XYPLUG   Simple plugin demo function to allow xY-plots
%
%             xyplug                   % register plugin
%
%             oo = xyplug(o)           % call local function of xyplug
%
%         See also: CARABAO
%
   if (nargin == 0)
      o = pull(carabao);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Register,@Plot,@Style,@XyPlot,@Info);
   oo = gamma(o);
end

%==========================================================================
% Plugin Registration
%==========================================================================

function o = Register(o)               % Plugin Registration           
   plugin(o,'carma/shell/Plot',{@xyplug,'Plot'});
   plugin(o,'play/shell/Plot',{@xyplug,'Plot'});
   plugin(o,'carma/shell/Style',{@xyplug,'Style'});     
   rebuild(o);                         % rebuild menu
end

%==========================================================================
% Plot Menu Plugin
%==========================================================================

function o = Plot(o)                   % Plot Menu Plugin              
   setting(o,{'xyplot.color'},'r');    % provide xyplot color default

   oo = mitem(o,'-');
   oo = mhead(o,'XY Plot',{@XyPlot});
end
function o = XyPlot(o)                 % XY Plotting                   
   refresh(o,inf);
   cls(o);
   o = opt(o,'basket.type',{'simple','plain'});
   list = basket(o);
   if isempty(list)
      message(o,'Empty basket!','(consider to create/import objects)');
      return
   end
   
   col = opt(o,'xyplot.color');
   
   for (i=1:length(list))
      oo = list{i};
      
      [x,~,sym.x] = cook(oo,'!x');
      [y,~,sym.y] = cook(oo,'!y');
      plot(x,y,col);
      hold on;
      
      title('XY-Plot');
      xlabel(sym.x);
      ylabel(sym.y);
   end
end

%==========================================================================
% Style Menu Plugin
%==========================================================================

function o = Style(o)                  % Style Menu Plugin             
   setting(o,{'xyplot.color'},'r');    % provide xyplot color default
   
   oo = mitem(o,'XY-Plot Color',{},'xyplot.color');
   choice(oo,{{'Red','r'},{'Green','g'},{'Blue','b'}},{});
end
