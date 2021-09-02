function [gamma0,gamma180,sys] = gamma(o,om)
%
% GAMMA      Calculation of gamma TRFs and critical quantities (very 
%            efficient implementation
%
%               [gamma0,gamma180,sys] = gamma(o)
%               [gamma0,gamma180,sys] = gamma(o,om)
%
%               [K0,f0,lambda0] = var(gamma0,'K0,f0,lambda0');
%               [K180,f180,lambda180] = var(gamma180,'K180,f180,lambda180');
% 
%               [psiw31,psiw33] = var(gamma0,'psiw31,psiw33');
%               [psiw31,psiw33] = var(gamma180,'psiw31,psiw33');
%
%            Notes
%               For finite critical gain K0,K180 the gamma TRF calculates
%
%                  gamma0 = 1/K0 * lambda0
%                  gamma180 = 1/K180 * lambda180
%
%               For infinite K=,K180 we have
%
%                  gamma0 = lambda0
%                  gamma180 = lambda180
%
%            Integrity check for spectral functions (gamma's and lambda's)
%
%               err = gamma(o,gamma0)
%               err = gamma(o,gamma180)
%               err = gamma(o,lambda0)
%               err = gamma(o,lambda180)
%
%            Options
%               progress:              % show progress (default: false)
%
%            Copyright(c): Bluenetics 2021
%
%            See also: SPM, SYSTEM, LAMBDA
%

%            Timing:
%               
%               system construction:      18.0 ms
%               psion calculation:         4.0 ms
%               omega construction:        0.4 ms
%               out arg construction:      0.3 ms
%
   if (nargin < 2)
      om = Omega(o);                   % omega construction by options
   elseif isobject(om)
      gamma0 = Integrity(o,om);        % integrity check
      return
   end
   
      % system construction
      
   sys = system(o);                    % forward system construction
   
      % psion calculation
      
   [psiw31,psiw33] = Psion(o,sys);
      
      % forward gamma calculation
      
   lambda0jw = lambda(o,psiw31,psiw33,om);
   lambda0 = OutArg(o,om,lambda0jw,sys,psiw31,psiw33,'0','ryyyy');   
   
   [gamma0,K0,f0,nyqerr] = Gamma(o,lambda0,psiw31,psiw33);
   
%  g31 = OutArg(o,om,g31jw,sys,'g31','g');
%  g33 = OutArg(o,om,g33jw,sys,'g33','g');
   
      % backward gamma calculation
   
   if (nargout > 1)
      lambda180 = Lambda(o,om,-lambda0jw,sys,-psiw31,psiw33,'180','ryyyk');
      
      [gamma180,K180,f180] = Gamma(o,lambda180,-psiw31,psiw33);
   end
end

%==========================================================================
% Critical Quantities
%==========================================================================

function [gamm,K,f,nyqerr] = Gamma(o,lamb,psiw31,psiw33)               
%
% GAMMA   Gamma object construction
%
%    [gamma0,K0,f0] = Gamma(o,lambda0,psiw31,psiw33)
%    [gamma180,K180,f180] = Gamma(o,lambda180,-psiw31,psiw33)
%
%    Note: lambda180 = (-1)*lambda0
%          gamma180 = (-1)*gamma0
%
   zc = ZeroCross(o,lamb);             % build complete zero cross table 
   
   oo = opt(o,'progress','');          % no progress updates!
   [K,f,i0,j0,k0,err] = Search(oo,zc); % iterative detail search

      % adjust omega and frequency response of lamb
      % and store variables to lambda function 
      
   [lamb,i0,nyqerr] = Adjust(lamb,j0,K,f);
   lamb = var(lamb,'K,f,i0,j0',K,f,i0,j0'); 
   
      % derive gamma function from lambda
      
   if isinf(K)                         % no gain to make gamma unstable?
      gamm = lamb;                     % gamm equals lamb for infinite K
   else
      gamm = K*lamb;
      fqr = gamm.work.var.fqr;
      gamm.work.var.fqr = K*fqr;
   end
   
      % add lambda function to variables of gamma and add name & color
      
   gamm = var(gamm,'lambda,critical',lamb,1);
   if (psiw31(1) > 0)
      gamm = set(gamm,'name,color', 'gamma0','r');
   else
      gamm = set(gamm,'name,color', 'gamma180','rrk');
   end      
   
      % that's it - bye!
   
   function zc = ZeroCross(o,lamb)             % Build zero cross table
   %
   % ZEROCROSS  Find final zero cross interval table with
   %            characteristic quantities of all zero crosses
   %
   %    crosses table is built as follows
   %    [
   %      k  j1   j2  om(j1)  om(j2)  phi(j1)  phi(j2) max(|G(jw(idx))|)
   %    ]
   %
      om = lamb.data.omega;
      [m,n] = size(lamb.data.matrix);

         % buildup mandatory zero cross table zc0 for forward cutting and
         % optional zero cross table zc180 for reverse cutting

      zc = [];
      for (kk=1:m)
         Gjw0 = lamb.data.matrix{kk};    % i-th FQR

            % buildup zero cross table for forward cutting

         zck = Crosses(o,om,Gjw0,kk);
         zc = [zc;zck];
      end
   end
   function zc = Crosses(o,om,Gjw,k)           % Find Zero Crosses     
   %
   % ZEROCROSS  Find all zero cross intervals and return a table with
   %            characteristic quantities of all zero crosses
   %
   %    crosses table is built as follows
   %    [
   %      :   :    :     :      :        :        :       :
   %      k  j1   j2  om(j1)  om(j2)  phi(j1)  phi(j2) max(|G(jw(idx))|)
   %      :   :    :     :      :        :        :       :
   %    ]
   %
      Gjw = -Gjw;
      
         % critical phases for lambda0 are at -pi +k*2*pi. If we map
         % G = -lambda0 then critical phases of G are at 0 + 2*k*pi
      
      phi = angle(Gjw);
      delta = diff([phi(2) phi phi(end-1)]);
      bwd = sign(delta(1:end-1));      % backward indicator
      fwd = sign(delta(2:end));        % forward indicator
      
         % calculate total indicator ind = bwd + fwd
         % > 0: increase point (1-1-2 or 1-2-2 or 1-2-3)
         % = 0: turning point  (3-2-3 or 2-2-2 or 1-2-1)
         % < 0: decrease point (3-2-1 or 3-2-2 or 3-3-2)

      ind = bwd + fwd;                 % total indicator
         
         % find all discontinuities of phi
         
      dis = (abs(delta(1:end-1)) > pi) | (abs(delta(2:end)) > pi);
      
         % find all turning points; note that first and last point must
         % be turning points by our construction
      
      assert(ind(1)==0);              % first: by our construction
      assert(ind(end)==0);            % last: by our construction
      tdx = find((ind == 0) | dis);   % turning point or jump indices
      
         % so we got N = length(tdx)-1 intervals; next we seek all N
         % intervals for zero crosses. To do so build the maximum phase
         % (pmax) and the minimum phase (pmin) of each interval, then
         % we conclude a zero cross if zc = (sign(pmin)*sign(pmax) <= 0).
         % Note that we must exclude and intervals with discontinuities,
         % which we detect by |diff(p)| > pi
         
      N = length(tdx)-1;
      zc = [];                         % init zero cross table
      
         % find zero crosses and fill zerocross table
         
      for (i=1:N)
         i1 = tdx(i);  i2 = tdx(i+1);
         idx = i1:i2;
         p = phi(idx);  pmin = min(p);  pmax = max(p);
         
         crossing = (sign(pmin)*sign(pmax) <= 0);
         if (crossing)
            if ~any(abs(diff(p)) > pi)       % no phi jumps?
               zdx = find(p==0);
               if ~isempty(zdx)
                  idx = idx(zdx);            % update idx            
                  [Gmax,i1] = max(abs(Gjw(idx)));
                  i2 = i1;
               elseif (p(1) > 0)
                  zdx = find(p<0);
                  i2 = min(idx(zdx));
                  i1 = i2-1;
                  Gmax = max(abs(Gjw(i1:i2)));
               else  % p(1) < 0
                  zdx = find(p>0);
                  i2 = min(idx(zdx));
                  i1 = i2-1;
                  Gmax = max(abs(Gjw(i1:i2)));
               end
               i1i2 = [i1 i2];
               assert(abs(diff(phi(i1i2))) <= pi);
               zc(end+1,:) = [k,i1,i2,om(i1i2),phi(i1i2),Gmax];
            end
         end
      end
      
      if (0)
            o = subplot(o,211);
            plot(o,om,abs(Gjw),'r1');
            for (i=1:size(crosses,1))
               i1 = crosses(i,2);  i2 = crosses(i,3);
               plot(o,crosses(i,4:5),abs(Gjw([i1 i2])),'co');
            end
            subplot(o);

            o = subplot(o,212);
            plot(o,om,phi,'g1');
            for (i=1:size(crosses,1))
               i1 = crosses(i,2);  i2 = crosses(i,3);
               plot(o,crosses(i,4:5),phi([i1 i2]),'mo');
            end
            subplot(o);
      end      
   end
   function [K0,f0,i0,j0,k0,err] = Search(o,zc)% Iterative Search      
   %
   % SEARCH
   %
   %    crosses table is built as follows
   %    [
   %      k  j1   j2  om(j1)  om(j2)  phi(j1)  phi(j2) max(|G(jw(idx))|)
   %    ]
   %
      GmaX = max(zc(:,7:8)')';
      [Mag,k0] = max(GmaX);            % maximum magnitude @ k
      K0 = 1/Mag;
      om1 = zc(k0,4);  om2 = zc(k0,5);  K_ = 1/max(zc(k0,8));
  
         % calculate critical quantities K0 and f0
      
      [K0,f0,lambda0jw] = lambda(o,psiw31,psiw33,om1,om2);
      
         % calculate Nyquist error
         
      G0jw = 1 + K0*lambda0jw;
      [err,i0] = min(abs(G0jw));       % Nyquist error
      
         % calculate j0 index
         
      j1 = zc(k0,2);  j2 = zc(k0,3);  om0 = 2*pi*f0;
      if (om0-om1 < om2-om0)           % is om0 closer to om1?
         j0 = j1;
      else
         j0 = j2;
      end
   end
   function [lamb,i0,nyq] = Adjust(lamb,j0,K,f)   % Adjustment of Omega   
      lamb.data.omega(j0) = 2*pi*f;    % adaption of omega domain vector
      L0jw_ = lambda(o,psiw31,psiw33,lamb.data.omega(j0));
      
         % reorder L0jw according to least jumps
      
      m = length(lamb.data.matrix);
      L0jw = NaN*L0jw_;                % init
      for (i=1:m)
         Ljw = lamb.data.matrix{i};
         d = abs(L0jw_-Ljw(j0));
         [dmin,idx] = min(d);
         L0jw(i,1) = L0jw_(idx);       % reorder
         L0jw_(idx) = [];              % out of game
      end
      
         % now L0jw is reordered according to öleast jumps
         
      lamb.work.var.fqr(:,j0) = L0jw;

         % store FQR as variable

      for (i=1:m)
         lamb.data.matrix{i} = lamb.work.var.fqr(i,:);
      end

         % final check and refresh i0

      [nyq,i0] = min(abs(1+K*L0jw));    % Nyquist error
      if (abs(nyq-err) > abs(err)/100)
         fprintf('*** warning: > 1%% Nyquist error deviation %g ~= %g (dev: %g)\n', ...
                 nyq,err,nyq-err);
      end
      
         % store nyquist error to lambda function

      lamb = var(lamb,'nyqerr',nyq'); 
   end
end

%==========================================================================
% Psion Calculation
%==========================================================================

function [psiw31,psiw33] = Psion(o,sys)     % Calc Psion Matrices      
   A = var(sys,'A');
   B_1 = var(sys,'B_1');
   B_3 = var(sys,'B_3');
   C_3 = var(sys,'C_3');
   T0 = var(sys,'T0');
   
   psiw31 = psion(o,A,B_1,C_3,T0);     % to calculate G31(jw)
   psiw33 = psion(o,A,B_3,C_3,T0);     % to calculate G33(jw)
end

%==========================================================================
% Omega Construction
%==========================================================================

function om = Omega(o)                      % Construct Omega Domain   
   oml = opt(o,'spectrum.omega.low');
   omh = opt(o,'spectrum.omega.high');
   points = opt(o,'spectrum.omega.points');
   
   om = logspace(log10(oml),log10(omh),points);
end

%==========================================================================
% Lambda Object Construction
%==========================================================================

function L = Lambda(o,om,Ljw,sys,psiw31,psiw33,tag,col)                
   for (i=1:size(Ljw,1))
      matrix{i,1} = Ljw(i,:);
   end
   
   name = ['lambda',tag];
   
   L = fqr(corasim,om,matrix);
   L = set(L, 'name',name, 'color',col);
   L = var(L,'tag,system,psiw31,psiw33,fqr,critical',...
              tag,sys,psiw31,psiw33,Ljw,0);
end

%==========================================================================
% Integrity Check for Spectral Functions
%==========================================================================

function err = Integrity(o,lamb)
%
% INTEGRITY   Integrity check for spectral functions (debug method)
%
%                err = integrity(o,lambda0)
%
%             Copyright(c): Bluenetics 2021
%
%             See also: SPM, CRITICAL, GAMMA
%
   [i0,j0,K,f,Ljw] = var(lamb,'i0,j0,K,f,fqr');
      
   if isinf(K)                   % no further checks
      err = 0;                   % no error
      return
   end
   
   Ljw0 = Ljw(:,j0);

      % K correction for gamma functions
      
   name = [get(lamb,{'name',''}),'____'];
   if isequal(name(1:4),'gamm')
      K = 1;
   end
   
      % FQR check
      
   for (i=1:length(Ljw0))
      Lijw = lamb.data.matrix{i};
      err = norm(Ljw(i,:)-Lijw);
      if (err)
         error('frequency response deviation');
      end
   end
   
      % calculate index integrity and Nyquist error
   
   M = abs(1+K*Ljw0);
   [err,i] = min(M);                   % Nyquist error
   
   if (i ~= i0)
      error('index integrity violated (i0)');
   end
   
   if (err > 1e-6)
      error('high Nyquist error');
   end
end