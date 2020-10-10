function K = stable(o,L0)              % Critical K for Stability
%
% STABLE   Calculate critical K for closed loop stability
%
%             L0 = cook(o,'L0');
%             K = stable(o,L0);        % calc critical K value
%
%             stable(o,L0)             % plot K range for stability
%             stable(o)                % cook L0 from object 
%
%          Copyright(c): Bluenetics 2020
%
%          See also: SPM, COOK
%
  if (nargin == 1)
     L0 = cook(o,'L0');
  end
  
  if (nargout == 0)
     Stable(o,L0);                     % plot
  else
     K0 = Stable(o,L0);
     o = opt(o,'magnitude.low',20*log10(K0*0.95));
     o = opt(o,'magnitude.high',20*log10(K0*1.05));
     K = Stable(o,L0);
  end
end

%==========================================================================
% Helper
%==========================================================================

function K = Stable(o,L0)
   low = opt(o,{'magnitude.low',-300});
   high = opt(o,{'magnitude.high',100});
   delta = opt(o,{'magnitude.delta',20});

   mag = logspace(low/20,high/20,10000);

   [num,den] = peek(L0);

   for (i=1:length(mag))
      K = mag(i);
      poly = add(L0,K*num,den);
      r = roots(poly);

      re(i) = max(real(r));
   end

      % find critical K
      
   K = inf;
   idx = find(re>0);
   if ~isempty(idx)
      idx = max(1,idx(1)-1);
      K = mag(idx);
   end
      
      % that's it if output args are provided
      
   if (nargout > 0)
      return
   end
   
      % otherwise plot
      
   dB = 0*re;

   idx = find(re>0);                   % strictly unstable roots
   if ~isempty(idx)
      dB(idx) = 20*log(1+re(idx));
   end

   idx = find(re<0);                   % stable roots
   if ~isempty(idx)
      dB(idx) = 20*log(-re(idx));
   end

   hdl = semilogx(mag,dB);
   hold on;

   lw = opt(o,{'linewidth',1});
   set(hdl,'LineWidth',lw,'Color',0.5*[1 1 1]);

   idx = find(re>0);
   margin = inf;

   if ~isempty(idx)
      semilogx(mag(idx),dB(idx),'r.');
      i = max(1,min(idx)-1);
      margin = mag(i);
   end

   idx = find(re<0);
   if ~isempty(idx)
      semilogx(mag(idx),dB(idx),'g.');
   end

      % plot axes

   col = o.iif(dark(o),'w-.','k-.');
   plot(get(gca,'xlim'),[0 0],col);
   plot([1 1],get(gca,'ylim'),col);
   subplot(o);

   title('Stability Analysis');
   xlabel('K-factor');
   mu = opt(o,'process.mu');
   if isempty(mu)
      ylabel(sprintf('Stability Margin: %g',o.rd(margin,2)));
   else
      ylabel(sprintf('Stability Margin: %g  (mu = %g)',...
             o.rd(margin,2),mu));
   end         
end
