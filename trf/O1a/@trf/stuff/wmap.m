function w = wmap(obj,A,B,axplot)
%
% WMAP    w-mapping of complex numbers.
%
%         Create a map object. This is formally a tff object and contains
%         the two parameter for the mapping a and b
%
%            w = -(-real(q)/sqrt(a))^(1/4) + sqrt(-1)*b((imag(q)/a).^b);
%
%            mob = wmap(tff,A,B);
%            mob = wmap(tff);              % A = 1000, B = 100
%            mob = wmap(tff,A,B,'axes');   % plot axes
%            mob = wmap(tff,'axes');       % plot axes
%
%            map = get(mob,'map');
%            a = map.a;
%            b = map.b;
%
%         Meaning of parameters:
%
%            A maps to 0
%            i*B maps to i
%
%         Draw Axes
%         =========
%
%            wmap(mob);
%
%         Actual mapping
%         ==============
%
%            W = wmap(map,[q1,q2,...,qn])
%
%			                 z - 1
%		       q = Omega0 --------- ,  Omega0 = 1
%			                 z + 1
%
%	  See TFF, STF, QTF, ZTF
%
   if (nargin == 1 || nargin >= 3)
      
      if (nargin == 1)
         A = 1000;  B = 100;
      end
 
      a = sqrt(A);
      x = 1;  
      for (k=1:50)
         f = x*(B/sqrt(A))^x - 1;
         df = (B/sqrt(A))^x * (1+x*log(B/sqrt(A)));
         x = x - f/df;
      end
      b = x;
      map.a = a;  map.b = b;
      map.A = A;  map.B = B;
      [knd,Ts] = kind(obj);
      map.kind = knd;  map.Ts = Ts;
      
      obj = set(obj,'map',map);
      obj = set(obj,'title',sprintf('map(%g,%g)',A,B));
      w = obj;
      
      if (nargin == 4)
         axes(obj);             % clear figure and plot axes
      end
      
      return
      
   elseif (nargin == 2)
      if (ischar(A))    % draw axes
         axes(obj);
         return
      end
      
      q = A;
      map = get(obj,'map');
      
      if (isempty(map))
         map = get(wmap(tff),'map');    % use defaults
      end
      
      a = map.a;  A = map.A;
      b = map.b;  B = map.B;
      
      n = size(q,2);
   
      Omega0 = 2/map.Ts;

      for (i=1:n)
         qi = q(:,i);
         if (map.kind == 'z' || map.kind == 'w')
            z = qi;
            qi = Omega0*(z-1)./(z+1);            
         end
         re = real(qi);  im = imag(qi);

         sigr = sign(re); sigi = sign(im);
         
         Qr = sigr.*(sigr.*re).^(1/4) / sqrt(a);
         Qi = b * sigi.*((sigi.*im/a).^b);
         
         Q = Qr + sqrt(-1)*Qi;

         if (map.kind == 'z' || map.kind == 'w' && 0)
            wi = (1 + Q/Omega0) ./ (1 - Q/Omega0);
         else
            wi = (1 + Q/1) ./ (1 - Q/1);
         end
         w(:,i) = wi;
      end
   else
      error('bad number of args!');
   end
   
   return

%==========================================================================
% Plot w-axis
%==========================================================================

function axes(mob)
%
% AXES     Plot axes
%
   cls;
   xlim = [-1.2 1.2];  ylim = xlim;
   plot([0 0],ylim,'k', xlim,[0 0],'k');
   set(gca,'xlim',xlim,'ylim',ylim);
   set(gca,'dataaspectratio',[1 1 1]);
   hold on;
   shg
   
   for (re = [-1,-10,-100,-1000,-10000])
      q = re + i*[-1e4:10:-1e3, -1e3:1:-1e2, -1e2:0.1:1e2, 1e2:1:1e3, 1e3:10:1e4];
      w = wmap(mob,q);
      color(plot(real(w),imag(w)),0.9*[1 1 1]);
   end
   shg
   
   for (im = [0, 1, 10, 100, 1000, 10000,100000,1000000])
      q = [-10000:10:-1000, -1000:1:-100, -100:0.1:-10, -10:0.01:1, ...
           1:0.01:10, 10:0.01:100] + i*im;
      w = wmap(mob,q);
      color(plot(real(w),+imag(w)),0.9*[1 1 1]);
      color(plot(real(w),-imag(w)),0.9*[1 1 1]);
   end
   shg
   
   for (im = [0.2,0.5, 2, 5, 20, 50, 200, 500, 2000, 5000, 20000, 50000, ...
              200000, 500000])
      q = [-10000:10:-1000, -1000:1:-100, -100:0.1:-10, -10:0.01:1, ...
           1:0.01:10, 10:0.01:100] + i*im;
      w = wmap(mob,q);
      plot(real(w),+imag(w),'c:');
      plot(real(w),-imag(w),'c:');
   end
   
   plot([0 0],ylim,'k', xlim,[0 0],'k');
   phi = 0:pi/100:2*pi;
   plot(cos(phi),sin(phi),'k');
   return

%eof   