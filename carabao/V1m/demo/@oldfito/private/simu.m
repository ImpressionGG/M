function [cpk,tout,rout,wout,yout,tfout,fout,kout] = simu(kind,type,Tf,Kp,Ns)
%
% SIMU      Simulation of several filters with specific type & parameter setups
%
%              simu('twin',2,Tf,Kp,Ns)
%              simu('kafi',{2 1},Tf,Kp)   % deterministic noise
%              simu('twin')               % Tf = 3, det = 0, Kp = 0.5
%
%              cpk = simu('twin',type,Tf,Kp)  % no plot
%              cpk = simu('twin',{type,det,ref},Tf,Kp)  % no plot
%
%           Meaning of arguments
%
%              kind: simu kind ('twin','kafi','refi')
%              type: filter type number  (if negativ, then uniform filter time constant) 
%              det:  deterministic noise
%              Tf:   filter time constant
%              Kp:   Kalman decay
%

% system parameters  & sampling time
   
   Nx = 0;
   
   if (nargin < 1) error('filter kind (arg1) expected!'); end
   if (nargin < 2) type = 0;   end % filter type number
   if (nargin < 3) Tf = 3;     end % filter time constant
   if (nargin < 4) Kp = 0.5;   end % Kalman decay
   if (nargin < 5) Ns = 1;     end % number of simultaneous runs
   if (nargin < 6) Nx = 0; end % number of simultaneous runs
   
% time stamp and reference signal definition   

   Ts = 0.2;                     % sample time: 0.2 min = 12 sec
   V = 50;                       % system gain factor

   if (iscell(type))
       det = type{2};             % deterministic noise ?
       ref = eval('type{3}','''reference(1,V,Ts)''');
       if (isstr(ref))
          [r,t] = eval(cmd);
       else
          [r,t] = reference(ref);
          eval('Nx = ref.Nx;','');
       end
       type = type{1};
   else
       det = 0;                  % random noise
       [r,t] = reference(1,V,Ts);
   end  

   uniform = 0;    % default
   if (type < 0)   % negative type indicates uniform filter time constant 
       uniform = 1;
       type = -type;
   end

   Tf0 = iif(uniform,Tf,0.5);  Kp0 = iif(uniform,Kp,0.3);
   Tf1 = iif(uniform,Tf,1.0);  Kp1 = iif(uniform,Kp,0.3);
   
   std0 = [];  std1 = [];  std2 = [];
   avg0 = [];  avg1 = [];  avg2 = [];
   cpk0 = [];  cpk1 = [];  cpk2 = [];

   Nruns = Ns; 
   while (Nruns > 0)
      ns = min(Nruns,100);             % max 200 simultaneous simulation runs
      Nruns = Nruns - ns;              % decrement loop counter
   
         % noise definition   

      if (det) 
         randn('state',0);             % reset random generator
      end 
      stdw = 1;                        % standard deviation of signal noise
      one = ones(size(t));             % ones-vector
      w = randn(length(t),ns);         % signal noise
      w = w./(one*std(w));             % normalize signal noise to stdw
      %y = r*one(1:ns)' + w;           % noisy signal
      y = r*ones(1,ns) + w;            % noisy signal
   
         % filter definition   
  
      cmd = [kind,'([type Tf Kp ns])'];   % prepare setup command for F2 
   
      F0 = twin([0 Tf0 Kp0 ns]);    % setup order 1 (non-twin) filter
      F1 = twin([1 Tf1 Kp1 ns]);    % setup standard twin filter
      F2 = eval(cmd);               % setup enhanced twin filter

   
      yf0 = [];  yf1 = [];  yf2 = [];  f0 = [];  f1 = [];  f2 = [];  p = [];
      idx = [];
      told = -100*Ts;
      for (k=1:length(t))
         tk = t(k);
         dtk = tk - told;
         told = tk;

         yk = y(k,:);                % noisy signal to be filtered

         [yf0k,F0] = twin(F0,yk,tk); % Filter F0 operation

         [yf1k,F1] = twin(F1,yk,tk); % Filter F1 operation
       
         cmd = [kind,'(F2,yk,tk)'];
         [yf2k,F2] = eval(cmd);      % Filter F2 operation

         pk = F2.p;
       
            % recording of estimation error
          
         f0k = yf0k - r(k,:); 
         f1k = yf1k - r(k,:);
         f2k = yf2k - r(k,:);
         
            % we will record data only if time stamps differ from
            % each other. Otherwise this would refer to repeated
            % measurements
            
         if (k > 1)
            repeated = (abs(t(k) - t(k-1)) < 1e4*eps);
         else
            repeated = 0;
         end
             
         if (~repeated)
            f0 = [f0; f0k];         
            f1 = [f1; f1k];
            f2 = [f2; f2k];     
            yf0 = [yf0;yf0k];           % record filter F0 output
            yf1 = [yf1;yf1k];           % record filter F1 output
            yf2 = [yf2;yf2k];           % record filter F2 output
         else                     % overwrite if repeated measurements
            m = size(f0,1);
            f0(m,:) = f0k;
            f1(m,:) = f1k;
            f2(m,:) = f2k;
            yf0(m,:) = yf0k;
            yf1(m,:) = yf1k;
            yf2(m,:) = yf2k;
            idx = [idx k];      
         end
         p = [p;pk];
      end

      tf = t;  tf(idx) = [];    % tf differs from t by deleting repeated time stamps
      
      spec = 3*std(w);

      std0 = [std0, std(f0)];  avg0 = [avg0, mean(f0)];
      std1 = [std1, std(f1)];  avg1 = [avg1, mean(f1)];
      std2 = [std2, std(f2)];  avg2 = [avg2, mean(f2)];

      cpk0 = [cpk0, (spec-abs(mean(f0)))./(3*std(f0))];
      cpk1 = [cpk1, (spec-abs(mean(f1)))./(3*std(f1))];
      cpk2 = [cpk2, (spec-abs(mean(f2)))./(3*std(f2))];
   
      q = ((p./(1+p))-0) * 4*stdw(1); 
   end % while (Nruns > 0)
   
% now plot results

   Kind = upper(F2.kind);

   if (nargout > 0)
      cpk = cpk2;
      tout = t;  rout = r(:,1);  wout = w(:,1);  yout = yf2(:,1);  
      tfout = tf;  fout = f2(:,1);  kout = Kind;
   else
      if (Ns > 1)  % calculate mean, least and sample values 
         mcpk0 = mean(cpk0);   lcpk0 = mcpk0 - 3*std(cpk0);
         mcpk1 = mean(cpk1);   lcpk1 = mcpk1 - 3*std(cpk1);
         mcpk2 = mean(cpk2);   lcpk2 = mcpk2 - 3*std(cpk2);
      
         mavg0 = mean(avg0);   mstd0 = mean(std0);
         mavg1 = mean(avg1);   mstd1 = mean(std1);
         mavg2 = mean(avg2);   mstd2 = mean(std2);

         nsigma = lcpk2*3;
      end

      extra = iif(Nx>0,sprintf('.%g',Nx),'');
      
      cls;
      subplot(2,1,1);
      plot(t,0*t,'k-',  t,r(:,1),'k',  t,y(:,1),'g',  tf,yf0(:,1),'b',  tf,yf1(:,1),'r',  tf,yf2(:,1),'k',  tf,yf2(:,1),'k.')
      xlabel('time t [min]');
      if (Ns == 1)
         title(sprintf([Kind,' (%g',extra,') Filter Demo - Tf = %g,  Kp = %g,  Noise: std = %g'],type,Tf,Kp,rd(stdw(1))));
         ylabel('1 simulation per parameter set');
      else
         title(sprintf([Kind,' (%g',extra,') Filter Demo - Tf = %g,  Kp = %g,  Noise: std = %g,  => %g Sigma'],type,Tf,Kp,rd(stdw(1)),rd(nsigma,1)));
         ylabel(sprintf('%g simulations per parameter set',Ns));
      end
   
      
      subplot(2,1,2);
      y0 = 0;
      plot(t,0*t,'k-');  hold on;
      for (k=1:length(t))
          plot(t(k)*[1 1],[0 w(k)],'g');
          plot(t(k),w(k),'go');
      end
      plot(t,q,'m.:');
      plot(tf,f0(:,1),'b',  tf,f0(:,1),'b.', tf,f1(:,1),'r', tf,f1(:,1),'r.', tf,f2(:,1),'k',  tf,f2(:,1),'k.');
      if (Ns > 1)
         title(sprintf(['ORFI(0',extra,') Filter - Cpk = %g (%g/%g), TWIN(1',extra,') Filter - Cpk = %g (%g/%g), ',Kind,'(%g',extra,') Filter - Cpk = %g (%g/%g)'],...
             rd(cpk0(1)),rd(mcpk0),rd(lcpk0),  rd(cpk1(1)),rd(mcpk1),rd(lcpk1),  type,rd(cpk2(1)),rd(mcpk2),rd(lcpk2)));
         xlabel(sprintf(['ORFI(0) Filter - Avg/Std = %g/%g, TWIN(1) Filter - Avg/Std = %g/%g, ',Kind,'(%g) Filter - Avg/Std = %g/%g'],...
             rd(avg0(1)),rd(std0(1)),rd(avg1(1)),rd(std1(1)),type,rd(avg2(1)),rd(std2(1))));
      else
         title(sprintf(['ORFI(0',extra,') Filter - Cpk = %g, TWIN(1',extra,') Filter - Cpk = %g, ',Kind,'(%g',extra,') Filter - Cpk = %g'],rd(cpk0(1)),rd(cpk1(1)),type,rd(cpk2(1))));
         xlabel(sprintf(['ORFI(0) Filter - Avg/Std = %g/%g, TWIN(1) Filter - Avg/Std = %g/%g, ',Kind,'(%g) Filter - Avg/Std = %g/%g'],...
             rd(avg0(1)),rd(std0(1)),rd(avg1(1)),rd(std1(1)),type,rd(avg2(1)),rd(std2(1))));
      end
      ylabel(sprintf(['ORFI(0): blue,  TWIN(1): blue,  ',upper(kind),'(%g): black'],type));
      set(gca,'ylim',[-4,4]);
      shg
   end
   
   return
  

%eof   

