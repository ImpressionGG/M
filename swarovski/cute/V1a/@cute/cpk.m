function [cpks,cpkw,mgrs,mgrw,mgn,sig] = cpk(o,sym)
%
% CPK   Calculate strong (Cpks) and weak (Cpkw) of a data stream given by 
%       symbol 'sym'. In addition calculate strong (mgrs) and weak (mrgw)
%       magniture reserve.
%
%          [cpks,cpkw,mgrs,mgrw] = cpk(o,sym) % Cpk & magnitude reseve
%
%       Examples:
%
%          [cpks,cpkw] = cpk(o,'ax')   % Cpk of Kappl x-acceleration
%          [cpks,cpkw] = cpk(o,'a')    % Cpk of Kappl radial acceleration
%
%       The data stream according to the symbol (sym) is the data stream 
%       returned by the cook method
%
%          ax = cook(o,'ax') 
%
%       and thus depending on the following
%
%       Options:
%
%          facette:  facette index
%          filter:   filter settings to calculate velocity and elongation
%          
%       Given lower spec limit (LSL) and upper spec limit (USL), which are
%       determined by the option settings, the following basic quantities
%       are calculated for a data stream s:
%
%          s = cook(o,sym)             % data stream
%          avg = mean(s)               % mean value (average) of stream
%          sig = std(s)                % standard dev. (sigma) of stream
%          mgn = max(abs(s))           % magnitude of data stream
%
%       Based on these quantities Cpk and magnitude reserve calculate:
%
%          Cpk = min(avg-LSL,USL-avg) / (3*sig)  % process capability (Cpk)
%          Mgr = min(avg-LSL,USL-avg) / mgn      % magnitude reserve
%
%       Special functions:
%
%          cpk(oo,'a')                 % show Cpk algorithm mechanics
%
%       Calculation method:
%
%          1) Strong Cpk (Cpks) is calculated against strong spec limits
%             given by opt(o,'specs')*[1;0]
%
%          2) Weak Cpk (Cpkw) is calculated against weak spec limits
%             given by opt(o,'specs')*[0;1]
%
%          3) Toatal Cpk of a data stream (strong or weak) is calculated
%             as the maximum of the facette Cpk's of each data seement
%             assigned to the cutting sub-process of a facette
%
%          4) Cpk formula for a data segment x of a facette is calculated
%             by first filtering the relevant data (squared data is greater
%             or equal 1 percent of maximum squared data)
%
%                idx = find(x >= 0.01*max(x.*x))  % index of relevant data
%                xr = x(idx)                      % relevant data
%
%             and then applying the usual Cpk formula
%
%                avg = mean(xr)                   % average value
%                sig = std(xr)
%
%                Cpk = min(avg-LSL,USL-avg) / (3*sig)
%
%             where LSL/USL is upper/lower spec limit, avg is the average
%             (mean value) of the relevant data, and sig is the standard
%             deviation of the relevant data.
%
%       Performance: 60ms
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CUTE, BREW, THDR
%
   if (nargout == 0)
      show = true;
      o = opt(o,'show',1);             % show cpk algorithm mechanics
   else
      show = false;
   end

   [oo,bag,rfr] = cache(o,o,'brew');   % hard cache refresh
         
   [specs,specw] = spec(oo,sym);
   lsl.s = specs(1); usl.s = specs(2); % strong spec limit
   lsl.w = specw(1); usl.w = specw(2); % weak spec limit

      % get number of facettes

   [nf,facette] = cluster(o,inf);      % number of facettes & facette idx
   
      % begin with graphics if in 'show' mode

   Show1(o);                           % Show 1st part of Cpk mechanics
   
      % for each facette (facette index k) calculate Cpks and max value
      
   if (facette > 0)
      [cpks,cpkw,mgrs,mgrw,mgn,sig] = Cpk(o,sym,1,facette,lsl,usl);
      [thd,chk] = thdr(o);
   else
      if (facette < 0)
         nf = -nf;
      end
      for (k=1:abs(nf)) 
         [cpks(k),cpkw(k),mgrs(k),mgrw(k),mgn(k),sig(k)] = ...
                                          Cpk(o,sym,nf,k,lsl,usl);
         [thd(k),chk(k)] = thdr(o);
      end
   end   
      % take minimum Cpk of all facettes
      
   cpks = min(cpks);                   % strong total cpk
   cpkw = min(cpkw);                   % weak total cpk
   mgrs = min(mgrs);                   % strong total margin
   mgrw = min(mgrw);                   % weak total margin
   mgn  = max(mgn);                    % magnitude
   sig = max(sig);                     % max of sigmas (~= sigma of total)
   thd = max(thd);                     % thd (total harmonic distortion)
   chk = min(chk);                     % harmonic capability
   
      % finalpart of graphics if in 'show' mode
      
   Show5(o);                           % Show final part of Cpk mechanics
      
   function Show1(o)                   % Show First Part of Graphics   
      if (show)
         cls(o);
         t = cook(o,'t');         
         s = cook(o,sym);
         subplot(311);
         plot(o,t,s,'c');
         hold on;
      end
   end
   function Show5(o)                   % Show FinalPart of Graphics    
      if (show)
         subplot(311);
         xlim = get(gca,'Xlim');
         plot(o,xlim,mgn*[1 1],'g-.');
         plot(o,xlim,3*sig*[1 1],'ryyy-.');
         
         t = cook(o,'t');
         s = cook(o,sym);
         
         idx = find(s==mgn);
         if ~isempty(idx)
            plot(o,t(idx),s(idx),'go');
         end
         
         ylim = get(gca,'Ylim');
         if (ylim(2) <= 1.1*mgn)
            set(gca,'Ylim',[ylim(1) 1.1*mgn]);
         end
         
         pareto = opt(o,{'cpk.pareto',0.99});
         tit = sprintf(['Magnitude: %g,  Mgr: %g (%g),  Cpk: %g (%g)',...
                  ' - Pareto %g%%'], o.rd(mgn,1), o.rd(mgrs,2),...
                  o.rd(mgrw,2), o.rd(cpks,2), o.rd(cpkw,2),pareto*100);
         title(tit);
         ylabel(sym);
         xlabel('time');
         
         heading(o);
      end
   end
end

%==========================================================================
% Calculate Cpk
%==========================================================================

function [cpks,cpkw,mgrs,mgrw,mgn,sig,avg] = Cpk(o,sym,nf,k,lsl,usl)   
%
% CPK   Calculate Cpk values vor strong and weak specs and other metrics
%       for a specific facette given by facette index k
%
%          [cpks,cpkw,mrgs,mrgw,mgn,avg,sig] = Cpk(o,sym,nf,k,lsl,usl)
%
%          cpks:   Cpk for strng specs
%          cpkw:   Cpk for weak specs
%
%          mgrs:   margin reserve for strong specs
%          mgrw:   margin reserve for weak specs
%
%          mgn:    magnitude (maximum amplitude value)
%          avg:    average value
%          sig:    sigma (standard deviation)
%
   compact = (nf < 0);                 % check whether compact mode
   nf = abs(nf);
   
   mode = opt(o,{'spec.mode',1});      % spec mode (1: sztong, 2:weak)
   pareto = opt(o,{'cpk.pareto',0.99});
   show = opt(o,{'show',false});
   relevance = opt(o,{'cpk.relevance',2});  % relevance algorithm

   if (show)
      tt = cook(o,'t');
      ss = cook(o,sym);                % get 'facette part' of data stream
   end
   
   assert(k > 0);                      % facette index must be positive!
   oo = opt(o,'select.facette',k);     % k: facette index
   s = cook(oo,sym);                   % get 'facette part' of data stream

      % calculate relevant data

   p = s.*s;                           % signal "power"
   p0 = (1-pareto)^2*max(p);           % power threshold (noise vs. signal)
   bdx = find(p >= p0);                % index of 'big' signals
   if (relevance == 1)
      rdx = bdx(1):bdx(end);           % index of relevant signals
   else
      rdx = bdx;
   end
   sr = s(rdx);                        % relevant signal data

      % in show mode show relevant signal data
      
   Show2(o);                           % Show 2nd part of Cpk mechanics
      
      % calculate Cpk

   if (all(sr>= 0))
      sr = [sr,-sr];
   end
   
   mgn = max(abs(s));                  % magnitude
   avg = mean(sr);                     % average
   sig = std(sr);                      % sigma

      % calculate cpk values for strong and weak spec

   cpks = min(avg-lsl.s,usl.s-avg) / (3*sig);
   cpkw = min(avg-lsl.w,usl.w-avg) / (3*sig);
   
      % calculate margin values for strong and weak spec

   mgrs = min(avg-lsl.s,usl.s-avg) / mgn;
   mgrw = min(avg-lsl.w,usl.w-avg) / mgn;
   
   Show3(o);                           % Show 3rd part of Cpk mechanics
   Show4(o);                           % Show 4th part of Cpk mechanics
  
   function Show2(o)                   % Show 2nd Part of Graphics   
      if (show)
         if (compact)                  % in compact mode tricky!
            persistent i0_
            if isempty(i0_)
               i0_ = 0;
            end
            
            itab = cache(o,'cluster.itab');
            i0 = itab(k,1);
            i0 = i0_ + bdx(1)-rdx(1);
            
               % next stuff is all 'pure magic' - don't try to understand!
              
            subplot(311);
            if (k>1)
               i0 = i0 + itab(k-1,2) - itab(k-1,1);
            else
               set(gca,'Xlim',[min(tt),max(tt)]);
            end
            i0_ = i0;
            
            t = cook(oo,'t');
            plot(o,tt(i0+rdx),sr,'rm'); % plot relevant signal data
            spec(o,sym,all(s>=0));
         else
            subplot(311);
            t = cook(oo,'t');

            plot(o,t(rdx),sr,'rm');     % plot relevant signal data
            if (nf == 1)
               set(gca,'Xlim',[min(t),max(t)]);
            end
            spec(o,sym,all(s>=0));
         end

         
         subplot(3,nf,o.iif(nf==1,2,nf+k));
         plot(o,t,s,'c');
         hold on
         plot(o,t(rdx),sr,'rm');
         set(gca,'Xlim',[min(t),max(t)]);
      end
   end
   function Show3(o)                   % Show 3rd Part of Graphics   
      if (show)
         subplot(3,nf,o.iif(nf==1,2,nf+k));
         spec(oo,sym,all(s>=0));

         plot(o,get(gca,'xlim'),mgn*[1 1],'g-.');
         idx = find(s==mgn);
         if ~isempty(idx)
            t = cook(oo,'t');
            plot(o,t(idx),s(idx),'go');
         end
    
         if (mode <= 1)                % strong spec mode
            plot(o,xlim,3*sig*[1 1],'ryyy-.');
         else                          % weak spec mode
            plot(o,xlim,3*sig*[1 1],'ryyy-.');
         end
         
         ylim = get(gca,'Ylim');
         if (ylim(2) <= 1.1*mgn)
            set(gca,'Ylim',[ylim(1) 1.1*mgn]);
         end

            % compose prolog
            
         if (nf > 1)
            prolog = '';               % no prolog in total or compact mode
         else
            prolog = sprintf('Facette: #%g,  Magnitude: %g, ',k,o.rd(mgn,1));
         end
         
            % set title
            
         if (mode <= 1)                % strong spec mode
            tit = sprintf('%sMgr:%g, Cpk:%g',...
                          prolog, o.rd(mgrs,2), o.rd(cpks,2));
         else                          % weak spec mode
            tit = sprintf('%sMgr:%g, Cpk:%g',...
                          prolog, o.rd(mgrw,2), o.rd(cpkw,2));
         end         
         title(tit);
      end
   end
   function Show4(o)                   % Show 3rd Part of Graphics   
      if (show)
         pareto0 = pareto;             % mind this value
         cpk0 = cpks;                  % mind this value
         
         subplot(3,nf,o.iif(nf==1,2,2*nf+k));
         if (dark(o))
            set(gca,'Color',control(o,'color'));
         end
%        list = [0.9:0.01:0.99, 0.991:0.001:0.999, 0.9991:0.00010:9999];
         list = [0.9 0.91:0.002:0.99, 0.991:0.0002:0.999, 0.9991:0.00002:0.9999];
         for (i=1:length(list))
            pareto = list(i);
            p0 = (1-pareto)^2*max(p);  % power threshold (noise vs. signal)
            bdx = find(p >= p0);       % index of 'big' signals
            if (relevance == 1)
               rdx = bdx(1):bdx(end);           % index of relevant signals
            else
               rdx = bdx;
            end
            sr = s(rdx);               % relevant signal data

            if (all(sr>= 0))
               sr = [sr,-sr];
            end

            mgn = max(abs(s));                  % magnitude
            avg = mean(sr);                     % average
            sig = std(sr);                      % sigma

               % calculate cpk values for strong and weak spec

            cpk(i) = min(avg-lsl.s,usl.s-avg) / (3*sig);
         end
         
         hdl = semilogx((1-list)*100,cpk,'m');
%        hdl = plot((1-list)*100,cpk,'m');
         set(hdl,'LineWidth',1);
         
         hold on;
         dark(o,'Axes');
         
         semilogx((1-pareto0)*100,cpk0,'go');
%        plot((1-pareto0)*100,cpk0,'go');
         
         title(sprintf('Facette #%g',k));
         xlabel('1-pareto [%]');
         ylabel('Cpk');
         grid(o);
         shg; 
         pause(0.1);
      end
   end
end

%==========================================================================
% Show Cpk Algorithm Mechanics
%==========================================================================
 
function Show(o,s,sym,idx,Cpks,Cpkw)   % Show Cpk Algorithm Mechanics  
   oo = corazon(o);
   cls(o);
   
   t = cook(o,':');
   plot(oo,t,s,'m');
   hold on;
   
   plot(oo,t(idx),s(idx),'k.');
   title(sprintf('%s (Cpk = %g/%g)',sym,o.rd(Cpks,2),o.rd(Cpkw,2)));
   spec(o,sym,all(s>=0));
   
   heading(o);
   dark(o);
end
