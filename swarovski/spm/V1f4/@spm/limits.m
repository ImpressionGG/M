function [lim,style] = limits(o,mode)
%
% LIMITS    Return limits and color or plot limits for varioius diagrams
%
%              [lim,style] = limits(o)   % return limits and plot style
%
%           Let mu denote the friction coefficient (opt(o,'process.mu'))
%           and kmu the friction range (opt(o,'process.kmu')). Then 
%
%              lim = [1/mu, 1/(mu*kmu)]
%
%           If limits are deactivated (in View>Limits menu) then lim = []
%
%           and style (plot style) equals to opt(o,'view.limitstyle') which
%           defaults to 'c1-.'
%
%           Plot limits for various diagrams
%
%              limits(o,'Nyq')         % for nyquist plot
%              limits(o,'Magni')       % for magnitude plot
%              limits(o,'Gain')        % for stability margin chart
%
%           Options
%
%              process.mu              % friction coefficient
%              process.kmu             % friction range
%
%           Copyright(c): Bluenetics 2021
%
%           See also: SPM, CRITICAL
%
   mu = opt(o,{'process.mu',0.1});
   kmu = opt(o,{'process.kmu',1});
  
   limits = opt(o,{'view.limits',1});
   style = opt(o,{'view.limitstyle','c1-.'});
   
   if (nargout > 0 && limits)
      lim = [1/mu 1/(mu*kmu)];
      return
   elseif (nargout > 0 && ~limits)
      lim = [];
      return
   end
   
      % otherwise plotting
      
   if (~ limits)
      return                           % no limits plotting
   end
   
   switch mode
      case 'Nyq'
            % create an FQR typed CORASIM object with a frequency response
            % that represents a circle

         om = 0:pi/100:2*pi;
         Gs = fqr(corasim,om,{1/mu * exp(1i*om)});  % circle
         Gs = inherit(Gs,o);

         nyq(Gs,style);  
         if (kmu ~= 1)
            nyq((1/kmu)*Gs,style);
         end

      case 'Magni'
         plot(o,get(gca,'xlim'),20*log10(1/mu)*[1 1],style);
         if (kmu ~= 1)
            plot(o,get(gca,'xlim'),20*log10(1/mu/kmu)*[1 1],style);
         end
         
      case 'Gain'
         plot(o,mu*[1 1],get(gca,'ylim'),style);
         if (kmu ~= 1)
            plot(o,mu*kmu*[1 1],get(gca,'ylim'),style);
         end

      otherwise
         error('bad mode');
   end