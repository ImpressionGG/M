function [v,s,a] = velocity(o,a,t,sym)          
%
% VELOCITY  Calculate velocity and elongation for given acceleration
%
%              [v,s,a] = velocity(o,a,t)    % calculate 
%              velocity(o,a,t,sym)          % show
%              
%           Units:
%              v: [mm/s]
%              s: [um]
%              a: [g]
%
%           options:
%              coordinate: opt(o,'coordinate','X'): used as title suffix
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CUTE, COOK, BREW, CROWD
%
   if (nargin < 4)
      sym = '';
   end
   
   mode = opt(o,{'vfilter.type','LowPass2'});
   
   switch mode
      case {'Order2','Order4'}
         if (nargout == 0)
            LowHighPass(o,a,t,sym);
         else
            [v,s,a] = LowHighPass(o,a,t);
         end
         
         % some legacy stuff 
         
      case {'order3','comb'}
         assert(o);                    % not supported so far
         if (nargout == 0)
            Filtering(o,a,t);
         else
            [vout,sout,aout,Vout,Sout,Aout,bias] = Filtering(o,a,t);
         end
      case {'LowPass2','LowPass4'}
         assert(o);                    % not supported so far
         if (nargout == 0)
            LowPass(o,a,t);
         else
            [vout,sout,aout,Vout,Sout,Aout,bias] = LowPass(o,a,t);
         end
      case {'HighPass2','HighPass4'}
         assert(o);                    % not supported so far
         if (nargout == 0)
            LowPass(o,a,t);
         else
            [vout,sout,aout,Vout,Sout,Aout,bias] = LowPass(o,a,t);
         end
      case 'parabolic'
         assert(o);                    % not supported so far
         if (nargout == 0)
            Debiasing(o,a,t);
         else
            [vout,sout,aout,Vout,Sout,Aout,bias] = Debiasing(o,a,t);
         end
      otherwise
         error('bad mode!');
   end
end

%==========================================================================
% Helpers
%==========================================================================

function y = OldFilter(o,Fs,x,t)                                       
   x = x(:)';  t = t(:)';
   yf = x(1) + rsp(Fs,x-x(1),t-t(1));      % forward filter
   
   idx = length(x):-1:1;
   
      % x has a parabolic trend, thus both first and second derivative
      % have an offset at max time. We can compensate for that if we first
      % subtract yf, reverse filter, reverse and add yf again at the end
      
   xd = x - yf;                               % subtract yf *)
   xr = xd(idx);                              % reverse input
   yr = xr(1) + rsp(Fs,xr-xr(1),t-t(1));      % reverse response
   yr = yr(idx);                              % reverse filter
   yr = yr + yf;                              % add yf - see *)
   
   y = (yf+yr)/2;
end
function y = Comb(o,window,x,t)           % Comb Filter                
   y = 0*x;
   delta = ceil(window/2);
   n = length(x);
   
   if (window == 1)
      y = x;
      return
   end
   
   for (i=1:n)
      i0 = max(i-delta,1);
      i1 = min(i+delta,n);
      y(i) = mean(x(i0:i1));
   end
end
function [s,v,a] = OldIntegration(o,a,t)                               
%
% INTEGRATION  
%        Integrate velocity and elongation following the differential 
%        equations:
%
%           dv/dt = a(t)       (v(1) = 0)
%           ds/dt = v(t)       (s(1) = 0) 
%
%        In order to perform the integration, if we are at stage t(i)
%        we basically want to proceed to t(i+1) = t(i) + dt. Under assump-
%        tion of trapezoidal integration (not used here) we would calculate:
%
%           v(i+1) = v(i) + [a(i)+a(i+1)]/2 * dt
%           s(i+1) = s(i) + [v(i)+v(i+1)]/2 * dt
%
%        Instead we are applying Heun's integration algorithm. This uses a
%        projected derivation which is estimated at tp = t(i) + dt/2, thus  
%
%           ap = [a(i)+a(i+1)] / 2
%           vp = v(i) + [a(i)+ap]/2 * dt/2
%           sp = s(i) + [v(i)+vp]/2 * dt/2
%
%        then in contrast to trapezoidal integration we progress from t(i)
%        to t(i+1) by calculating
%
%           v(i+1) = v(i) + ap * dt
%           s(i+1) = s(i) + vp * dt
%
   t = t(:)';
   a = a(:)'*9.81;             % convert from g to m/s2
   
   if any(size(t)~=size(a))
      error('sizes of a and t do not match!');
   end

   N = length(t);
   v = 0;  s = 0;
   
   for (i=1:N-1)
      ti = t(i);
      dt = t(i+1) - t(i);
      tp = ti + dt/2;                  % intermediate (projected) time

      ap = [a(i)+a(i+1)] / 2;
      vp = v(i) + [a(i)+ap]/2 * dt/2;  % projected velocity
      sp = s(i) + [v(i)+vp]/2 * dt/2;  % projected elongation
      
      v(1,i+1) = v(i) + ap * dt;
      s(1,i+1) = s(i) + vp * dt;
   end
end

%==========================================================================
% Low/High Pass Filtering
%==========================================================================

function [v,s,a] = LowHighPass(o,a_,t,sym)        
   show = (nargout == 0);              % show mode

   oo = opt(with(o,'vfilter'),'mode','filter');
   oi = opt(o,'type','Integrator');
   
      % integration of acceleration a_ to get velocity v_, 
      % and integration of v_ to get elongation s_
      % note: previously we used: [s_,v_] = Integration(o,a_,t);
   
   v_ = filter(oi,a_,t);
   s_ = filter(oi,v_,t);

      % both v_ and s_ are biased. To remove bias we use a combination
      % of a high pass filter and low pass filter.
     
   switch opt(oo,{'vfilter.type','Order2'})
      case 'Order2'
         HP = opt(oo,'type','HighPass2');
         LP = opt(oo,'type','LowPass2');
      case 'Order4'
         HP = opt(oo,'type','HighPass4');
         LP = opt(oo,'type','LowPass4');
      otherwise
         error('bad filter type');
   end
   
      % filter method  ...
      % 1) build    sf = HP*s_    (filtered signal, still biased with s0)
      % 2) build    s0 = LP*sf    (reconstruct bias signal s0)
      % 3) finally  s  = sf - s0  (eliminate bias s0 from filtered sf)
      
   sf = filter(HP,s_,t);               % high pass filtered s_
   s0 = filter(LP,sf,t);               % reconstruct bias signal s0
   s = sf - s0;                        % eliminate bias from filtered sig
   
      % finally reconstruct velocity and acceleration from elongation
      % by two times differentiation
      
   dt = mean(diff(t));
   v = [diff(s),diff(s(end-1:end))]/dt;% matched velocity
   a = [0, diff(v)/dt];                % matched acceleration
 
      % zero signals
      
   n = 1000;                            % 100 points at the end to scrap
   
   s(1:10) = zeros(1,10);   s(1+end-n:end) = zeros(1,n);
   v(1:10) = zeros(1,10);   v(1+end-n:end) = zeros(1,n);
   a(1:10) = zeros(1,10);   a(1+end-n:end) = zeros(1,n);
   
   
      % scale raw signals
      
   s_ = s_ * 1e6;                      % elongation [um]
   v_ = v_ * 1000;                     % velocity [m/s]
   a_ = a_ / 9.81;                     % acceleration [g]

      % scale matched/filtered signals
      
   s = s * 1e6;                        % elongation [um]
   v = v * 1000;                       % velocity [m/s]
   a = a / 9.81;                       % acceleration [g]

   Show(o);  
   return   
   
   function Show(o)                    % Show, Part 1                          
      if (show)
         ch = o.iif(length(sym)>=2,sym(2),'');
         
         uscore = util(o,'uscore');    % short hand
         %cls(o,'hold');
         
            % plot original and reconstructed acceleration
            
         subplot(o,[4 3 1]);
         plot(o,t,a_,'rrk');
         title('Raw Acceleration');
         ylabel(uscore(['a',ch,'_ [g]']));
         grid(o);

         subplot(o,[4 3 4]);
         plot(o,t,a,'r');
         title('Matched Acceleration');
         ylabel(uscore(['a',ch,' [g]']));
         grid(o);
         
            % plot integrated and reconstructed velocity
            
         subplot(o,[4 3 2]);
         plot(o,t,v_,'bck');
         title('Raw Velocity');
         ylabel(uscore(['v',ch,'_ [mm/s]']));
         grid(o);

         subplot(o,[4 3 5]);
         plot(o,t,v,'bc');
         title('Matched Velocity');
         ylabel(uscore(['v',ch,' [mm/s]']));
         grid(o);
    
            % plot integrated and filtered elongation
            
         subplot(o,[4 3 3]);
         plot(o,t,s_,'gk');
         title('Raw Elongation');
         ylabel(uscore(['s',ch,'_ [um]']));
         grid(o);

         subplot(o,[4 3 6]);
         plot(o,t,s,'g');
         title('Filtered Elongation');
         ylabel(uscore(['s',ch,' [um]']));
         grid(o);
         
            % compare raw acceleration a_ to reconstructed acceleration a
            % which is consistent with twice differentiated elongation s

         subplot(o,[2 1 2]);
         plot(o,t,a_,'r');
         hold on
         plot(o,t,a,o.iif(dark(o),'w.','k.'));
         ylabel([sym,' [g]']);
         grid(o);
         %set(gca,'Xlim',[19.53 19.55]);
         
            % calculate approximation quality
            
         n = 1000;                     % number of segments to check
         m = floor(length(t)/n);
         
         A_ = reshape(a_(1:m*n),m,n);
         A  = reshape(a(1:m*n),m,n);
         
         rms_ = sqrt(sum(A_.*A_));
         rms  = sqrt(sum(A.*A));
         e = abs(rms-rms_);
         
            % calculate approximation error
            
         err = sqrt(e*e'/length(e));
         title(sprintf('Approximation error: %g',err));
         
         dark(o);
         closeup(arg(o,{}));
      end
   end
end

%==========================================================================
% Filtering / Debiasing
%==========================================================================

function [vout,sout,aout,Vout,Sout,Aout,bias] = HighPass(o,a,t)        
   [s,v,a] = Integration(o,a,t);

   window = opt(o,{'analyse.filter.kind',1});
   f = opt(o,{'analyse.filter.bandwidth',100});
   T = 1/(2*pi*f);

   mode = opt(o,{'analyse.filter.type','order3'});
   switch mode         
      case 'order4'
         HP4 = trf(T^4,{0,0,0,0},{[1/T 0.6],[1/T 0.6]});
         HP4 = can(HP4);
         TP4 = trf(1,{},{[1/T 0.6],[1/T 0.6]});
         TP4 = can(TP4);
      case 'order4hp'
         HP4 = trf(T^4,{0,0,0,0},{[1/T 0.6],[1/T 0.6]});
         HP4 = can(HP4);
         TP4 = trf(1,1);
         TP4 = can(TP4);
      otherwise
         error('bad filter mode for high pass');
   end
   
   sf = rsp(HP4,s,t);
   s0 = rsp(TP4,sf,t);
   sf = sf - s0;
   
   vf = rsp(HP4,v,t);
   af = rsp(HP4,a,t);
   
      % scale signals
      
   s = s*1e6;                          % elongation [um]
   v = v*1000;                         % velocity [m/s]
   a = a/9.81;                         % acceleration [g]

   sf = sf*1e6;
   vf = vf*1000;
   af = af/9.81;
   
   if (nargout == 0)
      Plot(o,t,af,vf,sf,-af+a,-vf+v,-sf+s);
   else                        % convert column vectors back to row vectors
      sout = sf';              % elongation & elongation bias function
      vout = vf';              % velocity & velocoty bias function
      aout = af';              % acceleration & acceleration bias function
      
      Sout = s'-sf';           % elongation & elongation bias function
      Vout = v'-vf';           % velocity & velocoty bias function
      Aout = a'-af';           % acceleration & acceleration bias function
      
      bias = [0,0,0];
   end
end
function [vout,sout,aout,Vout,Sout,Aout,bias] = Filtering(o,a,t)       
   [s,v,a] = Integration(o,a,t);

   window = opt(o,{'analyse.filter.kind',1});
   f = opt(o,{'analyse.filter.bandwidth',100});
   T = 1/(2*pi*f);

   mode = opt(o,{'analyse.filter.type','order3'});
   oo = corasim;
   switch mode
      case 'order3'
         Ss = trf(oo,[1],[T*T*T 3*T*T 3*T 1]);
         Vs = trf(oo,[1 0],[T*T*T 3*T*T 3*T 1]);
         As = trf(oo,[1 0 0],[T*T*T 3*T*T 3*T 1]);
         
         q = [1 2*0.6/T 1/T^2];
         %Fs = trf(oo,T^4,{0, 0},{[1/T 0.6],[1/T 0.6]});
         Fs = trf(oo,[1 0 0],conv(q,q));
         
      case 'order4'
         q1 = [1 2*0.7/T  1/T^2];
         q2 = [1 2*0.5/T  1/T^2];
         %Ss = trf(1,{},{[1/T,0.7],[1/T,0.5]});
         Ss = trf(oo,1,conv(q1,q2));
         %Vs = trf(1,{0},{[1/T,0.7],[1/T,0.5]});
         Vs = trf(oo,1,conv(q1,q2));
         %As = trf(1,{0,0},{[1/T,0.7],[1/T,0.5]});
         As = trf(oo,1,conv(q1,q2));
   end
   
   if isequal(mode,'comb')
      sf = Comb(o,window,s,t);
      vf = Comb(o,window,v,t);
      af = Comb(o,window,a,t);
   else
      sf = Filter(o,Ss,s,t);
      vf = Filter(o,Ss,v,t);
      af = Filter(o,Ss,a,t);
   end
   
      % scale signals
      
   s = s*1e6;                          % elongation [um]
   v = v*1000;                         % velocity [m/s]
   a = a/9.81;                         % acceleration [g]

   sf = sf*1e6;
   vf = vf*1000;
   af = af/9.81;
   
   if (nargout == 0)
      Plot(o,t,a-af,v-vf,s-sf,af,vf,sf);
   else                        % convert column vectors back to row vectors
      sout = s-sf;             % elongation & elongation bias function
      vout = v-vf;             % velocity & velocoty bias function
      aout = a-af;             % acceleration & acceleration bias function
      
      Sout = sf;               % elongation & elongation bias function
      Vout = vf;               % velocity & velocoty bias function
      Aout = af;               % acceleration & acceleration bias function
      
      bias = [0,0,0];
   end
end
function [vout,sout,aout,Vout,Sout,Aout,bias] = Debiasing(o,a,t)       

   t = t(:);
   a = a*9.81;    a = a(:);            % convert from g to m/s2
   
   if any(size(t)~=size(a))
      error('sizes of a and t do not match!');
   end
   
   N = length(t);
   v = 0;  s = 0;
   
      % integrate velocity and elongation following the differential 
      % equations:
      %
      %    dv/dt = a(t)       (v(1) = 0)
      %    ds/dt = v(t)       (s(1) = 0) 
      %
      % In order to perform the integration, if we are at stage t(i)
      % we basically want to proceed to t(i+1) = t(i) + dt. Under assump-
      % tion of trapezoidal integration (not used here) we would calculate:
      %
      %    v(i+1) = v(i) + [a(i)+a(i+1)]/2 * dt
      %    s(i+1) = s(i) + [v(i)+v(i+1)]/2 * dt
      %
      % Instead we are applying Heun's integration algorithm. This uses a
      % projected derivation which is estimated at tp = t(i) + dt/2, thus  
      %
      %    ap = [a(i)+a(i+1)] / 2
      %    vp = v(i) + [a(i)+ap]/2 * dt/2
      %    sp = s(i) + [v(i)+vp]/2 * dt/2
      %
      % then in contrast to trapezoidal integration we progress from t(i)
      % to t(i+1) by calculating
      %
      %    v(i+1) = v(i) + ap * dt
      %    s(i+1) = s(i) + vp * dt
   
   for (i=1:N-1)
      ti = t(i);
      dt = t(i+1) - t(i);
      tp = ti + dt/2;                     % intermediate (projected) time

      ap = [a(i)+a(i+1)] / 2;
      vp = v(i) + [a(i)+ap]/2 * dt/2;     % projected velocity
      sp = s(i) + [v(i)+vp]/2 * dt/2;     % projected elongation
      
      v(i+1,1) = v(i) + ap * dt;
      s(i+1,1) = s(i) + vp * dt;
   end
   
       % remove bias by finding bias curve: 
       % S(t) = p(1) + p(2)*t + p(3)*t^2   (bias function of s(t))
       
       % S(t) = s0 + v0*t + a0/2*t^2   (bias function of s(t))
       % V(t) = v0 + a0*t              (bias function of velocity)
       % A(t) = a0                     (bias function of acceleration)
       
       % To calculate the bias function S(t) = p(1) + p(2)*t + p(3)*t^2
       % we have to find the local minimum of the objective
       %
       %    Q(p) = sum(e(i)*e(i)) -> min
       %    given: e(i) := S(t(i)) - s(i)
       %
       % by partial differentiation:
       %
       %    d{Q}/dp(i) =!= 0
       %
       % Setting:
       %
       %    tk := [t(1)^k, ..., t(n)^k]'
       %    s  := [s(1), ..., s(n)]'
       %
       % we get:
       %
       %    d{}/dp(i) sum_k{[p(1)+p(2)*t(k)+p(3)*t(k)^2-s(k)]^2} =
       %       = sum_k{[p(1)+p(2)*t(k)+p(3)*t(k)^2-s]*t(k)^(i-1)} =!= 0
       %
       % This can be rewritten as:
       %
       %    t0'*t0*p(1) + t0'*t1*p(2) + t0'*t2*p(3) = t0'*s 
       %    t1'*t0*p(1) + t1'*t1*p(2) + t1'*t2*p(3) = t1'*s 
       %    t2'*t0*p(1) + t2'*t1*p(2) + t2'*t2*p(3) = t2'*s 
       %
       % which is a linear equation system that can be solved in a straight
       % forward way.
       
   n = opt(o,{'analyse.filter.kind',50});
   dn = length(t)/n;
   i1 = 0;
   
   for (i=1:n)
      i0 = i1+1;
      i1 = min(ceil(i*dn),length(t));

      idx = (i0:i1);
      tt = t(idx);

      t0 = 0*tt+1;  t1 = tt;  t2 = t1.*tt;  t3 = t2.*tt;  t4 = t3.*tt;

      A = [
             t0'*t0 t0'*t1 t0'*t2
             t1'*t0 t1'*t1 t1'*t2
             t2'*t0 t2'*t1 t2'*t2
          ];
      B = [ t0'*s(idx) t1'*s(idx) t2'*s(idx)]';

         % solution of linear equation: x = [s0 v0 a0/2]

      p = A\B;                            % solve linear equation system
      clear A;

      s0 = p(1);
      v0 = p(2);
      a0 = 2*p(3);

      S(idx,1) = s0*t0 + v0*t1 + a0/2*t2; % bias function of elongation
      V(idx,1) = v0*t0 + a0*t1;           % bias function of velocity
      A(idx,1) = a0*t0;                   % bias function of acceleration

      s(idx,1) = (s(idx)-S(idx));         % elongation [um]
      v(idx,1) = (v(idx)-V(idx));         % velocity [m/s]
      a(idx,1) = (a(idx)-A(idx));         % acceleration [g]
   end
   
      % scale signals
      
   s = s*1e6;                          % elongation [um]
   v = v*1000;                         % velocity [m/s]
   a = a/9.81;                         % acceleration [g]

   S = S*1e6;
   V = V*1000;
   A = A/9.81;
   
      % plot if nargout = 0
      
   if (nargout == 0)
      Plot(o,t,a,v,s,A,V,S);
   else                        % convert column vectors back to row vectors
      sout = s';               % elongation & elongation bias function
      vout = v';               % velocity & velocoty bias function
      aout = a';               % acceleration & acceleration bias function
      
      Sout = S';               % elongation & elongation bias function
      Vout = V';               % velocity & velocoty bias function
      Aout = A';               % acceleration & acceleration bias function
      
      bias = [v0,s0,a0];
   end
end

%==========================================================================
% plot
%==========================================================================

function Plot(o,t,a,v,s,A,V,S)                                         

   cls(o);
   coord = opt(o,{'coordinate',''});  
   
      % acceleration
      
   subplot(221);
   o.color(plot(t,a+A),'r',1);
   hold on;
   o.color(plot(t,a),'r',1);
   o.color(plot(t,A),'k',1);
   title(['Acceleration ',coord]);
   ylabel('a(t) [g]');
   
      % velocity
      
   subplot(222);
   o.color(plot(t,v+V),'b',1);
   hold on;
   o.color(plot(t,v),'b',2);
   o.color(plot(t,V),'k',1);
   title(['Velocity ',coord]);
   ylabel('v(t) [mm/s]');

      % elongation
      
   subplot(223);
   o.color(plot(t,s+S),'g',1);
   hold on;
   o.color(plot(t,s),'g',2);
   o.color(plot(t,S),'k',1);
   title(['Elongation ',coord]);
   ylabel('s(t) [um]');

   subplot(224);
   o.color(plot(t,s),'g',2);
   title(['Bias Free Elongation ',coord]);
   ylabel('s(t) [um]');
end
