function oo = analyse(o,varargin)     % Graphical Analysis
%
% ANALYSE   Graphical analysis
%
%    Plenty of graphical analysis functions
%
%       analyse(o)                     % analyse @ opt(o,'mode.analyse')
%
%       oo = analyse(o,'menu')         % setup Analyse menu
%       oo = analyse(o,'Collision')    % collision analysis
%
%    See also: MESH, PLOT, STUDY
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,@WithSho,...
                  @WithBsk,@Collision,@Probability,@Optimal,@Boost);
   oo = gamma(o);                 % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)
   oo = mitem(o,'Optimal Repeat Number',{@WithCuo,'Optimal'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Collision Study',{@WithCuo,'Collision'},[]);
   oo = mitem(o,'Collision Probability',{@WithCuo,'Probability'},[]);
   oo = mitem(o,'Boost Rate',{@WithCuo,'Boost'});
   oo = mitem(o,'-');
   oo = bench(o,'Menu');
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
function oo = WithBsk(o)               % 'With Basket' Callback        
%
% WITHBSK  Plot basket, or perform actions on the basket, screen clearing, 
%          current object pulling and forwarding to executing local func-
%          tion, reporting of irregularities and dark mode support
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

%==========================================================================
% Actual Analysis
%==========================================================================

function o = Collision(o)              % Collision Analysis            
   N = opt(o,{'traffic.N',1000});      % number of concurrent transmissions
   n = opt(o,{'traffic.repeats',6});   % number of repeats
   Tobs = opt(o,{'traffic.Tobs',1000});
   Tpack = opt(o,{'traffic.Tpack',250})/1000;
   
      % let's go ...
      
   t = Setup(o,N,Tobs,Tpack);
   dt = diff(t);
   
   gdx = find(dt>Tpack);
   plot(rem(gdx,1000),dt(gdx),'pg');
   hold on;
   
   rdx = find(dt<=Tpack);
   plot(rem(rdx,1000),dt(rdx),'pr');
   
   
   c = length(rdx)/length(dt);
   title(sprintf('Collision Propability: %g %%',c*100));
   
   
   function t = Setup(o,N,Tobs,Tpack)
      t = rand(1,N) * (Tobs-Tpack);
      t = sort(t);
   end
end
function o = Probability(o)            % Collision Probability         
   L = opt(o,{'traffic.Tpack',250})*1e-6;
   
   T = 2000*250e-6/L;
   R = 0:250:2*T;
   collsim(o,R,L);
end
function o = Optimal(o)                % Optimal Repeat Analysis       
   Rmax = 2500;
   optimal(sho,100:50:Rmax);
end
function o = Boost(o)                  % Boost Rate                    
   o = subplot(o,2111);
   boost(o);
   
   o = subplot(o,2121);
   boost(o,1,0.256/1000,30000);
   set(gca,'ylim',[0 1]);
end