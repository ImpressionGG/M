function [K0,f0] = critical(o)
%
%  CRITICAL   Calculate or plot critical stability parameters K0 (critical
%             open loop gain) and f0 (critical frequency)
%
%                critical(o)           % plot critical stability parameters
%                [K0,f0] = critical(o) % calculate K0,f0
%
%             Options:
%                gain.low              % minimum gain (default: 1e-3)
%                gain.high             % maximum gain (default: 1e+3)
%                gain.points           % number of gain points
%
%             Copyright(c): Bluenetics 2021
%
%             See also: MINISPM, CONTACT
%
   if type(o,{'spm'})
      o = cache(o,o,'multi');          % refresh multi segment
   else
      error('SPM object expected');
   end
   
   if (nargout == 0)
      Plot(o);          
   else
      [K0,f0] = Calc(o);               % calculate
   end
end

%==========================================================================
% Calculate
%==========================================================================

function [K0,f0] = Calc(o)
   [oo,L0,K0,f0] = contact(o);
end

%==========================================================================
% Calculate
%==========================================================================

function Plot(o)
   subplot(o,312);
   message(o,'Calculation of Critical Quantities',...
             {'see figure bar for progress...'});
   idle(o);
   
      % we need a system according to contact specification, time
      % normalization and coordinate transformation. All these aspects
      % are implemented by contact method, which returns the required
      % system
   
   [oo,L0] = contact(o);
   [K0,f0] = cook(o,'K0,f0');
   [A,B_1,B_3,C_3,T0]=var(oo,'A,B_1,B_3,C_3,T0');
   m = size(C_3,1);
   multi = (m > 1);                 % multi contact
   
   [K0_,f0_] = PlotStability(o,L0,3111);
   if stop(o)
      return
   end
   if isequal(K0_,inf)
      set(gca,'ylim',[-5 5]);
      subplot(o,312);
      message(o,'No instabilities - skip frequency analysis!');
      return
   end
      
   olo = opt(o,{'omega.low',100});
   ohi = opt(o,{'omega.high',1e5});
   points = opt(o,{'omega.points',2000});

   om = logspace(log10(olo),log10(ohi),points);
   Om = om*T0;                      % time normalized omega
   f = om/2/pi;                     % frequency range
   
   L0jw = zeros(m,length(om));  G31jw = L0jw;  G33jw = L0jw; 

      % calculate G31(jw), G33(jw) and L0(jw)

   i123 = (1:m)';
   kmax = length(om);
   
   for(k=1:kmax)
      if (rem(k-1,50)==0)
         progress(o,'frequency response calculation',k/kmax*100);
      end
      
      [L0jw(:,k),G31jw(:,k),G33jw(:,k)] = Lambda(o,A,B_1,B_3,C_3,Om(k));
      
         % re-arrange
         
      if (k > 1)
         [~,idx] = TailSort(L0jw(:,k-1:k),om(k));
         L0jw(:,k) = L0jw(idx,k);
      end
   end
   progress(o);
   
      % calculate phases phi31,phi33 and phi=phi31-phi33

   phi = angle(L0jw);
   phi = mod(phi,2*pi) - 2*pi;           % map into interval -2*pi ... 0

      % calculate critical frequency response
      
   [L0jw0,G31jw0,G33jw0] = Lambda(o,A,B_1,B_3,C_3,2*pi*f0*T0);
   phi0 = mod(angle(L0jw0),2*pi) - 2*pi;
   
      % search characteristic frequency response with best matching
      % |N(jw)| = |1+K0*L0[k](jw0) = 1
      
   M = abs(1 + K0*L0jw0);              % magnitude of Nyquist FQR
   nyqerr = min(M);                    % Nyquist error
   
      % now find index k0 that approximates 1 + K0*L0jw =~= 0
      
   idx = min(find(f>=f0));
   M = abs(1 + K0*L0jw(:,idx));
   aprerr = min(M);                    % approximate Nyquist error
   k0 = min(find(M==aprerr));          % indexing critical characteristics        
   l0jw = L0jw(k0,:);                  % critical characteristics 
   
   BodePlot(o,3121,3131);              % plot intermediate results
   
   M31 = abs(G31jw0(k0));              % coupling gain
   phi31 = angle(G31jw0(k0));          % coupling phase      

   M33 = abs(G33jw0(k0));              % direct gain
   phi33 = angle(G33jw0(k0));          % direkt phase      

   ML0 = abs(L0jw0(k0));               % critical gain
   phi0 = angle(L0jw0(k0));            % critical phase      
      
   Results(o,3121,3131);               % display results
      
   heading(o);
   
   function BodePlot(o,sub1,sub2)
      subplot(o,sub1,'semilogx');
      set(gca,'visible','on');
      
         % magnitude plot
        
      if dark(o)
         colors = {'rk','gk','bk','ck','mk'};
      else
         colors = {'rwww','gwww','bwww','cwww','mwww'};
      end
      
      for (ii=1:size(L0jw,1))
         col = colors{1+rem(ii-1,length(colors))};
         plot(o,om,20*log10(abs(L0jw(ii,:))),col);
      end
      plot(o,om,20*log10(abs(l0jw)),'ryyy2');
      plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'K1-.');
      plot(o,2*pi*f0,-20*log10(K0),'K1o');

      title(sprintf('L0(s)=G31(s)/G33(s): Magnitude Plots (K0: %g @ %g Hz)',...
                    K0,f0));
      xlabel('Omega [1/s]');
      ylabel('|L0[k](jw)| [dB]');
      subplot(o);

         % phase plot
         
      subplot(o,sub2,'semilogx');
      set(gca,'visible','on');

      plot(o,om,0*f-180,'K');
      for (ii=1:size(L0jw,1))
         col = colors{1+rem(ii-1,length(colors))};
         plot(o,om,phi(ii,:)*180/pi,col);
      end
      
      phil0 = mod(angle(l0jw),2*pi)-2*pi;
      plot(o,om,phil0*180/pi,'yyyr2');
      set(gca,'ytick',-360:45:0);

      plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'K1-.');
      plot(o,2*pi*f0,-180,'K1o');
      
      subplot(o);  idle(o);  % give time to refresh graphics
      xlabel('Omega [1/s]');
      ylabel('L0[k](jw): Phase [deg]');
   end
   function Results(o,sub1,sub2)
      err = norm([K0-K0_,f0-f0_]);
      subplot(o,sub1);
      title(sprintf(['L(s) = G31(s)/G33(s): Magnitude Plot - K0: ',...
                     '%g @ %g Hz (Eigenvalue error: %g)'],K0_,f0_,err));

      txt = sprintf('G31(jw): %g um/N @ %g deg, G33(jw): %g um/N @ %g deg',...
             M31*1e6,phi31*180/pi, M33*1e6,phi33*180/pi);
      xlabel(txt);
      subplot(o);
      
      subplot(o,sub2);
      title(sprintf('L(s) = G31(s)/G33(s): Phase Plot (Nyquist error: %g)',nyqerr));
      plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'r1-.');
      plot(o,2*pi*f0*[1 1],get(gca,'ylim'),'K1-.');
      subplot(o);
   end
end

%==========================================================================
% Frequency Response
%==========================================================================

function [L0jw,G31jw,G33jw] = Lambda(o,A,B_1,B_3,C_3,om) % Lambda FQR's
   n = length(om);
   for (k=1:n)
      jw = 1i*om(k);
      I=eye(size(A));                     % unit matrix
      Phi = inv(jw*I-A);
      G31jw = C_3*Phi*B_1;
      G33jw = C_3*Phi*B_3;
      L0jw = G33jw\G31jw;

         % in multi contact case replace:
         % - G31jw by 'largest' eigenvalue of G31jw
         % - G33jw by 'smallest' eigenvalue of G33jw
         % - L0jw  by 'largest' eigenvalue  of L0jw

      m = length(L0jw);                        % number of contacts
      if (m > 1)                               % multi contact
         s31 = eig(G31jw);                     % eigenvalues (EV) of G31(jwk)
         [~,idx] = sort(abs(s31),'descend');   % get sorting indices
         G31jw = s31(idx);                     % pick 'largest' eigenvalues

         s33 = eig(G33jw);                     % eigenvalues (EV) of G33(jwk)
         [~,idx] = sort(abs(s33),'ascend');    % get sorting indices
         G33jw = s33(idx);                     % pick 'smallest' eigenvalues

         s0 = eig(L0jw);                       % eigenvalues of L0(jwk) 
         [~ ,idx] = sort(abs(s0),'descend');   % sort EV's by magnitude
         L0jw = s0(idx);                       % pick 'largest' eigenvalues
      end
   end
   
   if (n > 1)
      L0jw = Rearrange(L0jw);
   end
end
function L = Rearrange(L)              % Rearrange FQR (obsolete)      
%
% REARRANGE   Rearrange characteristic frequency responses in order to
%             obtain smooth graphs.
%
   [m,n] = size(L);
   if (n <= 1)
      return                           % nothing to re-arrange
   end
   
   one = ones(m,1);
   void = one*inf;
   
   for (k=2:n)
      x = L(:,k-1);  y = L(:,k);
      M = abs(y*one' - one*x.');       % magnitude change matrix

      px = angle(x);  py = angle(y);
      P = py*one' - one*px.';          % phase difference matrix
      P = abs(mod(P+pi,2*pi) - pi);    % phase change matrix, maps to [0,pi]

      % D matrix (deviations) is be a mix of magnitude changes M and
      % phase changes P
      
      D = M/norm(M) + P/norm(P);       % mix them together
      
      idx = void;
      for (l=1:m)
         row = min(D);
         j = min(find(row==min(row))); % target index
         col = D(:,j);
         i = min(find(col==min(col))); % source index
         
            % note: i-th element moves to j-th position
            
         idx(j) = i;                   % ith index equals j
         D(i,:) = void';               % ith row out of game
         D(:,j) = void;                % jth column out of game
         
       end
       L(:,k) = L(idx,k);
   end
end
function [L,idx] = TailSort(L,om)      % Sort Tail of FQR              
%
% TAILSORT    Rearrange characteristic frequency responses in order to
%             obtain smooth graphs.
%
   [m,n] = size(L);
   if (n <= 1)
      idx = (1:m)';
      return                        % nothing to sort
   end
   
   one = ones(m,1);
   void = one*inf;
   
   x = L(:,end-1);  y = L(:,end);
   M = abs(y*one' - one*x.');       % magnitude change matrix
   
   px = angle(x);  py = angle(y);
   P = py*one' - one*px.';          % phase difference matrix
   P = abs(mod(P+pi,2*pi) - pi);    % phase change matrix, maps to [0,pi]
   
      % D matrix (deviations) is be a mix of magnitude changes M and
      % phase changes P
      
   D = M/norm(M) + P/norm(P);       % mix them together
   
   idx = void;
   for (l=1:m)
      row = min(D);
      j = min(find(row==min(row))); % target index
      col = D(:,j);
      i = min(find(col==min(col))); % source index

         % note: i-th element moves to j-th position

      idx(j) = i;                   % ith index equals j
      D(i,:) = void';               % ith row out of game
      D(:,j) = void;                % jth column out of game
    end
    L(:,end) = L(idx,end);
end

%==========================================================================
% Helper
%==========================================================================

function [K0,f0] = PlotStability(o,L0,sub)  % Stability Chart          
   K0 = nan;  f0 = nan;
   subplot(o,sub,'semilogx');

   low  = opt(o,{'gain.low',1e-3});
   high = opt(o,{'gain.high',1e3});
   points = opt(o,{'gain.points',200});
   
   closeup = opt(o,{'stability.closeup',0});
   if (closeup)
      K0 = cook(o,'K0');
      low = K0/(1+closeup);
      high = K0*(1+closeup);
   end
   
   K = logspace(log10(low),log10(high),points);

      % get L0 system matrices

   [~,ridx] = sort(randn(1,length(K)));
   
   s = 0*K;
   stop(o,'Enable');
   steps = 10;
   for (i=1:steps)
      kdx = i:steps:length(K);
      Ki = K(ridx(kdx));
      si = CritEig(o,L0,Ki);
      s(ridx(kdx)) = si;

         % plot K for stable EV in green and unstable in red

      idx = find(real(si)<0);
      if ~isempty(idx)
         plot(o,Ki(idx),-real(si(idx))*100,'g.');
      end
      idx = find(real(si)>=0);
      if ~isempty(idx)
         plot(o,Ki(idx),-real(si(idx))*100,'r.');
      end
      idle(o);                         % give time for graphics refresh
      if stop(o)
         return;
      end
   end
   stop(o,'Disable');
   
   [K0,f0] = Stable(o,L0,K,s);
   if ~isequal(K0,inf)
      plot(o,[K0 K0],get(gca,'ylim'),o.iif(K0<=1,'r1-.','g1-.'));
   end
   
   xlim = get(gca,'xlim');             % save x-limits
   plot(o,[1 1],get(gca,'ylim'),'K1-.');
   set(gca,'xlim',xlim);               % restore x-limits
   
   title(sprintf('Worst Damping (K0: %g @ f0: %g Hz)',K0,f0));
   xlabel('closed loop gain K');
   ylabel('worst damping [%]');
end
function [K0,f0] = Stable(o,L0,K,s)    % Calc Stability Margin         
%
% STABLE  Calculate critical K0 and frequency f0 for open loop system L0
%         by interval search. K and s are auxillary data for quick
%         estimation of an initial interval.
%
%            [K0,f0] = Stable(o,L0,K,s)
%
   if (nargin < 3)
      low  = opt(o,{'gain.low',1e-3});
      high = opt(o,{'gain.high',1e3});
      points = opt(o,{'points',200});
      search = opt(o,{'search',points});
      K = logspace(log10(low),log10(high),search);
   end
   
   if (nargin < 4)
      s = CritEig(o,L0,K);
   end
   
   Klim = Initial(o,L0,K,s);
   if isequal(Klim,inf)
      K0 = inf;  f0 = 0;
      return
   end
   
   s = CritEig(o,L0,Klim);
   if (real(s(1))>= 0 || real(s(2)) < 0)
      error('bad initial data, cannot proceed');
   end
   
   if isequal(Klim,inf)
      K0 = inf;  f0 = 0;
      return
   elseif isequal(Klim,0)
      K0 = 0;  f0 = 0;
      return
   end

      % interval search

   [A0,B0,C0,D0,scale] = data(L0,'A,B,C,D,scale');

   kmax = length(K);
   for (k=1:100)
      if (rem(k-1,10)==0)
         progress(o,'interval search of K0',k);
      end
      
      K0 = mean(Klim);

         % calculate closed loop dynamic matrix

      Ak = A0 - B0*inv(eye(size(D0))+K0*D0)*K0*C0;  % closed loop A

         % find eigenvalue with largest real part

      sk = eig(Ak);
      re = real(sk);
      idx = find(re==max(re));
      s = sk(idx(1));
      f0 = imag(s)/(2*pi)/scale;
      
         % terminate?
         
      err = abs(real(s));
      if (err < 1e-10)
         break;
      end
      
         % closeup
         
      if (real(s) > 0)
         Klim(2) = K0;
      elseif (real(s) < 0)
         Klim(1) = K0;
      else
         break;
      end
   end
   progress(o);                     % done   
      
   function Klim = Initial(o,L0,K,s)
      idx = find(real(s)>=0);
      if isempty(idx)
         Klim = inf;
      elseif (idx(1) == 1)
         Klim = 0;
      else
         Klim = [K(idx(1)-1), K(idx(1))];
      end
   end
end
function s = CritEig(o,L0,K)           % Find critical Eigenvalues     
   [A0,B0,C0,D0] = data(L0,'A,B,C,D');

   kmax = length(K);
   for (k=1:length(K))
      if (rem(k-1,10) == 0)
         progress(o,sprintf('%g of %g: critical eigenvalues',k,kmax),k/kmax*100);
      end

      Kk = K(k);

         % calculate closed loop dynamic matrix

      Ak = A0 - B0*inv(eye(size(D0))+Kk*D0)*Kk*C0;  % closed loop A

         % find eigenvalue with largest real part

      sk = eig(Ak);
      re = real(sk);
      idx = find(re==max(re));
      s(k) = sk(idx(1));
   end
   progress(o);                     % done
end
