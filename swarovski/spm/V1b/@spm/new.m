function oo = new(o,varargin)          % JUNK7 New Method
%
% NEW   New SPM object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(spm,'Simple')    % some simple data
%           o = new(spm,'Wave')      % some wave data
%           o = new(spm,'Beat')      % some beat data
%
%       See also: SPM, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Simple,@Wave,@Beat,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'Simple (SMP)',{@Callback,'Simple'},[]);
   oo = mitem(o,'-');
   oo = mitem(o,'Wave (ALT)',{@Callback,'Wave'},[]);
   oo = mitem(o,'Beat (ALT)',{@Callback,'Beat'},[]);
end
function oo = Callback(o)
   mode = arg(o,1);
   oo = new(o,mode);
   oo = launch(oo,launch(o));          % inherit launch function
   paste(o,{oo});                      % paste object into shell
end

%==========================================================================
% New Simple Object
%==========================================================================

function oo = Simple(o)                % New wave object
   om = 2*pi*0.5;                      % 2*pi * (0.5 Hz)

   t = 0:0.01:10;                      % time vector
   x = (2+rand)*sin(om*t) + (1+rand)*sin(3*om*t+randn);
   y = (1.5+rand)*cos(om*t) + (0.5+rand)*cos(2*om*t+randn);

      % pack into object

   oo = spm('smp');                  % simple type
   oo.par.title = sprintf('Some Simple Function (%s)',datestr(now));
   oo.data.t = t;
   oo.data.x = randn + x + 0.1*randn(size(t));
   oo.data.y = randn + y + 0.12*randn(size(t));
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

   oo = spm('alt');                  % alternative type
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

   oo = spm('alt');                  % alternative type
   oo.par.title = sprintf('A Stupid Beat (%s)',datestr(now));
   oo.data.t = t;
   oo.data.x = x .* shape + 0.02*randn(size(t));
   oo.data.y = y .* shape + 0.03*randn(size(t));
end
