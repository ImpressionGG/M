function nyquist(o,L,sub)
%
% NYQUIST Nyquist plot for principal and critical spectrum
%
%           nyquist(o,gamma0,sub);       % critical forward spectrum
%           nyquist(o,gamma180,sub);     % critical backward spectrum
%
%           nyquist(o,lambda0,sub);      % principal forward spectrum
%           nyquist(o,lambda0,sub);      % principal backward spectrum
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, BODE, GAMMA, SPECTRUM, NICHOLS, BODE
%
   if (nargin < 3 || length(sub) < 1)
      sub = opt(o,{'subplot',111});
   end
   
      % now sub is proper!
      
   Nyquist(o,L,sub);   
end

function Nyquist(o,L,sub)                    
   o = subplot(o,sub);

   o = with(o,'nyq');
   L = inherit(L,o);
   
   colors = get(L,o.iif(dark(o),'dark','bright'));
   col0 = get(L,{'color','r2'}); 

   [K,f,critical,tag] = var(L,'K,f,critical,tag');

      % plot FQR of Li(jw)

   no = length(L.data.matrix(:));
   for (i=1:no)
      Li = peek(L,i);
      col = colors{1+rem(i,length(colors))};
      nyq(Li,col);
   end

   [Ld,Lc] = lambda(o,L);           % get dominant/critical FQR

   Lc = inherit(Lc,L);
   hdl = nyq(Lc,col0);              % Nyquist plot of critical FQR
   set(hdl,'linewidth',2);
   
   name = get(L,'name');
   kind = o.iif(critical,'Critical','Principal');
   title(sprintf('%s Spectrum: %s - K%s: %g @ %g Hz',kind,name,tag,K,f));
end