function oo = new(o,varargin)          % MESH New Method              
%
% NEW   New MESH object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(mesh,'Traffic')    % some traffic data
%
%       See also: MESH, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Traffic,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'Traffic (TRAF)',{@Callback,'Traffic'},[]);
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

%==========================================================================
% New Wave Object
%==========================================================================

function oo = Wave(o)                  % New wave object
   f = 1000+pi;                        % 1003.14 Hz

   t = 0:0.0001:5;                     % time vector
   x = 3*cos(2*pi*f*t);                % x data
   y = 2*sin(2*pi*f*t);                % y data

   shape = 3*exp(-4*(t-1.2).^2/0.5) + 2*exp(-4*(t-3.8).^2/0.5);

      % pack into object

   oo = mesh('alt');                  % alternative type
   oo.par.title = sprintf('A Stupid Wave (%s)',datestr(now));
   oo.data.t = t;
   oo.data.x = x .* shape + 0.02*randn(size(t));
   oo.data.y = y .* shape + 0.03*randn(size(t));
end

%==========================================================================
% New Beat Object
%==========================================================================

function oo = Beat(o)                  % New beat object
   f1 = 950;  f2 = 1050;               % close to 1000 Hz
   df = 50;                            % 50 Hz frequency deviation

   t = 0:0.0001:5;
   x = 0.9*cos(2*pi*f1*t) + 1.1*cos(2*pi*f2*t);
   y = 1.1*sin(2*pi*f1*t) + 1.4*sin(2*pi*f2*t);

   shape = 2*exp(-4*(t-1.5).^2/0.5) + 3*exp(-4*(t-3.5).^2/0.5);

      % pack into object

   oo = mesh('alt');                  % alternative type
   oo.par.title = sprintf('A Stupid Beat (%s)',datestr(now));
   oo.data.t = t;
   oo.data.x = x .* shape + 0.02*randn(size(t));
   oo.data.y = y .* shape + 0.03*randn(size(t));
end
