function oo = spm(o,varargin)          % SPM Plugin                    
%
% SPM      SPM plugin
%
%             oo = spm(o,func)         % call local spm function
%
%             spm(cut,'Register')      % register plugin
%
%          Note: all objects created by spm and imported by spm are
%          CUT objects. Note that in dynamic shells the Analyse menu
%          is therfore built up by cut/shell/Analyse.
%
%          See also: CARAMEL, PLUGIN, PLUG, BASIS, KEFALON, CUTLOG
%
   if (nargin == 0)
      o = pull(cut);                   % pull object from active shell
   end
   
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Config,...
                       @New,@Import,@Export,@Collect,@Signal,@ReadPkgPkg,...
                       @ReadSpmSpm,@WriteSpmSpm);
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
   o = Config(type(o,'spm'));          % register 'spm' configuration

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
      co = cut(o);                     % convert to caramel object
      oo = new(co,'Cutlog2');          % create new Simple object
      paste(o,{oo});                   % paste new object into shell
   end
end
function oo = Import(o)                % Import Menu Items             
   oo = mitem(o,'SPM');
   ooo = mitem(oo,'SPM (.spm)',{@ImportCb,'ReadSpmSpm','.spm',@cut});
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
end
function o = Config(o)                 % Change Configuration          
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
% Read/Write Driver
%==========================================================================

function oo = ReadSpmSpm(o)            % Read Driver for CUL .csv      
   path = arg(o,1);
   oo = read(o,'ReadSpmSpm',path);
   if ~isequal(oo.type,'spm')
      message(o,'Error: no CUL data!',...
                'use File>Import>SPM>SPM (.spm) to import data');
      oo = [];
      return
   end
end

