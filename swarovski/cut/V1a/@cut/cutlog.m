function oo = cutlog(o,varargin)       % cutlog Plugin
%
% cutlog   cutlog plugin
%
%             oo = cutlog(o,func)      % call local cutlog function
%
%             cutlog(cut,'Register')   % register plugin
%
%          Note: all objects created by cutlog and imported by cutlog are
%          CUT objects. Note that in dynamic shells the Analyse menu
%          is therfore built up by cut/shell/Analyse.
%
%          See also: CORDOBA, PLUGIN, PLUG, BASIS, SPM
%
   if (nargin == 0)
      o = pull(cut);                   % pull object from active shell
   end

   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Config,...
                       @New,@Import,@Export,@Collect,@Signal,@ReadPkgPkg,...
                       @ReadCulCsv,@ReadCutlog2Csv,...
                       @WriteCulCsv,@WriteCutlog2Csv);
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
   o = Config(type(o,'cul'));          % register 'pln' configuration

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

function o  = New(o)                   % New cutlog Trace
   oo = mitem(o,'Cut');
   ooo = mitem(oo,'CUL',{@NewCul});
%  ooo = mitem(oo,'Cutlog 2',{@NewCutlog2});
   return

   function oo = NewCul(o)             % Create New CUL Object
      co = cut(o);                     % convert to cut object
      oo = new(co,'Cul');              % create new CUL object
      paste(o,{oo});                   % paste new object into shell
   end
   function oo = NewCutlog2(o)         % Create New Cutlog2 Object
      co = cut(o);                     % convert to cordoba object
      oo = new(co,'Cutlog2');          % create new Simple object
      paste(o,{oo});                   % paste new object into shell
   end
end
function oo = Import(o)                % Import Menu Items
   oo = mitem(o,'Cut');
   ooo = mitem(oo,'CUL (.csv)',{@ImportCb,'ReadCulCsv','.csv',@cut});
%  ooo = mitem(oo,'Cutlog2 (.csv)',{@ImportCb,'ReadCutlog2Csv','.csv',@cut});
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
   setting(o,{'cut.separator'},',');
   oo = mitem(o,'Cut');
   set(mitem(oo,inf),'enable',onoff(o,{'cul'}));
   ooo = mitem(oo,'CUL (.csv)',{@ExportCb,'WriteCulCsv','.csv',@cut});
   set(mitem(ooo,inf),'enable',onoff(o,'cul'));
%  ooo = mitem(oo,'Cutlog2 (.csv)',{@ExportCb,'WriteCutlog2Csv','.csv',@cut});
%  set(mitem(ooo,inf),'enable',onoff(o,'cutlog2'));
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Separator',{},'cut.separator');
   choice(ooo,{{'None',''},{'","',','},{'"|"','|'},{'";"',';'}});
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
function o  = Collect(o)               % Configure Collection
   table = {{@read,'cut','ReadPkgPkg','.pkg'},...
            {@read,'cut','ReadGenDat', '.dat'}};
   collect(o,{'cul','cutlog2'},table);
end

%==========================================================================
% View Menu
%==========================================================================

function o = Signal(o)                 % Signal Menu
%
% SIGNAL   The Sinal function is responsible for both setting up the
%          'Signal' menu head and the subitems which are dynamically
%          depending on the type of the current object
%
   switch active(o)                    % depending on active type
      case {'cul'}
         oo = mitem(o,'Kappl X',{@Config},'KapplX');
         oo = mitem(o,'Kappl Y',{@Config},'KapplY');
         oo = mitem(o,'Kappl Z',{@Config},'KapplZ');
         oo = mitem(o,'-');
         oo = mitem(o,'Kappl XY',{@Config},'KapplXY');
         oo = mitem(o,'Kappl XZ',{@Config},'KapplXZ');
         oo = mitem(o,'Kappl YZ',{@Config},'KapplYZ');
         oo = mitem(o,'-');
         oo = mitem(o,'Kappl XYZ',{@Config},'KapplXYZ');
         oo = mitem(o,'-');
         oo = mitem(o,'Kolben X',{@Config},'KolbenX');
         oo = mitem(o,'Kolben Y',{@Config},'KolbenY');
         oo = mitem(o,'Kolben Z',{@Config},'KolbenZ');
         oo = mitem(o,'-');
         oo = mitem(o,'Kolben XY',{@Config},'KolbenXY');
         oo = mitem(o,'Kolben XZ',{@Config},'KolbenXZ');
         oo = mitem(o,'Kolben YZ',{@Config},'KolbenYZ');
         oo = mitem(o,'-');
         oo = mitem(o,'Kolben XYZ',{@Config},'KolbenXYZ');
         oo = mitem(o,'-');
         oo = mitem(o,'All',{@Config},'CulAll');
   end
end
function o = Config(o)                 % Change Configuration
   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'Layout',1);          % layout with 1 subplot column

   switch o.type
      case 'cul'                   % cul type
         o = subplot(o,'Color',[1 1 0.9]);
         o = category(o,1,[-25 25],[],'g');
         o = category(o,2,[-2.5 2.5],[],'g');
         o = category(o,3,[-40 40],[],'mm/s');
         o = category(o,4,[-4   4],[],'mm/s');
         o = category(o,5,[-6   6],[],'um');
         o = category(o,6,[-0.6 0.6],[],'um');
   end

      % define colors

   axcol = 'r';   aycol = 'g';   azcol = 'b';
   bxcol = 'rk';  bycol = 'gk';  bzcol = 'bk';

      % get mode and provide a proper default if empty
      % (empty mode is provided during registration phase)

   mode = o.either(arg(o,1),o.type);
   switch mode                         % dispatch on configuration mode
      case {'KapplX'}
         o = config(o,'ax',{1,axcol,1});
      case {'KapplY'}
         o = config(o,'ay',{1,aycol,1});
      case {'KapplZ'}
         o = config(o,'az',{1,azcol,1});
      case {'KapplXY'}
         o = config(o,'ax',{1,axcol,1});
         o = config(o,'ay',{2,aycol,1});
      case {'KapplXZ'}
         o = config(o,'ax',{1,axcol,1});
         o = config(o,'az',{2,azcol,1});
      case {'KapplYZ'}
         o = config(o,'ay',{1,aycol,1});
         o = config(o,'az',{2,azcol,1});
      case {'KapplXYZ'}
         o = config(o,'ax',{1,axcol,1});
         o = config(o,'ay',{2,aycol,1});
         o = config(o,'az',{3,azcol,1});

      case {'KolbenX'}
         o = config(o,'bx',{1,bxcol,2});
      case {'KolbenY'}
         o = config(o,'by',{1,bycol,2});
      case {'KolbenZ'}
         o = config(o,'bz',{1,bzcol,2});
      case {'KolbenXY'}
         o = config(o,'bx',{1,bxcol,2});
         o = config(o,'by',{2,bycol,2});
      case {'KolbenXZ'}
         o = config(o,'bx',{1,bxcol,2});
         o = config(o,'bz',{2,bzcol,2});
      case {'KolbenYZ'}
         o = config(o,'by',{1,bycol,2});
         o = config(o,'bz',{2,bzcol,2});
      case {'KolbenXYZ'}
         o = config(o,'bx',{1,bxcol,2});
         o = config(o,'by',{2,bycol,2});
         o = config(o,'bz',{3,bzcol,2});

      case {'CulAll','cul'}
         o = config(o,'ax',{1,axcol,1});
         o = config(o,'ay',{2,aycol,1});
         o = config(o,'az',{3,azcol,1});
         o = config(o,'bx',{4,bxcol,2});
         o = config(o,'by',{5,bycol,2});
         o = config(o,'bz',{6,bzcol,2});
         mode = 'CulAll';
      otherwise
         error('bad mode!');
   end
   o = subplot(o,'Signal',mode);       % set signal mode

   change(o,'Bias','absolute');        % change bias mode, update menu
   change(o,'Config');                 % change config, rebuild & refresh
end

%==========================================================================
% Plot Menu
%==========================================================================

function o = Stream(o)                 % Plot Stream
   t = data(o,'t');
   ax = data(o,'ax');
   ay = data(o,'ay');
   az = data(o,'az');
   bx = data(o,'bx');
   by = data(o,'by');
   bz = data(o,'bz');

   mode = setting(o,'mode.signal');

   switch mode
       case {'CulXY','Cutlog2XY'}
           o.color(plot(t,ax),'r');
           hold on;
           o.color(plot(t,ay),'g');
           o.color(plot(t,az),'b');
       case {'KolbenXY'}
           o.color(plot(t,bx),'ck');
           hold on;
           o.color(plot(t,by),'b');
       case {'KolbenXZ'}
           o.color(plot(t,bx),'ck');
           hold on;
           o.color(plot(t,bz),'bk');
       case {'KolbenYZ'}
           o.color(plot(t,by),'b');
           hold on;
           o.color(plot(t,bz),'bk');
       case {'CulAll','Cutlog2All'}
           subplot(611);
           o.color(plot(t,ax),'r');
           subplot(612);
           o.color(plot(t,ay),'rm');
           subplot(613);
           o.color(plot(t,az),'m');

           subplot(614);
           o.color(plot(t,bx),'ck');
           subplot(615);
           o.color(plot(t,by),'b');
           subplot(616);
           o.color(plot(t,bz),'bk');
   end
end
function o = Fft(o)                    % Plot Fft
   Stream(o);
end

%==========================================================================
% Read/Write Driver & Plot Configuration
%==========================================================================

function oo = ReadPkgPkg(o)            % Read Driver for package info
   path = arg(o,1);
   oo = read(o,'ReadPkgPkg',path);
end
function oo = ReadCulCsv(o)            % Read Driver for CUL .csv
   path = arg(o,1);
   oo = read(o,'ReadCulCsv',path);
   if ~isequal(oo.type,'cul')
      message(o,'Error: no CUL data!',...
                'use File>Import>Cut (.csv) to import data');
      oo = [];
      return
   end
%  oo = Config(oo);                    % overwrite configuration
end
function oo = ReadCutlog2Csv(o)        % Read Driver for simple .dat
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'smp')
      message(o,'Error: no simple sample data!',...
                'use File>Import>Cut (.csv) to import data');
      oo = [];
      return
   end
%  oo = Config(oo);                    % overwrite configuration
end

function oo = WriteCulCsv(o)           % Write Driver for CUL .csv
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
function oo = WriteCutlogCsv2(o)       % Write Driver for simple .dat
   path = arg(o,1);
   oo = write(o,'WriteCutlogCsv',path);
end
