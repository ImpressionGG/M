function oo = telica(o,varargin)       % Telica Plugin                 
%
% TELICA  Telica plugin - to analyse basis tests, loke vibration test and
%         BMC test. Supported types: 'vsc', 'vuc', 'bmc'
%
%             telica(caramel)          % register plugin
%
%             oo = telica(o,func)      % call local simple function
%
%         See also: CARAMEL, SIMPLE, PBI, DANA
%
   if (nargin == 0)
      o = pull(carabao);               % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@New,@Import,@Export,...
                       @Signal,@Analysis,@Transient);
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
   plugin(o,[name,'/shell/Import'],{mfilename,'Import'});
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
   plugin(o,[name,'/shell/Analysis'],{mfilename,'Analysis'});
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function o = Import(o)                 % Import from File              
   oo = mitem(o,'Telica');
   ooo = mitem(oo,'MAT Log File (.mat)',{@ImportCb,@MatFileDrv,'.mat','telica'});
   return
   
   function o = ImportCb(o)            % Import Log Data Callback      
      gamma = arg(o,1);                % import driver
      ext = arg(o,2);                  % file extension
      typ = o.either(arg(o,3),'log');  % object type
      %o = caramel(o);                 % finally want create a CARAMEL obj
      
      caption = sprintf('Import %s data from %s file',upper(typ),ext);
      [files, dir] = fselect(o,'i',ext,caption);

      list = {};                          % init: empty object list
      for (i=1:length(files))
         path = o.upath([dir,files{i}]);  % construct path
         oo = gamma(o,path);              % call read driver function
         oo = launch(oo,launch(o));       % inherit launch function
         
            % returned object can either be container (kids list appends to
            % list) or non-container (which goes directly into list)

         if container(oo)
            list = [list,data(oo)];       % append container's kids to list
         else
            list{end+1} = oo;             % add imported object to list
         end
      end
      paste(o,list);
   end
   return
   
   function oo = MatFileDrv(o,path)    % MAT File Load Driver
      S = load(path);                  % load structure
      flds=fields(S);
      tag = flds{1};
      D = S.(tag);
      
      x = [];  y = [];
      xm = [];  ym = [];
      r = size(D.Grid_Points,1);       % number of repeats

      
      [dir,file,ext] = fileparts(path);
      for (k=1:r)
         if isequal(file,'Test_C_Stiff')
            Sk = D.Grid_Points{k,1};

            X = Sk.TP_ref_X';
            X(:,end) = [];
            x = [x;X(:)];  

            Y = Sk.TP_ref_Y';
            Y(:,end) = [];
            y = [y;Y(:)];  

            Xm = Sk.TP_mach_X';
            Xm(:,end) = [];
            xm = [xm;Xm(:)];  

            Ym = Sk.TP_mach_Y';
            Ym(:,end) = [];
            ym = [ym;Ym(:)];  
         else
            Sk = D.Grid_Points{k,1};

            X = Sk.TP_ref_X';
            x = [x;X(:)];  

            Y = Sk.TP_ref_Y';
            y = [y;Y(:)];  

            Xm = Sk.TP_mach_X';
            xm = [xm;Xm(:)];  

            Ym = Sk.TP_mach_Y';
            ym = [ym;Ym(:)];  
         end
      end
      [m,n] = size(X');
      
      oo = caramel('telica');          % create 'telica' typed caramel object
      oo.tag = o.tag;
      oo = balance(oo);

      oo.data.xm = 1e6*x';                  % measured x
      oo.data.ym = 1e6*y';                  % measured y
      oo.data.xt = 1e6*xm';                 % target position x
      oo.data.yt = 1e6*ym';                 % target position y
      
      oo.data.x = oo.data.xm - oo.data.xt;
      oo.data.y = oo.data.ym - oo.data.yt;
      
      mnr = m*n*r;
      switch file
         case {'Test_B_Stiff','Test_A_Stiff','Test_C_Stiff'}
            oo.data.t = [0:m*n*r-1]*r*46/mnr;
         case {'Test_D_20Hz'}
            oo.data.t = [0:m*n*r-1]*r*97/mnr;
         otherwise
            oo.data.t = [0:m*n*r-1];
      end
      
      oo.par.title = file;
      oo.par.method = 'blcs';
      oo.par.sizes = [m,n,r];          % sizes info
      oo = Config(oo);                 % configurate plotting
   end
   function o = Config(o)              % Configurate plotting          
   %
      o = subplot(o,'layout',1);
      o = category(o,1,[0 0],[0 0],'µ');
      o = category(o,2,[0 0],[0 0],'1');

      o = config(o,'x',{1,'r',1});
      o = config(o,'y',{2,'b',1});
      o = config(o,'xt',{0,'r',1});
      o = config(o,'yt',{0,'b',1});
      o = config(o,'xm',{0,'r',1});
      o = config(o,'ym',{0,'b',1});
   end
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu                   
   if isequal(type(current(o)),'telica')
      oo = mitem(o,'Placement Error X/Y',{@PlacementXY});
      oo = mitem(o,'Target Coordinates XT/YT',{@TargetXY});
      oo = mitem(o,'Measurement Coordinates XM/YM',{@MeasureXY});
   end
   return
   
   function o = PlacementXY(o)         % Configure for Placement Coords XY 
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'x',{1,'r'});
      o = config(o,'y',{2,'b'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = TargetXY(o)            % Configure for Target Coords XY  
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'xt',{1,'r'});
      o = config(o,'yt',{2,'b'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
   function o = MeasureXY(o)           % Configure for Measurement Coord XY  
      o = subplot(o,'layout',1);       % layout with 1 subplot column   
      o = config(o,[]);                % set all sublots to zero
      o = config(o,'xm',{1,'r'});
      o = config(o,'ym',{2,'b'});
      o = config(o,o);                 % update settings, rebuild & refresh
   end
end

%==========================================================================
% Analysis Menu
%==========================================================================

function o = Analysis(o)               % Analysis Menu                 
   oo = mhead(o,'Telica');
   if isequal(type(current(o)),'telica')
      ooo = mitem(oo,'Transient Analysis',{@invoke,'telica','Transient'});
   end
   return
end
function o = Transient(o)              % Transient Analysis            
   oo = current(o);
   if ~isequal(type(current(o)),'telica')
      message(o,'Select a TELICA object!');
      return
   end   
   refresh(o,inf);                     % refresh here

   oo = category(oo,1,[-1 1],[0 0],'µ');
   oo = subplot(oo,'layout',1);        % one column for subplots
   oo = config(oo,[]);                 % reset configuration
   oo = config(oo,'x',{1,'r'});        % plot x in subplot 1     
   oo = config(oo,'y',{2,'b'});        % plot y in subplot 2

   oo = opt(oo,'filter.mode','both');
   oo = opt(oo,'filter.type',9);
   oo = opt(oo,'filter.window',50);

   [m,n,r] = sizes(oo);
   oo = opt(oo,'scope',1:min(10,r));   % focus on first 10 repeats
   oo = opt(oo,'ignore',0);            % no matrices to ignore

   cls(o);
   plot(oo,'Stream');

   subplot(oo,1);  sym = 'x';
   [sub,col,cat] = config(oo,sym);
   [spec,limit,unit] = category(oo,cat); 
   [y,yf] = cook(oo,sym,'stream'); % data to be plotted
   rng = o.rd(max(yf)-min(yf));
   xlabel(sprintf('Transient range: %g%s @ %s',rng,unit,sym));

   subplot(oo,2);  sym = 'y';
   [sub,col,cat] = config(oo,sym);
   [spec,limit,unit] = category(oo,cat); 
   [y,yf] = cook(oo,sym,'stream'); % data to be plotted
   rng = o.rd(max(yf)-min(yf));
   title('');
   xlabel(sprintf('Transient range: %g%s @ %s',rng,unit,sym));
end
function o = Transient1(o)             % Transient Analysis (Altern.)  
   oo = current(o);
   if ~isequal(type(current(o)),'telica')
      message(o,'Select a TELICA object!');
      return
   end   
   refresh(o,inf);                     % refresh here

   oo = opt(oo,'filter.mode','both');
   oo = opt(oo,'filter.type',9);
   oo = opt(oo,'filter.window',50);

   oo = opt(oo,'scope',1:10);
   oo = opt(oo,'ignore',0);

   cls(o);
   plot(oo,'Stream');

   for (k=1:subplot(oo,inf))
      for (i=1:config(oo,inf))
         [sym,sub,col,cat] = config(oo,i);
         if (sub == k && ~isempty(col))
            subplot(oo,sub);
            [spec,limit,unit] = category(oo,cat); 
            [y,yf] = cook(oo,i,'stream');       % data to be plotted

            rng = o.rd(max(yf)-min(yf));
            xlabel(sprintf('Transient range: %g%s @ %s',rng,unit,sym));
         end
      end
   end
end
