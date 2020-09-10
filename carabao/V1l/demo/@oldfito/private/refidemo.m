function [cpk,tout,rout,wout,yout,fout] = refidemo(nmb,Tf,Kp)
%
% REFIDEMO  Simulation of several refi filter types & parameter setups
%
%              refidemo(1,Tf,Kp)
%              refidemo({1 1},Tf,Kp)  % deterministic noise
%              refidemo          % Tf = 3, det = 0, Kp = 0.5
%
%              cpk = refidemo(nmb,Tf,Kp)  % no plot
%              cpk = refidemo({nmb,det,ref},Tf,Kp)  % no plot
%
%           Meaning of arguments
%
%              nmb: demo number
%              det: deterministic noise
%              Tf:  filter time constant
%              Kp:  Kalman time constant
%

% system parameters  & sampling time

   if (nargin < 1) nmb = 0; end  % filter demo number
   if (nargin < 2) Tf = 3; end   % filter time constant
   if (nargin < 3) Kp = 0.5; end % Kalman time constant
   
% time stamp and reference signal definition   

   Ts = 0.2;                     % sample time: 0.2 min = 12 sec
   V = 50;                       % system gain factor

   if (iscell(nmb))
       det = nmb{2};             % deterministic noise ?
       cmd = eval('nmb{3}','''reference(1,V,Ts)''');
       [r,t] = eval(cmd);
       nmb = nmb{1};
   else
       det = 0;                  % random noise
       [r,t] = reference(1,V,Ts);
   end  

   
   
% noise definition   

   if (det) 
      randn('state',0);          % reset random generator
   end 
   stdw = 1;                     % standard deviation of signal noise
   w = randn(size(t));           % signal noise
   w = w * stdw/std(w);          % normalize signal noise to stdw
   y = r + w;                    % noisy signal
   
% Regression filter definition   
   
   F0 = twin([0 Tf]);            % setup order 1 (non-refi) filter
   F1 = twin([1 Tf]);            % setup standard twin filter
   F2 = refi([1 Tf Kp]);         % setup enhanced refi filter
   
   yf0 = [];  yf1 = [];  yf2 = [];  f0 = [];  f1 = [];  f2 = [];  p = [];

   told = -100*Ts;
   for (k=1:length(t))
       tk = t(k);
       dtk = tk - told;
       told = tk;

       yk = y(k);                  % noisy signal to be filtered

       [yf0k,F0] = twin(F0,yk,tk); % Filter F0 operation
       yf0 = [yf0,yf0k];           % record filter F0 output

       [yf1k,F1] = twin(F1,yk,tk); % Filter F1 operation
       yf1 = [yf1,yf1k];           % record filter F1 output
       
       [yf2k,F2] = refi(F2,yk,tk); % Filter F2 operation
       yf2 = [yf2,yf2k];           % record filter F2 output

       pk = F2.p;
       p = [p,pk];
       
          % recording of estimation error
          
       f0k = yf0k - r(k);   f0 = [f0 f0k];
       f1k = yf1k - r(k);   f1 = [f1 f1k];
       f2k = yf2k - r(k);   f2 = [f2 f2k];
   end
   
   stdw = std(w);   spec = 3*stdw;
   
   std0 = std(f0);  avg0 = mean(f0);
   std1 = std(f1);  avg1 = mean(f1);
   std2 = std(f2);  avg2 = mean(f2);

   cpk0 = (spec-abs(avg0))/(3*std0);
   cpk1 = (spec-abs(avg1))/(3*std1);
   cpk2 = (spec-abs(avg2))/(3*std2);
   
   q = ((p./(1+p))-0) * 4*stdw; 
   
% now plot results

   if (nargout > 0)
      cpk = cpk2;
      tout = t;  rout = r;  wout = w;  yout = yf2;  fout = f2;
   else
      clrscr;
      subplot(2,1,1);
      plot(t,0*t,'k-',  t,r,'k',  t,y,'g',  t,yf0,'b',  t,yf1,'r',  t,yf2,'k',  t,yf2,'k.')
      title(sprintf('Regression Filter Demo %g - Tf = %g,  Kp = %g,  noise: std = %g',nmb,Tf,Kp,rd(stdw)));
      xlabel('time t [min]');
   
      subplot(2,1,2);
      y0 = 0;
      plot(t,0*t,'k-');  hold on;
      for (k=1:length(t))
          plot(t(k)*[1 1],[0 w(k)],'g');
          plot(t(k),w(k),'go');
      end
      plot(t,q,'m.:');
      plot(t,f0,'b',  t,f0,'b.', t,f1,'r', t,f1,'r.', t,f2,'k',  t,f2,'k.');
      title(sprintf('Ordinary Filter - Cpk = %g, Twin Filter - Cpk = %g, Regression Filter - Cpk = %g',rd(cpk0),rd(cpk1),rd(cpk2)));
      xlabel(sprintf('Ordinary Filter - Avg/Std = %g/%g, Twin Filter - Avg/Std = %g/%g, Regression Filter - Avg/Std = %g/%g',...
             rd(avg0),rd(std0),rd(avg1),rd(std1),rd(avg2),rd(std2)));
      set(gca,'ylim',[-4,4]);
      shg
   end
   
   return
  

%eof   

