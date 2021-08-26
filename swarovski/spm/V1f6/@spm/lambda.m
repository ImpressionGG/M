function [oo,g31,g33] = lambda(o,varargin)  % Spectral FQRs            
%
% LAMBDA  Calculate spectral frequency responses lambda(s) for an open
%         loop system. Result is an mx1 MIMO FQR (frequency response) typed
%         corasim system consisting of m spectral functions which are
%         ordered by highest magnitude.
%
%            o = with(o,'critical');  
%            sys = system(o,cdx);           % contact related system 
%            lambda0 = lambda(o,sys);       % spectral FQRs
%
%            lambda0 = lambda(o);           % implicite call to system(o)
%            l0 = lambda(o,lambda0);        % calculate critical TRF
%
%            sys = system(o,cdx);           % get contact relevant system
%            lambda0 = lambda(o,sys,om);    % calculate spectral FQRs
%
%            [lambda0,g31,g33] = lambda(o,sys,omega);
%
%         The next two calls return the frequency response (not a CORASIM
%         system), which enables efficient calculation in some algorithms
%
%            lambda0jw = lambda(o,A,B_1,B_3,C_3,T0*omega)
%            lambda0jw = lambda(o,PsiW31,PsiW33,T0*omega)
%
%         Calculate critical quantities K0 and f0 for given omega interval
%         [om1,om2] assuming in given omega interval one of the spectral
%         functions has a continuous phase crossing of pi+2*k*pi:
%
%            [K0,f0,lambda0jw] = lambda(o,psiW31,psiW33,om1,om2)
%
%         Theory:
%
%            sys = system(o,cdx)
%            [A,B_1,B_3,C_3,T0] = var(sys,'A,B_1,B_3,C_3,T0')
%            PsiW31 = psion(o,A,B_1,C_3) % to calculate G31(jw)
%            PsiW33 = psion(o,A,B_3,C_3) % to calculate G33(jw)
%
%            Pjw = psion(o,PsiW31,om*T0)
%            Qjw = psion(o,PsiW33,om*T0)
%
%            m = sqrt(size(Pjw,1))
%            for (k=1:size(Pjw,2))
%               Pjwk = reshape(Pjw(:,k),m,m)
%               Qjwk = reshape(Qjw(:,k),m,m)
%               Ljwk = Pjwk\Qjwk;
%               lambda0jw(1:m,k) = Sort(ljw,eig(Ljwk))
%            end
%
%         Example 1:
%
%            sys = system(o,cdx);      % get contact relevant system
%            [l0,g31,g33] = lambda(o,sys,omega);
%            [A,B_1,B_3,C_3,T0] = var(sys,'A,B_1,B_3,C_3,T0')
%            psiW31 = psion(o,A,B_1,C_3,T0) % to calculate G31(jw)
%            psiW33 = psion(o,A,B_3,C_3,T0) % to calculate G33(jw)
%            lambda0jw = lambda(o,psiW31,psiW33,omega)
%            l0jw = lambda(o,lambda0jw);
%
%         Example 2:
%
%            sys = system(o,cdx)
%            [A,B_1,B_3,C_3,T0] = var(sys,'A,B_1,B_3,C_3,T0')
%            lambda0jw = lambda(o,A,B_1,B_3,C_3,T0*omega)
%            l0jw = lambda(o,lambda0jw);
%
%            PsiW31 = psion(o,A,B_1,C_3) % to calculate G31(jw)
%            PsiW33 = psion(o,A,B_3,C_3) % to calculate G33(jw)
%            lambda0jw = lambda(o,PsiW31,PsiW33,T0*omega)
%            l0jw = lambda(o,lambda0jw);
%       
%         Example 3:  find critical gain in interval [om1,om2]
%
%            sys = system(o,cdx);                % contact relevant system
%            [A,B_1,B_3,C_3,T0] = var(sys,'A,B_1,B_3,C_3,T0')
%            psiW31 = psion(o,A,B_1,C_3,T0)      % to calculate G31(jw)
%            psiW33 = psion(o,A,B_3,C_3,T0)      % to calculate G33(jw)
%            [lambda0jw,om0] = lambda(o,psiW31,psiW33,om1,om2)
%            l0jw = lambda(o,lambda0jw);
%
%         Options:
%            process.contact   contact indices (default: inf (all))
%            omega.low         lower omega (default: 100)
%            omega.high        higher omega (default 1e5)
%            omega.points      number of omega points (default 2000)
%            eps               numerical epsilon for zero phase crossing
%                              search (default: 1e-10)
%            iter              number of iterations for zero phase
%                              crossing search (default: 50)
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, SYSTEM, PRINCIPAL, LAMBDA
%
   o.profiler('lambda',1);
   if (nargin == 4)                    % calculate as fast as possible
      PsiW31 = varargin{1};  PsiW33 = varargin{2};  om = varargin{3};  
      oo = Lambda(o,PsiW31,PsiW33,om);
      o.profiler('lambda',0);
      return
   elseif (nargin == 5)                % zero cross search
      PsiW31 = varargin{1};  PsiW33 = varargin{2};  
      om1 = varargin{3};  om2 = varargin{4};  
      [oo,g31,g33] = Critical(o,PsiW31,PsiW33,om1,om2);
      o.profiler('lambda',0);
      return
   end
   
      % otherwise do first some overhead
      
   if (nargin <= 1)
      sys = system(o);
   else
      sys = varargin{1};
   end

      % calculate critical lambda TRF
      
   if (nargin == 2 && isequal(class(sys),'double'))
      oo = CritDouble(sys);
      o.profiler('lambda',0);
      return;
   elseif (nargin == 2 && isequal(class(sys),'corasim') && type(sys,{'fqr'}))
      oo = CritCorasim(sys);
      o.profiler('lambda',0);
      return;
   end
   
   if (nargin < 3)
      olo = opt(o,{'omega.low',100});
      ohi = opt(o,{'omega.high',1e5});
      points = opt(o,{'omega.points',2000});

      om = logspace(log10(olo),log10(ohi),points);
   else
      om = varargin{2};
   end
   
   if (nargin <= 3)
      [A,B_1,B_3,C_3,T0] = var(sys,'A,B_1,B_3,C_3,T0');
   else
      A = varargin{1};  B_1 = varargin{2};  B_3 = varargin{3};
      C_3 = varargin{4}; om = varargin{5};
      T0 = 1;                           % must be compensated by omega
   end
   
   [PsiW31,Idx] = psion(o,A,B_1,C_3);   % to calculate G31(jw)
   [PsiW33,Idx] = psion(o,A,B_3,C_3);   % to calculate G33(jw)

      % alternative way to calculate G31(jw)
      
%  [Psi0W31,Idx] = psion(o,A,B_1,C_3,T0); % to calculate G31(jw)
%  [Psi0W33,Idx] = psion(o,A,B_3,C_3,T0); % to calculate G33(jw)
   
   om = om(:)';
   Om = om * T0;                        % time normalize
%  ljw = Lambda(o,PsiW31,PsiW33,Om);

      % for nargin >= 4 we are done
      
   m = size(B_1,2);  

   if (nargin >= 4)
      ljw = Lambda(o,PsiW31,PsiW33,Om);

%alternative way to calculate ljw
%ljw_ = Lambda(o,Psi0W31,Psi0W33,om);
%assert(norm(ljw-ljw_)==0);

      oo = ljw;
      o.profiler('lambda',0);
      return
   elseif (nargout > 1)
      [ljw,g31jw,g33jw] = Lambda(o,PsiW31,PsiW33,Om);

%alternative way to calculate ljw,g31jw,g33jw
%[ljw_,g31jw_,g33jw_] = Lambda(o,Psi0W31,Psi0W33,om);
%assert(0);
   
   else
      ljw = Lambda(o,PsiW31,PsiW33,Om);

%alternative way to calculate ljw
%ljw_ = Lambda(o,Psi0W31,Psi0W33,om);
%assert(0);
   end
   
      % otherwise create a CORASIM system l0(jw) and optionally 
      % g31(jw),g33(jw) 
   
   for (i=1:m)
      l0{i,1} = ljw(i,:);
   end
   oo = fqr(corasim,om,l0);            % FQR typed CORASIM system
   oo = set(oo,'name','l0(jw)','color','yyyr');
   
      % add PsiW31 and PsiW33 to variables
      
   oo = var(oo,'PsiW31,PsiW33',PsiW31,PsiW33);
%  oo = var(oo,'Psi0W31,Psi0W33',Psi0W31,Psi0W33);
   
   if (nargout <= 1)
      o.profiler('lambda',0);
      return                           % return l0
   else   
      for (i=1:m)
         g31{i,1} = g31jw(i,:);
         g33{i,1} = g33jw(i,:);
      end
      g31 = fqr(corasim,om,g31);       % FQR typed CORASIM system
      g31 = set(g31,'name','g31(s)','color','g');
   
      g33 = fqr(corasim,om,g33);       % FQR typed CORASIM system
      g33 = set(g33,'name','g33(s)','color','g');
   end
   
   o.profiler('lambda',0);
end

%==========================================================================
% Lambda Calculation
%==========================================================================

function [ljw,g31jw,g33jw] = Lambda(o,PsiW31,PsiW33,om)                
   o.profiler('Lambda',1);

   G31jw = psion(o,PsiW31,om);
   G33jw = psion(o,PsiW33,om);

   m = sqrt(size(PsiW31,2)-3);
   if (m == 1)
      Ljw = G31jw ./ G33jw;
      ljw = Ljw;

      if (nargout > 1)
         g31jw = G31jw;  g33jw = G33jw;
      end
   else
      ljw = zeros(m,length(om));       % init
      phi = ljw;                       % init

      kmax = size(G31jw,2);
      for (k=1:kmax)
         G31jwk = reshape(G31jw(:,k),m,m);
         G33jwk = reshape(G33jw(:,k),m,m);
         Ljwk = G33jwk\G31jwk;

         ljw(:,k) = eig(Ljwk);
         if (k > 1)
            ljw(:,k-1:k) = Sort(o,ljw(:,k-1:k));
         end
         
            % optionally calculate g31(jw), g33(jw)
            % note: ljw = g0jw * g31jw/g33jw
            
         if (nargout > 1)
            g31jwk = eig(G31jwk);
            [~,idx] = sort(abs(g31jwk),'descend');
            g31jw(:,k) = g31jwk(idx);
            
            g33jwk = eig(G33jwk);
            [~,idx] = sort(abs(g33jwk),'descend');
            g33jw(:,k) = g33jwk(idx);
         end
      end
         
         % order by maximum magnitude
      
      if (kmax > 1)
         Gmax = max(abs(ljw)');
      else
         Gmax = abs(ljw);
      end
      [Gmax,idx] = sort(Gmax,'descend');    % sort by descending order
      ljw = ljw(idx,:);                     % reorder
   end
   o.profiler('Lambda',0);
end

%==========================================================================
% Calculate Critical Transfer Function (Max. Magnitude)
%==========================================================================

function L0 = CritCorasim(l0)          % Calculate Critical Fqr        
   assert(type(l0,{'fqr'}));
   [m,n] = size(l0.data.matrix);
   assert(n==1);
   for (i=1:m)
      l0jw(i,:) = l0.data.matrix{i};
   end

      % find greatest magnitude

   [m,n] =size(l0jw);
   for (j=1:n)
      mag = abs(l0jw(:,j));
      idx = find(mag==max(mag));
      L0jw(1,j) = l0jw(idx(1),j);
   end

   om = l0.data.omega;
   L0 = fqr(corasim,om,{L0jw});
end
function L0jw = CritDouble(l0jw)       % Calculate Critical Fqr        
   [m,n] =size(l0jw);
   for (j=1:n)
      mag = abs(l0jw(:,j));
      idx = find(mag==max(mag));
      L0jw(1,j) = l0jw(idx(1),j);
   end
end

%==========================================================================
% Zero Cross Search
%==========================================================================

function [K0,f0,l0jw] = Critical(o,psiW31,psiW33,om1,om2)
   if (om1 > om2)
      tmp = om1;  om1 = om2; om2 = tmp;     % swap
   end
   
      % calculate spectrum at points om1 and om2 and phase of negative
      % spectrum, as we investigate zero crosses (not pi crosses)
      
   ljw = Lambda(o,psiW31,psiW33,[om1 om2]); 
   phi1 = angle(-ljw(:,1));  phi2 = angle(-ljw(:,2));
   dphi = phi1 - phi2;
   
      % now find first index where phi has no discontinuous jumps
      % and is at the same time zero crossing
      
   idx = find(abs(dphi) < pi & sign(phi1).*sign(phi2) <= 0); 
   if isempty(idx)
      error('no continuous phase crossing in givem omega interval');
   end
   k = idx(1);
   
      % get phase values at om1 and om2 and verify that sign of phases is
      % changing or one of the phase values is zero
      
   p1 = phi1(k);  p2 = phi2(k);
   assert(sign(p1)*sign(p2) <= 0);     % no sign change of phase values
   assert(abs(p2-p1) < pi);
   
      % interval search ...
      
   iter = max(1,opt(o,{'iter',50}));
   eps = max(0,opt(o,{'eps',1e-10}));
   
   for (i=1:iter)
      width = om2-om1;                 % interval width
      if (width == 0 || p1 == p2 )     % avoid deadlock or division by zero
         om0 = mean([om1 om2]);  p0 = mean([p1 p2]);
         break;                        % terminate iterations
      end
      
         % determine om0 by linear interpolation
         
      om0 = mean([om1 om2]);
      assert(om1<=om0 && om0 <= om2);
      
         % calculate spectrum at om0 and phase of negative spectrum,
         % as we investigate zero crosses (not pi crosses)
         
      l0jw = Lambda(o,psiW31,psiW33,om0);
      p0 = angle(-l0jw(k));
      
         % tighten interval
         
      if (abs(p0) <= eps)
         break;
      elseif sign(p0) == sign(p1)
         om1 = om0;  p1 = p0;
      else
         om2 = om0;  p2 = p0;
      end
   end
   
      % get critical magnitude and critical gain
      
   mag = abs(l0jw(k));                 % critical magnitude  
   K0 = 1/mag;                         % critical gain
   f0 = om0/2/pi;                      % critical frequency
end

%==========================================================================
% Helper
%==========================================================================

function L = Sort(o,L)        % Sort Tail of FQR                 
%
% TAILSORT    Rearrange characteristic frequency responses in order to
%             obtain smooth graphs.
%
   [m,n] = size(L);
   if (n <= 1)
      idx = (1:m)';
      return                        % nothing to sort
   end
   
   o.profiler('Sort',1);
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
      [~,j] = min(row);
jj = min(find(row==min(row))); % target index
assert(j==jj);
 
      col = D(:,j);
      [~,i] = min(col);
ii = min(find(col==min(col))); % source index
assert(ii==i);

         % note: i-th element moves to j-th position

      idx(j) = i;                   % ith index equals j
      D(i,:) = void';               % ith row out of game
      D(:,j) = void;                % jth column out of game
    end
    L(:,end) = L(idx,end);
    
    if any(idx~=(1:m)')
       'debug';
    end
    o.profiler('Sort',0);
end

