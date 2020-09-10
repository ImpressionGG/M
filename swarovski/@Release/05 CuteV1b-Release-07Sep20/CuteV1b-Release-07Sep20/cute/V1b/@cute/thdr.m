function [thd,chk] = thdr(o,sym)
%
% THDR    Total harmonic distortion (thd) and harmonic capability (chk) of
%         a signal or an object
%
%            thdr(o)                 % show harmonic distortion & capabity
%            [thd,chk] = thdr(o)     % harmonic metrics of an object
%            [thd,chk] = thdr(o,sym) % harmonic metrics of a signal
%
%         Definition
%
%            thd = sum(i=2,...){X_rms,i^ 2} / X_rms,tot
%            chk = thd / USL         % USL = upper spec limit (see options)
%
%         Example
%
%            [~,chk] = thdr(o)      % harmonic capability of an object
%            cpk = cook(o,'chk')    % easiest way to get proper Chk
%
%         Algorithm
%
%            1) for a facette: for each acceleration component a1,a2,a3
%               calculate RMS_noise(1:3) and RMS_total(1:3). Then calculate
%               thd = norm(RMS_noise) / norm(RMS_total)
%
%            2) for a multi facette data stream calculate thd(k) for each
%               facette k and take max(thd(:)) as the resulting value.
%
%            3) Chk always calculates: chk = thd / USL
%
%         Options:
%
%            spec.thdr               % upper spec limit (USL) for thdr
%            thdr.bwfactor           % bandwidth factor
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CUTE, FFT, CPK
%
   if ~type(o,{'cut'})
      error('type ''cut'' expected');
   end
   
   if (nargin == 1 && nargout == 0)
      Show(o);
   elseif (nargin == 1 && nargout > 0)
      [thd,chk] = Thdr(o,'a');
   elseif (nargin == 2)
      [thd,chk] = Thdr(o,sym);
   else
      error('1 or 3 input args expected');
   end
end

%==========================================================================
% Total Harmonic Distortion RMS (THDR)
%==========================================================================

function [thd,chk,noise,tot] = Thdr(o,sym) % Calculate THDR & Chk      
   [nf,facette] = cluster(o,inf);      % number of facettes & facette idx
   
   if (facette > 0)
      if isequal(sym,'a')
         [o,bag,rfr] = cache(o,o,'brew');   % cold refresh cache
         
         [thd(1),chk(1),noise(1),tot(1)] = Thdr(o,'a1');
         [thd(2),chk(2),noise(2),tot(2)] = Thdr(o,'a2');
         [thd(3),chk(3),noise(3),tot(3)] = Thdr(o,'a3');

         tot = norm(tot);                   % geometric mean
         noise = norm(noise);               % geometric mean

         thd = noise/tot;
         USL = opt(o,{'spec.thdr',0.05});   % upper spec limit
         chk = USL / thd;
      else
         [thd,chk,noise,tot] = ThdrFacette(o,sym);
      end
   else
      if (nargout > 2)
         error('no noise and total to be returned!');
      end
      
      [thd,chk] = ThdrTotal(o,sym);
   end
   
   function [thd,chk,noise,tot] = ThdrFacette(o,sym)                   
      t = cook(o,'t');
      x = cook(o,sym);
   
      [f,X] = fft(o,t,x);
   
         % find indices of higher order harmonics
         
      f0 = cook(o,'fcut');
      idx = find(f>f0);   
   
         % calculate THDR
         
      USL = opt(o,{'spec.thdr',0.05}); % upper spec limit
      tot = norm(X);
      noise = norm(X(idx));
      
      if (norm(X) == 0)
         thd = 0;  chk = 1;
      else
         thd = noise/tot;
         chk = USL / thd;
      end
   end
   function [thd,chk] = ThdrTotal(o,sym)                     
      for (k=1:nf)
         oo = opt(o,'select.facette',k);
         [thd(k),chk(k),noise(k),tot(k)] = Thdr(oo,sym);
      end
      
      thd = max(thd);  chk = min(chk);  
   end
end

%==========================================================================
% Show Total Harmonic Distortion RMS (THDR)
%==========================================================================

function Show(o)                       % Show THDR Calculation         
   cls(o);
   [nf,facette] = cluster(o,inf);      % number of facettes & facette idx
   m = o.iif(facette>0,3,2+nf);
   n = 4;

   f0 = cook(o,'fcut');
         
   for (k=1:m)
      if (facette < 0)
         oo = opt(o,'select.facette',k-2);
      else
         oo = o;
      end
      
      Xtot = 0;
      for (i=1:3)
         sym = sprintf('a%g',i);

         if (k == 1)
            t = cook(o,'t');
            a = cook(o,sym);
            PlotA(o,sym,[m,n,i],0);
         elseif (k == 2)
            t = cook(o,'t');
            a = cook(o,sym);
            [f,X] = fft(o,t,a);
            Xtot = Xtot + X.*X;
            PlotF(o,sym,[m,n,i+n]);
            if (facette > 0)
               PlotN(o,sym,[m,n,i+2*n]);
            end
         else
            fdx = k-2;                       % facette index
            if (facette <= 0)
               oo = opt(o,'select.facette',fdx);
               t = cook(oo,'t');
               a = cook(oo,sym);
               [f,X] = fft(oo,t,a);
               Xtot = Xtot + X.*X;
               PlotN(oo,sym,[m,n,i+(k-1)*n]);
            end
         end
      end

      if (k == 1)
         a = cook(o,'a');
         PlotA(o,'a',[m,n,4],1);
      elseif (k == 2)
         X = sqrt(Xtot);
         PlotF(o,'a',[m,n,4+n],1);
         if (facette > 0)
            PlotN(o,'a',[m,n,4+2*n]);
         end
      else
         if (facette <= 0)
            X = sqrt(Xtot);
            PlotN(oo,'a',[m,n,4+(k-1)*n]);
         end
      end
   end
   
   closeup(o);
   
      % draw heading
      
   tit = get(o,{'title',''});
   if (facette > 0)
      head = sprintf('%s (Facette #%g)',tit,facette);
   elseif (facette == 0)
      head = sprintf('%s (Total)',tit);
   else
      head = sprintf('%s (Compact)',tit);
   end
   
   [thd,chk] = thdr(o);
   metrics = sprintf('THDR: %g%%, Chk: %g', o.rd(thd*100,1), o.rd(chk,2));
   
   kcut = opt(o,'thdr.cutoff');
   fcut = cook(o,'fcut');
   f0 = fcut/kcut;
   cutoff = sprintf('(f0: %g Hz, fcut: %g Hz)', o.rd(f0,0), o.rd(fcut,0)); 
   
   heading(o,[head,' - ',metrics,'  ',cutoff]);
   
   function PlotA(o,sym,sub,summary)   % Plot Acceleration             
      subplot(o,sub);
      col = o.iif(summary,'rm','r');
      
      plot(o,t,a,col);
      spec(o,sym);
      ylabel([sym,' [g]']);
      if (summary)
         title(['Acceleration Magnitude a']);
         set(gca,'Ylim',[0,max(get(gca,'Ylim'))]);
      else
         title(['Process Acceleration ',sym]);
      end
      set(gca,'Xlim',[min(t),max(t)]);
      dark(o,'Axes');
      grid(o);
      idle(o);
   end
   function PlotF(o,sym,sub,summary)   % Plot FFT                      
      subplot(o,sub);      

%     idx = find(f <= f0);
%     plot(o,f(idx),X(idx),'g');
      plot(o,f,X,'g');
      grid(o);

      ylabel(['|',upper(sym),'|  [g]']);
      title(['| FFT (',sym,') |'])
      dark(o,'Axes');
      grid(o);
      idle(o);
   end
   function PlotN(o,sym,sub,summary)   % Plot FFT of Noise             
      subplot(o,sub);      

      idx = find(f > f0);
      plot(o,f(idx),X(idx),'ryk');
      grid(o);

      [thd,chk] = thdr(o,sym);
      txt = sprintf('THDR: %g%%, Chk: %g', o.rd(thd*100,1), o.rd(chk,2));
      
      ylabel(['|',upper(sym),'#|  [g]']);
%     title(['| FFT (',sym,'#) | ',txt])
      title(txt);
      dark(o,'Axes');
      grid(o);
      idle(o);
   end
end
