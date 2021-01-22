function oo = sample(o,varargin)       % Sample Plugin                 
%
% SAMPLE   Sample plugin
%
%             sample(corazon)          % register plugin
%
%             oo = sample(o,func)      % call local sample function
%
%          Read Driver for Simple & Plain Objects
%
%             oo = sample(o,'PlnDatDrv',path);
%             oo = sample(o,'SmpDatDrv',path);
%
%          Note: all objects created by SAMPLE and imported by SAMPLE are
%          CORAZON objects. Note that in dynamic shells the Analyse menu
%          is therefore built up by corazon/shell/Analyse.
%
%          See also: CORAZON, PLUGIN, SIMPLE
%
   [gamma,oo] = manage(o,varargin,@Setup,@Register,@Basket,...
                       @Plug,@New,@Import,@Export,@Collect,...
                       @Plot,@Stream,@Analyse,@Shuffle,@Callback,...
                       @Study,@Study1,@Study2,@Study3,@Tutorial,@Session,...
                       @Plugin,@Plugin1,@Plugin2,@Plugin3,...
                       @Play,@Play1,@Play2,@Play3,...
                       @Scatter,@ReadPkgPkg,@ReadPlnDat,@WritePlnDat);
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
   plugin(o,[name,'/menu/End'],{mfilename,'Plug'});
   plugin(o,[name,'/current/Select'],{mfilename,'Plug'});
   plugin(o,[name,'/shell/New'],{mfilename,'New'});
   plugin(o,[name,'/shell/Import'],{mfilename,'Import'});
   plugin(o,[name,'/shell/Export'],{mfilename,'Export'});
   plugin(o,[name,'/shell/Collect'],{mfilename,'Collect'});
   plugin(o,[name,'/shell/Plot'],{mfilename,'Plot'});
   plugin(o,[name,'/shell/Analyse'],{mfilename,'Analyse'});
   plugin(o,[name,'/shell/Study'],{mfilename,'Study'});
   plugin(o,[name,'/shell/Plugin'],{mfilename,'Plugin'});
   plugin(o,[name,'/shell/Play'],{mfilename,'Play'});
   plugin(o,[name,'/shell/Tutorial'],{mfilename,'Tutorial'});
end
function oo = Callback(o)              % General Callback              
   refresh(o,o);                       % remember to refresh here
   cls(o);                             % clear screen
   
   oo = current(o);                    % get current object
   gamma = eval(['@',mfilename]);
   oo = gamma(oo);                     % forward to executing method
end

%==========================================================================
% General Plugins
%==========================================================================

function o = Plug(o)                   % General Plugins               
%
% PLUG   General Plugins can be used to plug-in menus at any menu locat-
%        ion. All it needs to be done is to locate a menu item by path and
%        to insert a new menu item at this location.
%
   oo = Range(o);                      % add Range menu
end
function oo = Range(o)                 % Range Menu                    
%
% RANGE   Add Range menu to Select rolldown menu
%
   oo = mseek(o,{'#','Select'});       % find Select rolldown menu
   if isempty(oo)
      return
   end
   
   setting(o,{'range.tmax'},1);
   setting(o,{'range.ymin'},-5);
   setting(o,{'range.ymax'},+5);

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Range');
   oooo = mitem(ooo,'Max Time',{},'range.tmax');
          choice(oooo,[1,10,100,1000],{});
   oooo = mitem(ooo,'Min Y',{},'range.ymin');
          choice(oooo,[-1,-2,-5,-10],{});
   oooo = mitem(ooo,'Max Y',{},'range.ymax');
          choice(oooo,[1,2,5,10],{});
end

%==========================================================================
% File Menu Plugins
%==========================================================================

function o = New(o)                    % New Sample Trace              
   oo = mitem(o,'Sample');
   ooo = mitem(oo,'Plain',{@NewPlain});
   return
   
   function oo = NewPlain(o)           % Create New Plain Object       
      om = 2*pi*0.5;                   % 2*pi * (0.5 Hz)
      t = 0:0.01:10;                   % time vector
      
      x = (2+rand)*sin(om*t) + (1+rand)*sin(3*om*t+randn);
      x = x + randn + 0.1*randn(size(t));
      
      y = (1.5+rand)*cos(om*t) + (0.5+rand)*cos(2*om*t+randn);
      y = y + randn + y + 0.12*randn(size(t));

         % pack into object (and add some noise)

      oo = corazon('pln');             % plain type
      oo.par.title = sprintf('Plain Object (%s)',datestr(now));
      oo = data(oo,'t,x,y',t,x,y);
      
      paste(o,oo);                     % paste new object into shell
   end
end
function oo = Import(o)                % Import Menu Items             
   oo = mitem(o,'Sample');
        %enable(oo,o.is(type(current(o)),{'pln'}));
   ooo = mitem(oo,'Plain Sample (.dat)',{@ImportCb,'ReadPlnDat','.dat',@corazon});
        %enable(ooo,o.is(type(current(o)),{'pln'}));
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
   oo = mitem(o,'Sample');
        %enable(oo,o.is(type(current(o)),{'pln'}));
   ooo = mitem(oo,'Plain Sample (.dat)',{@ExportCb,'WritePlnDat','.dat',@corazon});
        %enable(ooo,o.is(type(current(o)),{'pln'}));
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
   table = {{@read,'corazon','ReadPkgPkg','.pkg'},...
            {@read,'corazon','ReadGenDat', '.dat'}};
   collect(o,{'pln'},table); 
end

%==========================================================================
% Plot Plugins
%==========================================================================

function o = Plot(o)                   % Plot Menu Setup               
   enabled = basket(o,{'shell','pln'});% if supported type found in basket
   
   oo = mitem(o,'Stream',{@Basket,'Stream'});
        enable(oo,enabled);
   oo = mitem(o,'Scatter',{@Basket,'Scatter'});
        enable(oo,enabled);
end
function o = Basket(o)                 % Acting on the Basket          
%
% BASKET  Plot basket, or perform actions on the basket
%
   refresh(o,o);                       % use this callback for refresh
   cls(o);                             % clear screen

   gamma = eval(['@',mfilename]);
   oo = basket(o,gamma);               % perform operation gamma on basket
   
   if ~isempty(oo)                     % irregulars happened?
      message(oo);                     % report irregular
   end
end

function o = Stream(o)                 % Stream Plot                   
   if ~o.is(type(o),{'pln'})
      o = [];  return
   end
   
   [t,x,y] = data(o,'t,x,y');

   oo = opt(o,'subplot',211,'xlabel','t', 'ylabel','x', 'title','X Data');
   plot(oo,t,x,'r');
   grid on;

   oo = opt(o,'subplot',212,'xlabel','t', 'ylabel','y', 'title','Y Data');
   plot(oo,t,y,'b');
   grid on  
end
function o = Scatter(o)                % Scatter Plot                  
   if ~o.is(type(o),{'pln'})
      o = [];  return
   end
   
   [x,y] = data(o,'x,y');

   oo = opt(o,'xlabel','x', 'ylabel','y', 'title','Scatter Plot');
   plot(oo,x,y,'ko');
   set(gca,'visible','on');            % don't know, but is needed !!!
   grid on;
end

%==========================================================================
% Analyse Plugins
%==========================================================================

function o = Analyse(o)                % Analyse Menu Setup            
   enabled = basket(o,{'shell','pln'});% if supported type found in basket
   
   oo = mitem(o,'Shuffle',{@Shuffle});
        enable(oo,enabled);
end
function o = Shuffle(o)                % Shuffle Analysis              
   refresh(o,o);                       % use this callback for refresh
   o = opt(o,'basket.type','pln');
   o = opt(o,'basket.collect','*');    % all traces in basket
   list = basket(o);
   
   if (isempty(list))
      message(o,'No plain objects in basket!');
   else
      cls(o);
      o = opt(o,'hold',1);

      xx = [];  yy = [];
      for (i=1:length(list))
         oo = list{i};
         [x,y] = data(oo,'x,y');
         xx = [xx,x];  yy = [yy,y];
      end
      
      idx = 1:length(xx);
      for (i=1:length(idx))             % shuffle
         k = 1 + rem(floor(1e10*rand),length(xx));
         j = idx(k);  idx(k) = [];  idx = [idx,j];
      end
      
      plot(o,xx(idx),yy(idx),'y');
      plot(o,xx,yy,'ko');   
      
      title('Shuffle Analysis');
   end
end

%==========================================================================
% Study Menu Plugin
%==========================================================================

function o = Study(o)                  % Study Menu Setup              
   oo = mitem(o,'Study 1',{@Callback,'Study1'});
   oo = mitem(o,'Study 2',{@Callback,'Study2'});
   oo = mitem(o,'Study 3',{@Callback,'Study3'});
end
function o = Study1(o)                 % Study 1                       
   message(o,'Study 1',{'to be done ...'});
end
function o = Study2(o)                 % Study 2                       
   message(o,'Study 2',{'to be done ...'});
end
function o = Study3(o)                 % Study 3                       
   message(o,'Study 3',{'to be done ...'});
end

%==========================================================================
% Plugin Menu Plugin
%==========================================================================

function o = Plugin(o)                 % Plugin Menu Setup             
   oo = mitem(o,'Plugin 1',{@Callback,'Plugin1'});
   oo = mitem(o,'Plugin 2',{@Callback,'Plugin2'});
   oo = mitem(o,'Plugin 3',{@Callback,'Plugin3'});
end
function o = Plugin1(o)                % Plugin 1                      
   message(o,'Plugin 1',{'to be done ...'});
end
function o = Plugin2(o)                % Plugin 2                      
   message(o,'Plugin 2',{'to be done ...'});
end
function o = Plugin3(o)                % Plugin 3                      
   message(o,'Plugin 3',{'to be done ...'});
end

%==========================================================================
% Play Plugins
%==========================================================================

function o = Play(o)                   % Play Menu Setup               
   oo = mitem(o,'Play 1',{@Callback,'Play1'});
   oo = mitem(o,'Play 2',{@Callback,'Play2'});
   oo = mitem(o,'Play 3',{@Callback,'Play3'});
end
function o = Play1(o)                  % Play 1                        
   message(o,'Play 1',{'to be done ...'});
end
function o = Play2(o)                  % Play 2                        
   message(o,'Play 2',{'to be done ...'});
end
function o = Play3(o)                  % Play 3                        
   message(o,'Play 3',{'to be done ...'});
end

%==========================================================================
% Tutorial Plugins
%==========================================================================

function o = Tutorial(o)               % Study Menu Setup              
   oo = mitem(o,'Chapter 1');
   ooo = mitem(oo,'Section 1.1',{@Session,'1.1'});
   ooo = mitem(oo,'Section 1.2',{@Session,'1.2'});
   
   oo = mitem(o,'Chapter 2');
   ooo = mitem(oo,'Section 2.1',{@Session,'2.1'});
   ooo = mitem(oo,'Section 2.2',{@Session,'2.2'});
   
   oo = mitem(o,'Chapter 3');
   ooo = mitem(oo,'Section 3.1',{@Session,'3.1'});
   ooo = mitem(oo,'Section 3.2',{@Session,'3.2'});
end
function o = Session(o)                % Session Callback              
   refresh(o,o);
   switch arg(o,1)
      case '1.1'
         message(o,'Section 1.1',{'to be done ...'});
      case '1.2'
         message(o,'Section 1.2',{'to be done ...'});
         
      case '2.1'
         message(o,'Section 2.1',{'to be done ...'});
      case '2.2'
         message(o,'Section 2.2',{'to be done ...'});
         
      case '3.1'
         message(o,'Section 3.1',{'to be done ...'});
      case '3.2'
         message(o,'Section 3.2',{'to be done ...'});
   end
end

%==========================================================================
% Read/Write Driver & Plot Configuration
%==========================================================================

function oo = ReadPkgPkg(o)            % Read Driver for package info  
   path = arg(o,1);
   oo = read(o,'ReadPkgPkg',path);
end
function oo = ReadPlnDat(o)            % Read Driver for plain .dat    
   path = arg(o,1);
   oo = read(o,'ReadGenDat',path);
   if ~isequal(oo.type,'pln')
      message(o,'Error: no plain sample data!',...
                'use File>Import>General>Log Data (.dat) to import data');
      oo = [];
      return
   end
%  oo = Config(oo);                    % overwrite configuration
end
function oo = WritePlnDat(o)           % Write Driver for plain .dat   
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
