function oo = bqr(o,varargin)          % BQR Plugin                    
%
% BQR   BQR plugin. 2D data analysis for x/y based data   
%
%            bqr(cordoba)              % register plugin
%
%            oo = bqr(o,func)          % call local function
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORDOBA, PLUGIN, SAMPLE, BASIS
%
   if (nargin == 0) || isempty(figure(o))
      o = pull(corazon);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@New,@NewBqr,...
                       @Import,@Export,@Collect,@Signal,...
                       @ReadBqrDat,@ReadBqrM,@WriteBqrDat);
   oo = gamma(oo);
end

%==========================================================================
% Plugin Registration
%==========================================================================

function o = Setup(o)                  % Setup Registration            
   o = Register(o);                    % register plugins
   rebuild(o);                         % rebuild menu
end
function o = Register(o)               % Plugin Registration           
   name = class(o);
   plugin(o,[name,'/shell/New'],{mfilename,'New'});
   plugin(o,[name,'/shell/Import'],{mfilename,'Import'});
   plugin(o,[name,'/shell/Export'],{mfilename,'Export'});
   plugin(o,[name,'/shell/Collect'],{mfilename,'Collect'});
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function oo = New(o)                   % New Menu                      
%
   setting(o,{'sample.format'},'#TKP02');  % quality run ('#TKP02')
   setting(o,{'sample.gantry'},0);         % dual gantry
   setting(o,{'sample.m'},4);
   setting(o,{'sample.n'},5);
   setting(o,{'sample.r'},10);
   setting(o,{'sample.corner'},'BotLeft');
   setting(o,{'sample.process'},'ColSawtooth');
   setting(o,{'sample.zigzag'},'seq');
   setting(o,{'sample.sigma'},0.2);
   setting(o,{'sample.dphi'},0.1);
   setting(o,{'sample.drift'},5);
   setting(o,{'sample.scale'},10);
   setting(o,{'sample.lambda'},3);
   setting(o,{'sample.nonlin.x'},1);
   setting(o,{'sample.nonlin.y'},1);
   setting(o,{'sample.axerr.x1'},0);
   setting(o,{'sample.axerr.x2'},0);
   setting(o,{'sample.axerr.x3'},0);
   setting(o,{'sample.axerr.x4'},0);
   setting(o,{'sample.axerr.y1'},0);
   setting(o,{'sample.axerr.y2'},0);
   setting(o,{'sample.axerr.y3'},0);
   setting(o,{'sample.axerr.y4'},0);

      % setup menu
      
   %oo = mhead(o,'BQR',{},'$BQR$');
   oo = mhead(o,'Base Calib & Quality Run (BQR)',{},'$BQR$');
   
   ooo = mitem(oo,'Create',{@NewBqr});
   ooo = Preset(oo);
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Format','','sample.format');
   choice(ooo,{{'Base Calibration','#BKB03'},{'Quality Run','#TKP02'}});
   ooo = mitem(oo,'Gantry','','sample.gantry');
   choice(ooo,{{'Left',1},{'Right',2},{'Dual',0}});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'m: Number of Rows','','sample.m');
          choice(ooo,[2:5,10,15,20,80]);
   ooo = mitem(oo,'n: Number of Columns','','sample.n');
          choice(ooo,[2:5,10,15,20,75]);
   ooo = mitem(oo,'r: Number of Repeats','','sample.r');
          choice(ooo,[1:5,10,20,50,100,200,500,1000]);
   ooo = mitem(oo,'-');             
   ooo = mitem(oo,'Corner to Start','','sample.corner');
   list = {{'Top Left','TopLeft'},{'Top Right','TopRight'},...
           {'Bottom Left','BotLeft'},{'Bottom Right','BotRight'}};
          choice(ooo,list);
   ooo = mitem(oo,'Processing','','sample.process');
   list = {{'Columns @ Sawtooth','ColSawtooth'},...
           {'Columns @ Meander','ColMeander'},...
           {'Rows @ Sawtooth','RowSawtooth'},...
           {'Rows @ Meander','RowMeander'}};
          choice(ooo,list);
   ooo = mitem(oo,'Zig-Zag','','sample.zigzag');
   list = {{'Sequential','seq'},{'Alternating','alt'},...
            {'Random','rand'}};
          choice(ooo,list);
   ooo = mitem(oo,'-');             
   ooo = mitem(oo,'Sigma [�]','','sample.sigma');
          choice(ooo,[0:0.05:0.5]);
   ooo = mitem(oo,'-');  
   ooo = mitem(oo,'Drift');
   oooo = mitem(ooo,'Rotation [�]','','sample.dphi');
          choice(oooo,[0:0.1:0.5,1:5,10 20 30 45]);
   oooo = mitem(ooo,'Offset [�]','','sample.drift');
          choice(oooo,[0:0.5:2, 3:10, 15:5:30]);
   oooo = mitem(ooo,'Scaling [�]','','sample.scale');
          choice(oooo,[0:0.5:2, 3:10, 15:5:30]);
   oooo = mitem(ooo,'Lambda','','sample.lambda');
          choice(oooo,[0:0.2:1, 1.5:0.5:5]);
   ooo = mitem(oo,'Nonlinearity Error');
   charm(mitem(ooo,'Gain X','','sample.nonlin.x'));
   charm(mitem(ooo,'Gain Y','','sample.nonlin.y'));
   ooo = mitem(oo,'Axis Error');
   charm(mitem(ooo,'X Harmonic 1','','sample.axerr.x1'));
   charm(mitem(ooo,'X Harmonic 2','','sample.axerr.x2'));
   charm(mitem(ooo,'X Harmonic 3','','sample.axerr.x3'));
   charm(mitem(ooo,'X Harmonic 4','','sample.axerr.x4'));
   mitem(ooo,'-');
   charm(mitem(ooo,'Y Harmonic 1','','sample.axerr.y1'));
   charm(mitem(ooo,'Y Harmonic 2','','sample.axerr.y2'));
   charm(mitem(ooo,'Y Harmonic 3','','sample.axerr.y3'));
   charm(mitem(ooo,'Y Harmonic 4','','sample.axerr.y4'));
end
function oo = Import(o)                % Import Menu Items             
   oo = mitem(o,'Base Calib & Quality Run (BQR)');
   ooo = mitem(oo,'Data File (.dat)',{@ImportCb,'ReadBqrDat','.dat',@cordoba});
   ooo = mitem(oo,'M-File (.m)',{@ImportCb,'ReadBqrM','.m',@cordoba});
   return
   
   function o = ImportCb(o)            % Import Log Data Callback
      drv = arg(o,1);                  % export driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      read = eval(['@',mfilename]);    % reader method

      co = cast(o);                    % casted object
      list = import(co,drv,ext,read);  % import object from file
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mitem(o,'Base Calib & Quality Run (BQR)');
   set(mitem(oo,inf),'enable',onoff(o,{'bqr'}));
   ooo = mitem(oo,'Data File (.dat)',{@ExportCb,'WriteBqrDat','.dat',@cordoba});
   return
   
   function oo = ExportCb(o)           % Export Callback               
      oo = current(o);
      if container(oo)
         message(oo,'Select an object for export!');
      else
         drv = arg(o,1);               % export driver
         ext = arg(o,2);               % file extension
         cast = arg(o,3);              % cast method
         write = eval(['@',mfilename]);% writer method

         co = cast(oo);                % casted object
         export(co,drv,ext,write);     % export object to file
      end
   end
end
function oo = Collect(o)               % Configure Collection          
   table = {{@read,'cordoba','ReadPkgPkg','.pkg'},...
            {@bqr,'cordoba','ReadBqrDat','.dat'},...
            {@bqr,'cordoba','ReadBqrM', '.m'}};
   collect(o,{'pln','smp'},table);
   oo = o;                             % pass through
end
function oo = Preset(o)                % Presetting of Settings        
   oo = mitem(o,'Preset');              
   ooo = mitem(oo,'Steady Data',{@SteadyCb});
   ooo = mitem(oo,'Noise Free Data',{@NoiseFreeCb});
   ooo = mitem(oo,'Axis Error',{@AxisErrorCb});
   return
  
   function o = SteadyCb(o)            % Steady Callback               
      setting(o,'sample.dphi',0);
      setting(o,'sample.drift',0);
      setting(o,'sample.scale',0);
      setting(o,'sample.lambda',0);
      rebuild(o,'$BQR$',{mfilename,'New'});  % rebuild New menu
   end
   function o = NoiseFreeCb(o)
      setting(o,'sample.sigma',0.0);
      rebuild(o,'$BQR$',{mfilename,'New'});  % rebuild New menu
   end      
   function o = AxisErrorCb(o)
      setting(o,'sample.axerr.x1',0.5);
      setting(o,'sample.axerr.x2',0.4);
      setting(o,'sample.axerr.x3',0.3);
      setting(o,'sample.axerr.x4',0.0);
      setting(o,'sample.axerr.y1',0.6);
      setting(o,'sample.axerr.y2',-0.5);
      setting(o,'sample.axerr.y3',0.4);
      setting(o,'sample.axerr.y4',0.0);
      rebuild(o,'$BQR$',{mfilename,'New'});  % rebuild New menu
   end
end
function oo = NewBqr(o)                % New BQR Object Callback       
%
   o = with(o,'sample');
   
   m = opt(o,{'m',4});                 % row size = 4
   n = opt(o,{'n',5});                 % col size = 5
   r = opt(o,{'r',10});                % repeats = 5
   zigzag = opt(o,{'zigzag','seq'});   % sequential by default
   
   fmt = opt(o,{'format','#TKP02'});   % BQR object's format
   gantry = opt(o,{'gantry',0});       % BQR object's format
   
   sigma = opt(o,{'sigma',0.2});       % sigma = 0.2
   meth = opt(o,{'method','tlrs'});    % TopLeftRowSawtooth
   
   dphi = opt(o,{'dphi',0})*pi/180;    % rotation 
   drift = opt(o,{'drift',0});         % drift
   scale = opt(o,{'scale',0});         % scaling
   lambda = opt(o,{'lambda',0})+1e-10; % lambda (speed of drift)

   nonlin = opt(o,{'nonlin',NaN});     % non-linearity gains
   axerr = opt(o,{'axerr',NaN});       % axis error gains
   
   %sizes = [m n r];
   
   ix = 1:n;  iy = (m:-1:1);
   px = (ix-1)*2*pi/(n-1);             % phi x
   py = (iy-1)*2*pi/(m-1);             % phi y
   
   dx = -(n-1)/2:1:(n-1)/2;  dx = dx(ix) / max(abs(dx)) * scale;
   dy = -(m-1)/2:1:(m-1)/2;  dy = dy(iy) / max(abs(dy)) * scale;
   
   assert(length(ix)==length(dx) && length(iy)==length(dy));
   
   fx = ix + nonlin.x * 10*sin(ix); 
   fy = iy + nonlin.y * 10*cos(iy);
   
   dx = dx + axerr.x1*sin(1*px) + axerr.x2*sin(2*px) + ...
             axerr.x3*sin(3*px) + axerr.x4*sin(4*px);
   dy = dy + axerr.y1*sin(1*py) + axerr.y2*sin(2*py) + ...
             axerr.y3*sin(3*py) + axerr.y4*sin(4*py);
   
   [Ax,Ay] = meshgrid(fx,fy);
   [Qx,Qy] = meshgrid(ix,iy);
   [Dx,Dy] = meshgrid(dx,dy);
%   
% Qx, Qy, Dx and Dy are now established (mxn matrices). The tricky part
% is the system vector, since it defines the actual zig-zag order.
%
%
% ok - major challenges already mastered. continue with straight forward
% stuff
%
   t = [];  dx = [];  dy = [];  qx = [];  qy = [];  
   ax = [];  ay = [];  sys = [];
   tr = 0;  dt = 0.5;
   
   
   for (i=1:r)
      sysi = gantry + zeros(1,m*n);    % default: system info vector
      if (gantry == 0)                 % dual gantry?
         sysi = System(o,m,n,zigzag);  % compose a proper system vector
      end
   
         % calculate indices with respecting system vector. Function
         % 'method' does all the magic ...
   
      [idx,Idx] = method(o,meth,m,n,sysi); % do the magic ...
      Sys = sysi(Idx);
      
      t = [t, tr + dt*(0:length(idx)-1)];
      tr = max(t) + dt;
      
      nx = sigma*randn(size(idx));     % axis noise x
      ny = sigma*randn(size(idx));     % axis noise y
      
      d = [Dx(idx); Dy(idx)] * [1 + (1-exp(-i*lambda/r))];
      
         % make a linear transformation
      
      R = [cos(i*dphi) -sin(i*dphi);  sin(i*dphi) cos(i*dphi)];
      d = R*d + i*drift/r;
      
      dx = [dx, d(1,:)+nx];
      dy = [dy, d(2,:)+ny];

      ax = [ax, Ax(idx)];
      ay = [ay, Ay(idx)];
      
      qx = [qx, Qx(idx)];
      qy = [qy, Qy(idx)];
      
      sys = [sys, Sys(idx)];
      assert(all(sysi==Sys(idx)));
   end
%
% from here 'oo' will be a newly constructed BQR-type CORDOBA object
%
   oo = opt(cordoba('bqr'),opt(o));
   oo = set(oo,'title',[o.now,' Sample BQR object']);
   oo = set(oo,'comment',{['Created by: sample(bqr,''tlrs'')']});
   oo = set(oo,'sizes',[m n r]);
   oo = set(oo,'method',meth);
   oo = set(oo,'format',fmt);
   oo = set(oo,'distance',[1000 1000]);
   
   oo = data(oo,'time',t,'dx',dx,'dy',dy);
   oo = data(oo,'ax',ax,'ay',ay,'qx',qx,'qy',qy,'sys',sys);
   
   oo = Config(oo);                    % Provide some object info
   paste(o,{oo});
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu                   
   if isequal(type(current(o)),'bqr')
      oo = mitem(o,'Drift Coordinates DX/DY',{@DriftXY});
      oo = mitem(o,'Position Coordinates PX/PY',{@PositionXY});
      oo = mitem(o,'Isometric Coordinates QX/QY',{@IsometricXY});
      oo = mitem(o,'Axis Coordinates AX/AY',{@AxisXY});
   end
   return
   
   function o = DriftXY(o)             % Configure for Drift Signal XY 
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'dx',{1,'r'});
      o = config(o,'dy',{2,'b'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = AxisXY(o)              % Configure for Axis Signal XY  
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'ax',{1,'r'});
      o = config(o,'ay',{2,'b'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = PositionXY(o)          % Configure for Position Signal XY  
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'px',{1,'r'});
      o = config(o,'py',{2,'b'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = IsometricXY(o)         % Configure for Isometric Signal XY  
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'qx',{1,'r'});
      o = config(o,'qy',{2,'b'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function sys = System(o,m,n,zigzag)    % Compose System Vector         
%
% SYSTEM   Compose proper system vector
%
%    The whole procedure is fairly tricky, I don't make the trial to ex-
%    plain it to everybody.
%
   'take a beer before you change something here!';
%   
% Let's start with simple things - the creation of the system-number 
% matrix. Independently of the actual method we create the 'Sys' matrix by
% assuming 'blcs' method, where the first half of the time sequence is 
% done by the left system (1) and the second half is done by the right
% system (2).
%
   k = round(m*n/2);                   % middle index
   sys1 = 1*ones(1,k);
   sys2 = 2*ones(1,m*n-k);
   sys = [sys1,sys2];
   assert(length(sys)==m*n);
%   
% Now, as we have the system matrix (see how it looks!) we can definitely
% forget the way how we created it. Now we have to incorporate the zig-zag
% mode
%
   'take another beer!';
%
% In sequential zigzag mode we assume that in the first phase only system 1
% is working and system 2 is idle. After that system 2 is working and sys-
% tem 1 is idle. Easy to create the system vector.
%
   switch zigzag
      case 'seq'                       % sequential mode
         sys = [sys1,sys2];            % go with current 'sys'
      case 'alt'
         sys0 = [1;2]*ones(1,m*n,1);
         sys0 = sys0(:)';
         sys = sys0(1:m*n);            % alternating sequence
      case 'rand'
         sys = [];
         while(~isempty(sys1) && ~isempty(sys2))
            if (rand >= 0.5)
               sys(1,end+1) = 1;  sys1(1) = [];
            else
               sys(1,end+1) = 2;  sys2(1) = [];
            end
         end
         sys = [sys,sys1,sys2];
      otherwise
         error('bad zigzag mode!');
   end
end
function o = Config(o)                 % Configurate plotting          
%
   o = subplot(o,'layout',1);
   o = category(o,1,[0 0],[0 0],'�');
   o = category(o,2,[0 0],[0 0],'1');

   o = config(o,'ax',{0,'r',1});
   o = config(o,'ay',{0,'b',1});
   o = config(o,'dx',{1,'r',1});
   o = config(o,'dy',{2,'b',1});
   o = config(o,'px',{0,'r',1});
   o = config(o,'py',{0,'b',1});
   o = config(o,'qx',{0,'r',1});
   o = config(o,'qy',{0,'b',1});
   o = config(o,'sys',{0,'k',2});
end

%==========================================================================
% Read/Write Drivers
%==========================================================================

function oo = ReadBqrDat(o)            % Read Bqr .dat File            
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'bqr');
      message(o,'No BQR log data file!',['Type: ',oo.type]);
      oo = [];
   end
end
function oo = ReadBqrM(o)              % read BQR object from .m file  
   is = @carabull.is;                  % short hand
   path = arg(o,1);                    % get path
   [dir,file,ext] = fileparts(path);
   
   DanaobjFunctionality(o);            % provide DANAOBJ functionality 
   try
      current = cd;                    % save current path
      cd(dir);
      cmd = ['odat = ',file,';'];      % read object data
      eval(cmd);
      
         % depending on DANA toolbox is installed we get an object
         % otherwise we get a struct, what we prefer!
      
      if isa(odat,'danaobj')           % if DANA toolbox installed
         odat = data(odat);            % fetch object's data
      end
      cd(current);                     % restore current directory
   catch
      cd(current);                     % restore current directory
      message(o,'Cannot read BQR log file',path);
      oo = [];                         % no object read
      return
   end
   
   oo = [];
   if ~isempty(odat)
      list = {};
      for (i=1:length(odat.data))
         odi = odat.data{i};           % object data i
         oo = cordoba('bqr');

            % get some parameters
            
         oo.par.title = odi.title;
         oo.par.date = odi.date{1};
         oo.par.time = odi.time{1};
         oo.par.sizes = [odi.points(1),odi.points(2),length(odi.t)];
         oo.par.format = odi.format;
         oo.par.machine = odi.machine;
         oo.par.pitch = odi.distance;
         oo.par.method = ExamineMethod(odi);
         oo.par.version = ['corazon ',version(corazon)];
         oo.par.package = ExtractPackage(oo.par.machine);

            % examine gantry
            
         if oo.find('left',file)
            oo.par.system = 'L';
         elseif oo.find('right',file)
            oo.par.system = 'R';
         else
            oo.par.system = '';
         end
         
            % initialize streams
            
         oo.data.t = [];
         oo.data.ax = [];
         oo.data.ay = [];
         oo.data.qx = [];
         oo.data.qy = [];
         oo.data.dx = [];
         oo.data.dy = [];
         
         system = oo.assoc(oo.par.system,{{'L','Left'},{'R','Right'},''});
         id = [oo.par.package,'.',upper(oo.type)];
         
         switch odi.format
            case '#BKB03'
               oo.par.kind = 'bcal';
               %oo.par.title = ['Base Calibration ',system,' (',id,')'];
               oo.par.title = ['Base Calibration ',system];
               oo.data.rx = [];
               oo.data.ry = [];
            case '#TKP02'
               oo.par.kind = 'qrun';
               %oo.par.title = ['Quality Run ',system,' (',id,')'];
               oo.par.title = ['Quality Run ',system];
               oo.data.px = [];
               oo.data.py = [];
         end
         for (j = 1:length(odi.t))
            t = odi.t{j}';    oo.data.t  = [oo.data.t,t(:)'];
            ax = odi.Ax{j}';  oo.data.ax = [oo.data.ax, ax(:)'];
            ay = odi.Ay{j}';  oo.data.ay = [oo.data.ay, ay(:)'];
            qx = odi.Qx{j}';  oo.data.qx = [oo.data.qx, qx(:)'];
            qy = odi.Qy{j}';  oo.data.qy = [oo.data.qy, qy(:)'];
            switch odi.format
               case '#BKB03'
                  rx = odi.Rx{j}';  oo.data.rx = [oo.data.rx, rx(:)'];
                  ry = odi.Ry{j}';  oo.data.ry = [oo.data.ry, ry(:)'];
                  dx = odi.Ax{j}' - odi.Qx{j}';
                  oo.data.dx = [oo.data.dx, dx(:)'];
                  dy = odi.Ay{j}' - odi.Qy{j}';  
                  oo.data.dy = [oo.data.dy, dy(:)'];
               case '#TKP02'
                  px = odi.Px{j}';  oo.data.px = [oo.data.px, px(:)'];
                  py = odi.Py{j}';  oo.data.py = [oo.data.py, py(:)'];
                  dx = odi.Dx{j}';  oo.data.dx = [oo.data.dx, dx(:)'];
                  dy = odi.Dy{j}';  oo.data.dy = [oo.data.dy, dy(:)'];
            end
         end
         
         oo = launch(oo,launch(o));
         list{end+1} = Config(oo);
      end
      
      oo = cordoba('bqr');             % create a container object
      oo.par.format = odat.format;     % copy format
      oo.par.title = odat.title;       % copy title
      oo.data = list;                  % add list of objects
   end
end
function oo = WriteBqrDat(o)           % Write BQR .dat File           
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function DanaobjFunctionality(o)       % provide DANAOBJ functionality 
%
% Reading a DANAOBJ means just executing the according .m file. At the end
% of the execution the .m file calls the DANAOBJ constructor which con-
% structs a DANAOBJ from the reviously prepared data structure. 
%
% This procedure works only if the DANA toolboox is loaded (included in the
% MATLAB path). If not then we need to provide a dummy function which
% passes the prepared datastructure to the outside world. This dummy
% function is located at */guerilla/danahack/danaobj.m
%
% The actual function DanaobjFunctionality makes sure that a proper func-
% tionality for DANAOBJ is available, either by verifying that DANA toolbox
% is installed, or providing a path for dummy DANAOBJ function.
%
   if exist('danaobj') ~= 2
      cordobapath = which('cordoba');
      [dir,file,ext] = fileparts(cordobapath);
      [dir,file] = fileparts(dir);
      dir = [dir,'/','hacks'];
      addpath(dir);                    % add '*/hacks' to MATLAB path 
   
      if exist('danaobj') ~= 2
         message(o,'Cannot setup for DANAOBJ functionality!');
      end
   end
end
function meth = ExamineMethod(odi)     % examine method of processing  
   iif = @carabull.iif;                % short hand
   
   t = odi.t{1};
   [m,n] = size(t);
   t = t(m:-1:1,:);
   
      % artificially expand for single rows or single columns
      
   if (m == 1)                         % single row
      t = [t; t+max(t(:))+1];          % artificially add row
      [m,n] = size(t);
   end
   if (n == 1)                         % single column
      t = [t, t+max(t(:))+1];          % artificially add column
      [m,n] = size(t);
   end
   
      % now t is mapped to a rectangle with upper left corner index being
      % (1,1) and lower lewft corner being (m,n)
      
   tmin = min(min(t));
   if t(1,1) == tmin
      start = 'tl';                    % start at top-left
      if t(1,n) < t(m,1)               % row wise
         meth = [start,'r',iif(t(2,1)<t(2,n),'s','m')];   
      else                             % column wise
         meth = [start,'c',iif(t(1,2)<t(m,2),'s','m')];   
      end
   elseif t(m,1) == tmin
      start = 'bl';                    % start at bottom-left
      if t(m,n) < t(1,1)               % row wise
         meth = [start,'r',iif(t(m-1,1)<t(m-1,n),'s','m')];   
      else                             % column wise
         meth = [start,'c',iif(t(m,2)<t(1,2),'s','m')];   
      end
   elseif t(1,n) == tmin
      start = 'tr';                    % start at top-right
      if t(1,1) < t(m,n)               % row wise
         meth = [start,'r',iif(t(2,n)<t(2,1),'s','m')];   
      else                             % column wise
         meth = [start,'c',iif(t(1,n-1)<t(m,n-1),'s','m')];   
      end
   elseif t(m,n) == tmin
      start = 'br';                    % start at bottom-right
      if t(m,1) < t(1,n)               % row wise
         meth = [start,'r',iif(t(m-1,n)<t(m-1,1),'s','m')];   
      else                             % column wise
         meth = [start,'c',iif(t(m,n-1)<t(1,n-1),'s','m')];   
      end
   else
      fprintf('*** Warning: cannot extract method!\n');
      fprintf('             Use blcs as a default!\n');
      beep
      meth = 'blcs';
   end   
end
function pkg = ExtractPackage(machine) % extract package from machine  
   pkg = '';
   for (i=1:length(machine))
      c = machine(i);
      if ('0' <= c && c <= '9')
         pkg = [pkg,c];
      end
   end
   
   pkg = ['0000',pkg];                 % add leading zeros
   pkg = [pkg(end-3:end),'.00'];       % extracted package name
end