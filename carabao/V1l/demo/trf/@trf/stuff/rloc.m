function rloc(obj)
%
% RLOC   Root locus plot of a transfer function
%
%               Ps = tff(1,[1 1]);
%               rloc(Ps)
%
   profiler('rloc',1);
   
   nominal = either(option(obj,'rloc.nominal'),inf);
   zoom = either(option(obj,'rloc.zoom'),1);
   aspect = either(option(obj,'rloc.aspect'),1);
   asymptotes = either(option(obj,'rloc.asymptotes'),1);
   scope = either(option(obj,'rloc.scope'),1.2);
   pzonly = either(option(obj,'rloc.pzonly'),0);
   
   ncol = either(option(obj,'rloc.ncolor'),'b');   % negative color (K < 0)
   icol = either(option(obj,'rloc.icolor'),'m');   % intermediate color (0 <= K < 1)
   pcol = either(option(obj,'rloc.pcolor'),'r');   % negative color (K >= 1)
   mcol = either(option(obj,'rloc.mcolor'),'k');   % marker color

   width = either(option(obj,'rloc.width'),1);     % line width
   mwidth = either(option(obj,'rloc.mwidth'),2);   % marker width
   bullets = either(option(obj,'rloc.bullets'),1); % draw bullets
   
   colors = [ncol; icol; pcol];                    % color table
   setting('logging',{});                          % initialize
   
   %cls;             % clear screen

   p = num(obj);    % numerator of transfer function
   q = den(obj);    % numerator of transfer function

   nA = length(q) - length(p);   % number of asymptotes
   phiA = iif(nA==0,0,pi/nA);    % basis angle of asymptotes 
   
   if (nA < 0)
      error('Cannot plot root locus for deg(num) > deg(den)!');
   end
   
   rp = calcroots(p);
   rq = calcroots(q);
   
      % now convert scope from a relative to an absolute value
      
   rp0 = [0;rp(:)];  rq0 = [0;rq(:)];         % no empty matrix!
   rmax = max(max(abs(rp0)),max(abs(rq0)));
   scope = scope*min(rmax,nominal);
   if (scope > 1)
      scope = ceil(scope);
   end
   
   xlim = [-1.5*scope,scope*0.5]/zoom;
   ylim = [-scope,scope]/zoom;
   
   mob = get(obj,'map');   % see if map has to be applied
   if (isempty(mob))   
      plot([0 0],ylim,'k');  hold on;
      plot(xlim,[0 0],'k');

      set(gca,'xlim',xlim/aspect, 'ylim',ylim);
      %set(gca,'dataaspectratio',[1 1 1]);
   end
   
   if (~pzonly)  % if plotting of root locus is really desired
      [Krange,ccode] = range(p,q,scope);    % calculate proper range [Kmin,Kmax]

         % calculate root locus segments and plot

      dist = scope/zoom/200;                % nominal distance of root loci

         % the following loop is the 
         % time consuming loop
         
      profiler('rlocloop',1);
      
      if (~isempty(mob))
         wmap(mob,'axes');    % clear screen and plot axes
         shg
      end
      
      for (i=1:size(Krange,2))
         Kmin = Krange(1,i);  Kmax = Krange(2,i); 
         ci = ccode(i) + 2;  col = colors(ci,:);

         rseg = locus(p,q,Kmin,Kmax,dist);
         if (~isempty(mob))   
            rseg = wmap(mob,rseg);
         end
         
         for (j=1:size(rseg,1))
            x = real(rseg(j,:));  y = imag(rseg(j,:));
            %color(plot(x,y,col),col,width);

            if (bullets)
               profiler('rlocbullets',1);
               color(plot(x,y,[col,'.']),col,width);
               profiler('rlocbullets',0);
            end
         end
         shg
      end
      
      profiler('rlocloop',0);
   end
   
      % 
      % Now plot poles & zeros
      %
      
   d = scope/zoom/15;   % diameter of zero marker
      
   for (i=1:length(rp))
      z = rp(i);
      if (~isempty(mob))   
         z = wmap(mob,z);
      end
      marker(z,'o',d,mcol,mwidth,aspect);  hold on;
   end
   
   for (i=1:length(rq))
      z = rq(i);
      if (~isempty(mob))   
         z = wmap(mob,z);
      end
      marker(z,'x',d,mcol,mwidth,aspect)
   end
   
      % finally plot the nominal roots for K = 1

   if (~pzonly)  % if plotting of root locus is really desired
      K = 1;
      p = [zeros(1,length(q)-length(p)), p];       % adopt dimension
      poly = K*p + q;
      z = calcroots(poly);
      if (~isempty(mob))   
         z = wmap(mob,z);
      end
      marker(z,'#',d,mcol,mwidth,aspect)
      plot(real(z),imag(z),[mcol,'.']);
   end

   if (~pzonly && isempty(mob))
      set(gca,'xlim',xlim/aspect,'ylim',ylim);
      if (aspect == 1)
         set(gca,'dataaspectratio',[1 1 1]);
      end
   end

   if (kind(obj) == 'z')
      set(gca,'xlim',[-1.2,1.2],'ylim',[-1.2,1.2]);
      phi = 0:pi/100:2*pi;
      hold on
      plot(cos(phi),sin(phi),'k');
   end
   
   profiler('rloc',0);
   return
   
%==========================================================================
% Root calculation of a polynomial
%==========================================================================

function root = sortroots(root)
%
% SORTROOTS
%
   r = 100000 * abs(root) + angle(root);
   [ans,idx] = sort(r);
   root = root(idx);       % reorder roots
   return

function root = calcroots(poly,mode)
%
% CALCROOTS
%
   if (nargin < 2) 
      mode = 0;
   end
   
   root = roots(poly);
   if (mode == 0)
      return
   elseif (mode == 1)
      Om0 = 1;
      root = (1 + root/Om0) ./ (1 - root/Om0);
      return
   else
      return
   end
   return

%==========================================================================
% Calculate range of K
%==========================================================================

function [Krange,ccode] = range(p,q,scope)
%
% RANGE      Calculate proper range [Kmin,Kmax]
%   
%               [Krange,col] = krange(ps,qs,scope)   
%
%            The return value is a matrix
%
%                        [ Kmin(1), Kmin(2), ..., Kmin(n) ]
%               Krange = [                                ]
%                        [ Kmax(1), Kmax(2), ..., Kmax(n) ]
%
%            and second out arg col is a vector suggesting color codes
%
%            There are two scenarios for nA := dim(q) - dim(p)
% 
%            1) For nA = 0 one root at the real axis moves to -inf and
%               comes back at +inf. We need to calculate for which K-value
%               the root is +/-inf. This is for K = -qn/pn
%
%            2) For nA > 0 a number of nA roots approaches infinity along
%               an asymptote. We estimate the K value where nA roots have
%               an absolute exceeding the 'outer Scope', a multiple of
%               scope (e.g. Scope = 2 x scope)
%               
   Scope = scope * 2;        % the outer scope
   
      % adopt numerator polynom if necessary

   nA = length(q) - length(p);
   
   if (nA < 0)
      error('Cannot handle dim(ps) > dim(qs)!');
   end
   
   p = [zeros(1,length(q)-length(p)), p];       % adopt dimension
      
      % distinguish the two cases: nA = 0 and nA > 0   
   
   if (nA == 0)
      Kfac = 1.05;
      Kinf = -p(1)/q(1);     % Kinf = -qn/pn (mind: index is reverse)
      
      Kmax = Kinf*(1-1e-10); % close to Kinf
      for (n=1:1000)         % emergency termination after 1000 iterations
         poly = Kmax*p + q;
         rt = calcroots(poly);
         if (isempty(rt))    % then we need to help with a dummy
            rt = 1000*Scope; % just a bigger number than Scope
         end
         nbig = sum(abs(rt) > Scope);
         if (nbig < 1)
            break;
         end
         Kmax = Kmax / Kfac; % continue with a smaller Kmax
      end      

         % correct back and do the checks (this is redundant)
         
      Kmax = Kmax*Kfac;      % correct back to the next bigger Kmax
      poly = Kmax*p + q;
      rt = calcroots(poly);
      nbig = sum(abs(rt) > Scope);

         % Similar procedure for Kmin
         
      Kmin = Kinf*(1+1e-10); % close to Kinf
      for (n=1:1000)         % emergency termination after 1000 iterations
         poly = Kmin*p + q;
         rt = calcroots(poly);
         if (isempty(rt))    % then we need to help with a dummy
            rt = 1000*Scope; % just a bigger number than Scope
         end
         nbig = sum(abs(rt) > Scope);
         if (nbig < 1)
            break;
         end
         Kmin = Kmin * Kfac; % continue with a smaller Kmax
      end      

         % correct back and do the checks (this is redundant)
         
      Kmin = Kmin/Kfac;      % correct back to the next bigger Kmax
      poly = Kmin*p + q;
      rt = calcroots(poly);
      nbig = sum(abs(rt) > Scope);

      TINY = 1e-10;
      HUGE = 1e10;
      
      if (Kinf < 0)          % negative Kinf
         Krange = [-HUGE, Kmax, 0,   1
                   Kmin,   0,   1,  HUGE];

         ccode  = [ -1,   -1,   0,   1];
      elseif (Kinf == 1)
         Krange = [-HUGE, 0,   Kmin,
                     0,  Kmax, HUGE];
                
         ccode  = [ -1,   0,     1];
      elseif (Kinf < 1)
         Krange = [-HUGE, 0,   Kmin,    1
                     0,  Kmax,   1,    HUGE];
                
         ccode  = [ -1,   0,     0,     1];
      elseif (Kinf > 1)
         Krange = [-HUGE, 0,   1     Kmin
                     0,   1,  Kmax,  HUGE];
                
         ccode  = [ -1,   0,   1,     1];
      else
         error('bug!');
      end
      
   else  % nA > 0
      TINY = 1e-10;
      HUGE = 1e50;

      Kfac = 1.5;
      Kmax = HUGE;
      for (n=1:1000)         % emergency termination after 1000 iterations
         poly = Kmax*p + q;
         rt = calcroots(poly);
         nbig = sum(abs(rt) > Scope);
         if (nbig < nA)
            break;
         end
         Kmax = Kmax / Kfac; % continue with a smaller Kmax
      end      

         % correct back and do the checks (this is redundant)
         
      Kmax = Kmax*Kfac;      % correct back to the next bigger Kmax
      poly = Kmax*p + q;
      rt = calcroots(poly);
      nbig = sum(abs(rt) > Scope);

         % repeat whole procedure with Kmin
         
      Kmin = -HUGE;
      for (n=1:1000)         % emergency termination after 1000 iterations
         poly = Kmin*p + q;
         rt = calcroots(poly);
         nbig = sum(abs(rt) > Scope);
         if (nbig < nA)
            break;
         end
         Kmin = Kmin / Kfac; % continue with a smaller Kmax
      end      

         % correct back and do the checks (this is redundant)
         
      Kmin = Kmin*Kfac;      % correct back to the next bigger Kmax
      poly = Kmin*p + q;
      rt = calcroots(poly);
      nbig = sum(abs(rt) > Scope);

      Krange = [Kmin,  0,   1
                  0,   1,  Kmax];
                
      ccode  = [ -1,   0,   1];
      
   end
   
   if (0)    % change to if(1) for debug reasons
      for (i=1:size(Krange,2))
         fprintf('%g:  %g -> %g\n',ccode(i),Krange(1,i),Krange(2,i));
      end
   end
   
   return
   
%==========================================================================   
% Locus of roots (calculate a segment)
%==========================================================================

function [rseg,Kval] = locus(p,q,Kmin,Kmax,dist,recursion)
%
% LOCUS     Calculate a root locus segment for given limits [Kmin,Kmax]
%           Keep distance of roots on a path between values dist and dist/2
%
%  profiler('locus',1);
   debug = setting('debug');
   
   p = [zeros(1,length(q)-length(p)), p];       % adopt dimension

   if (nargin < 6)
      recursion = 1;
   end
   
   if (isinf(Kmin))
      Kmin = 1e10*sign(Kmin);
   end

   if (isinf(Kmax))
      Kmax = 1e10*sign(Kmin);
   end

   if (Kmin == 0)
      Kmin = 1e-20;
   end

   if (Kmax == 0)
      Kmax = -1e-20;
   end
   
   if (sign(Kmin) ~= sign(Kmax))
      error('bug: cannot proceed with change of signs!');
   end
   
   sgn = sign(Kmin);
   K1 = min(abs(Kmin),abs(Kmax));
   K2 = max(abs(Kmin),abs(Kmax));

   if (K1 == K2)
      error('bug: cannot proceed with zero interval');
   end
   
      % calculate roots at the boundaries

   K = K1;
   Kexp = 1/2;              % means square root
   root = calcroots(sgn*K*p+q);
   m = length(root);

   Kval = K;                % save also K values
   rseg = root(:);
   
   log.total = 0;
   log.tiny = 0;
   log.small = 0;
   log.ok = 0;
   log.big = 0;
   log.huge = 0;
   
   while (K < K2)
   
         % first step is to calculate proper K until delta
         % is reasonable (delta <= dist)
       
      expo = 0;                       % search phase 0
      while (1)
         Kfac = (K2/K1)^Kexp;
         K = min(K1*1.001*Kfac,K2);

         rootp = calcroots(sgn*K*p+q);
         [root,delta] = rootsort(root,rootp);
   
         maxdelta = max(delta);
         ratio = maxdelta/dist;

         log.total = log.total + 1;
         
         if (ratio > 10 && expo == 0)  % huge
            Kexp = Kexp^2;                 % decrease progress factor
            log.huge = log.huge+1;
         elseif (ratio > 1 && expo == 0)   % big
            Kexp = Kexp^1.5;               % decrease progress factor
            log.big = log.big+1;
         elseif (ratio < 1/1000)           % tiny
            expo = 0.3;
            Kexp = Kexp^expo;              % increase progress factor
            log.tiny = log.tiny+1;
         elseif (ratio < 1/10)             % small
            expo = 0.95;
            Kexp = Kexp^expo;              % increase progress factor
            log.small = log.small+1;
         else
            if (maxdelta > dist)
               Kexp = Kexp^(1/expo);
            end
            K1 = K;                        % proper K found, we can proceed
            log.ok = log.ok+1;
            break;                         % break loop and go ahead
         end
         
         if (rem(log.total,1000) == 0 || K >= K2)
            pct = 10*round(log.ok/log.total*10);
            if (debug)
               fprintf('log: tot %g(%g%%), tiny: %g, small: %g, ok: %g, big: %g, huge: %g\n',...
                  log.total,pct,log.tiny,log.small,log.ok,log.big,log.huge);
               stop = [];                   % debug stop
            end
            if (K >= K2)
               %log.ok = log.ok+1;
               break;                         % break loop and go ahead         end
            end
         end
      end
      
      Kval(end+1) = K;                % save also K values
      rseg(1:m,end+1) = root(:);      % save found roots
      
      similar = abs(K2/K1-1);
      if (K >= K2 || similar < 1e-10)
         break;                       % we are done
      end
   end

   logging = setting('logging');
   logging{end+1} = log;
   setting('logging',logging);
   
   %profiler('locus',0);
   return
   
      
%==========================================================================   
% Old Locus of roots (calculate a segment)
%==========================================================================

function [rseg,Kval] = oldlocus(p,q,Kmin,Kmax,dist,recursion,rootmin,rootmax)
%
% LOCUS     Calculate a root locus segment for given limits [Kmin,Kmax]
%           Keep distance of roots on a path between values dist and dist/2
%
%  profiler('locus',1);
   p = [zeros(1,length(q)-length(p)), p];       % adopt dimension

   if (nargin < 6)
      recursion = 1;
   end
   
   if (isinf(Kmin))
      Kmin = 1e10*sign(Kmin);
   end

   if (isinf(Kmax))
      Kmax = 1e10*sign(Kmin);
   end

   if (Kmin == 0)
      Kmin = 1e-20;
   end

   if (Kmax == 0)
      Kmax = -1e-20;
   end
   
   if (sign(Kmin) ~= sign(Kmax))
      error('bug: cannot proceed with change of signs!');
   end
   sgn = sign(Kmin);
   
      % calculate roots at the boundaries

   if (nargin < 7)
      rootmin = calcroots(Kmin*p+q);
   end

   if (nargin < 8)
      [rootmax,delta] = rootsort(rootmin,calcroots(Kmax*p+q));
   else
      delta = abs(rootmax-rootmin);
   end
      
   diffmax = max(delta);
   N = ceil(diffmax/dist) + 3;
   if (N > 50)
      N = 50;  shg;
   end
   m = length(q)-1;
   
   if (sgn >= 0)
      Klog = log([Kmin,Kmax]);
   else
      Klog = log([-Kmax,-Kmin]);
   end
   Kspace = sgn*exp(Klog(1):(Klog(2)-Klog(1))/N:Klog(2));
   Kspace = sort(Kspace);
  
   %root = rootmin;
   
   root = calcroots(Kspace(1)*p+q);
   for (k=1:length(Kspace))
      K = Kspace(k);  
      poly = K*p + q;
      rootp = calcroots(poly);

      delta = abs(root(:)-rootp(:));
      if (any(delta > dist))
         [root,delta] = rootsort(root,rootp);
      else
         root = rootp;
      end

      Kval(k) = K;                % save also K values
      rseg(1:m,k) = root(:);

      if (k > 1 && any(delta > dist) && recursion < 3)
         if (recursion >= 4)
            fprintf('recursion %g: delta = %g, K = %g\n',recursion,max(delta),K);
            'debug';
         end
         [rsegx,Kvalx] = locus(p,q,Kval(k-1),Kval(k),dist,recursion+1,rseg(:,k-1),rseg(:,k));
         [mx,nx] = size(rsegx);
         rseg(:,end:end+nx-1) = rsegx;
         Kval(end:end+nx-1) = Kvalx;
      end
   end
   
   %profiler('locus',0);
   return
      
%==========================================================================
% Plot Marker
%==========================================================================

function marker(z,mark,d,col,width,aspect)
%
% MARKER     Plot a marker at a given complex number
%
%                   plot([-1+i;-1-i],'x',diameter,'k',2);   % pole
%                   plot([-1+i;-1-i],'O',diameter,'k',2);   % zero
%                   plot([-1+i;-1-i],'#',diameter,'r',2);   % diamond

   if (nargin < 4)  col = 'k'; end
   if (nargin < 5)  width = 3; end
   
   rx = d/2/aspect;  ry = d/2;
   
   switch mark
      case 'x'                   % pole
         for (i=1:length(z))
            x = real(z(i));  y = imag(z(i));
            color(plot(x,y,'kx'),col);  hold on;
         end
      case 'o'                   % zero
         for (i=1:length(z))
            x = real(z(i));  y = imag(z(i));
            color(plot(x,y,'ko'),col);  hold on;
         end
      case '#'                   % diamond
         for (i=1:length(z))
            x = real(z(i));  y = imag(z(i));
            color(plot(x,y,'kd'),col);  hold on;
         end
      case 'X'                   % pole
         for (i=1:length(z))
            x = real(z(i));  y = imag(z(i));
            color(plot([x-rx x+rx],[y+ry,y-ry]),col,width);  hold on;
            color(plot([x-rx x+rx],[y-ry,y+ry]),col,width);
         end
      case 'O'                   % zero
         for (i=1:length(z))
            x = real(z(i));  y = imag(z(i));
            phi = 0:pi/20:2*pi;
            color(plot(x+rx*cos(phi),y+ry*sin(phi)),col,width);  hold on;
         end
      case 'D'                   % diamond
         rx = ry*1.5/aspect;
         for (i=1:length(z))
            x = real(z(i));  y = imag(z(i));
            color(plot([x x-rx x x+rx x],[y+ry,y y-ry, y, y+ry]),col,width);
            hold on;
         end
   end
   return

%==========================================================================
% Root Sort
%==========================================================================

function [zs,delta] = rootsort(z0,z)
%
% ROOTSORT      Sort root vector in alignment with existing root vector z0
%               and calculate the delta between according roots
%
   n = length(z);
   if (length(z0) ~= n)
      error('root vectors must be of same dimension!');
   end
   
   for (i=1:n)     % walk through all roots of z0
      z0i = z0(i);
      absdz = abs(z0i-z); 
      minabsdz = min(absdz);
      idx = find(minabsdz == absdz);
      idx = idx(1);                     % need only 1
      zs(i) = z(idx);
      delta(i) = minabsdz;
      z(idx) = [];                      % remove root
   end
   return
   
%eof   