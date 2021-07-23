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
%                sensitivity(o,'Critical')
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

function oo = Dispatch(o,mode)
   if ~ischar(mode)
      error('character expected for arg2');
   end
   
   switch (mode)
      case 'Critical'
         oo = Critical(o);
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

function o = Critical(o)
   if ~type(o,{'spm'})
      plot(o,'About');
      return
   end
   
   sub1 = 2211;                        % for bode plot
   sub2 = 2221;                        % for K plot
   sub3 = 1212;                        % for damping
   
      % plot nominal damping
      
   subplot(o,sub3);
   damping(o);
   
   [l0,K0,f0] = cook(o,'l0,K0,f0');
   
      % get nominal zeta and variation from settings
      
   [zeta,omega] = damping(o);
   m = length(zeta);                  % number of modes
   dtab0 = [1:m; 1:m; zeta(:)']';
   vari = opt(o,{'sensitivity.variation',2});

      % init plots
      
   PlotBode(o,sub1,l0,f0,'ryyyyy','r-.');
   title(sprintf('Critical Magnitude: K0: %g, f0: %g Hz',...
         o.rd(K0,2),o.rd(f0,0)));
   xlabel('omega [1/s]');
   ylabel('|l0(jw)|');
      
   PlotK(o,sub2,[1 m],K0);
   title(sprintf('Critical Gain (nominal K0: %g)',o.rd(K0,2)));
   xlabel('mode number [#]');
   ylabel('K0');
   
      % run through all modes
      
   K0tab = [];

   stop(o,'Enable');
   terminated = 0;
   for (k=1:m)
      dtab = dtab0;                    % startig from dtab0
      dtab(k,3) = dtab(k,3)*vari;      % variate damping of mode k
      oo = damping(o,dtab);            % change damping
      
         % we have to clear critical and spectral cache segment
         
      oo = cache(oo,'critical',[]);    % clear critical cache segment
      oo = cache(oo,'spectral',[]);    % clear spectral cache segment
      
      oo = opt(oo,'cache.hard',false); % no hard refresh !!!
      [lk,Kk,fk] = cook(oo,'l0,K0,f0');
      
         % plot actual damping
         
      subplot(o,sub3);
      delete(gca);
      subplot(o,sub3);
      damping(oo);
 
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
      
         % Plot K
         
      PlotK(o,sub2,k,Kk);
      
      K0tab(k) = Kk;
      l{k} = lk;
      K(k) = Kk;
      f(k) = fk;
      
      if stop(o)         
         terminated = 1;
         break;
      end
   end
   stop(o,'Disable');
   
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
         return;
      end
      
      col = o.iif(dark(o),'w','k');
      plot([k k],[0 K],col,  k,K,'ro');
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