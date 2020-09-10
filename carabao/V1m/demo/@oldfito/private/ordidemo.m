function ordidemo(nmb,Tf)
%
% ORDIDEMO  Simulation of ordinary filter types & parameter setups
%
%              ordidemo(1,Tf)
%              ordidemo([1 1],Tf)  % deterministic noise
%              ordidemo            % Tf = 3, det = 0
%
%           Meaning of arguments
%
%              nmb: demo number
%              det: deterministic noise
%              Tf:  filter time constant
%

% system parameters  & sampling time

   if (nargin < 1) nmb = 0; end  % filter demo number
   if (nargin < 2) Tf = 3; end   % filter time constant
   if (nargin < 3) Tp = 0.5; end % Kalman time constant
   if (nargin < 4) P0 = 10; end  % Kalman initial covariance
   
   if (length(nmb) > 1)
       det = nmb(2);             % deterministic noise ?
       nmb = nmb(1);
   else
       det = 0;                  % random noise
   end  

% time stamp and reference signal definition   

   Ts = 0.2;                     % sample time: 0.2 min = 12 sec
   V = 50;                       % system gain factor
   [r,t] = reference(1,V,Ts);    % get a proper reference signal
   
% noise definition   

   if (det) 
      randn('state',0);          % reset random generator
   end 
   stdw = 1;                     % standard deviation of signal noise
   w = stdw * randn(size(t));    % signal noise
   y = r + w;                    % noisy signal
   
% Twin filter definition   
   
   F0 = twin(0);                 % setup order 1 (non-twin) filter
   F0.T1 = Tf;                   % filter time constant
   F0 = twin(F0);                % reinitialize
   
   yf0 = [];  f0 = [];  p = [];

   told = -100*Ts;
   for (k=1:length(t))
       tk = t(k);
       dtk = tk - told;
       told = tk;

       yk = y(k);                  % noisy signal to be filtered

       [yf0k,F0] = twin(F0,yk,tk); % Filter F0 operation
       yf0 = [yf0,yf0k];           % record filter F0 output

       pk = F0.p;
       p = [p,pk];
       
          % recording of estimation error
          
       f0k = yf0k - r(k);   f0 = [f0 f0k];
   end
   
   stdw = round(100*std(w))/100;
   stdf0 = round(100*std(f0))/100;
   
   red0 = round(100*stdw/stdf0)/100;
   
   q = ((p./(1+p))-1) * 4*stdw; 
   
% now plot results

   clrscr;
   subplot(2,1,1);
   plot(t,0*t,'k-',  t,r,'k',  t,y,'b',  t,yf0,'r')
   title(sprintf('Ordinary Filter Demo %g, Tf = %g - Effectivity F0: %g',nmb,Tf,red0));
   set(gca,'ylim',[-5,35]);
   
   subplot(2,1,2);
   y0 = 0;
   plot(t,0*t,'k-',  t,w,'g',  t,w,'go', t,f0,'r',  t,f0,'k.', t,q,'m:', t,q,'m.');
   title(sprintf('Tf = %g,  noise: std = %g',Tf,stdw));
   xlabel(sprintf('Standard Filter: std(f0) = %g',stdf0));
   set(gca,'ylim',[-4,4]);
   shg
   
   
%eof   
   