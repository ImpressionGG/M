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
%            Timing:
%               
%               system construction:      18.0 ms
%               psion calculation:         4.0 ms
%               omega construction:        0.4 ms
%               out arg construction:      0.3 ms
%
%            Options
%               progress:              % show progress (default: false)
%
%            Copyright(c): Bluenetics 2021
%
%            See also: SPM, SYSTEM, LAMBDA
%
   if (nargin < 2)
      om = Omega(o);                   % omega construction by options
   end
   
      % system construction
      
   sys = system(o);                    % forward system construction
   
      % psion calculation
      
   [psiw31,psiw33] = Psion(o,sys);
      
      % forward gamma calculation
      
   lambda0jw = lambda(o,psiw31,psiw33,om);
   lambda0 = OutArg(o,om,lambda0jw,sys,'lambda0','ryyyy');
   
%  g31 = OutArg(o,om,g31jw,sys,'g31','g');
%  g33 = OutArg(o,om,g33jw,sys,'g33','g');
   
   [gamma0,K0,f0] = Critical(o,lambda0,psiw31,psiw33);

      % backward gamma calculation
   
   if (nargout > 1)
      lambda180 = OutArg(o,om,-lambda0jw,sys,'lambda180','ryyyk');
      [gamma180,K180,f180] = Critical(o,lambda180,-psiw31,psiw33);
   end
end

%==========================================================================
% Critical Quantities
%==========================================================================

function [gamm,K,f] = Critical(o,lamb,psiw31,psiw33)        
%
% CRITICAL
%
%    [gamma0,K0,f0] = Critical(o,lambda0,psiw31,psiw33)
%    [gamma180,K180,f180] = Critical(o,lambda180,-psiw31,psiw33)
%
%    Note: lambda180 = (-1)*lambda0
%          gamma180 = (-1)*gamma0
%
   zc = ZeroCross(o,lamb);             % build complete zero cross table 
   
   oo = opt(o,'progress','');          % no progress updates!
   [K,f,nyqerr] = Search(oo,zc);       % iterative detail search
   
   V = o.iif(isinf(K),1,1/K);          % scale factor: gamma = V*lambda

   if (psiw31(1) > 0)
      gamm = var(V*lamb,'K0,f0,lambda0,nyqerr0',K,f,lamb,nyqerr);
      gamm = set(gamm,'name','gamma0', 'color','r');
   else
      gamm = var(V*lamb,'K180,f180,lambda180,nyqerr180',K,f,lamb,nyqerr);
      gamm = set(gamm,'name,color','gamma180','rrk');
   end      
   gamm = var(gamm,'psiw31,psiw33',psiw31,psiw33);
   
      % that's it - bye!
   
   function zc = ZeroCross(o,lamb)     % build zero cross table        
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
   function zc = Crosses(o,om,Gjw,k)   % Find Zero Crosses             
   %
   % ZEROCROSS  Find all zero cross intervals and return a table with
   %            characteristic quantities of all zero crosses
   %
   %    crosses table is built as follows
   %    [
   %      :   :    :     :      :        :        :       :
   %      k  i1   i2  om(i1)  om(i2)  phi(i1)  phi(i2) max(|G(jw(idx))|)
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
   function [K0,f0,err] = Search(o,zc) % Iterative Search              
      GmaX = max(zc(:,7:8)')';
      [Mag,k] = max(GmaX);                % maximum magnitude
      K0 = 1/Mag;
      om1 = zc(k,4);  om2 = zc(k,5);  K_ = 1/max(zc(k,8));
  
         % calculate critical quantities K0 and f0
      
      [K0,f0,lambda0jw] = lambda(o,psiw31,psiw33,om1,om2);
      
         % calculate Nyquist error
         
      G0jw = 1 + K0*lambda0jw;
      err = min(abs(G0jw));            % Nyquist error
   end
end

%==========================================================================
% Psion Calculation
%==========================================================================

function [psiw31,psiw33] = Psion(o,sys)
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

function om = Omega(o)
   oml = opt(o,'spectrum.omega.low');
   omh = opt(o,'spectrum.omega.high');
   points = opt(o,'spectrum.omega.points');
   
   om = logspace(log10(oml),log10(omh),points);
end

%==========================================================================
% Out Arg Construction
%==========================================================================

function L = OutArg(o,om,Ljw,sys,name,col)
   for (i=1:size(Ljw,1))
      matrix{i,1} = Ljw(i,:);
   end
   L = fqr(corasim,om,matrix);
   L = set(L, 'name',name, 'color',col);
   L = var(L,'system',sys);
end