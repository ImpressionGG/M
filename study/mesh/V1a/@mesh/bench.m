function oo = bench(o,varargin)        % Mesh Benchmark Scenarios
%
% BENCH Test benchmarks for mesh performance
%
%          oo = bench(o,'Menu')        % setup Benchmark menu
%
%          bench(o,'Sensor')           % periodic sensor benchmark
%          bench(o,'Burst')            % message burst benchmark
%
%       Sensor Benchmark
%         - situation: 1000 (number N) sensors are collecting measurements 
%           at a periodic basis (period T)
%         - there is no external disturbance assumed for the transmission
%           channel, and the mesh radios are always open for receive, i.e.
%           the collisios are the only root c 
%         - sensor data fits into an unsegmented mesh message with length L
%           (L = 0.256e-3s)
%         - what is the smallest period for send&pray protocol according to 
%           repeat rates of 3,6,9
%         - what is the smallest period for ACK'ed protocol, and which
%           repeat rate should be used
%
%       Burst Benchmark
%          - situation: 30% out of 1000 (number N) sensors are sending an
%            alarm message within one second
%         - there is no external disturbance assumed for the transmission
%           channel, and the mesh radios are always open for receive, i.e.
%           the collisios are the only root c 
%         - alarm data fits into an unsegmented mesh message with length L
%           (L = 0.256e-3s)
%         - what is the time until all alarm messages reach the gateway 
%           in case of 10% 20% 50% and 100% relay rate in the mesh network
%         - is there a critical relay rate above the network blocks and be-
%           low the network recovers?
%          
%        
%       Copyright(c): Bluenetics 2021
%
%       See also: MESH
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,@WithSho,@Menu,...
                                 @Sensor,@Burst);
   oo = gamma(o);                 % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)
   setting(o,{'bench.decel'},1);
   
   oo = mitem(o,'Benchmarks',{},[]);
   ooo = mitem(oo,'Sensor',{@WithCuo,'Sensor'},[]);
   ooo = mitem(oo,'Burst',{@WithCuo,'Burst'},[]);
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Deceleration',{},'bench.decel');
         choice(ooo,[0,0.01 0.02 0.05 0.1 0.2 0.5 1],{});
end

%==========================================================================
% Launch Callbacks
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% WITHSHO General callback for operation on shell object
%         with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   gamma = eval(['@',mfilename]);
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   dark(o);                            % do dark mode actions
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
 
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
  end
  dark(o);                            % do dark mode actions
end

%==========================================================================
% Actual Analysis
%==========================================================================

function oo = Burst(o)                 % Burst Benchmark
   KD = opt(o,{'bench.decel',1});   
   KR = [1:10]/100;
   
   o = subplot(o,1111);
   for (i=1:length(KR))
      oo = CalcBurst(o,KR(i),KD);
      
      PlotC(o,2111);
      PlotM(o,2121);
   end
   
   function PlotC(o,sub)
      o = subplot(o,sub,'semilogx');
      [t,M,R,T,C] = var(oo,'t,M,R,T,C');
      plot(o,t,100*C,'r');
      
      idx = min(find(C<0.3));
      o.color(text(t(idx),100*C(idx),sprintf('%g%%',100*KR(i))),'r');
      
      title(sprintf('Collision Probability (Deceleration: %g)',KD));
      xlabel('time');
      ylabel('collision probability [%]');
      subplot(o);
   end
   function PlotM(o,sub)
      o = subplot(o,sub,'semilogx');
      [t,M,R,T,C] = var(oo,'t,M,R,T,C');
      plot(o,t,max(M)-M,'bc');

      idx = min(find(max(M)-M>150));
      o.color(text(t(idx),max(M)-M(idx),sprintf('%g%%',100*KR(i))),'bc');      
      
      title('Transmission Progress');
      xlabel('time');
      ylabel('Messages [#]');
      subplot(o);
   end
end

%==========================================================================
% Helper
%==========================================================================

function oo = CalcBurst(o,KR,KD)
%
% KR: relay ratio
% KD: deceleration factor <= 1
%
   L = 0.000256;                       % packet length
   NW = 1000;                          % number of wearables
   KA = 0.3;                           % alarm ratio
   r = 3;                              % repeat number
   NR = KR*NW;                         % number of relays
    
   S = NW*KA;                          % remaining packets to send                       
   Tmax = 1e3;
   Ts = 0.1;
   n = Tmax/Ts;
   
   B = boost(o,r,L);
   
   for (i=1:n)
      t(i) = (i-1)*Ts;
      M(i) = S;
      if (KD == 0)
         D(i) = min(S,B*Ts/NR);
         R(i) = D(i)*NR/Ts;
         Ri = round(R(i));
         T(i) = Ts;                      
         C(i) = collision(o,R(i),r,L);
      else
         D(i) = KD*M(i)*Ts;
         R(i) = D(i)*NR/Ts;
%        R(i) = NR*M(i);
         T(i) = Ts;                      
         C(i) = collision(o,KD*R(i),r,L);
      end
      S = M(i) - (1-C(i))*D(i);
   end
   
   oo = mesh('burst');
   oo = var(oo,'t,M,R,T,C',t,M,R,T,C);
end