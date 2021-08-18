function [o1,o2,o3] = sensitivity(o,in1,in2)
%
% SENSITIVITY Calculate mode sensitivity: analyse all mode numbers with
%             respect to magnitude sensitivity in the critical frequency 
%             region and return modenumber and according dB values sorted
%             by greatest sensitivity.
%
%                [dB,Sjw] = sensitivity(o)
%
%             Calculate sensitivity frequency response for given mode
%             number and omega vector
%
%                [skjw,lkjw,l0jw] = sensitivity(o,k,omega)
%             
%             Graphics Generation
%
%                sensitivity(o,'Critical') % plot/calc critical sensitivity
%                sensitivity(o,'Damping')  % plot/calc damping sensitivity
%                sensitivity(o,'Weight')   % plot/calc weight sensitivity
%
%             Example 1
%
%                omega = logspace(2,7,1000);
%                mode = 5;      % study sensitivity of mode 5
%                [s5jw,l5jw,l0jw] = sensitivity(cuo,mode,omega);
%                s5 = fqr(corasim,omega,{s5jw});
%                l5 = fqr(corasim,omega,{l5jw});
%                l0 = fqr(corasim,omega,{l0jw});    % original
%                bode(l0,'r')
%                bode(l5,'g')
%                bode(s5,'c');
%
%             Options
%                detail      % plot intermediate details of sensitivity
%                            % calculation for modes 'Damping' and 'weight'
%                            % (default true)
%
%             Copyright(c) Bluenetics 2021
%
%             See also: SPM
%
    if ~type(o,{'spm'})
       error('SPM typed object expected (arg1)');
    end
    
    if (nargin == 1)
       [o1,o2] = Sensitivity(o);
    elseif (nargin == 2)
       o1 = Dispatch(o,in1);
    elseif (nargin == 3)
       if (nargout > 0)
          [o1,o2,o3] = Sfqr(o,in1,in2);
       else
          Sfqr(o,in1,in2);
       end
    else
       error('1 or 3 input args expected');
    end 
end

%==========================================================================
% Dispatch Mode
%==========================================================================

function oo = Dispatch(o,mode)         % Dispatch Local Function       
   if ~ischar(mode)
      error('character expected for arg2');
   end
   
   switch (mode)
      case 'Critical'                  % plot/calc critical sensitivity
         oo = Critical(o);
      case 'Damping'
         o = opt(o,'mode.sensitivity','damping');
         oo = WeightOrDamping(o);      % plot/calc damping sensitivity
      case 'Weight'
         o = opt(o,'mode.sensitivity','weight');
         oo = WeightOrDamping(o);      % plot/calc weight sensitivity
      otherwise
         error('bad mode');
   end
end

%==========================================================================
% Sensitivity
%==========================================================================

function [dB,Sjw] = Sensitivity(o)     % Sensitivity Data Calculation  
   o = cache(o,o,'spectral');          % hard refresh spectral cache
   [PsiW31,PsiW33] = cook(o,'PsiW31,PsiW33');
   
   dB = 0*PsiW31(:,1);
   Sjw = PsiW33;
end

%==========================================================================
% Calculate Sensitivity Frequency Response
%==========================================================================

function [skjw,lkjw,l0jw,PsiW31,PsiW33] = Sfqr(o,k,omega,l0jw,PsiW31,PsiW33)
%
%   SFQR  Sensitivity Frequency Response
%
%      Example 1: standard call
%
%            [skjw,lkjw,l0jw] = Sens(o,k,omega);
%
%      Example 2: efficient calculation
%
%         [~,~,l0jw,PsiW31,PsiW33] = Sens(o,0,omega)
%         for (k=1:n)
%            [skjw,lkjw] = Sens(o,k,omega,l0jw,PsiW31,PsiW33);
%         end
%
%   k (arg2) is the mode number. For k > 0 the weight sensitivity with
%   respect to mode number k is calculated. For k = 0 the original 
%   spectrum is returned and the sensitivity is zero
%
   if (nargin < 6)
      [PsiW31,PsiW33,T0] = cook(o,'PsiW31,PsiW33,Tnorm');

          % calculate spectrum and critical spectrum

      L0jw = lambda(o,PsiW31,PsiW33,omega*T0);  % spectrum (n rows)
      l0jw = lambda(o,L0jw);                    % critical spectrum (1 row)
   end
   
      % check range of k (mode argument)

   if (length(k) ~= 1 || round(k) ~= k)
      error('scalar integer expected for mode number (arg2)');
   end

   [m,n] = size(PsiW31);
   if (k < 0 || k > m)
      error('mode number (arg2) of range');
   end
   
      % get sensitivity calculation mode
      
   mode = opt(o,'mode.sensitivity');
   vari = opt(o,'sensitivity.variation');
   
      % extract Psi and weight parts from PsiW31 and PsiW33
      
   Psi31 = PsiW31(:,1:3);  W31 = PsiW31(:,4:end);
   Psi33 = PsiW33(:,1:3);  W33 = PsiW33(:,4:end);

      % inactivate mode related weight
      
   if (k == 0)                        % for k=0 no inactivation!
      lkjw = l0jw;  skjw = 0*l0jw;
      return
   else
      switch mode
         case 'weight'
            W31(k,:) = 0*W31(k,:);  
            W33(k,:) = 0*W33(k,:);
         case 'damping'
            Psi31(k,2) = vari*Psi31(k,2);
            Psi33(k,2) = vari*Psi33(k,2);
         otherwise
            error('bad sensitivity calculation mode');
      end
   end
   
      % refresh PsiW31 and PsiW33 with inactivated weight or
      % damping variation
   
   PsiW31 = [Psi31 W31];
   PsiW33 = [Psi33 W33];

      % calculate frequency response for inactivated weight
      
   Lkjw = lambda(o,PsiW31,PsiW33,omega*T0);
   lkjw = lambda(o,Lkjw);                      % critical function

      % finally calculate sensitivity frequency response

%  skjw = (lkjw./l0jw) - 1;
   skjw = max(abs(lkjw ./ l0jw), abs(l0jw ./ lkjw));
%  skjw = abs(lkjw ./ l0jw);
   
   if (nargout == 0)
      cls(o);
      Plot(o,111)
   end
   
   function Plot(o,sub)
      l0 = fqr(corasim,omega,{l0jw});
      lk = fqr(corasim,omega,{lkjw});
      sk = fqr(corasim,omega,{skjw});
      
      bode(l0,'ryyyyy3');
      bode(lk,'r');
      bode(sk,'c');
      
      omk = sqrt(Psi31(k,3))/oscale(o);  fk = omk/2/pi;
      title(sprintf('sensitivity Study - Mode: #%g @ %g 1/s (%g Hz)',...
                    k,round(omk),round(fk)));
   end
end

%==========================================================================
% Plot/Calculate Critical Sensitivity
%==========================================================================

function o = Critical(o)               % Critical Sensitivity          
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   heading(o);
   
   sub1 = 2212;                        % for bode plot
   sub2 = 3221;                        % for K plot
   sub3 = 2222;                        % for damping
   sub4 = 3211;                        % for damping sensitivity
   sub5 = 3231;                        % for Percentage plot
   
      % hard refresh of caches
      
   o = cache(o,o,'critical');          % hard refresh
   o = cache(o,o,'spectral');          % hard refresh
   o = cache(o,o,'sensitivity');       % hard refresh
   
      % plot nominal damping
      
   subplot(o,sub3);
   damping(o);
   
      % plot damping sensitivity
      
   PlotS(o,sub4);
   
   [l0,K0,f0] = cook(o,'l0,K0,f0');
   
      % get nominal zeta and variation from settings
      
   [zeta,omega] = damping(o);
   m = length(zeta);                  % number of modes
   dtab0 = [1:m; 1:m; zeta(:)']';
   vari = opt(o,{'sensitivity.variation',2});

      % now object variation always on
      
   o = opt(o,'damping.object',true);  % otherwise pot. inactive variation
   
      % init plots
      
   PlotBode(o,sub1,l0,f0,'ryyyyy','r-.');
   title(sprintf('Critical Magnitude: K0: %g, f0: %g Hz',...
         o.rd(K0,2),o.rd(f0,0)));
   xlabel('omega [1/s]');
   ylabel('|l0(jw)|');
      
   PlotK(o,sub2,[1 m],K0);
   PlotPercent(o,sub5,[1 m],K0);
   
      % run through all modes
      
   K0tab = [];

   stop(o,'Enable');
   terminated = 0;
   
      % lookup sensitivity in cache
      
   S = cache(o,'sensitivity.S');
   if (~isempty(S) && length(S) == m)
      [~,idx] = sort(-abs(S));
   else
      idx = 1:m;
   end
      

   K = cache(o,'sensitivity.Kcrit');
   l = cache(o,'sensitivity.lcrit');
   f = cache(o,'sensitivity.fcrit');
   
   if isempty(K) || length(K) ~= m
      K = NaN*ones(1,m);
   end
   
   for (k=idx)
      dtab = dtab0;                    % startig from dtab0
      dtab(k,3) = dtab(k,3)*vari;      % variate damping of mode k
      oo = damping(o,dtab);            % change damping
      
         % we have to clear critical and spectral cache segment
         
      oo = cache(oo,'critical',[]);    % clear critical cache segment
      oo = cache(oo,'spectral',[]);    % clear spectral cache segment
      
      oo = opt(oo,'cache.hard',false); % no hard refresh !!!
      oo = opt(oo,'stop',true);        % can break @ user stop request
      
      Kk = K(k);
      if isnan(Kk)

            % plot actual damping

         subplot(o,sub3);
         delete(gca);
         subplot(o,sub3);
         damping(oo);
      
            % cook up critical quantities (break if user stop request)
            
         [lk,Kk,fk] = cook(oo,'l0,K0,f0');

            % store results in tables (to be cached). Note that calculated
            % values are invalid in case of a stop request!

         if ~stop(o)
            l{k} = lk;
            K(k) = Kk;
            f(k) = fk;

               % note that o contains the original cache contents, and it is
               % not an issue if we cold refresh this cache (but attention:
               % oo must not be cold refreshed!!!)

            o = cache(o,'sensitivity.Kcrit',K);
            o = cache(o,'sensitivity.lcrit',l);
            o = cache(o,'sensitivity.fcrit',f);
            cache(o,o);                      % cold refresh

               % plot Bode

            subplot(o,sub1);
            delete(gca);
            subplot(o,sub1);
            PlotBode(oo,sub1,lk,fk,'r','c-.');   
            plot(omega(k)*[1 1]/2/pi,get(gca,'ylim'),'g-.');

            PlotBode(o,sub1,l0,f0,'ryyyyy','r-.');
            title(sprintf('Mode: #%g, K0: %g',k,o.rd(Kk,2)));
            xlabel('omega [1/s]');
            ylabel('|l0(jw)|');
         end
      end
      
         % Plot K and percentage
         
      PlotK(o,sub2,k,Kk);         
      PlotPercent(o,sub5,k,Kk);
            
      if stop(o)         
         terminated = 1;
         break;
      end
   end
   stop(o,'Disable');
   
   title(sprintf('Critical Gain (nominal K0: %g)',o.rd(K0,2)));
   if (~terminated)
      PlotFavorites(o)
   end
   
   function PlotBode(o,sub,l0,f0,col1,col2)
      subplot(o,sub1);

      bode(l0,col1);
      plot(2*pi*[f0 f0],get(gca,'ylim'),col2);
   end
   function PlotK(o,sub,k,K)
      subplot(o,sub);
      
      if (length(k) == 2)
         plot(o,k,[K K],'K');
         title(sprintf('Critical Gain (nominal K0: %g)',o.rd(K0,2)));
         xlabel('mode number [#]');
         ylabel(sprintf('K0 (variation: %g)',vari));
         return;
      end
      
      col = o.iif(dark(o),'w','k');
      plot([k k],[0 K],col,  k,K,'ro');
      title(sprintf('Critical Gain K0: %g (nominal K0: %g)',...
                    o.rd(Kk,3),o.rd(K0,3)));
   end
   function PlotPercent(o,sub,k,K)
      subplot(o,sub);
      
      p = (K-K0)/K0*100;               % percentage
      if (length(k) == 2)
         plot(o,k,[p p],'K');
         title('Percentual deviation of critical gain');
         xlabel('mode number [#]');
         ylabel('percentage');
         return;
      end
      
      col = o.iif(dark(o),'w','k');
      plot([k k],[0 p],col,  k,p,'ro');
      title(sprintf('Percentual deviation of critical gain: %g%%',...
                    o.rd(p,3)));
   end
   function PlotFavorites(o)
      [~,idx] = sort(-K);
      n = 5;
      for (i=1:n)
         subplot(o,[n 2 i 2]);
         k = idx(i);
         
         bode(l0,'ryyyyy');
         bode(l{k},'r');
         ylim = get(gca,'ylim');
         
         plot(2*pi*[f0 f0],ylim,'r-.');
         plot(2*pi*[f(k) f(k)],ylim,'c-.');
         
         title(sprintf('mode #%g, K0: %g',k,o.rd(K(k),2)));
      end
   end
end

%==========================================================================
% Plot/Calculate Damping Sensitivity
%==========================================================================

function o = WeightOrDamping(o)        % Damping Sensitivity           
%
% Idea:
%    - let L0(jw) be the nominal frequency response
%    - vary w(k) such that L0(jw) -> Lk(jw)
%    - build dL := L0(jw)-Lk(jw)
%    - Sensitivity S := |dL(jw)| / |L0(jw)|
%
   heading(o);

   s = [];  modes = [];                % initialize
   watch = false;                      % don't watch (try to set true!)

   col = o.iif(dark(o),'w.','k.');
   
   modus = opt(o,'mode.sensitivity');
   if isequal(modus,'weight')
      tit = 'Weight Sensitivity';
   elseif isequal(modus,'damping')
      tit = 'Damping Sensitivity';
   end
   
      % transfer required options
   
   o = with(o,'sensitivity');          % access sensitivity settings
   opts = opt(o,'sensitivity');
   o = opt(o,'bode',opts);

      % cold refresh critical cache
      
   o = cache(o,o,'critical');
   o = cache(o,o,'spectral');
   
   [f0,T0] = cook(o,'f0,Tnorm');
   [lambda0,PsiW31,PsiW33] = cook(o,'lambda0,PsiW31,PsiW33');

   [om0,w0] = Omega(o);                % omega range and center frequency
   
   L0 = lambda(o,lambda0);             % calculate critical Fqr
   L0 = inherit(L0,o);                 % inherit bode settings
   L0 = opt(L0,'color','ryyyyy');      % set plot color
   
      % sensitivity study

   m = size(PsiW31,1);                 % number of modes
   [~,om] = fqr(with(L0,'bode'));      % get full omega range

      % get full range phi(om)

   L0jw = lambda(o,PsiW31,PsiW33,om*T0);
   L0jw0 = lambda(o,PsiW31,PsiW33,om0*T0);

   PlotL0(o,3211);
   o = Variation(o,3211,3221);         % run variations
   PlotS(o,3231);

      % plot FQR for 5 most sensitive modes
      
   [~,idx] = sort(-s);                 % sort from largest to smallest
   for (k=1:5)
      PlotL0(o,[5,2,k,2]);
      PlotE(o,[5,2,k,2],idx(k));
      if stop(o)
         break
      end
   end

   heading(o);

      % done - that's it!
      
   function o = Variation(o,sub1,sub2) % run variations                
      subplot(o,sub2);
      
      modus = opt(o,'mode.sensitivity');
      vari = opt(o,'sensitivity.variation');
      
      bode(trf(corasim),'W');
      set(gca,'ylim',[-10,40],'ytick',-10:10:40);
      
      Psi31 = PsiW31(:,1:3);  W31 = PsiW31(:,4:end);
      Psi33 = PsiW33(:,1:3);  W33 = PsiW33(:,4:end);
      zero = 0;      
      
      l0jw = lambda(o,L0jw);
      l0jw0 = lambda(o,L0jw0);
            
      detail = opt(o,{'detail',1});

      for (i=1:m)
         switch modus
            case 'weight'
               w31 = W31;  w31(i,:) = w31(i,:)*zero;  psiw31 = [Psi31 w31];
               w33 = W33;  w33(i,:) = w33(i,:)*zero;  psiw33 = [Psi33 w33];
            case 'damping'
               k = i;         
               psiw31 = PsiW31;  psiw31(k,2) = vari*psiw31(k,2);
               psiw33 = PsiW33;  psiw33(k,2) = vari*psiw33(k,2);
            otherwise
               error('bad sensitivity calculation mode')
         end
         
         Gjw = lambda(o,psiw31,psiw33,om*T0);    % full omega range
         Gjw0 = lambda(o,psiw31,psiw33,om0*T0);  % omega range next to om0

            % calculate critical function
            
         gjw = lambda(o,Gjw);
         gjw0 = lambda(o,Gjw0);
         
                % sensitivity function

         sjw = max(abs(gjw./l0jw),abs(l0jw./gjw));       
                
         sjw0 = max(abs(l0jw0./gjw0),abs(gjw0./l0jw0)); 
         
            % store sensitivity and modal frequency

         S(i) = max(20*log10(abs(sjw0))); % store max dB value of sensitivity
         mode = sqrt(Psi31(i,3))/oscale(o); % mode omega
         modes(i) = mode;

         if (detail)
            subplot(o,sub1);

            hdl0 = semilogx(om0,20*log10(abs(gjw0)),'r.');
            hdl1 = semilogx(om,20*log10(abs(gjw)),'r');

            subplot(o,sub2);
            hdl2 = semilogx(om,20*log10(abs(sjw)),'c');
            hold on;
            hdl3 = semilogx(om0,20*log10(abs(sjw0)),col);
            hdl4 = semilogx([mode mode],get(gca,'ylim'),'c-.');
            title(sprintf('mode #%g: %g dB @ %g 1/s (%g Hz)',...
                          i,o.rd(S(i),1),mode,mode/2/pi));
                                              
            idle(o);
            delete([hdl0 hdl1,hdl3,hdl4]);
          end

         if (rem(i-1,10) == 0)
            progress(o,'analysing sensitivity',(i-1)/m*100);
         end
      end
      progress(o);

         % store sensitivity S and modal frequency f in cache
      
      f = modes / (2*pi);
      o = cache(o,'sensitivity.S',S);         % store sensitivity
      o = cache(o,'sensitivity.f',f);         % store frequency of mode
      o = cache(o,'sensitivity.mode',modus);  % store sensitivity mode
      cache(o,o);                      % hard refresh cache

         % plot FQR for most sensitive modes

      S0 = max(S) - 20;
      s = S;
      
      [~,idx] = sort(-s);
      
      for (k=1:min(10,length(idx)))
         kk = idx(k);
         plot(o,modes(kk),10*s(kk),[col,'|'], modes(kk),10*s(kk),'ro');
         hdl = text(modes(kk),10*s(kk),sprintf('#%g',kk));
         set(hdl,'horizontal','center','vertical','top');
         set(hdl,'color',o.iif(dark(o),1,0)*[1 1 1]);
      end

      h = semilogx([w0 w0],get(gca,'ylim'),'r-.');
      set(h,'linewidth',1);
      
      ylim = get(gca,'ylim');
      ylim = [min(ylim(1),min(s(idx))), max(ylim(2),max(s))];
      set(gca,'ylim',ylim);
      
      title(sprintf('%s @ Frequency',tit));
            
      subplot(o);
   end
   function PlotL0(o,sub)              % Plot L0 (Psion Based)         
      o = opt(o,'plotcrit',1);
      diagram(o,'Bode','',L0,sub);

      title(sprintf('om0: %g 1/s (f: %g Hz)',w0,w0/2/pi));
      subplot(o,sub);
   end
   function PlotE(o,sub,k)             % plot Example                  
      subplot(o,sub);

      [skjw,lkjw,l0jw] = sensitivity(o,k,om);
      
      mode = modes(k);                 % mode omega

      hdl = semilogx(om,20*log10(abs(lkjw)),'r');
      hold on
      hdl = semilogx(om,20*log10(abs(skjw)),'c');
      set(hdl,'linewidth',1);
      title(sprintf('Mode #%g, Omega: %g 1/s (%g Hz), Sensitivity: %g dB',...
                k,o.rd(modes(k),0),o.rd(modes(k)/2/pi,0),o.rd(s(k),1)));

      subplot(o);
      h = semilogx([w0 w0],get(gca,'ylim'),'r-.');
      set(h,'linewidth',1);
      h = semilogx([modes(k),modes(k)],get(gca,'ylim'),'c-.');
      set(h,'linewidth',1);
      
      ylim = get(gca,'ylim');
      set(gca,'ylim',[ylim(1) max(ylim(2),50)]);
   end
   function PlotLjw(o,sub)             % plot Bode diagram             
      subplot(o,sub);

      bode(L0,'r');

      dB0 = 20*log10(max(abs(L0jw0)));
      plot(o,om0,dB0,'K.');
      
      
      [m0,n0] = size(lambda0.data.matrix);
      for (ii=[2:m0,1])                % first row at the end
         L0i = fqr(corasim,lambda0.data.omega,{lambda0.data.matrix{ii,1}});
         colii = o.iif(ii==1,'ryyy','kw');
         bode(L0i,colii);
      end
      
      [m0,n0] = size(L0jw0);
      for (ii=[2:m0,1])                % first row at the end
         L0i = fqr(corasim,om0,{L0jw0(ii,:)});
         colii = o.iif(ii==1,'ryyyo','kwo');
         bode(L0i,colii);
      end
   end
end
function PlotS(o,sub)                  % Plot Sensitivity              
   subplot(o,sub);
   modus = cache(o,'sensitivity.mode');
   S = cache(o,'sensitivity.S');
   m = length(S);
   col = o.iif(dark(o),'w.','k.');
   
   plot(o,1:m,S,[col,'|'], 1:m,S,'ro');
   title('Weight Sensitivity');
   if isequal(modus,'weight')
      title('Weight Sensitivity @ Mode Number');
   elseif isequal(modus,'damping')
      what = 'Damping Sensitivity @ Mode Number';
      vari = opt(o,'sensitivity.variation');
      title(sprintf('%s (variation: %g)',what,vari));
   end
   xlabel('mode number [#]');
   ylabel('sensitivity [dB]');
   subplot(o);
end

%==========================================================================
% Helper
%==========================================================================

function [om,om0] = Omega(o,f0,k,n)    % Omega range near f0           
%
% OMEGA  Omega range near f0
%
%           om = Omega(o,f0,1.05,50)   % om = f0/1.02,..,f0*1.02, 50 points
%           om = Omega(o,f0)           % same as above
%           om = Omega(o)              % cook f0
%
%           [om,om0] = Omega(o)        % also return center frequency
%
   if (nargin < 4)
      n = opt(o,{'omega.window',50});
   end
   if (nargin < 3)
      k = 1.05;
   end
   k1 = 1/k;  k2 = k;

   if (nargin < 2)
      [f0,L0] = cook(o,'f0,L0');
   end

   om0 = 2*pi*f0;
   om = logspace(log10(om0*k1),log10(om0*k2),n);
end
