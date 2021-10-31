function oo = new(o,varargin)          % MESH New Method              
%
% NEW   New MESH object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(mesh,'Traffic')    % some traffic data
%           o = new(mesh,'TinyWeak')   % tiny network with weak traffic
%
%       See also: MESH, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Traffic,@TinyWeak,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'Traffic',{@Callback,'Traffic'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Tiny Weak',{@Callback,'TinyWeak'},[]);
end
function oo = Callback(o)
   mode = arg(o,1);
   oo = new(o,mode);
   paste(o,oo);                        % paste object into shell
end

%==========================================================================
% New Traffic Object
%==========================================================================

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

