function oo = basis(o,varargin)        % Basis Plugin                  
%
% BASIS   Basis plugin - to analyse basis tests, loke vibration test and
%         BMC test. Supported types: 'vsc', 'vuc', 'bmc'
%
%             basis(caramel)           % register plugin
%
%             oo = basis(o,func)       % call local simple function
%
%         Local functions:
%            oo = basis(o,'New')       % add New/Basis menu
%            oo = basis(o,'Import')    % add Import/Basis menu
%            oo = basis(o,'Export')    % add Export/Basis menu
%
%            oo = Config(oo)           % configure plotting of basis obj.
%
%         Import Driver
%            oo = basis(o,'ReadVibTxt','.vib')
%            oo = basis(o,'ReadVibDat','.dat')
%            oo = basis(o,'ReadBmcTxt','.txt')
%            oo = basis(o,'ReadBmcDat','.dat')
%
%         See also: CARAMEL, SAMPLE, PBI, DANA, KEFALON
%
   if (nargin == 0)
      o = pull(carabao);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,...
                       @New,@Import,@Export,@Collect,@Signal,@Analysis,...
                       @VibrationCb,@Config,...
                       @ReadVibVib,@ReadVibTxt,@ReadVibDat,@ReadBmcTxt,@ReadBmcDat,@ReadBmcPbi,...
                       @WriteVibTxt,@WriteVibDat,@WriteBmcTxt,@WriteBmcDat);
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
   plugin(o,[name,'/shell/Analysis'],{mfilename,'Analysis'});
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function o = New(o)                    % add New/Basis Menu            
   setting(o,{'plugin.basis.sigma'},0.2);
   setting(o,{'plugin.basis.drift'},1.5);
   setting(o,{'plugin.basis.jump'},0.2);
   setting(o,{'plugin.basis.gantry'},'L');
   
   oo = mitem(o,'Basis');
   ooo = mitem(oo,'BMC (Basis Machine Capability)',{@NewObj,'bmc'});
   ooo = mitem(oo,'VUC (Vibration Test UC)',{@NewObj,'vuc'});
   ooo = mitem(oo,'VSC (Vibration Test SC)',{@NewObj,'vsc'});
   ooo = mitem(o,'-');
   ooo = mitem(oo,'Sigma',{},'plugin.basis.sigma');
   charm(ooo);
   ooo = mitem(oo,'Drift',{},'plugin.basis.drift');
   charm(ooo);
   ooo = mitem(oo,'Jump',{},'plugin.basis.jump');
   charm(ooo);
   ooo = mitem(oo,'Gantry',{},'plugin.basis.gantry');
   choice(ooo,{{'Left','L'},{'Right','R'}});
   return
   
   function oo = NewObj(o)             % Create New BMC/VUC/VSC object         
      o = with(o,'plugin.basis');
      drift = opt(o,{'drift',2});      % drift of vibration test
      jump = opt(o,{'jump',0.1});      % jump of vibration test
      sig = opt(o,{'sigma',0.2});      % sigma for x/y
      Sig = 10*sig;                    % sigma for theta
            
      typ = arg(o,1);                  % fetch type arg
      m = 1;  n = 1; 
      r = o.assoc(typ,{{'bmc',80},302});
      sz = m*n*r;                      % size of data vector
      
      t = 1:m*n*r;                     % create a time vector
      x = sig*randn + sig*randn(1,sz); % create an 'x' data vector
      y = sig*randn + sig*randn(1,sz); % create an 'y' data vector
      th = Sig*randn + Sig*randn(1,sz);% create a 'th' vector

         % create a caramel object with t,x,y & th

      oo = caramel(typ);               % construct CARAMEL object
      switch typ
         case 'bmc'
            oo = trace(oo,t,'x',x,'y',y,'th',th);
         case 'vuc'
            x = 1000 + x/4 + t*drift/max(t) + jump*sign(t-max(t)/2);
            y = 1000 + y/4 - t*drift/max(t) - jump*sign(t-max(t)/2);
            oo = trace(oo,t,'x',x,'y',y);
            oo.type = 'vib';
            oo.par.kind = 'uc';
         case 'vsc'
            x = 1000 + x/4 - t*drift/max(t) + jump*sign(t-max(t)/2);
            y = 1000 + y/4 + t*drift/max(t) - jump*sign(t-max(t)/2);
            oo = trace(oo,t,'x',x,'y',y);
            oo.type = 'vib';
            oo.par.kind = 'sc';
      end
      
      system = get(o,{'system','L'});
      oo = set(oo,'system',system);
      oo = set(oo,'sizes',[m,n,r]);    % set data sizes
      oo = set(oo,'method','blcs');    % set processing method

         % provide title & comments for the caracook object

      [date,time] = o.now;
      oo = set(oo,'title',[date,' @ ',time,' ',upper(typ),' Data']);
      oo = set(oo,'comment',{'(gaussian random data)',['Type: ',oo.type]});
      oo = set(oo,'date',date,'time',time);
      mnmb = 95088602200 + round(0.1+9.9*rand);
      oo = set(oo,'machine',sprintf('%08.0f',mnmb));
      oo = set(oo,'project','Sample Project');

         % provide plot defaults and paste object into shell
         % and display object's info on screen

      oo = Config(oo,typ);             % setup plot configuration
      %oo.tag = o.tag;                 % inherit tag from parent
      %oo = balance(oo);               % balance object
      paste(o,{oo});                   % paste new object into container
   end
   function o = Config(o,typ)
      if o.is(typ,{'vuc','vsc'})
         typ = 'vib';                  % vibration test
      end
      o.type = typ;
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = category(o,1,[-2 2],[0 0],'µ');
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{2,'b',1});
      if o.is(typ,'bmc')
         o = category(o,2,[-20 20],[0 0],'m°');
         o = config(o,'th',{3,'g',2});
      end
   end
end
function o = Import(o)                 % add Import/Basis Menu         
   oo = mitem(o,'Basis');
   ooo = mitem(oo,'Vibration Test (.txt)',{@ImportCb,@ReadVibTxt,'.txt',@caramel});
   ooo = mitem(oo,'Vibration Test (.dat)',{@ImportCb,@ReadVibDat,'.dat',@caramel});
   ooo = mitem(oo,'Vibration Test (.vib)',{@ImportCb,@ReadVibVib,'.vib',@caramel});
   ooo = mitem(o,'-');
   ooo = mitem(oo,'BMC Test (.txt)',{@ImportCb,@ReadBmcTxt,'.txt',@caramel});
   ooo = mitem(oo,'BMC Test (.dat)',{@ImportCb,@ReadBmcDat,'.dat',@caramel});
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
function o = Export(o)                 % add Export/Basis Menu         
   oo = mitem(o,'Basis');              % add menu header
   set(mitem(oo,inf),'enable',onoff(o,'vib,bmc'));
   ooo = mitem(oo,'Vibration Test (.txt)',{@ExportCb,'WriteVibTxt','.txt',@caramel});
   set(mitem(ooo,inf),'enable',onoff(o,'vib'));
   ooo = mitem(oo,'Vibration Test (.dat)',{@ExportCb,'WriteVibDat','.dat',@caramel});
   set(mitem(ooo,inf),'enable',onoff(o,'vib'));
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'BMC Test (.txt)',{@ExportCb,'WriteBmcTxt','.txt',@caramel});
   set(mitem(ooo,inf),'enable',onoff(o,'bmc'));
   ooo = mitem(oo,'BMC Test (.dat)',{@ExportCb,'WriteBmcDat','.dat',@caramel});
   set(mitem(ooo,inf),'enable',onoff(o,'bmc'));
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
function o = Collect(o)                % Configure Collection          
   table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
            {@basis,'caramel','ReadVibDat','.dat'},...
            {@basis,'caramel','ReadVibTxt','.txt'},...
            {@basis,'caramel','ReadVibVib','.vib'}};
   collect(o,{'vib'},table); 

   table = {{@read,'caramel','ReadPkgPkg','.pkg'},...
            {@basis,'caramel','ReadBmcDat','.dat'},...
            {@basis,'caramel','ReadBmcTxt','.txt'},...
            {@basis,'caramel','ReadBmcPbi','.pbi'}};
   collect(o,{'bmc'},table); 
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu                   
   switch active(o)                    % depending on active type
      case {'bmc'}
         oo = mitem(o,'X and Y and Theta',{@Config},'X_Y_Th');
         oo = mitem(o,'X/Y and Theta',{@Config},'XY_Th');
         oo = mitem(o,'X and Y',{@Config},'X_Y');
         oo = mitem(o,'X/Y',{@Config},'XY');
      case {'vib'}
         oo = mitem(o,'X/Y',{@Config},'XY');
         oo = mitem(o,'X and Y',{@Config},'X_Y');
   end
end
function o = Config(o)                 % Plot Configuration            
   o = config(o,[],active(o));         % init config
   o = subplot(o,'layout',1);          % layout with 1 subplot column   
   o = category(o,1,[-2 2],[0 0],'µ');

   switch o.type
      case {'bmc','pbi','mbc'}
         o = subplot(o,'Color',[0.8 0.9 1]);
         o = category(o,2,[-20 20],[0 0],'m°');
      case 'vib'
         o = subplot(o,'Color',[0.9 0.8 1]);
      otherwise
         o = subplot(o,'Color',[1 1 1]);
   end

   mode = o.either(arg(o,1),'XYandTh');
   switch arg(o,1)
      case 'X_Y_Th'
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{2,'b',1});
         o = config(o,'th',{3,'g',2});
      case 'XY_Th'
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{1,'b',1});
         o = config(o,'th',{2,'g',2});
      case 'X_Y'
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{2,'b',1});
      case 'XY'
         o = config(o,'x',{1,'r',1});
         o = config(o,'y',{1,'b',1});
   end
   o = subplot(o,'Signal',mode);       % set signal mode
   
   change(o,'Bias','drift');           % change bias mode, update menu
   change(o,'Config');                 % change config, rebuild & refresh
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                 
   oo = [];
   if isequal(onoff(o,'vib'),'on')
      oo = mhead(o,'Vibration Analysis');
      ooo = mitem(oo,'VUC/VSC Analysis',{@VibrationCb,'analysis'});
      ooo = mitem(oo,'-');
      ooo = mitem(oo,'VUC/VSC Measurements',{@VibrationCb,'measure'});
      ooo = mitem(oo,'VUC/VSC Noise',{@VibrationCb,'noise'});
   end
end   
function o = VibrationCb(o)            % Vibration Analysis Callback   
   refresh(o,o);                       % refresh here
   filt.window = 100;                  % setup filter window
   filt.type = 9;                      % setup filter type
   filt.mode = 'noise';                % setup filter mode

   o = Config(o);                      % configure plotting

   list = basket(opt(o,'basket.type','vib'));   % select 'vib' types
   if isempty(list)
      message(o,'No ''vibration test'' objects in basket!',...
                '(cannot perform vibration analysis)');
   else
      V = [];  J = [];
      cls(o);                          % clear screen
      for (i=1:length(list))
         oo = list{i};
%oo = opt(oo,opt(o));
         of = opt(oo,'filter',filt); 

         [x,y] = data(oo,'x','y');            % measurement data
         xn = x - filter(of,x);               % x-noise
         yn = y - filter(of,y);               % y-noise
         oo = data(oo,'xn',xn,'yn',yn);       % store in data properties

         l = length(xn); 
         idx1 = o.either(floor(l/2)+1:l,[]);
         idx2 = o.either(1:floor(l/2),[]);  
         xjump = mean(x(idx2)) - mean(x(idx1));
         yjump = mean(y(idx2)) - mean(y(idx1));
         
         xjump = o.iif(isnan(xjump),[],xjump);
         yjump = o.iif(isnan(yjump),[],yjump);
         
         xc = [x(idx1)+xjump/2,x(idx2)-xjump/2];
         yc = [y(idx1)+yjump/2,y(idx2)-yjump/2];

            % calculate noise again
            
         xcn = filter(of,xc) - xc;     % recalculated x-noise
         ycn = filter(of,yc) - yc;     % recalculated y-noise
         
         V = [V,[xcn;ycn]];            % collect noise vectors
         J = [J;[xjump,yjump]];        % collect jumps

         oo = opt(oo,'filter.mode','raw');
         plot(oo,'Stream');
         shg
      end
      oo = o.iif(length(list) > 1,o,oo);
      Labels(oo,V,J);
   end
   return
   
   function o = Config(o)              % Setup Proper Plot Config      
      o = config(type(o,'vib'),[]);    % reset all plots
      o = category(o,1,[-2.0 2.0],[0 0],'µ');
      o = category(o,2,[-0.5 0.5],[0 0],'µ');
      switch arg(o,1)                  % switch mode
         case 'analysis'
            o = subplot(o,'layout',2);
            o = config(o,'x', {1,'r',1});
            o = config(o,'xn',{2,'m',2});
            o = config(o,'y', {3,'b',1});
            o = config(o,'yn',{4,'c',2});
         case 'measure'
            o = subplot(o,'layout',1);
            o = config(o,'x',{1,'r',1});
            o = config(o,'y',{2,'b',1});
         case 'noise'
            o = subplot(o,'layout',1);
            o = config(o,'xn',{1,'m',2});
            o = config(o,'yn',{2,'c',2});
      end
   end
   function o = Labels(o,V,J)          % Provide Proper Labels         
      rd = @o.rd;                      % shorthand for utility
      if container(o)
         tit = 'Vibration Analysis';
      else
         tit = ['Vibration Analysis - ',get(o,'title')];
      end

         % calculate statistical numbers

      cat = 1;                         % category number is 1
      [spec,~,unit] = category(type(o,'vib'),cat);
      [Cpk,Cp,sig,avg,mini,maxi] = capa(o,V,spec);
      jmp = mean([J;J]);               % calculate mean jumps
      packtag = [get(o,'package'),'.',upper(o.type)];
      
      switch arg(o,1)                  % switch mode
         case 'analysis'
            subplot(221);
            title('Vibration Analysis');
            xlabel(sprintf('Cp = %3.1f/%3.1f @ x/y [%g%s/%g%s]',...
                   rd(Cp(1),2),rd(Cp(2),2),spec(2),unit,spec(2),unit));
            subplot(222);
            if ~container(o)
               title(get(o,'title'));
            end
            if o.is(opt(o,'style.title'),'package')
               xlabel(['Package ',packtag]);
            end
            subplot(223);
            title(sprintf('sigma x/y = %g%s/%g%s',...
                   rd(sig(1)),unit,rd(sig(2)),unit));
            xlabel('Measurements');
            subplot(224);
            title(sprintf('jump x/y = %g%s/%g%s',...
                           rd(jmp(1)),unit,rd(jmp(2)),unit));
            xlabel('Noise');
         case 'noise'
            subplot(211);
            if o.is(opt(o,'style.title'),'package')
               title([tit,' (',packtag,') [noise]']);
            else
               title([tit,' [noise]']);
            end
            xlabel(sprintf('sigma x/y = %g%s/%g%s, jump x/y = %g%s/%g%s',...
                   rd(sig(1)),unit,rd(sig(2)),unit,rd(jmp(1)),unit,rd(jmp(2)),unit));
            subplot(212);
            title(sprintf('Cp = %3.1f/%3.1f @ x/y [%g%s/%g%s]',...
                   rd(Cp(1),2),rd(Cp(2),2),spec(2),unit,spec(2),unit));
         case 'measure'
            subplot(211);
            if o.is(opt(o,'style.title'),'package')
               title([tit,' (',packtag,') [measurement]']);
            else
               title([tit,' [measurement]']);
            end
      end
   end
end

%==========================================================================
% Vibration Test Read/Write Driver
%==========================================================================

function oo = ReadVibTxt(o)            % Read Driver for VIB .txt File 
%
% READVIBTXT   Read diver for VIB .txt file (vibration test)
%
   path = arg(o,1);
   oo = read(o,'ReadVibTxt',path);
   oo = Config(oo);                    % overwrite configuration
end
function oo = ReadVibDat(o)            % Read Driver for VIB .dat File 
%
% READVIBDAT   Read diver for VIB .dat file (vibration test)
%
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'vib')
      message(o,'Error: no VIB data!',...
                'use File>Import>General>Log Data (.dat) to import data');
      oo = [];
      return
   end
   oo = Config(oo);                    % overwrite configuration
end
function oo = ReadVibVib(o)            % Read Driver for VIB .vib File 
%
% READVIBVIB   Read diver for VIB .vib file (vibration test)
%
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'vib')
      message(o,'Error: no VIB data!',...
                'use File>Import>General>Log Data (.dat) to import data');
      oo = [];
      return
   end
   
      % be tolerant to truncated data and adopt sizes dynamically
      
   sizes = get(oo,'sizes');
   t = data(oo,'t');                   % get time vector to see dimensions
   sizes(3) = length(t)/prod(sizes(1:2));
   oo = set(oo,'sizes',sizes);
   
   oo = Config(oo);                    % overwrite configuration
end
function oo = WriteVibTxt(o)           % Write Driver for VIB .txt File
%
% WRITEVIBTXT   Write diver for VIB .txt file (vibration test)
%
   path = arg(o,1);
   oo = write(o,'WriteVibTxt',path);
end
function oo = WriteVibDat(o)           % Write Driver for VIB .dat File
%
% WRITEVIBDAT   Write diver for VIB .dat file (vibration test)
%
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end

%==========================================================================
% BMC Test Read/Write Driver
%==========================================================================

function oo = ReadBmcTxt(o)            % Read Driver for BMC .txt File 
   path = arg(o,1);
   oo = read(o,'ReadBmcTxt',path);
   oo = Config(oo);                    % overwrite configuration
end
function oo = ReadBmcDat(o)            % Read Driver for BMC .dat File 
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'bmc')
      message(o,'Error: no BMC data!',...
              'use File>Import>General>Log Data (.dat) to import data');
      oo = [];
      return
   end
   oo = Config(oo);                    % overwrite configuration
end
function oo = ReadBmcPbi(o)            % Read Driver for BMC .pbi File 
   path = arg(o,1);
   co = cast(o,'caramel');
   oo = read(co,'ReadBmcPbi',path);
   oo = Config(oo);                    % overwrite configuration
end
function oo = WriteBmcTxt(o)           % Write Driver for BMC .txt File
%
% WRITEBMCTXT   Write diver for BMC .txt file (BMC test)
%
   path = arg(o,1);
   oo = write(o,'WriteBmcTxt',path);
end
function oo = WriteBmcDat(o)           % Write Driver for BMC .dat File
%
% WRITEBMCDAT   Write diver for BMC .dat file (BMC test)
%
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end

%==========================================================================
% Configure Plotting
%==========================================================================

function o = OldConfig(o)              % Configure for Plotting        
   typ = o.type;
   o = subplot(o,'layout',1);       % layout with 1 subplot column   
   o = category(o,1,[-2 2],[0 0],'µ');
   o = config(o,[]);                % set all sublots to zero
   o = config(o,'x',{1,'r',1});
   o = config(o,'y',{2,'b',1});
   switch o.type
      case {'bmc','pbi','mbc'}
         o = subplot(o,'color',[0.8 0.9 1]);
         o = category(o,2,[-20 20],[0 0],'m°');
         o = config(o,'th',{3,'g',2});
      case 'vib'
         o = subplot(o,'color',[0.9 0.8 1]);
      otherwise
         o = subplot(o,'color',[1 1 1]);
   end
end
