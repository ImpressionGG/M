

function oo = shell(o,varargin)        % SPM Shell                     
   [gamma,o] = manage(o,varargin,@Shell,@Tiny,@Dynamic,@View,@Select,...
                                 @Plot,@PlotCb,@Analysis,@Study);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = Edit(o);                       % add Edit menu
   oo = View(o);                       % add View menu
   oo = Select(o);                     % add Select menu
   oo = Plot(o);                       % add Plot menu
   oo = Analyse(o);                    % add Analyse menu
   oo = Study(o);                      % add Study menu
   oo = menu(o,'Gallery');             % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = menu(o,'Figure');              % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Tiny(o)                   % Tiny Shell Setup              
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function
   o = control(o,{'dark'},1);          % run in dark mode
   o = control(o,{'verbose'},0);       % no verbose talking

   o = opt(o,{'style.bullets'},0);     % provide bullets default
   o = opt(o,{'view.grid'},1);         % grid on by default
   o = opt(o,{'mode.organized'},'plain');
 
   o = provide(o,'par.title','SPM Toolbox');
   o = provide(o,'par.comment',{'Playing around with SPM objects'});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
end
function list = Dynamic(o)             % List of Dynamic Menus         
   list = {'View','Select','Plot','Analyse','Study'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
   ooo = New(oo);                      % add New menu
   ooo = Import(oo);                   % add Import menu items
   ooo = Export(oo);                   % add Export menu items
   ooo = Tools(oo);
   ooo = Extras(oo);
end
function oo = New(o)                   % New Menu                      
   oo = mseek(o,{'New'});
   ooo = mitem(oo,'-');
   %ooo = mitem(oo,'Stuff');
   %oooo = new(corazon(ooo),'Menu');    % add CORAZON New stuff items
   %ooo = mitem(oo,'Spmx');
   ooo = new(oo,'Menu');
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % locate Import menu header
   ooo = mitem(oo,'Package',{@CollectCb});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Package Info (.pkg)',{@ImportCb,'ReadPkgPkg','.pkg',@spm});
   ooo = mitem(oo,'SPM Data (.spm)',{@ImportCb,'ReadSpmSpm','.spm',@spm});
   return

   function o = ImportCb(o)            % Import Log Data Callback
      drv = arg(o,1);                  % import driver
      ext = arg(o,2);                  % file extension
      cast = arg(o,3);                 % cast method
      list = import(cast(o),drv,ext);  % import object from file
      paste(o,list);
   end
   function o = CollectCb(o)           % Collect All Files of Folder   
      collect(o,{})                    % reset collection config
      table = {{@read,'spm','ReadPkgPkg','.pkg'},...
               {@read,'spm','ReadSpmSpm', '.spm'}};
      collect(o,{},table);             % only default table

      list = collect(o);               % collect files in directory
      
         % upgrade object if possible

      if (~isempty(list) && type(list{end},{'pkg'}))
         po = list{end};
         phi = get(po,'phi');
         if ~isempty(phi)
            for (j=1:length(list)-1)   
               oo = list{j};
               if type(oo,{'spm'})
                  package = get(oo,{'package',''});
                  if isequal(package,get(po,'package'))
                     oo = set(oo,'phi',phi);
                  end
               end
               list{j} = oo;
            end
         end
      end
      
      paste(o,list);
      
      plot(current(o),'About');
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % locate Export menu header
   ooo = mitem(oo,'Stuff');
   enable(ooo,0);

   oooo = mitem(ooo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt',@corazon});
   ooo = mitem(oo,'Spmx');
   enable(ooo,0);

   oooo = mitem(ooo,'Log Data (.dat)',{@ExportCb,'WriteGenDat','.dat',@spm});
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
function oo = Tools(o)                 % Tools Menu Items              
   oo = mseek(o,{'Tools'});
   ooo = mitem(oo,'Provide Package Info',{@PackageInfo});
   ooo = mitem(oo,'Setup Parameters',{@SetupParameters});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Brew Cache',{@BrewCache});
   ooo = mitem(oo,'Clear Cache',{@ClearCache});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Store Cache',{@StoreCache});
   ooo = mitem(oo,'Recall Cache',{@RecallCache});
end
function oo = PackageInfo(o)           % Provide Package Info File     
   caption = 'Provide Package Info File (.pkg)';
   path = fselect(o,'d','*.*',caption);
   if isempty(path)
      return
   end
   
   [dir,file,ext] = fileparts(path);
   title = [file,ext];              % recombine file&extension to name
   
      % extract package type
      
   try
      [package,typ,name,run,mach] = split(o,title);
   catch
      typ = '';                        % initiate an error
   end
      
   if isempty(package) || isempty(typ) || isempty(run) || isempty(mach)
      message(o,'Error: something wrong with package folder syntax!',...
                '(cannot import files)');
      return
   end
   
   [date,time] = filedate(o,path);
   project = context(o,'Project',path);     % extract project from path
   
      % create a package object and set package parameters
      
   oo = spm('pkg');
   oo.data = [];                       % make a non-container object
   oo.par.title = title;
   oo.par.comment = {};
   oo.par.date = date;
   oo.par.time = time;
   oo.par.kind = typ;
   oo.par.project = project;
   oo.par.machine = mach;
   
   oo.par.package = package;
   oo.par.creator = opt(o,{'tools.creator',user(o,'name')});
   oo.par.version = [upper(class(o)),' ',version(o)];
   
      % open a dialog for parameter editing
      
   oo = opt(oo,'caption',['Package Object: ',package]);
   oo = ReadInfo(oo,[path,'/info.txt']);
   oo = Dialog(oo);                    % dialog for editing key parameters
   
   if isempty(oo)
      return
   end

      % update some settings
      
   setting(o,'tools.creator',get(oo,'creator'));
   
      % now write package file (.pkg)
      
   file = [FileName(oo,typ,date,time,package),'.pkg'];
   filepath = [path,'/',file];
   filepath = o.upath(filepath);
   
   oo = write(oo,'WritePkgPkg',filepath);
   if isempty(oo)
      o = Error(o,'could not write package file!');
      o = [];
      return
   end
   
   folder = o.either(context(o,'Path',path),title);
   [dir,fname,ext] = fileparts(folder);
   
   message(o,'Package info successfully written!',...
      ['Package: ',package],['Path: ',dir],['Folder: ',title],['File: ',file]);
   return
   
   function file = FileName(o,typ,date,time,pkg)  % Compose File Name             
      file = [upper(typ),date([1:2,4:6,8:11]),'-',time([1:2,4:5,7:8])];

      if isequal(o.type,'pkg')
         file = o.either(pkg,file);
         if ~isempty(typ)
            file = [file,'.',upper(typ)];
         end
      end
      file = Allowed(file);
   end
   function name = Allowed(name)       % Convert to Allowed File Name  
   %
   % ALLOWED   Substitute characters in order to have an allowed file name
   %
      allowed = '!$%&()=?+-.,#@������ ';
      for (i=1:length(name))
         c = name(i);
         if ('0' <= c && c <= '9')
            'ok';
         elseif ('A' <= c && c <= 'Z')
            'ok';
         elseif ('a' <= c && c <= 'z')
            'ok';
         elseif ~isempty(find(c==allowed))
            'ok';
         else
            name(i) = '-';                % substitute character with '-'
         end
      end
   end
end
function oo = SetupParameters(o)       % Setup Specific Parameters     
   o = pull(o);
   oo = current(o);
   setup = get(oo,'choice');
   
   if isempty(setup)
      message(o,'No setup info provided in current object',...
         {['object: ',get(o,{'title',''})],'empty ''choice'' parameter!'});
      return
   end
   
   list = fields(setup);
   for (i=1:length(list))
      value = setup.(list{i});
      Choice(o,list{i},value);
   end
   
   message(o,'Parameters have been setup!',{'see: get(cuo,''choice'')'});
   
   function Choice(o,tag,val,context)   % Change parameters             
      if (nargin < 4)
         context = '';
      end
      
      if isstruct(val)
         if isempty(context)
            context = tag;
         else
            context = [context,'.',tag];
         end
            
         tags = fields(val);
         for (j=1:length(tags))
            tagj = tags{j};
            valj = val.(tagj);
            Choice(o,tagj,valj,context);
         end
      elseif isempty(context)
         choice(o,tag,val);          % change setting
      else
         tag = [context,'.',tag];
         choice(o,tag,val);
      end    
   end
end
function oo = BrewCache(o)             % Re-Brew Cache Segments        
   switch type(current(o))
      case 'spm'
         message(o,'Brew all cache segments of data object ...');
      case 'pkg'
         message(o,'Brew all cache segments of package ...',...
                 {'(this may take a while)'});
      otherwise
         message(o,'Select data object or package object for brewing!');
   end
   oo = brew(o);
   message(o,'Brewing complete!');
   return
end
function oo = ClearCache(o)            % Clear All Caches              
   o = pull(o);
   for (i=1:length(o.data))
      oo = o.data{i};
      cache(oo,oo,[]);                 % cache hard reset
   end
   message(o,'Caches of all objects have been cleared!');
end
function oo = StoreCache(o)            % Store All Caches              
   o = pull(o);
   for (i=1:length(o.data))
      oo = o.data{i};
      bag = work(oo,'cache');
      oo = set(oo,'cache',bag);
      o.data{i} = oo;
   end
   push(o);
   message(o,'Caches of all objects have been stored!');
end
function oo = RecallCache(o)           % Recall All Caches              
   o = pull(o);
   for (i=1:length(o.data))
      oo = o.data{i};
      bag = get(oo,'cache');
      if ~isempty(bag)
         oo = work(oo,'cache',bag);
      end
      o.data{i} = oo;
   end
   push(o);
   message(o,'Caches of all objects have been recalled!');
end
function oo = Extras(o)                % Extras Menu Items
   setting(o,{'study.menu'},false);    % provide setting
   
   oo = mseek(o,{'Extras'});
   ooo = mitem(oo,'Study Menu',{},'study.menu');
         check(ooo,{@StudyMenu});
   return
   function o = StudyMenu(o)
      menu = opt(o,'study.menu');
      if (menu)
         rebuild(o);
      else
         rebuild(o);
      end
   end
end

%==========================================================================
% Edit Menu
%==========================================================================

function oo = Edit(o)                  % Edit Menu                     
   oo = menu(o,'Edit');                % add Edit menu items

   plugin(o,'spm/shell/Edit');         % plug point
end

%==========================================================================
% View Menu
%==========================================================================

function oo = View(o)                  % View Menu                     
   oo = mhead(o,'View');               % add roll down header item
   dynamic(oo);                        % make this a dynamic menu

   ooo = menu(oo,'Grid');              % add Grid menu item
   ooo = menu(oo,'Dark');              % add Dark mode menu item
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Clear Screen',{@Cls});
   ooo = mitem(oo,'-');
   ooo = menu(oo,'Style');             % add plot style sub menu
   ooo = Scale(oo);                    % add Scale sub-menu
   ooo = Bode(oo);                     % add Bode settings menu
   ooo = Nyquist(oo);                  % add Nyquist settings menu
   ooo = Rloc(oo);                     % add Root Locus menu
   ooo = Weight(oo);                   % add Weight diagram settings menu
   ooo = Stability(oo);                % add Stability settings menu
   
   ooo = mitem(o,'-');
   ooo = Miscellaneous(oo);            % add Miscellaneous menu        
   
   plugin(o,'spm/shell/View');         % plug point

   function o = Cls(o)
      cls(o);
   end
end
function oo = Scale(o)                 % Scale Sub-Menu                
   setting(o,{'scale.xunit'},'ms');     % time scaling unit
   setting(o,{'scale.xscale'},1e3);     % time scaling factor
   
   setting(o,{'scale.yunit'},'um');     % elongation scaling unit
   setting(o,{'scale.yscale'},1e6);     % elongation scaling factor
   
   setting(o,{'scale.vunit'},'mm/s');   % velocity scaling unit
   setting(o,{'scale.vscale'},1e3);     % velocity scaling factor

   setting(o,{'scale.aunit'},'g');      % acceleration scaling unit
   setting(o,{'scale.ascale'},1/9.81);  % acceleration scaling factor

   setting(o,{'scale.funit'},'N');      % force scaling unit
   setting(o,{'scale.fscale'},1);       % force scaling factor
   
   oo = mitem(o,'Scale');
   ooo = mitem(oo,'Time Scale',{},'scale.xunit');
   choice(ooo,{{'s','s'},{'ms','ms'}},{@XscaleCb});
   
   ooo = mitem(oo,'Elongation Scale',{},'scale.yunit');
   choice(ooo,{{'m','m'},{'mm','mm'},{'um','um'}},{@YscaleCb});

   ooo = mitem(oo,'Velocity Scale',{},'scale.vunit');
   choice(ooo,{{'m/s','m/s'},{'mm/s','mm/s'},{'um/s','um/s'}},{@VscaleCb});
   
   ooo = mitem(oo,'Acceleration Scale',{},'scale.aunit');
   choice(ooo,{{'m/s2','m/s2'},{'mm/s2','mm/s2'},{'g','g'}},{@AscaleCb});

   ooo = mitem(oo,'Force Scale',{},'scale.funit');
   choice(ooo,{{'N','N'},{'kN','kN'}},{@FscaleCb});
   
   function o = XscaleCb(o)            % Time Scale Callback           
      unit = setting(o,'scale.xunit');
      switch unit
         case 's'
            setting(o,'scale.xscale',1);
         case 'ms'
            setting(o,'scale.xscale',1e3);
      end
      refresh(o);
   end
   function o = YscaleCb(o)            % Elongation Scale Callback     
      unit = setting(o,'scale.yunit');
      switch unit
         case 'm'
            setting(o,'scale.yscale',1);
         case 'mm'
            setting(o,'scale.yscale',1e3);
         case 'um'
            setting(o,'scale.yscale',1e6);
      end
      refresh(o);
   end
   function o = VscaleCb(o)            % Velocity Scale Callback       
      unit = setting(o,'scale.vunit');
      switch unit
         case 'm/s'
            setting(o,'scale.vscale',1);
         case 'mm/s'
            setting(o,'scale.vscale',1e3);
         case 'um/s'
            setting(o,'scale.vscale',1e6);
      end
      refresh(o);
   end
   function o = AscaleCb(o)            % Acceleration Scale Callback   
      unit = setting(o,'scale.aunit');
      switch unit
         case 'm/s2'
            setting(o,'scale.ascale',1);
         case 'mm/s2'
            setting(o,'scale.ascale',1e3);
         case 'g'
            setting(o,'scale.ascale',1/9.81);
      end
      refresh(o);
   end
   function o = FscaleCb(o)            % Force Scale Callback          
      unit = setting(o,'scale.funit');
      switch unit
         case 'N'
            setting(o,'scale.fscale',1);
         case 'kN'
            setting(o,'scale.fscale',1e-3);
      end
      refresh(o);
   end
end
function oo = Bode(o)                  % Bode Settings Menu            
   setting(o,{'bode.omega.low'},1e2);
   setting(o,{'bode.omega.high'},1e5);
   setting(o,{'bode.magnitude.low'},[]);
   setting(o,{'bode.magnitude.high'},[]);
   setting(o,{'bode.phase.low'},-360);
   setting(o,{'bode.phase.high'},0);
   
   setting(o,{'bode.magnitude.enable'},true);
   setting(o,{'bode.phase.enable'},false);
   setting(o,{'bode.omega.points'},200000);
   setting(o,{'bode.closeup'},0);
   
   
   oo = mitem(o,'Bode');
   ooo = mitem(oo,'Lower Frequency',{},'bode.omega.low');
         Choice(ooo,[1e-2,1e-1,1e0,1e1,1e2,1e3],{});
   ooo = mitem(oo,'Upper Frequency',{},'bode.omega.high');
         Choice(ooo,[1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9,1e10],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Magnitude',{},'bode.magnitude.low');
         Choice(ooo,[-400,-360,-300,-200,-100:10:-20],{});
   ooo = mitem(oo,'Upper Magnitude',{},'bode.magnitude.high');
         Choice(ooo,[20:10:100, 200,300,360,400],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Lower Phase',{},'bode.phase.low');
         Choice(ooo,[-270:45:-90],{});
   ooo = mitem(oo,'Upper Phase',{},'bode.phase.high');
         Choice(ooo,[-90:45:135],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Magnitude Plot',{},'bode.magnitude.enable');
   choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Phase Plot',{},'bode.phase.enable');
   choice(ooo,{{'Off',0},{'On',1}},{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Points',{},'bode.omega.points');
   choice(ooo,[100,500,1000,5000,10000,20000,50000,...
               1e5,2e5,5e5,1e6,2e6,5e6,1e7],{});
   ooo = mitem(oo,'Closeup',{},'bode.closeup');
   choice(ooo,{{'Off',0},{},{'500%',5},{'200%',2},{'100%',1},...
               {'50%',0.5},{'20%',0.2},{'10%',0.1},...
               {'5%',0.05},{'2%',0.02},{'1%',0.01}},{});
   
   function Choice(o,values,cblist)    % Choice Menu List With Auto    
      list = {{'Auto',[]},{}};         % list head
      
         % sort values in reverse order
         
      values = sort(values);
      values = values(length(values):-1:1);
      
         % add values to choice items
         
      for (i=1:length(values))
         list{end+1} = {sprintf('%g',values(i)),values(i)};
      end
      
         % add choice menu items
         
      choice(o,list,cblist);
   end
end
function oo = Nyquist(o)               % Nyquist Settings Menu         
   oo = menu(corasim(o),'Nyquist');    % delegate to corasim/menu
end
function oo = Rloc(o)                  % Root Locus Settings Menu      
   setting(o,{'rloc.xlim'},[]);
   setting(o,{'rloc.ylim'},[]);
   setting(o,{'rloc.zoom'},2);
   setting(o,{'rloc.delta'},0.01);
   setting(o,{'rloc.pentagon'},1);
   setting(o,{'rloc.kmin'},-inf);
   setting(o,{'rloc.kmax'},+inf);
   
   
   oo = mitem(o,'Root Locus');
   ooo = mitem(oo,'Real Part',{},'rloc.xlim');
   choice(ooo,{{'Auto',[]},{},{'[-1 0.5]',[-1 0.5]},...
               {'[-2 1]',[-2 1]},{'[-5 2]',[-5 2]},...
               {'[-10 2]',[-10 2]},{'[-100 20]',[-100 20]},...
               {'[-10e2 2e2]',[-10e2 2e2]},{'[-10e3 2e3]',[-10e3 2e3]},...
               {'[-10e4 2e4]',[-10e4 2e4]},...
               {'[-10e5 2e5]',[-10e5 2e5]}},{});
   ooo = mitem(oo,'Imaginary Part',{},'rloc.ylim');
   choice(ooo,{{'Auto',[]},{},{'[-1 +1]',[-1 1]},...
               {'[-2 +2]',[-2 +2]},{'[-5 +5]',[-5 5]},...
               {'[-10 +10]',[-10 10]},{'[-100 +100]',[-100 100]},...
               {'[-10e2 +10e2]',[-10e2 10e2]},{'[-10e3 +10e3]',[-10e3 10e3]},...
               {'[-10e4 +10e4]',[-10e4 10e4]},...
               {'[-10e5 +10e5]',[-10e5 10e5]}},{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Style');
   oooo = mitem(ooo,'Pentagon',{},'rloc.pentagon');
   check(oooo,{});
   ooo = mitem(oo,'Range');
   oooo = mitem(ooo,'Minimum K',{},'rloc.kmin');
   choice(oooo,[-inf -1000 -100 -50 -20 -10 -5 -2 -1.5 -1.2 -1],{});
   oooo = mitem(ooo,'Maximum K',{},'rloc.kmax');
   choice(oooo,[1 1.2 1.5 2 3 4 5 10 20 50 100 1000 inf],{});
     
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Zoom',{},'rloc.zoom');
   choice(ooo,[0.01 0.02 0.05 0.1:0.1:1 ...
               1.2 1.5 2 3 4 5 7.5 10 15 20 50 100],{});
   ooo = mitem(oo,'Delta',{},'rloc.delta');
   choice(ooo,[0.05 0.02 0.01 0.005 0.002 0.001],{});
end
function oo = Weight(o)                % Weight Diagram Settings Menu  
   setting(o,{'weight.equalize'},1);   % enable equalizing by default
   setting(o,{'weight.db'},1);         % show weight in dB by default
   setting(o,{'weight.small'},1e-3);   % threshold for small weights
    
   oo = mitem(o,'Weight');
   ooo = mitem(oo,'Equalize',{},'weight.equalize');
   check(ooo,{});
   ooo = mitem(oo,'Show in dB',{},'weight.db');
   check(ooo,{});
   ooo = mitem(oo,'Small',{},'weight.small');
   choice(ooo,[1e-1 1e-2 1e-3 1e-4 1e-5 1e-6],{});
end
function oo = Stability(o)             % Stability Menu                
   setting(o,{'stability.gain.points'},200);% points for diagram
   setting(o,{'stability.gain.low'},1e-3);
   setting(o,{'stability.gain.high'},1e3);
   setting(o,{'stability.chartstyle'},1);   % new stability chart style
   setting(o,{'stability.closeup'},0); % closeup off

   setting(o,{'view.critical'},1);

   oo = mitem(o,'Stability');
   ooo = mitem(oo,'Lower Gain',{},'stability.gain.low');
         choice(ooo,[1e-15,1e-10,1e-5,1e-4,1e-3,1e-2],{});
   ooo = mitem(oo,'Upper Gain',{},'stability.gain.high');
         choice(ooo,[1e1,1e2,1e3,1e4,1e5],{});
   ooo = mitem(oo,'Points',{},'stability.gain.points');
   choice(ooo,[25 50 100 200 500 1000 2000],{});  
   
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Show Critical',{},'view.critical');
   choice(ooo,{{'Off',0},{'On',1}},{});
   ooo = mitem(oo,'Chart Style',{},'stability.chartstyle');
   choice(ooo,{{'Old',0},{'New',1}},{});

   ooo = mitem(oo,'Closeup',{},'stability.closeup');
   choice(ooo,{{'Off',0},{},{'500%',5},{'200%',2},{'100%',1},...
               {'50%',0.5},{'20%',0.2},{'10%',0.1},...
               {'5%',0.05},{'2%',0.02},{'1%',0.01}},{});
end
function oo = Miscellaneous(o)         % Miscellaneous Menu            
   setting(o,{'view.precision'},1);    % current settings
   
   oo = mitem(o,'Miscellaneous');
   ooo = mitem(oo,'Precision',{},'view.precision');
   choice(ooo,{{'Current Settings',1},{'Comparison',2}},{});
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = mhead(o,'Select');             % add roll down header item
   dynamic(oo);                        % make this a dynamic menu
   event(o,'Select',o);                % rebuild menu on 'Select' event

   ooo = menu(oo,'Objects');           % add Objects menu
   ooo = Channel(oo);                  % add Transfer Channel menu

   ooo = mitem(oo,'-');
   ooo = menu(oo,'Organize');   
   ooo = Basket(oo);                   % add Basket menu

   ooo = mitem(oo,'-');
   ooo = Coordinates(oo);              % add Coordinates sub menu
   ooo = Contact(oo);                  % add Contact sub menu
   ooo = Friction(oo);                 % Friction menu
   ooo = Variation(oo);                % Variation menu
   
   ooo = mitem(oo,'-');
   ooo = Simu(oo);                     % add Simu sub menu
   ooo = Motion(oo);                   % add Motion sub menu

   ooo = mitem(oo,'-');
   ooo = Internal(oo);                 % add Internal sub menu
end
function oo = Channel(o)               % Transfer Channel Menu         
   setting(o,{'select.channel'},[1 1]);

   oo = mitem(o,'Transfer Channel',{},'select.channel');
   choice(oo,{{'G11(s): 1 -> 1',[1 1]},{'G12(s): 2 -> 1',[1 2]},...
              {'G13(s): 3 -> 1',[1 3]},{},{'G21(s): 1 -> 2',[2 1]},...
              {'G22(s): 2 -> 2',[2 2]},{'G23(s): 3 -> 2',[2 3]},{},...
              {'G31(s): 1 -> 3',[3 1]},{'G32(s): 2 -> 3',[3 2]},...
              {'G33(s): 3 -> 3',[3 3]}},{});
   
end
function oo = Basket(o)                % Basket Menu                   
   [pivots,piv] = Pivots(o);
   setting(o,{'basket.pivot'},piv);

      % build-up Basket menu
      
   oo = mhead(o,'Basket');
   ooo = mitem(oo,'Pivot [°]',{},'basket.pivot');
   if ~isempty(pivots)
      choice(ooo,pivots,{});
   end
   
   function [pivots,piv] = Pivots(o);  % collect pivots
      pivots = [];
      o = pull(o);
      for (i=1:length(o.data))
         oi = o.data{i};
         if type(oi,{'spm'})
            pivot = get(oi,'pivot');
            if (~isempty(pivot) && isa(pivot,'double') && length(pivot)==1)
               if isempty(find(pivots==pivot))
                  pivots(end+1) = pivot;
               end
            end
         end
      end
      pivots = sort(pivots);
      
      if ~isempty(find(pivots==85))
         piv = 85;
      elseif ~isempty(pivots)
         piv = pivots(end);
      else
         piv = [];
      end
   end
end
function oo = Friction(o)              % Friction Menu                 
   setting(o,{'process.mu'},0.1);      % Coulomb friction parameter
   
   oo = mitem(o,'Friction');
   ooo = mitem(oo,'Mu (Coefficient)',{},'process.mu');
   charm(ooo,{@FrictionCb});
   
   function o = FrictionCb(o)          % On Friction Changes           
      mu = setting(o,'process.mu');    
      
         % make 'loop' cache segment dirty
         
      setting(o,'loop.dirty.process.mu',mu);
      
         % finally refresh actual drawing
         
      refresh(pull(o));
   end
end
function oo = Variation(o)             % Parameter Variation           
   setting(o,{'variation.omega'},1);   % global omega variation
   setting(o,{'variation.zeta'},1);    % global zeta variation
   
   oo = mhead(o,'Variation');
   ooo = mitem(oo,'Omega',{},'variation.omega');
   charm(ooo,{@OmegaCb});
   ooo = mitem(oo,'Zeta',{},'variation.zeta');
   charm(ooo,{@ZetaCb});
   
   function o = OmegaCb(o)             % On Omega Variation Changes    
      omega = setting(o,'variation.omega');
      
         % make 'trf', 'consd', 'loop' and 'principal' cache segment dirty

      setting(o,'trf.dirty.variation.omega',omega);
      setting(o,'consd.dirty.variation.omega',omega);
      setting(o,'loop.dirty.variation.omega',omega);
      setting(o,'principal.dirty.variation.omega',omega);
      
         % finally refresh actual drawing

      refresh(pull(o));
   end
   function o = ZetaCb(o)             % On Zeta Variation Changes    
      zeta = setting(o,'variation.zeta');
      
         % make 'trf', 'consd', 'loop' and 'principal' cache segment dirty

      setting(o,'trf.dirty.variation.zeta',zeta);
      setting(o,'consd.dirty.variation.zeta',zeta);
      setting(o,'loop.dirty.variation.zeta',zeta);
      setting(o,'principal.dirty.variation.zeta',zeta);
      
         % finally refresh actual drawing

      refresh(pull(o));
   end
end
function oo = Simu(o)                  % Simulation Parameter Menu     
%
% SIMU   Add simulation parameter menu items
%
   setting(o,{'simu.tmax'},0.01);
   setting(o,{'simu.dt'},1e-5);
   setting(o,{'simu.plot'},200);       % number of points to plot
 
   setting(o,{'simu.Fmax'},100);
   setting(o,{'simu.Nmax'},10);        % noise magnitude
 
   oo = mitem(o,'Simulation');
   ooo = mitem(oo,'Max Time (tmax)',{},'simu.tmax');
          choice(ooo,{{'Auto',[]},{},{'1 h',3600},{},...
                      {'30 min',30*60},{'20 min',20*60},{'10 min',600},...
                      {'5 min',5*60},{'2 min',2*60},{'1 min',1*60},{},...
                      {'30 s',30},{'20 s',20},{'10 s',10},{'5 s',5},...
                      {'2 s',2},{'1 s',1},{},{'500 ms',0.5},...
                      {'200 ms',0.2},{'100 ms',0.1},{'50 ms',0.05},...
                      {'20 ms',0.02},{'10 ms',0.01}},{});
   ooo = mitem(oo,'Time Increment (dt)',{},'simu.dt');
          choice(ooo,[1e-6,2e-6,5e-6, 1e-5,2e-5,5e-5, 1e-4,2e-4,5e-4,...
                      1e-3,2e-3,5e-3, 1e-2,2e-2,5e-2, 1e-2,2e-2,5e-2,...
                      2e-2,1e-2,5e-3,2e-3,1e-3],{});
   ooo = mitem(oo,'Number of Plot Intervals',{},'simu.plot');
          choice(ooo,{{'50',50},{'100',100},{'200',200},{'500',500},...
                      {'1000',1000},{},{'Maximum',inf}},{});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Max Force [N]',{},'simu.Fmax');
          choice(ooo,[1 2 5 10 20 50 100 200 500 1000 inf],{});
   ooo = mitem(oo,'Noise [N]',{},'simu.Nmax');
          choice(ooo,[1 2 5 10 20 50 100 200 500 1000 inf],{});
end
function oo = Critical(o)              % Critical Menu                
   setting(o,{'stability.algo'},'ss'); % stability algorithm
   setting(o,{'stability.search'},50); % number of search points
   setting(o,{'stability.iter'},15);   % iterations

   oo = mitem(o,'Critical');
   ooo = mitem(oo,'Algorithm',{},'stability.algo');
   choice(ooo,{{'Transfer function','trf'},{'State Space','ss'},...
               {'Mixed Type','mix'}},{});
   
   ooo = mitem(oo,'Initial Searches',{},'stability.search');
   choice(ooo,[25 50 100 200 500],{});

   ooo = mitem(oo,'Iterations',{},'stability.iter');
   choice(ooo,[5 10 15 20 25 30 35 40 45 50 75 100],{});
   ooo = mitem(oo,'-');  
end
function oo = Spectrum(o)              % Spectrum Menu                 
   setting(o,{'spectrum.omega.low'},1e2);
   setting(o,{'spectrum.omega.high'},1e5);
   setting(o,{'spectrum.omega.points'},2000);
   
   
   oo = mitem(o,'Spectrum');
   ooo = mitem(oo,'Lower Frequency',{},'spectrum.omega.low');
         Choice(ooo,[1e-2,1e-1,1e0,1e1,1e2,1e3],{});
   ooo = mitem(oo,'Upper Frequency',{},'spectrum.omega.high');
         Choice(ooo,[1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8,1e9,1e10],{});
         
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Points',{},'spectrum.omega.points');
   choice(ooo,[100,500,1000,2000,5000,10000,20000,50000,...
               1e5,2e5],{});

   function Choice(o,values,cblist)    % Choice Menu List With Auto    
      list = {{'Auto',[]},{}};         % list head
      
         % sort values in reverse order
         
      values = sort(values);
      values = values(length(values):-1:1);
      
         % add values to choice items
         
      for (i=1:length(values))
         list{end+1} = {sprintf('%g',values(i)),values(i)};
      end
      
         % add choice menu items
         
      choice(o,list,cblist);
   end
end
function oo = Filter(o)                % Add Filter Menu Items         
   setting(o,{'filter.mode'},'raw');   % filter mode off
   setting(o,{'filter.type'},'LowPass2');
   setting(o,{'filter.bandwidth'},5);
   setting(o,{'filter.zeta'},0.6);
   setting(o,{'filter.method'},1);

   oo = mhead(o,'Filter');
   ooo = mitem(oo,'Mode','','filter.mode');
   choice(ooo,{{'Raw Signal','raw'},{'Filtered Signal','filter'},...
                {'Raw & Filtered','both'},{'Signal Noise','noise'}},'');
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Type',{},'filter.type');
   choice(ooo,{{'Order 2 Low Pass','LowPass2'},...
                {'Order 2 High Pass','HighPass2'},...
                {'Order 4 Low Pass','LowPass4'},...
                {'Order 4 High Pass','HighPass4'}},{});
   ooo = mitem(oo,'Bandwidth',{},'filter.bandwidth');
   charm(ooo,{});
   ooo = mitem(oo,'Zeta',{},'filter.zeta');
   charm(ooo,{});
   ooo = mitem(oo,'Method',{},'filter.method');
   choice(ooo,{{'Forward',0},{'Fore/Back',1},{'Advanced',2}},{});
end
function oo = Motion(o)                % Add Motion Menu Items         
   setting(o,{'motion.smax'},10e-6);   % 10 um stroke
   setting(o,{'motion.vmax'},0.15e-3); % 0.15mm/s max velocity
   setting(o,{'motion.amax'},100e-3);  % 100 mm/s2 max acceleration
   setting(o,{'motion.tj'},0.005);     % 5 ms jerk time
   setting(o,{'motion.sunit'},'mm');   % stroke unit: mm
   setting(o,{'motion.tunit'},'ms');   % time unit: ms

   oo = mitem(o,'Motion');
   ooo = mitem(oo,'Stroke (smax)',{},'motion.smax');
        choice(ooo,[10 20 50 100 200 300 400 500]*1e-6,{});
   ooo = mitem(oo,'Max. Velocity [m/s]',{},'motion.vmax');
        choice(ooo,[0.05 0.10 0.15 0.2 0.3 0.4 0.5]*1e-3,{});
   ooo = mitem(oo,'Max. Acceleration [m/s2]',{},'motion.amax');
        choice(ooo,[1e-3 1e-2 1e-1],{});
   ooo = mitem(oo,'Jerk Time [s]',{},'motion.tj');
        choice(ooo,[0.02 0.01 0.005],{});
end
function oo = Contact(o)               % Add Contact Menu Items        
   setting(o,{'process.contact'},inf); % multi contact
   
   oo = current(o);
   if type(oo,{'spm'})
      N = round(size(oo.data.B,2)/3);
   else
      N = 5;
   end
   
   if (N == 5)
      leading =  {1 1 1 0 0};
      trailing = {0 0 1 1 1};
      triple =   {0 1 1 1 0};
   elseif (N == 7)
      leading =  {1 1 1 1 0 0 0};
      trailing = {0 0 0 1 1 1 1};
      triple =   {0 0 1 1 1 0 0};
   else
      leading = inf;
      trailing = inf;
      triple = inf;
   end
   
   list = {{'Center',0},{'Leading',leading},{'Trailing',trailing},...
           {'Triple',triple},{'Multi',inf},{}};
   for(i=1:N)
      list{end+1} = {sprintf('%g',i),i};
   end
   
   oo = mitem(o,'Contact',{},'process.contact');
   choice(oo,list,{@CacheReset});
end
function oo = Coordinates(o)           % Add Coordinates Menu Items    
   setting(o,{'process.phi'},0);
   setting(o,{'process.Cphi'},1);
    
   oo = mitem(o,'Coordinates');
   ooo = mitem(oo,'Phi Rotation',{},'process.phi');
   choice(ooo,{{'-90°',-90},{'0°',0},{'90°',90},{'180°',180}},{@CacheReset});
   
   ooo = mitem(oo,'Phi Correction',{},'process.Cphi');
   choice(ooo,[-2 -1.5 -1:0.2:1 1.5 2],{@CacheReset});
end


function oo = Internal(o)              % Internal Menu
   oo = mitem(o,'Internal');
   ooo = Trf(oo);                      % add Transfer Function menu
   ooo = Fqr(oo);                      % add Frequency Response menu
   ooo = Precision(oo);                % add Precision Menu
   ooo = Normalize(oo);                % add Normalize menu   
   ooo = Cancel(oo);                   % add Cancel sub menu
   ooo = Critical(oo);                 % add Critical sub menu
   ooo = Spectrum(oo);                 % add Spectrum sub menu
   ooo = Filter(oo);                   % add Filter sub menu
end

function oo = Trf(o)                   % Transfer Function Menu        
   setting(o,{'trf.type'},'szpk');
   
   oo = mitem(o,'Transfer Functions',{},'trf.type');
   choice(oo,{{'Trf Type','strf'},{'ZPK Type','szpk'},...
              {'Modal Type','modal'}},{@CacheReset});
end
function oo = Fqr(o)                   % Frequency Response Menu       
   setting(o,{'select.fqr'},'standard');
   
   oo = mitem(o,'Frequency Response',{},'select.fqr');
   choice(oo,{{'Standard','standard'},{'Expression','expression'}},...
              {@CacheReset});
end
function oo = Precision(o)             % Variable Presicion Menu       
   setting(o,{'precision.G'},0);       % VPA digits of G(s) calculation
   setting(o,{'precision.Gcook'},0);   % G(s) cooking as double   
   setting(o,{'precision.check'},128);
   setting(o,{'precision.V0'},0);      % VPA digits of V0 calculation
   setting(o,{'select.controltoolbox'},0);
   
   oo = mitem(o,'Precision');
   ooo = mitem(oo,'G(s) Calculation',{},'precision.G');
   choice(ooo,{{'Double',0},{},{'VPA 32',32},{'VPA 64',64},{'VPA 128',128},...
               {'VPA 256',256},{'VPA 512',512},{'VPA 1024',1024}},...
               {@DigitCb});
   
   ooo = mitem(oo,'G(s) Cooking',{},'precision.Gcook');
   choice(ooo,{{'Double',0},{'VPA',1}},{});

   ooo = mitem(oo,'Check',{},'precision.check');
   choice(ooo,{{'Double',0},{},{'VPA 32',32},{'VPA 64',64},{'VPA 128',128},...
               {'VPA 256',256},{'VPA 512',512},{'VPA 1024',1024}},...
               {});
   
   ooo = mitem(oo,'V0 = G33(0)\G31(0)',{},'precision.V0');
   choice(ooo,{{'Double',0},{},{'VPA 32',32},{'VPA 64',64},{'VPA 128',128},...
               {'VPA 256',256},{'VPA 512',512},{'VPA 1024',1024}},...
               {@DigitCb});

   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Use Control Toolbox',{},'select.controltoolbox');
   check(ooo,{@ControlCb});
   
   function o = DigitCb(o)
      CacheReset(o);
      try
         old = digits(32);
         digits(old);                  % and restore immediately
      catch
         choice(o,'precision.G',0);
         choice(o,'precision.Gcook',0);
         choice(o,'precision.V0',0);
         message(o,'Selection rejected!',...
                   {'Seems that Symbolic Toolbox is not supported!'});
      end
   end
   function o = ControlCb(o)
      ctbox = setting(o,'select.controltoolbox');
      if (ctbox == 0)
         CacheReset(o);
      else
         try
            sys = ss(1,1,1,1);
            CacheReset(o);
         catch
            check(o,'select.controltoolbox',0);
            message(o,'Selection rejected!',...
                      {'Seems that Control Toolbox is not supported!'});
         end
      end
   end
end
function oo = Normalize(o)             % Normalize Menu                
   setting(o,{'brew.T0'},1e-3);
   
   oo = mitem(o,'Normalize');
   ooo = mitem(oo,'T0',{},'brew.T0');
   choice(ooo,{{'1s',1},{},{'100ms',100e-3},{'10ms',10e-3},{'1 ms',1e-3},...
               {},{'100 us',100e-6},{'10 us',10e-6},{'1 us',1e-6}},...
               {@CacheReset});
end
function oo = Cancel(o)                % Add Cancel Menu Items         
   setting(o,{'cancel.G.eps'},1e-7);
   setting(o,{'cancel.H.eps'},1e-7);
   setting(o,{'cancel.L.eps'},1e-7);
   setting(o,{'cancel.T.eps'},1e-7);
   
   oo = mitem(o,'Cancel');
   ooo = mitem(oo,'G(s)',{},'cancel.G.eps');
   choice(ooo,[1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7],{@CacheReset});
   ooo = mitem(oo,'H(s)',{},'cancel.H.eps');
   choice(ooo,[1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7],{@CacheReset});
   ooo = mitem(oo,'L(s)',{},'cancel.L.eps');
   choice(ooo,[0.1,0.09,0.08,0.07,0.06,0.05,0.04,0.03,0.02,0.01,...
               0.005,0.002,0.001,1e-4,1e-5,1e-6,1e-7],{@CacheReset});
   ooo = mitem(oo,'T(s)',{},'cancel.T.eps');
   choice(ooo,[1e-1,1e-2,1e-3,1e-4,1e-5,1e-6,1e-7],{@CacheReset});
end
function oo = CacheReset(o)            % Reset All Caches              
%  callback = control(o,'refresh');    % save refresh callback
   
   o = pull(o);
   for (i=1:length(o.data))
      oo = o.data{i};
      cache(oo,oo,[]);                 % cache hard reset
   end
   
%  control(o,'refresh',callback);      % restore refresh callback
   refresh(o);
   oo = o;
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                     
   oo = mhead(o,'Plot');               % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = plot(oo,'Menu');              % setup plot menu

   plugin(o,'spm/shell/Plot');         % plug point
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analyse(o)               % Analyse Menu                  
   oo = mhead(o,'Analyse');            % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');           % setup analyse menu

   plugin(o,'spm/shell/Analyse');      % plug point
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = mhead(o,'Study');              % add roll down header menu item
   dynamic(oo);                        % make this a dynamic menu
   ooo = study(oo,'Menu');             % setup study menu

   plugin(o,'spm/shell/Study');        % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   ooo = mseek(oo,{'Version'});
   oooo = mitem(ooo,['Spm Class: Version ',version(spm)]);
   ooooo = mitem(oooo,'Edit Release Notes','edit spm/version');

   plugin(o,'spm/shell/Info');         % plug point
end

%==========================================================================
% Helper
%==========================================================================

function oo = Dialog(o)                % Edit Key Parameters           
%
% Dialog  A dialog box is opened to edit key parameters
%         With opt(o,'caption') the default caption of the dialog box
%         can be redefined.
%
   either = @corazito.either;          % short hand
   is = @corazito.is;                  % short hand
   trim = @corazito.trim;              % short hand
   
   caption = opt(o,{'caption','Edit Key Parameters'});
   title = either(get(o,'title'),'');
   comment = either(get(o,'comment'),{});
   if ischar(comment)
      comment = {comment};
   end
   date = either(get(o,'date'),'');
   time = either(get(o,'time'),'');
   project = either(get(o,'project'),'');
   variation = either(get(o,'variation'),'pivot');
   image = either(get(o,'image'),'image.png');
   version = either(get(o,'version'),'');
   creator = either(get(o,'creator'),'');
%
% We have to convert comments into a text block
%
   text = '';
   for (i=1:length(comment))
      line = comment{i};
      if is(line)
         text(i,1:length(line)) = line;
      end
   end
%
% Now prepare for the input dialog
%
   prompts = {'Title','Comment','Date','Time',...
              'Project','Variation','Image','Version','Creator'};
   values = {title,text,date,time,project,variation,image,version,creator};
   dims = ones(length(values),1)*[1 50];  dims(2,1) = 3;
   
   values = inputdlg(prompts,caption,dims,values);   
   if isempty(values)
      oo = [];
      return                           % user pressed CANCEL
   end
   
   title = either(values{1},title);
   text = values{2};
   comment = {};
   for (i=1:size(text,1))
      comment{i,1} = trim(text(i,:),+1);   % right trim
   end
   oo = set(o,'title,comment',title,comment);
   
   date = values{3};  time = values{4};
   oo = set(oo,'date',date,'time',time);
   
   project = values{5};  variation = values{6};
   image = values{7};  version = values{8};  creator = values{9};
   oo = set(oo,'project',project,'version',version,'creator',creator);
   oo = set(oo,'variation',variation,'image',image);
end
function oo = ReadInfo(o,path)         % Read Info into Comment        
   fid = fopen(path);
   if isequal(fid,-1)
      oo = o;
      return                           % file not found / cannot open file
   end
   phi = 0;                        % init by default
   
   comment = get(o,{'comment',{}});
   while (1)
      line = fgetl(fid);
      if ~isequal(line,-1)
         idx = find(line==':');
         if ~isempty(idx)
            idx = idx(1)+1;
            while (length(line)>=idx+1 && line(idx)==' ' && line(idx+1)==' ')
               line(idx) = [];
            end
         end
         
         comment{end+1} = o.trim(line);
         
            % search for key 'phi:' and if found set 'phi'
            % parameter
            
         key = 'phi:';             % key to search
         idx = strfind(line,key);
         if ~isempty(idx)
            str = line(idx+length(key):end);
            phi = eval(str);
         end
      else
         break
      end
   end
   
   fclose(fid);
   oo = set(o,'comment',comment);
   oo = set(oo,'phi',phi);
end
