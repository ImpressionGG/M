function oo = analysis(o,varargin)     % Graphical Analysis
%
% ANALYSIS   Graphical analysis
%
%    Plenty of graphical analysis functions
%
%       analysis(o)               % analysis @ opt(o,'mode.analysis')
%
%       oo = analysis(o,'menu')   % setiup analysis menu
%       oo = analysis(o,'Surf')   % surface plot
%       oo = analysis(o,'Histo')  % display hostogram
%
%    See also: SPM, PLOT, STUDY
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@Callback,@Surf,@Histo);
   oo = gamma(o);                 % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)
   oo = mitem(o,'Surface',{@Callback,'Surf'},[]);
   oo = mitem(o,'Histogram',{@Callback,'Histo'},[]);
end
function oo = Callback(o)
   refresh(o,o);                       % remember to refresh here
   oo = current(o);                    % get current object
   cls(o);

   if container(oo)
      message(oo);
   else
      analysis(oo,arg(o,1));
   end
end

%==========================================================================
% Actual Analysis
%==========================================================================

function o = Surf(o)                  % Surf Plot
   x = cook(o,'x');
   y = cook(o,'y');

   idx = 1:ceil(length(x)/50):length(x);
   idy = 1:ceil(length(y)/50):length(y);
   z = x(idx)'.*y(idy);
   surf(x(idx),y(idy),z);
end
function o = Histo(o)                 % Histogram
   t = cook(o,':');
   x = cook(o,'x');
   y = cook(o,'y');

   subplot(211);
   plot(with(corazon(o),'style'),t,sort(x),'r');
   subplot(212);
   plot(with(corazon(o),'style'),t,sort(y),'b');
end
