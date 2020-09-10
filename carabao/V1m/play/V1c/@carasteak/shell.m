function oo = shell(o,varargin)        % CARASTEAK shell
   [gamma,o] = manage(o,varargin,@Shell,@Dynamic,@Plot,@Analysis);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = menu(o,'Edit');                % add Edit menu
   oo = menu(o,'View');                % add View menu
   oo = menu(o,'Select');              % add Select menu
   oo = Plot(o);                       % add Plot menu
   oo = Analysis(o);                   % add Analysis menu
   oo = menu(o,'Gallery');             % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = menu(o,'Figure');              % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function

   o = provide(o,'par.title','Carasteak Shell');
   o = provide(o,'par.comment',{'Playing around with CARASTEAK objects'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
   %o = opt(o,{'control.options',0});
end
function list = Dynamic(o)             % List of Dynamic Menus             
   list = {'Plot','Analysis'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
   ooo = New(oo);                      % add New menu
   ooo = Import(oo);                   % add Import menu items
   ooo = Export(oo);                   % add Export menu items
end
function oo = New(o)                   % New Menu Items                
   oo = mhead(o,'New');
   ooo = mitem(oo,'Log Data',{@NewCb});
   return
   
   function oo = NewCb(o)              % Create New CARACOOK Callback  
      m = 5;  n = 8;  r = 10;          % rows x columns x repeats
      t = 0:1000/(m*n*r-1):1000;       % crate a time vector
      sz = size(t);
      om = r*2*pi/max(t);              % random circular frequency
      
      x = (2+3*rand)*sin(om*t)+0.2*randn(sz); % create an 'x' data vector
      y = (2+3*rand)*cos(om*t)+0.3*randn(sz); % create an 'y' data vector
      p = 5*x + 5*y + 0.7*randn(sz);   % create a 'th' vector
      
      x = x.*(1+0.2*t/max(t));         % time variant
      y = y.*(1+0.2*t/max(t));         % time variant
      p = p.*(1+0.2*t/max(t));         % time variant
      
      oo = carasteak;                  % construct caracook object
      oo = trace(oo,t,'x',x,'y',y,'p',p); % make a trace with t, x & y

      oo = set(oo,'sizes',[m,n,r]);    % set data sizes
      oo = set(oo,'method','blcs');    % set processing method

         % provide title & comments for the caracook object

      
      [date,time] = o.now;
      comment = {'sin/cos data (random frequency & magnitude)',...
                 '(test data)'};
      oo = set(oo,'title',[date,' @ ',time,' Sample Log Data']);
      oo = set(oo,'comment',comment);
      oo = set(oo,'copperfield',magic(3));
      oo = set(oo,'date',date,'time',time);
      oo = set(oo,'machine',sprintf('%08g',round(0.1+9.9*rand)));
      oo = set(oo,'project','Sample Project');

         % provide plot defaults

      oo = category(oo,1,[-5 5],[0 0],'µ');    % category 1 for x,y
      oo = category(oo,2,[-50 50],[0 0],'m°'); % category 2 for p

      oo = config(oo,'x',{1,'r',1});
      oo = config(oo,'y',{1,'b',1});
      oo = config(oo,'p',{2,'g',2});

         % paste object into shell and display shell info on screen

      paste(o,{oo});                   % paste new caracook into shell
   end
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Text File (.txt)',{@ImportCb,'TextFile','.txt',@carasteak});
   ooo = mitem(oo,'Log Data (.log)',{@ImportCb,'LogData','.log',@carasteak});
   return
   
   function o = ImportCb(o)            % Import Log Data Callback
      drv = arg(o,1);                  % export driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      list = import(cast(o),drv,ext);  % import object from file
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % locate Export menu header
   ooo = mitem(oo,'Text File (.txt)',{@ExportCb,'TextFile','.txt',@carasteak});
   ooo = mitem(oo,'Log Data (.log)',{@ExportCb,'LogData','.log',@carasteak});
   return
   
   function oo = ExportCb(o)           % Export Log Data Callback
      oo = current(o);
      if container(oo)
         message(oo,'Select an object for export!');
      else
         drv = arg(o,1);               % export driver
         ext = arg(o,2);               % file extension
         cast = arg(o,3);              % cast method
         export(cast(oo),drv,ext);     % export object to file
      end
   end
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu 
   oo = menu(cast(o,'carma'),'Plot');
   
   setting(o,{'plot.bullets'},true);   % provide bullets default
   setting(o,{'plot.linewidth'},3);    % provide linewidth default
   
   %oo = mhead(o,'Plot');               % add roll down header menu item
   %dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'My Plot #1',{@PlotCb,'Plot1'});
   ooo = mitem(oo,'My Plot #2',{@PlotCb,'Plot2'});
   ooo = mitem(oo,'My Plot #3',{@PlotCb,'Plot3'});
   ooo = mitem(oo,'-');                % separator
   ooo = mitem(oo,'Show',{@PlotCb,'Show'});
   ooo = mitem(oo,'Animation',{@PlotCb,'Animation'});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Bullets','','plot.bullets');
   check(ooo,'');
   ooo = mitem(oo,'Line Width','','plot.linewidth');
   choice(ooo,[1:5],'');
   return

   function oo = PlotCb(o)
      oo = plot(o);                    % forward to carasteak.plot method
   end
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu                     
   oo = mhead(o,'Analysis');           % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                   
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Carasteak Class: Version ',version(carasteak)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit espresso/version');
end
