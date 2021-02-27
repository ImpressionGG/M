function ljw = lambda(o,varargin)         % Spectral Frequency Responses
%
% LAMBDA  Calculate spectral frequency responses lambda(s) for an open
%         loop system.
%
%            oo = system(o,cdx);       % contact related system 
%            ljw = lambda(o,oo);       % spectral frequencies
%
%            ljw = lambda(o);          % implicite call to system(o)
%
%            oo = system(o,cdx);       % get contact relevant system
%            ljw = lambda(o,oo,omega); % calculate spectral FQRs
%
%            ljw = lambda(o,A,B_1,B_3,C_3,T0*omega)
%
%         Theory:
%
%            oo = system(o,cdx)
%            [A,B_1,B_3,C_3,T0] = var(oo,'A,B_1,B_3,C_3,T0')
%            PsiW31 = psion(o,A,B_1,C_3) % to calculate G31(jw)
%            PsiW33 = psion(o,A,B_3,C_3) % to calculate G33(jw)
%
%            G31jw = psion(o,PsiW31,om*T0)
%            G33jw = psion(o,PsiW33,om*T0)
%
%            m = sqrt(size(G31,1))
%            for (k=1:size(G31jw,2))
%               G31jwk = reshape(G31jw(:,k),m,m)
%               G33jwk = reshape(G33jw(:,k),m,m)
%               Ljwk = G33jwk\G31jwk;
%               ljw(1:m,k) = Sort(ljw,eig(Ljwk))
%            end
%
%       Options:
%          process.contact   contact indices (default: inf (all))
%          omega.low         lower omega (default: 100)
%          omega.high        higher omega (default 1e5)
%          omega.points      number of omega points (default 2000)
%
%       Copyright(c): Bluenetics 2021
%
%       See also: SPM, SYSTEM, LAMBDA
%
   if (nargin <= 1)
      oo = system(o);
   else
      oo = varargin{1};
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
      [A,B_1,B_3,C_3,T0] = var(oo,'A,B_1,B_3,C_3,T0');
   else
      A = varargin{1};  B_1 = varargin{2};  B_3 = varargin{3};
      C_3 = varargin{4}; om = varargin{5};
      T0 = 1;                           % must be compensated by omega
   end
   
   PsiW31 = psion(o,A,B_1,C_3);         % to calculate G31(jw)
   PsiW33 = psion(o,A,B_3,C_3);         % to calculate G33(jw)
   
   Om = om(:)' * T0;                    % time normalize
   
   G31jw = psion(o,PsiW31,Om);
   G33jw = psion(o,PsiW33,Om);

   m = sqrt(size(G31jw,1));
   
   if (m == 1)
      Ljw = G31jw ./ G33jw;
      ljw = Ljw;
   else
      ljw = zeros(m,length(om));

      kmax = size(G31jw,2);  k_ = 1;
      for (k=1:kmax)
         G31jwk = reshape(G31jw(:,k),m,m);
         G33jwk = reshape(G33jw(:,k),m,m);
         Ljwk = G33jwk\G31jwk;

         ljw(:,k) = eig(Ljwk);
         ljw(:,k_:k) = Sort(ljw(:,k_:k));
         k_ = k;
      end
   end
end

%==========================================================================
% Helper
%==========================================================================

function L = Sort(L)                % Sort Tail of FQR              
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

