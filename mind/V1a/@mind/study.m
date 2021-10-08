function oo = study(o,varargin)     % Do Some Studies
%
% STUDY   Several studies
%
%       oo = study(o,'Menu')     % setup study menu
%
%       oo = study(o,'Bubbles')  % draw some bubbles
%
%    See also: MIND, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,@WithSho,...
                        @Bubbles,@Move);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)
  oo = mitem(o,'Bubbles',{@WithSho,'Bubbles'},[]);
  oo = mitem(o,'-');
  oo = mitem(o,'Left',{@WithCuo,'Move'},'left');
  oo = mitem(o,'Right',{@WithCuo,'Move'},'right');
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
%  cls(o);                             % clear screen
 
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

%==========================================================================
% Studies
%==========================================================================

function o = Bubbles(o)                % Study 1: Raw Signal
   n = 100;
   phi = 0:pi/100:2*pi;
   
   for (i=1:n)
      x0 = randn;  y0 = randn;  r = (2 + rand)/5;
      x = x0 + r*cos(phi);
      y = y0 + r*sin(phi);
      c = 0.2 + 0.8*rand(1,3);
      hdl(i) = patch(x,y,c);
   end
   
   set(gca,'DataAspectRatio',[1 1 1]);
   set(gca,'xlim',[-5,5],'ylim',[-5,5]);
   
   o = pull(o);
   o = set(o,'hdl,x0,y0',hdl,0,0);
   push(o);
end
function o = Move(o)                   % Move Bubbles
   mode = arg(o,1);
   o = pull(o);
   [hdl,x0_,y0_] = get(o,'hdl,x0,y0');
   
   switch mode
      case 'left'
         x0 = -1+0.5*randn;  y0 = 0.5*randn;
      case 'right'
         x0 = +1+0.5*randn;  y0 = 0.5*randn;
   end
      
   for (i=1:length(hdl))
      x = get(hdl(i),'xdata') - x0_;
      y = get(hdl(i),'ydata') - y0_;
     
      x = x+x0;  y = y+y0;
      set(hdl(i),'xdata',x, 'ydata',y);
   end
   
   o = set(o,'x0,y0',x0,y0);
   push(o);
end
