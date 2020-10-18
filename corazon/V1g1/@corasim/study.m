function oo = study(o,varargin)     % Do Some Studies
%
% STUDY   Several studies
%
%       oo = study(o,'Menu')     % setup study menu
%
%       oo = study(o,'Study1')   % raw signal
%       oo = study(o,'Study2')   % raw & filtered signal
%       oo = study(o,'Study3')   % filtered
%       oo = study(o,'Study4')   % signal noise
%
%    See also: CORASIM, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,@WithSho,@WithBsk,...
                        @SystemInvert);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                                                     
   oo = mitem(o,'System Inversion',{@WithCuo,'SystemInvert'},[]);
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
% System Inversion
%==========================================================================

function o = SystemInvert(o)           % System Inversion Study        
   A = [0 1; -6 -5];
   B = [0;1];  C = [-1 -2];  D = 1;
   
   oo = system(o,A,B,C,D);
   G = set(trf(oo),'name','G(s)');     % convert to transfer function
   
   DispG(o,G,'',4111);
   Step(o,G,4221);
   Bode(o,G,4222);
   
      % inverted system
      
   oo = system(o,A-B*(D\C),B/D,-D\C,inv(D));
   H = set(trf(oo),'name','H(s) = inv(G(s))');
   
   DispG(o,H,'',4131);
   Step(o,H,4241);
   Bode(o,H,4242);

   function DispG(o,G,sym,sub)             % Display G(s)                  
      subplot(o,sub);
      sym = o.either(sym,get(G,'name'));
      o = opt(o,'subplot',sub,'pitch',2);
      txt = display(G);
      message(o,sym,txt);
      axis off;
      
      subplot(o);
   end
   function Step(o,G,sub)
      subplot(o,sub);
      G = with(G,{'simu','style'});
      step(G);
      subplot(o);
   end
   function Bode(o,G,sub)
      subplot(o,sub);
      G = with(G,{'bode','style'});
      bode(G);
      subplot(o);
   end
end
