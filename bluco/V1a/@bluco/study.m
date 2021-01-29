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
%    See also: BLUCO, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,@WithSho,@WithBsk,...
                        @Hilbert,@GridPhase);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)
   oo = mitem(o,'Hilbert Transform',{@WithCuo,'Hilbert'},[]);
   oo = mitem(o,'Grid Phase Estimator',{@WithCuo,'GridPhase'},[]);
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
% Studies
%==========================================================================

function o = Hilbert(o)                % Hilbert Transform             
   n = 21;
   y = rand(n,1);
   
      % take FFT
      
   f = fft(y);
   fi = 1i*f;                          % complex multiplication by i
   
      % indices of positive and negative frequencies
      
   pos = 2:floor(n/2) + mod(n,2);
   neg = ceil(n/2) + 1 + ~mod(n,2):n;
   
   f(pos) = f(pos) - 1i*fi(pos);
   f(neg) = f(neg) + 1i*fi(neg);
   
      % take inverse FFT
      
   h = ifft(f);
   
      % plot
      
   subplot(o,211);
   plot(o,1:n,y,'r');
   title('Original signal');
   
   subplot(o,212);
   plot(o,1:n,abs(h),'g');
   hold on
   plot(o,1:n,abs(hilbert(o,y)),'go');
   title('Magnitude of Hilbert transform');
end
function o = GridPhase(o)              % Grid Phase Estimation         
   t = 0:0.001:0.1;
   om = 2*pi*50;
   u = sqrt(2)*230*sin(om*t);
   
      % estimator
      % y = (y_ + u + u_)/3
      
   u_ = 0;  y_ = 0;
   for (k=1:length(u))
%     y(k) = 0.9*y_ + 0.476/3*(u(k) + u_);
      y(k) = (7*y_ + (u(k) + u_)) / 8;
      y_ = y(k);  u_ = u(k);
   end
      
   
   o = opt(o,'xscale',1000);
   plot(o,t,u,'bc', t,y,'g');
   
   xlabel('time [ms]');
   ylabel('grid voltage [V]');
   title('Grid Phase Estimator');
   
   subplot(o);
end
