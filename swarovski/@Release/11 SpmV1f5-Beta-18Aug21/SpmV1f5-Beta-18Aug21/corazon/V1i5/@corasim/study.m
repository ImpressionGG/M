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
                        @SystemInvert,@FqrTest0,@FqrTest1,@FqrTest2,...
                        @FqrTest3,@PsiwVpaTest);
   oo = gamma(o);                   % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                                                  
   oo = mitem(o,'System Inversion',{@WithCuo,'SystemInvert'},[]);
   Numeric(o);                         % add Numeric menu
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

%==========================================================================
% Numeric Quality
%==========================================================================

function oo = Numeric(o)               % Numeric Menu                  
   setting(o,{'numeric.damping'},1e-6);
   setting(o,{'numeric.window'},1);
   setting(o,{'numeric.digits'},0);

   oo = mitem(o,'Numeric Quality');
   ooo = mitem(oo,'Damping',{},'numeric.damping');
   choice(ooo,[1e-1 1e-2 1e-3 1e-4 1e-5 1e-6 1e-7 1e-8 1e-9 1e-10 1e-11],{});
   ooo = mitem(oo,'Window',{},'numeric.window');
   choice(ooo,[1 2 5 1e1 1e2 1e3, 1e4, 1e5, 1e6],{});
   ooo = mitem(oo,'Digits',{},'numeric.digits');
   choice(ooo,[0 2 4 6 8 10 12 14 16 50 100 200 500 1000],{});
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Frequency Response Test 0',{@WithSho,'FqrTest0'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Frequency Response Test 1',{@WithSho,'FqrTest1'});
   ooo = mitem(oo,'Frequency Response Test 2',{@WithSho,'FqrTest2'});
%  ooo = mitem(oo,'Frequency Response Test 3',{@WithSho,'FqrTest3'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Variable Precision Test',{@WithSho,'PsiwVpaTest'});
end

function o = FqrTest0(o)               % Frequency Response Test 0
%
% define F1(s) = 2d / (s^2 + 2ds + 1)
%        F2(s) = 2d / (s^2 - 2ds + 1)
% compare
%        |[F1+F2](jw)| against |F1(jw)+F2(jw)|
%
   d = opt(o,{'numeric.damping',0.1});
   win = opt(o,{'numeric.window',1});
   
   F1 = trf(o,2*d,[1 +2*d 1]);
   F2 = trf(o,2*d,[1 -2*d 1]);
   F = F1 + F2;
   
   olim = [1/(1+d*win),1+d*win];
   omega.low = olim(1);
   omega.high = olim(2);
   omega.points = 20000;

   F1 = opt(F1,'omega',omega);
   F2 = opt(F2,'omega',omega);
   F = opt(F,'omega',omega);

   om = orange(F);

   [F1jw,~,F1dB] = fqr(F1,om);
   [F2jw,~,F2dB] = fqr(F2,om);
   FdB = 20*log10(abs(F1jw+F2jw));
   
   [~,~,dB] = fqr(F,om);
   idx = find(dB==min(dB));
   
   
   PlotBode(o,211);
   PlotDeviation(o,212);
   
   function PlotBode(o,sub)
      subplot(o,sub);

      magni(F,'g4');
      hold on;
      
      hdl = semilogx(om,FdB,'r');
      set(hdl,'linewidth',2);
      
      plot(o,om(idx(1)),dB(idx(1)),'go');

      title(sprintf('Minimum: %g',dB(idx(1))));
      subplot(o);
   end
   function PlotDeviation(o,sub)
      subplot(o,sub);
      
      semilogx(om,dB-FdB,'c');
      title(sprintf('Deviation'));
      ylabel('|F(jw)|-|F1(jw)+F2(jw)| [dB]');
      xlabel('omega [1/s]');
      subplot(o);
   end
   heading(o,sprintf('Damping: %g',d));
   subplot(o,211);
end
function o = FqrTest1(o)               % Frequency Response Test 1
   d = opt(o,{'numeric.damping',0.1});
   win = opt(o,{'numeric.window',1});

   psi = [1 2*d 1; 1 -2*d 1];
   w = 2*d*[1 1];   
   G = psiw(o,psi,w);
   
   F = trf(o,2*d,[1 2*d 1]) + trf(o,2*d,[1 -2*d 1]);
   
   olim = [1/(1+d*win),1+d*win];
   omega.low = olim(1);
   omega.high = olim(2);
   omega.points = 20000;

   G = opt(G,'omega',omega);
   F = opt(F,'omega',omega);

   FqrMatch(o,F,G);

   heading(o,sprintf('Damping: %g',d));
   subplot(o,211);
end
function o = FqrTest2(o)               % Frequency Response Test 2
   d = opt(o,{'numeric.damping',0.1});
   win = opt(o,{'numeric.window',1});

   psi = [1 2*d (1+d);  1 2*d 1/(1+d)];
   w = d*[1 1];   
   G = psiw(o,psi,w);

   F = trf(o,d,[1 2*d (1+d)]) + trf(o,d,[1 2*d 1/(1+d)]);
   
   olim = [1/(1+d*win),1+d*win];
   omega.low = olim(1);
   omega.high = olim(2);
   omega.points = 20000;

   G = opt(G,'omega',omega);
   F = opt(F,'omega',omega);

   FqrMatch(o,F,G);

   heading(o,sprintf('Damping: %g',d));
   subplot(o,211);
end
function o = FqrTest3(o)               % Frequency Response Test 3     
%
%           w11         w12
%  G1 = ---------- + ---------- = g11(s) + g12(s) = g11 + g12
%        psi11(s)     psi12(s)
%
%           w21         w22
%  G2 = ---------- + ---------- = g21(s) + g22(s) = g21 + g22
%        psi21(s)     psi22(s)
%
%  G = G1*G2 = (g11+g12)*(g21+g22) = g11*g21 + g11*g21 + g12*g21 + g12*g22
%
%               A         B
%  g11*g21 = ------- + --------  => w11*w12 = A*psi21(s) + B(psi11(s)
%            psi11(s)  psi21(s)
%
%  w11*w22 = A*(1 + a11*s + a10*s^2) + B*(1 + a21*s + a20*s^2)
%
   d = opt(o,{'numeric.damping',0.1});
   win = opt(o,{'numeric.window',1});

   psi1 = [1 2*d 1; 1 -2*d 1];
   w1 = 2*d*[1 1];
   G1 = psiw(o,psi1,w1);
   
   psi2 = [1 2*d (1+d);  1 2*d 1/(1+d)];
   w2 = d*[1 -1];   
   G2 = psiw(o,psi2,w2);

   F1 = trf(o,2*d,[1 2*d 1]) + trf(o,2*d,[1 -2*d 1]);
   F2 = trf(o,d,[1 2*d (1+d)]) + trf(o,-d,[1 2*d 1/(1+d)]);
   F = F1*F2;
   
   G = modal(F);
   G = F;
   
   olim = [1/(1+d*win),1+d*win];
   omega.low = olim(1);
   omega.high = olim(2);
   omega.points = 20000;

   G = opt(G,'omega',omega);
   F = opt(F,'omega',omega);

   FqrMatch(o,F,G);

   heading(o,sprintf('Damping: %g',d));
   subplot(o,211);
end
function o = PsiwVpaTest(o)            % VpaPsiW Var. Precision Test   
   d = opt(o,{'numeric.damping',0.1});
   psi = [1 2*d 1; 1 -2*d 1];
   w = d*[1 1];
   
   G = psiw(opt(o,'digits',50),psi,w);
   F = psiw(opt(o,'digits',0),psi,w);

   olim = [1/(1+d*win),1+d*win];
   omega.low = olim(1);
   omega.high = olim(2);
   omega.points = 20000;

   G = opt(G,'omega',omega);
   F = opt(F,'omega',omega);

   FqrMatch(o,F,G);

   heading(o,sprintf('Damping: %g',d));
   subplot(o,211);
end

function FqrMatch(o,F,G)               % Analyse Frequ. Responnse Match
   digits = opt(o,{'numeric.digits',0});
   if (digits > 0)
      F = opt(G,'digits',digits);
   end

   om = orange(F);

   [~,~,GdB] = fqr(G,om);
   [~,~,FdB] = fqr(F,om);
   
   idx = find(GdB==min(GdB));
   
   PlotBode(o,211);
   PlotDeviation(o,212);
   
   function PlotBode(o,sub)
      subplot(o,sub);

      magni(F,'g4');
      hold on;
      magni(G,'r2');
      plot(o,om(idx(1)),GdB(idx(1)),'go');

      title(sprintf('Minimum: %g',GdB(idx(1))));
      subplot(o);
   end
   function PlotDeviation(o,sub)
      subplot(o,sub);
      
      semilogx(om,GdB-FdB,'c');
      title(sprintf('Deviation'));
      ylabel('|G(jw)|-|F(jw)| [dB]');
      xlabel('omega [1/s]');
      subplot(o);
   end
end
