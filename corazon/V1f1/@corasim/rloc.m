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
   
   o = Auto(o,num,den);                % auto setting of plot range
   o = Rloc(o,num,den);
end

%==========================================================================
% Root Locus
%==========================================================================

function o = Rloc(o,num,den)
   [z,p,k] = zpk(o,num,den);
   
   nz = length(z);                     % number of zeros
   np = length(p);                     % number of poles
   
   if (nz > 0)
      plot(o,real(z),imag(z),'Ko');
      hold on;
   end
   if (np > 0)
      plot(o,real(p),imag(p),'Kx');
      hold on;
   end
   
      % determine delta, which is the minimum progress which should
      % be achieved during each itewration
      
   [xlim,ylim] = opt(o,'xlim,ylim');
   assert(o.is(xlim) && o.is(ylim));
   set(gca,'Xlim',xlim,'Ylim',ylim);
   
   delta = [diff(xlim),diff(ylim)] / 100;

   Branch(o,+eps,'r');                 % calc & plot positive branch
   Branch(o,-eps,'bc');                % calc & plot negative branch
   
   function Branch(o,K,col)
      r = p(:);                           % initial root location (for K=0)                           
      x = real(r);  y = imag(r);
      while (1)
         [r,K] = Roots(o,num,den,z,p,r,K,delta);
         x(:,end+1) = real(r);
         y(:,end+1) = imag(r);

         N = Interesting(o,r,z,delta,xlim,ylim);  % still interesting roots?
         if (N == 0)
            break;
         end
      end

      for (i=1:size(x,1))
         %plot(o,x,y,col, x,y,[col,'.']);
         plot(o,x,y,col);
         hold on
      end
   end
end

%==========================================================================
% Helper
%==========================================================================

function o = Auto(o,num,den)           % Auto Setting of Plot Range
   o = opt(o,'xlim',[-10,10]);
   o = opt(o,'ylim',[-10,10]);
end
function [r,K] = Roots(o,num,den,z,p,r,K,delta)                        
   delta = ones(length(r),1)*delta;
   r0 = r;  K0 = K;
   
   K = K + sign(K)*10.^[-10:0.1:10];

   i1 = 1;  i2 = length(K);
   while (1)
      i = floor((i1+i2)/2);
      poly = add(o,K(i)*num,den);
      r = roots(poly);

         % sort according to lowest distance

      r = Sort(r,r0);
      dr = r-r0;
      d = [abs(real(dr)), abs(imag(dr))];

         % if d exceeds delta we have to reduce K, otherwise we 
         % increase K ...

      if any(any(d > delta))        % reduce K
         i = i-1; i2 = i;           % decrement upper bound
      else
         i = i+1;  i1 = i;          % increment lower bound
      end

         % if i1 == i2 we found the optimum value

      if (i1 >= i2)
         break;                     % done loop
      end
   end

      % calc roots and sort with optimal K ...

   K = K(i);
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
   if (N > 0 || length(r) == 0)
      return
   end
   
      % r contains same number of roots as zeros in z
      
   r = Sort(r,z);
   dr = r-r0;
   d = [abs(real(dr)), abs(imag(dr))];
         
   somewhere = any(d > delta);            
   N = sum(somewhere);      
end