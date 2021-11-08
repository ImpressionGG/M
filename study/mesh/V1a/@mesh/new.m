function oo = new(o,varargin)          % MESH New Method              
%
% NEW   New MESH object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(mesh,'Traffic')    % some traffic data
%           o = new(mesh,'TinyWeak')   % tiny network with weak traffic
%
%           o = mew(mesh,'Single')     % single mesh message post
%
%       See also: MESH, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Single,@Net,@Traffic,@TinyWeak,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'Single Mesh Message',{@Callback,'Single'},[]);
   oo = mitem(o,'Small Net',{@Callback,'Net'},'small');
   oo = mitem(o,'Large Net',{@Callback,'Net'},'large');
   oo = mitem(o,'-');
   oo = mitem(o,'Traffic',{@Callback,'Traffic'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Tiny Weak',{@Callback,'TinyWeak'},[]);
end
function oo = Callback(o)
   mode = arg(o,1);
   kind = arg(o,2);
   oo = new(o,mode,kind);
   paste(o,oo);                        % paste object into shell
end

%==========================================================================
% New Traffic Object
%==========================================================================

function oo = Single(o)
%
% SINGLE  Setup a single mesh message scenario at time zero with default 
%         3 repeats and 20 ms observation time (no acknowlege)
%
   send.ID = [1];                      % node 1
   send.t = [0];                       % first transmit at time 0

   net.L = 256e-6;                     % packet length
   net.T = 0.02;                       % 20 ms observation time
   net.r = 3;                          % 3 repeats
   net.ack = 0;                        % no acknowlegments
   net.due = 0.2;                      % due expectation in 200 ms
   net.hop = 6;                        % max 6 hops
   
   oo = mesh('send');
   oo.par.net = net;
   oo.data = send;
end
function oo = Net(o)                   % Network Object                
   kind = o.either(arg(o,1),'small');
   
   switch kind
      case 'small'
         NW = 14;                      % number of wearables;
         NB = 5;                       % number of beacons
         NG = 1;                       % number of gateways
         NR = 20;                      % number of relays
         tit = 'Small Scale Network (10/5 @ 100%)';
      case 'large'
         NW = 1000;                    % number of wearables;
         NB = 100;                     % number of beacons
         NG = 10;                      % number of gateways
         NR = 1110;                    % number of relays
         tit = 'Large Scale Network (1000/100 @ 100%)';
      otherwise
         error('bad network type');
   end

   wids = 1:NW;                        % wearable IDs
   bids = max(wids) + (1:NB);          % beacon IDs
   gids = max(bids) + (1:NG);          % gateway IDs
   
   nids = [wids,bids,gids];

   oo = mesh('net');
   oo.par.title = tit;
   oo = data(oo,'NW,NB,NG,NR,wids,bids,gids,nids',...
                 NW,NB,NG,NR,wids,bids,gids,nids);
end
function oo = Traffic(o)               % New Traffic Object            
   Tobs = 1000000;                     % 1000000 us observation time
   Tpack = 500;                        % 500 us packet time
   n = 6;                              % 6 packets per observation

   N = opt(o,{'traffic.N',1000});      % number of concurrent transmissions
   n = opt(o,{'traffic.repeats',6});   % number of repeats
   Tobs = opt(o,{'traffic.Tobs',1000})*1000;
   Tpack = opt(o,{'traffic.Tpack',500});

      % setup transmission scenarios
   
   t = zeros(N,2*n);
   for (k=1:N)
      while (1)
         tk = sort(rand(1,n));           % time stamps
         tk = round(tk * Tobs); 

         if (all(diff([tk,Tobs]) > Tpack))
            break;
         end
      end
   
      tk = [tk; tk+Tpack];
      t(k,:) = tk(:)';
   end
   
      % pack into object

   oo = mesh('traf');                  % traffic type
   oo.par.title = sprintf('%g x %g packets (%gus) @ %gs Mesh Traffic (%s)',...
                           N,n,Tpack,Tobs/1e6,datestr(now));
   oo.data.Tobs = Tobs;
   oo.data.Tpack = Tpack;
   oo.data.t = t;
end
function oo = TinyWeak(o)              % New Tiny/Weak Traffic Object  
   Tobs = 100000;                      % 100000 us observation time
   Tpack = 250;                        % 250 us packet time
   n = 6;                              % 6 packets per observation

   N = opt(o,{'traffic.N',1000});      % number of concurrent transmissions
   n = opt(o,{'traffic.repeats',6});   % number of repeats
   Tobs = opt(o,{'traffic.Tobs',1000})*1000;
   Tpack = opt(o,{'traffic.Tpack',500});

      % setup transmission scenarios
   
   t = zeros(N,2*n);
   for (k=1:N)
      while (1)
         tk = sort(rand(1,n));           % time stamps
         tk = round(tk * Tobs); 

         if (all(diff([tk,Tobs]) > Tpack))
            break;
         end
      end
   
      tk = [tk; tk+Tpack];
      t(k,:) = tk(:)';
   end
   
      % pack into object

   oo = mesh('traf');                  % traffic type
   oo.par.title = sprintf('%g x %g packets (%gus) @ %gs Mesh Traffic (%s)',...
                           N,n,Tpack,Tobs/1e6,datestr(now));
   oo.data.Tobs = Tobs;
   oo.data.Tpack = Tpack;
   oo.data.t = t;
end

