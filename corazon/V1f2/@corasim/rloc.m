function o = rloc(o,num,den)           % Plot Root Locus               
%
% RLOC  Root locus plot
%
%          rloc(G)                     % plot root locus of system
%          rloc(o,num,den)             % plot root locus of transfer fct.
%
%       Options
%
%          xlim              real part limits        (default: [])
%          ylim              imaginary part limits   (default: [])
%
%       Copyright8c): Bluenetics 2020
%
%       See also: CORASIM, SYSTEM, BODE
%
   if (nargin ~= 3)
      [num,den] = peek(o);
   end
   
   held = ishold;
   
   o = Inherit(o);                     % inherit options from shell (?!)
   o = Auto(o,num,den);                % auto setting of plot range
   o = Rloc(o,num,den);                % plot root locus
   
   if (held)
      hold on;
   else
      hold off;
   end
end

%==========================================================================
% Root Locus
%==========================================================================

function o = Rloc(o,num,den)           % Plot Root Locus               
   col = {'b','bc','r','m','rw','mw','rww','mww'};
   K = [-inf 0 1 1.5 2 5 10 20];
   
   [z,p,k] = zpk(o,num,den);
   
   nz = length(z);                     % number of zeros
   np = length(p);                     % number of poles
   
   if (nz > 0)
      plot(o,real(z),imag(z),'Ko2');
      hold on;
   end
   if (np > 0)
      plot(o,real(p),imag(p),'Kx');
      hold on;
   end
   
   for (i=3:length(col))
      r = roots(add(o,K(i)*num,den));  % closed loop roots for K = 1
      plot(o,real(r),imag(r),[col{i},'p']);
   end

      % determine delta, which is the minimum progress which should
      % be achieved during each itewration
      
   [xlim,ylim] = opt(o,'xlim,ylim');
   assert(o.is(xlim) && o.is(ylim));   
   set(gca,'Xlim',xlim,'Ylim',ylim);
   
   plot(o,[0 0],ylim,'K2-.');
   subplot(o);
   
   delta = opt(o,{'delta',0.01});
   delta = [diff(xlim),diff(ylim)] * delta;

      % positive branches
         
   Branch(o,[+eps,K(3)],col{3});       % calc & plot positive branch
   Branch(o,[K(3),K(4)],col{4});       % calc & plot positive branch
   Branch(o,[K(4),K(5)],col{5});       % calc & plot positive branch
   Branch(o,[K(5),K(6)],col{6});       % calc & plot positive branch
   Branch(o,[K(6),K(7)],col{7});       % calc & plot positive branch
   Branch(o,K(7),col{7});              % calc & plot positive branch

      % negative branch
      
   Branch(o,-eps,col{2});              % calc & plot negative branch
   
   Legend(o,K,col);
   subplot(o);
   
   function Branch(o,K,col)            % Calculate And Plot Branch     
   %
   % BRANCH   Calc and plot branch
   %
   %             Branch(o,eps,'r')
   %             Branch(o,-eps,'b')
   %             Branch(p,[eps,0.1],'rrw')
   %         
      Kmax = inf;
      if (length(K) >= 2)
         Kmax = K(2);
         K = K(1);
      end
      
      poly = add(o,K*num,den);
      r = roots(poly);                 % initial roots location
      x = real(r);  y = imag(r);
      
      for (k=1:5000)
         [r,K] = Roots(o,num,den,z,p,r,K,Kmax,delta);
         x(:,end+1) = real(r);
         y(:,end+1) = imag(r);

         N = Interesting(o,r,z,delta,xlim,ylim);  % still interesting roots?
         if (N == 0)
            break;
         end
         
         if isequal(K,Kmax)
            break;
         end
         
         %plot(o,x,y,[col,'5']);
         %hold on
      end

      for (i=1:size(x,1))
         if opt(o,{'bullets',0})
            plot(o,x(i,:),y(i,:),col, x(i,:),y(i,:),[col,'K.']);
         else
            plot(o,x(i,:),y(i,:),col);
         end
         hold on
      end
      idle(o);                         % show graphics
   end
   function Legend(o,K,col)            % Show Legend
      txt = 'K = ';
      sep = '';
      for (i=1:length(K))
         txt = [txt,sep,sprintf('%g',K(i))];
         sep = ' -> ';
      end
      xlabel(txt);
      
      return
      
      labels = {};
      for (i=2:length(K))
         hdl(i-1) = plot([0 0],[i i]/1e15);
         o.color(hdl(i-1),col{i});
         hold on;
         labels{i-1} = sprintf('K = %g ... %g',K(i-1),K(i));
      end
      
      legend(hdl,labels,'Location','southeast');
      subplot(o);                      % refresh drawing
   end
end

%==========================================================================
% Helper
%==========================================================================

function o = Auto(o,num,den)           % Auto Setting of Plot Range    
   z = roots(num);
   p = roots(den);
   zp = [z(:)' p(:)'];
      
   zoom = opt(o,{'zoom',2});           % zoom factor
   
      % make pretty
      
   xlim = [min(real(zp)), max(real(zp))];
   ylim = [min(imag(zp)), max(imag(zp))];

   assert(xlim(1) <= xlim(2));
   assert(ylim(1) <= ylim(2));
        
   if isempty(opt(o,'xlim'))
      if (xlim(2) < 0)
         xlim(2) = -xlim(1)*0.5;
      elseif (xlim(1) > 0)
         xlim(1) = -xlim(2)*0.5;
      end
      xlim(2) = abs(xlim(1))*0.5;
      
      xlim = xlim*zoom;
            
      xlim(1) = Pretty(xlim(1));
      xlim(2) = Pretty(xlim(2));
      o = opt(o,'xlim',xlim);
   end
   
   if isempty(opt(o,'ylim'))      
      if (ylim(2) < 0)
         ylim(2) = -ylim(1)*0.5;
      elseif (ylim(1) > 0)
         ylim(1) = -ylim(2)*0.5;
      end
      
      ylim = ylim*zoom;
      
      if (abs(ylim(1)) < abs(xlim(1)) || abs(ylim(2)) < abs(xlim(1)))
         ylim(1) = -abs(xlim(1));
         ylim(2) = +abs(xlim(1));
      end
      
      ylim(1) = Pretty(ylim(1));
      ylim(2) = Pretty(ylim(2));
      o = opt(o,'ylim',ylim);
   end
      
   function y = Pretty(x)
      if (x==0)
         y = x;
         return
      end
      sgn = sign(x);
      x = abs(x);
      
      base = 10^floor(log10(x));
      x = o.rd(x/base,1);
      
      if (x == 1)
         y = 1*sgn*base;
      elseif (x <= 2)
         y = 2*sgn*base;
      elseif (x <= 5)
         y = 5*sgn*base;
      else
         y = 10*sgn*base;
      end
   end
end
function [r,K] = Roots(o,num,den,z,p,r,K,Kmax,delta)                   
   delta = ones(length(r),1)*delta;
   
   r0 = r;
   Kmax = abs(Kmax);
   K0 = K;
   
   K = K + sign(K)*10.^[-10:0.1:10, 10:10:100, 101:300];

   i1 = 1;  i2 = length(K);
   while (1)
      i = floor((i1+i2)/2);
      
      poly = add(o,K(i)*num,den);
      if any(isinf(poly))
         i2 = max(i-1,1);
         continue
      end
      
      r = roots(poly);

         % sort according to lowest distance

      r = Sort(r,r0);
      dr = r-r0;
      d = [abs(real(dr)), abs(imag(dr))];

         % if d exceeds delta we have to reduce K, otherwise we 
         % increase K ...

      if any(any(d > delta))        % reduce K
         i = max(i-1,1); i2 = i;           % decrement upper bound
      else
         i = i+1;  i1 = i;          % increment lower bound
      end

         % if i1 == i2 we found the optimum value

      if (i1 >= i2)
         i = max(i-1,1);            % one step back to avoid inf in poly
         break;                     % done loop
      end
   end

      % calc roots and sort with optimal K ...

   K = K(i);
   if (sign(K0) > 0) && (K > Kmax)
      K = Kmax;
   elseif (sign(K0) < 0) && (K < -Kmax)
      K = -Kmax;
   end
   
   poly = add(o,K*num,den);
   r = roots(poly);
   r = Sort(r,r0);
   r = r(:);
end
function r = Sort(r,r0)                % Sort Roots For Best Match     
   for (i=1:length(r)-1)
      ri = r0(i);
      d = abs(r0(i)-r);
      
         % swap rj with minimum distance
         
      j = find(d==min(d));  j = j(1);
      tmp = r(i);  r(i) = r(j);  r(j) = tmp;
   end
end
function N = Interesting(o,r,z,delta,xlim,ylim)  % Interesting Roots   
   x = real(r);  y = imag(r);
   
   idx = find((x < xlim(1)) | (x > xlim(2)) | ...
              (y < ylim(1)) | (y > ylim(2)));
   if ~isempty(idx)
      r(idx) = [];
      x = real(r);  y = imag(r);
   end
   
   N = length(r) - length(z);
   if (N ~= 0 || length(r) == 0)
      return
   end
   
      % r contains same number of roots as zeros in z
      
   r = Sort(r,z);
   dr = r - z;
   d = [abs(real(dr)), abs(imag(dr))];
         
   idx = find(d(:,1)>=delta(1) | d(:,2)>=delta(2));            
   N = length(idx);      
end
function o = Inherit(o)                % inherit options from shell    
   if isempty(figure(o))
      so = pull(o);
      if ~isempty(so)
         o = inherit(o,so);
         o = with(o,'style');
         o = with(o,'rloc');
      end
   end
end
