function oo = batch(o,varargin)        % Batch figure printing         
%
% BATCH Batch figure generation
%
%       oo = batch(o,'Menu')           % setup Batch menu
%       oo = batch(o,'Options')        % set Batch options
%
%       oo = batch(o,func)             % call local batch function
%
%    See also: SPM, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,@WithSho,@WithBsk,...
                        @RunBatch,@About,@Options,...
                        @StabilityMargin,@CriticalOverview,...
                        @CriticalSensitivity,@DampingSensitivity,...
                        @SetupStudy,@ClearAllCaches,@Confirm);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Study Menu              
   oo = Config(o);                     % add config menu      
   oo = mitem(o,'Run Batch',{@WithCuo,'RunBatch'});
   oo = mitem(o,'-');
   oo = mitem(o,'Stability Margin',{@WithCuo,'StabilityMargin'});
   oo = mitem(o,'Critical Overview',{@WithCuo,'CriticalOverview'});
   oo = mitem(o,'-');
   oo = mitem(o,'Damping Sensitivity',{@WithCuo,'DampingSensitivity'});
   oo = mitem(o,'Critical Sensitivity',{@WithCuo,'CriticalSensitivity'});
   oo = mitem(o,'-');
   oo = mitem(o,'Setup Study',{@WithCuo,'SetupStudy'});
end
function o = Config(o)                 % Configuration Menu            
   setting(o,{'batch.stabilitymargin'},1);
   setting(o,{'batch.criticaloverview'},1);
   setting(o,{'batch.dampingsensitivity'},1);
   setting(o,{'batch.criticalsensitivity'},1);
   setting(o,{'batch.setupstudy'},0);
   setting(o,{'batch.pareto'},1.0);             % crit. sensitivity pareto
   setting(o,{'batch.cutting'},+1);             % forward cutting
   setting(o,{'batch.fast'},1);                 % fast batch processing 
   setting(o,{'batch.cleanup'},0);              % cache cleanup
   setting(o,{'batch.save'},1);                 % intermediate save
   setting(o,{'batch.spectrum.points'},10000);  % points of spectrum
   setting(o,{'batch.critical.eps'},1e-6);      % epsilon of critical phase
   
   oo = mitem(o,'Batch Config');
   ooo = mitem(oo,'Show Config',{@About});
   
   mitem(oo,'-');
   ooo = mitem(oo,'Stability Margin',{},'batch.stabilitymargin');
         check(ooo,{@Cb,0});
   ooo = mitem(oo,'Critical Overview',{},'batch.criticaloverview');
         check(ooo,{@Cb});
   
   mitem(oo,'-');
   ooo = mitem(oo,'Damping Sensitivity',{},'batch.dampingsensitivity');
         check(ooo,{@Cb,0});
   ooo = mitem(oo,'Critical Sensitivity',{},'batch.criticalsensitivity');
         check(ooo,{@Cb,0});
   
   mitem(oo,'-');
   ooo = mitem(oo,'Setup Study',{},'batch.setupstudy');
         check(ooo,{@Cb,0});

   mitem(oo,'-');
   ooo = mitem(oo,'Pareto',{},'batch.pareto');
        choice(ooo,{{'10%',0.1},{'20%',0.2},{'40%',0.4},{'60%',0.6},...
                   {'80%',0.8},{'100%',1.0}},{@Cb});
   ooo = mitem(oo,'Cutting',{},'batch.cutting');
        choice(ooo,{{'Forward',+1},{'Backward',-1},{'Both',0}},{@Cb});
   ooo = mitem(oo,'Fast Processing',{},'batch.fast');
        check(ooo,{@Cb,0});
   ooo = mitem(oo,'Cache Cleanup',{},'batch.cleanup');
        check(ooo,{@Cb,0});
   ooo = mitem(oo,'Intermediate Save',{},'batch.save');
        check(ooo,{@Cb,0});

   mitem(oo,'-');
   ooo = mitem(oo,'Points',{},'batch.spectrum.points');
   choice(ooo,[100,500,1000,2000,5000,10000,20000],{@Cb,1});
   ooo = mitem(oo,'Epsilon',{},'batch.critical.eps');
   choice(ooo,10.^[-10:-3],{@Cb,0});

   function o = Cb(o)
      clear = o.either(arg(o,1),0);
      if (clear)
         o = ClearAllCaches(o);
         o = About(o,'All caches cleared');
      else
         o = About(o);
      end
   end
end
function [o,list] = About(o,msg)       % About Batch Configuration     
   refresh(o,o);                       % come here for refresh
   batch = opt(o,'batch');
   comment = {};

   if (batch.stabilitymargin)
      comment{end+1} = 'Stability Margin';
   end
   if (batch.criticaloverview)
      comment{end+1} = 'Critical Overview';
   end
   if (batch.dampingsensitivity)
      comment{end+1} = 'Damping Sensitivity';
   end
   if (batch.criticalsensitivity)
      comment{end+1} = 'Critical Sensitivity';
   end
   if (batch.setupstudy)
      comment{end+1} = 'Setup Study';
   end
   
   comment{end+1} = ' ';
   
   comment{end+1} = sprintf('Pareto %g %%',batch.pareto*100);
   
   switch batch.cutting
      case +1
         comment{end+1} = 'Forward Cutting';
      case -1
         comment{end+1} = 'Backward Cutting';
      case 0
         comment{end+1} = 'Forward/Backward Cutting';
   end
   
   if (batch.fast)
      comment{end+1} = 'Fast Processing';
   end
   if (batch.cleanup)
      comment{end+1} = 'Cache Cleanup';
   end
   if (batch.save)
      comment{end+1} = 'Intermediate Save';
   end
   
   comment{end+1} = sprintf('Points: %g',opt(o,'batch.spectrum.points'));
   comment{end+1} = sprintf('Epsilon: %g',opt(o,'batch.critical.eps'));
   
   if (nargout <= 1)
      cls(o);

      title = 'Batch Configuration';
      if (nargin >= 2)
         title = sprintf('%s (%s)',title,msg);
      end

      oo = opt(o,'pitch',0.5);
      message(oo,title,comment);
   else
      list = comment;
   end
end

%==========================================================================
% Launch Callbacks
%==========================================================================

function oo = WithSho(o)               % 'With Shell Object' Callback  
%
% WITHSHO General callback for operation on shell object
%         with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,{@batch,'About'});        % display About message on refresh

   mode = dark(o);
   dark(o,0);
   o = dark(o,0);                      % disable dark mode for object o
   
   cls(o);                             % clear screen
   
   stop(o,'Enable');
   gamma = eval(['@',mfilename]);
   o = Options(o);                     % set batch options
   oo = gamma(o);                      % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   
   dark(o,mode);                       % restore dark mode
   o = dark(o,mode);                   % restore dark mode for object o
   
   done = var(oo,'done');
   if ~isempty(done)
      cls(o);
      message(o,done);
   end
end
function oo = WithCuo(o)               % 'With Current Object' Callback
%
% WITHCUO A general callback with refresh function redefinition, screen
%         clearing, current object pulling and forwarding to executing
%         local function, reporting of irregularities, dark mode support
%
   refresh(o,{@batch,'About'});        % display About message on refresh
   
   mode = dark(o);                     % save dark mode
   dark(o,0);                          % disable dark mode shell setting
   o = dark(o,0);                      % disable dark mode for object o
   
   cls(o);                             % clear screen

   oo = current(o);                    % get current object 
   
      % oo = current(o) directly inherits options from shell object,
      % this we have to set dark mode option also for oo!
      
   oo = dark(oo,0);                    % disable dark mode
   
   stop(o,'Enable');
   gamma = eval(['@',mfilename]);
   oo = Options(oo);                   % set batch options
   oo = gamma(oo);                     % forward to executing method

   if isempty(oo)                      % irregulars happened?
      oo = set(o,'comment',...
                 {'No idea how to plot object!',get(o,{'title',''})});
      message(oo);                     % report irregular
   end
   
   dark(o,mode);                       % restore dark mode (shell settings)
   o = dark(o,mode);                   % restore dark mode for object o
   
   done = var(oo,'done');
   if ~isempty(done)
      cls(o);
      message(o,done);
   end
end

%==========================================================================
% Run Batch
%==========================================================================

function o = RunBatch(o)               % Master Entry for Batch Process
   tstart = tic;
   
%o = ClearAllCaches(o);                 % at this beta stage safer ;-)
   o = Confirm(o);
   if isempty(o)
      return
   end
      
   switch o.type
      case 'shell'
         o = RunAll(o);
      case 'pkg'
         o = RunPkg(o);
      case 'spm'
         o = RunSpm(o);
   end
   
      % print/display end message
      
   elapse = toc(tstart);
   msg = o.iif(stop(o),'batch processing stopped',...
                       'batch processing complete');
   msg = sprintf('%s (total time: %g s)',msg,o.rd(elapse,0));
   fprintf('%s\n',msg);

   o = var(o,'done',msg);
end
function o = RunAll(o)                 % Run All Configured Batch Items
   assert(type(o,{'shell'}));

   list = children(o);                 % get list of SPM objects 
   for (i=1:length(list))
      oo = list{i};
      RunPkg(oo);
      if stop(o)
         break;
      end
   end
end
function o = RunPkg(o)                 % Run a Single Package          
   assert(type(o,{'pkg'}));
   batch = opt(o,'batch');

      % individual package specific plots

   if (batch.stabilitymargin)
      if stop(o)
         return
      end
      
      StabilityMarginPkg(o);
      
      if (~stop(o) && batch.save)
         IntermediateSave(o);
      end
   end
         
   list = children(o);                 % list of package's children
   for (i=1:length(list))
      if stop(o)
         return;
      end
      
      oo = list{i};                    % i-th child
      oo = RunSpm(oo);                 % run batch for SPM object

         % intermediate save, if activated

      if (~stop(o) && ~isempty(oo) && batch.save)
         IntermediateSave(o);
      end
   end
   
      % setup overview for the package
      
   if (batch.setupstudy)
      if stop(o)
         return
      end
   
      SetupStudyPkgOnly(o);

         % intermediate save, if activated

      if (~stop(o) && batch.save)
         IntermediateSave(o);
      end
   end      

      % cache cleanup

   if (batch.cleanup)
      fprintf('clear cache of package and all SPM objects\n');
      o = cache(o,o,[]);               % cache hard clear of PKG object
      for (i=1:length(list))
         oo = list{i};                 % i-th child
         oo = cache(oo,oo,[]);         % cache hard clear of SPM object
      end
   end
end
function oo = RunSpm(o)                % Run a Single SPM Object       
%
% RUNSPM   Run batch tasks for a single SPM object.
%
%             o = RunSpm(o)
%
%          If cache needs to be cleared then return SPMobject with cleared
%          cache!
%
   oo = [];
   assert(type(o,{'spm'}));
   batch = opt(o,'batch');

      % stability margin

   if (batch.stabilitymargin)
      if stop(o)
         return
      end
      %StabilityMarginSpm(o);          % not supported
   end

      % critical overview

   if (batch.criticaloverview)
      if stop(o)
         return
      end
      CriticalOverviewSpm(o);
      oo = o;
   end

      % damping sensitivity

   if (batch.dampingsensitivity)
      if stop(o)
         return
      end
      DampingSensitivitySpm(o);
      ID = id(o);
      oo = id(o,ID);                   % refresh object with updated cache
      o = inherit(oo,o);               % inherit actual options
      oo = o;
   end

      % critical sensitivity

   if (batch.criticalsensitivity)
      if stop(o)
         return
      end
      CriticalSensitivitySpm(o);
      oo = o;
   end

      % setup study

   if (batch.setupstudy)
      if stop(o)
         return
      end
      SetupStudySpm(o);
      oo = o;
   end
end

%==========================================================================
% Stability Margin
%==========================================================================

function o = StabilityMargin(o)        % Dispatcher                    
   switch o.type
      case 'shell'
         StabilityMarginAll(o);
      case 'pkg'
         StabilityMarginPkg(o);
      case 'spm'
         StabilityMarginSpm(o);
   end
end
function o = StabilityMarginAll(o)                                     
   assert(type(o,{'shell'}));
   list = children(o);                  % get list of packages 
   
   for (i=1:length(list))
      oo = list{i};
      StabilityMarginPkg(oo);
      if stop(o)
         break
      end
   end
end
function o = StabilityMarginPkg(o)                                     
   assert(type(o,{'pkg'}));
   cls(o);

   o = Cls(o,'Stability Margin');
   analyse(o,'StabilityMargin');
   Png(o);
end
function o = StabilityMarginSpm(o)                                     
   assert(type(o,{'spm'}));
   cls(o);
end

%==========================================================================
% Critical Overview
%==========================================================================

function o = CriticalOverview(o)       % Dispatcher                    
   switch o.type
      case 'shell'
         CriticalOverviewAll(o);
      case 'pkg'
         CriticalOverviewPkg(o);
      case 'spm'
         CriticalOverviewSpm(o);
   end
end
function o = CriticalOverviewAll(o)                                    
   assert(type(o,{'shell'}));
   list = children(o);                  % get list of packages 
   
   for (i=1:length(list))
      oo = list{i};
      CriticalOverviewPkg(oo);
      if stop(o)
         break
      end
   end
end
function o = CriticalOverviewPkg(o)                                    
   assert(type(o,{'pkg'}));
   list = children(o);                 % get list of SPM objects 
   
   for (i=1:length(list))
      oo = list{i};
      CriticalOverviewSpm(oo);
      if stop(o)
         break
      end
   end
end
function o = CriticalOverviewSpm(o)                                    
   assert(type(o,{'spm'}));
   batch = opt(o,'batch');
   
   if (batch.cutting >= 0)             % forward cutting      
      o = Cls(o,'Critical Overview (Forward)');
      o = opt(o,'view.cutting',+1);
      analyse(o,'Critical','Overview');
      Png(o);
   end
      
   if stop(o)                          % time to  stop?
      return
   end
   
   if (batch.cutting <= 0)             % backward cutting      
      o = Cls(o,'Critical Overview (Backward)');
      o = opt(o,'view.cutting',-1);
      analyse(o,'Critical','Overview');
      Png(o);
   end
end

%==========================================================================
% Damping Sensitivity
%==========================================================================

function o = DampingSensitivity(o)     % Dispatcher                    
   switch o.type
      case 'shell'
         DampingSensitivityAll(o);
      case 'pkg'
         DampingSensitivityPkg(o);
      case 'spm'
         DampingSensitivitySpm(o);
   end
end
function o = DampingSensitivityAll(o)                                  
   assert(type(o,{'shell'}));
   list = children(o);                  % get list of packages 
   
   for (i=1:length(list))
      oo = list{i};
      DampingSensitivityPkg(oo);
      if stop(o)
         break
      end
   end
end
function o = DampingSensitivityPkg(o)                                  
   assert(type(o,{'pkg'}));
   list = children(o);                 % get list of SPM objects 
   
   for (i=1:length(list))
      oo = list{i};
      DampingSensitivitySpm(oo);
      if stop(o)
         break
      end
   end
end
function o = DampingSensitivitySpm(o)                                  
   assert(type(o,{'spm'}));
   batch = opt(o,'batch');
   
   if (batch.cutting >= 0)             % forward cutting      
      o = Cls(o,'Damping Sensitivity (Forward)');
      o = opt(o,'view.cutting',+1);
      sensitivity(o,'Damping');
      Png(o);
   end
      
   if stop(o)                          % time to  stop?
      return
   end
   
   if (batch.cutting <= 0)             % backward cutting      
      o = Cls(o,'Damping Sensitivity (Backward)');
      o = opt(o,'view.cutting',-1);
      sensitivity(o,'Damping');
      Png(o);
   end
end

%==========================================================================
% Critical Sensitivity
%==========================================================================

function o = CriticalSensitivity(o)    % Dispatcher                    
   switch o.type
      case 'shell'
         CriticalSensitivityAll(o);
      case 'pkg'
         CriticalSensitivityPkg(o);
      case 'spm'
         CriticalSensitivitySpm(o);
   end
end
function o = CriticalSensitivityAll(o)                                 
   assert(type(o,{'shell'}));
   list = children(o);                  % get list of packages 
   
   for (i=1:length(list))
      oo = list{i};
      CriticalSensitivityPkg(oo);
      if stop(o)
         break
      end
   end
end
function o = CriticalSensitivityPkg(o)                                 
   assert(type(o,{'pkg'}));
   list = children(o);                 % get list of SPM objects 
   
   for (i=1:length(list))
      oo = list{i};
      CriticalSensitivitySpm(oo);
      if stop(o)
         break
      end
   end
end
function o = CriticalSensitivitySpm(o)                                 
   assert(type(o,{'spm'}));
   batch = opt(o,'batch');
   
   if (batch.cutting >= 0)             % forward cutting      
      o = Cls(o,'Critical Sensitivity (Forward)');
      o = opt(o,'view.cutting',+1);
      sensitivity(o,'Critical');
      Png(o);
   end
      
   if stop(o)                          % time to  stop?
      return
   end
   
   if (batch.cutting <= 0)             % backward cutting      
      o = Cls(o,'Critical Sensitivity (Backward)');
      o = opt(o,'view.cutting',-1);
      sensitivity(o,'Critical');
      Png(o);
   end
end

%==========================================================================
% Setup Study
%==========================================================================

function o = SetupStudy(o)             % Dispatcher                    
   switch o.type
      case 'shell'
         SetupStudyAll(o);
      case 'pkg'
         SetupStudyPkg(o);
      case 'spm'
         SetupStudySpm(o);
   end
end
function o = SetupStudyAll(o)                                          
   assert(type(o,{'shell'}));
   list = children(o);                  % get list of packages 
   
   for (i=1:length(list))
      oo = list{i};
      SetupStudyPkg(oo);
      if stop(o)
         break
      end
   end
end
function o = SetupStudyPkg(o)                                          
   assert(type(o,{'pkg'}));
   list = children(o);                 % get list of SPM objects 
  
   for (i=1:length(list))
      oo = list{i};
      SetupStudySpm(oo);
      if stop(o)
         break
      end
   end

      % finally make the setup study for the package
      
   SetupStudyPkgOnly(o);
end
function o = SetupStudyPkgOnly(o)                                      
   assert(type(o,{'pkg'}));

   o = Cls(o,'Setup Study Basic');
   analyse(o,'SetupAnalysis','basic',3);
   Png(o); 
   
   o = Cls(o,'Setup Study Symmetry');
   analyse(o,'SetupAnalysis','symmetry',3);
   Png(o);      
end
function o = SetupStudySpm(o)                                          
   assert(type(o,{'spm'}));
   
   o = Cls(o,'Setup Study Basic');
   analyse(o,'SetupAnalysis','basic',1);
   Png(o);

   o = Cls(o,'Setup Study Symmetry');
   analyse(o,'SetupAnalysis','symmetry',1);
   Png(o);
end

%==========================================================================
% Helper
%==========================================================================

function o = ClearAllCaches(o)         % Clear All Caches              
%  os = pull(o);
%  for (i=1:length(os.data))
%     oo = os.data{i};
%     cache(oo,oo,[]);
%  end
   cache(o,o,{});                      % clear all caches
end
function o = Options(o)                % Set Batch Options             
   o = Folder(o);
   
   points = opt(o,'batch.spectrum.points');
   o = opt(o,'spectrum.omega.points',points);

   eps = opt(o,'batch.critical.eps');
   o = opt(o,'critical.eps',eps);
   
   fast = opt(o,'batch.fast');
   o = opt(o,'sensitivity.fast',fast);
   
   pareto = opt(o,{'batch.pareto',1.0});
   o = opt(o,'pareto',pareto);
   
   o = opt(o,'critical.check',0);      % no checks for batch processing
end
function o = Cls(o,title)              % Clear Screen and Setup Tag    
   cls(o);
   Footer(o);

   tag = sprintf('%s - %s',title,id(o));
   fprintf('   plot %s diagram ...\n',tag);
   o = var(o,'tag,tic',tag,tic);
end
function Png(o)                        % Write PNG File                
%
% PNG  Create PNG file and take care of a friendly refresj setting
%
%         Png(o)
%
%      This is also a good location to override refresh setting, as
%      we do not want to refresh according to a deeper level setting
%
   tag = var(o,{'tag','$$$'});
   time = toc(var(o,'tic'));
   
   Footer(o,time);
   
   refresh(o,{'batch','About'});
   fprintf('   create PNG file ...\n');
   
   png(o,tag);
end
function o = Folder(o)                 % Setup PNG Directory           
   date = datestr(clock,29);
   vs = version(o);
   folder = sprintf('PNG-%s-V%s',date,vs);
   o = opt(o,'folder',folder);
end
function Footer(o,time)                % Refresh Footer                
   batch = opt(o,'batch');
   foot = sprintf('SPM V%s, points: %g, eps: %g, pareto: %g%%',...
                  version(o),batch.spectrum.points,batch.critical.eps,...
                  batch.pareto*100);
   if (nargin >= 2)
      foot = sprintf('%s, time: %gs',foot,o.rd(time,1));
   end
   footer(o,foot);
end
function IntermediateSave(o)           % Save to .Mat file             
   assert(type(o,{'pkg'}));

      % get path
      
   path = get(o,'dir');
   if isempty(path)
      fprintf('*** warning: no directory info provided for save: %s\n',...
              id(o));
      return
   else
      pngdir = png(o);
      [dir,file,ext] = fileparts(pngdir);
      file = [file,ext];
      
      path = [path,'/',file,'/package.mat'];
   end

      % make new shell object with only package and its children
      
   list = children(o);
   list = [{o},list];                  % add package  object to children
   o = pull(o);
   o.data = list;
   
      % clean object and save
   
   fprintf('   intermediate saving to %s\n ',path);
   
   o = clean(o);
   save(o,pack(o),path);
end
function oo = Confirm(o)               % Batch Confirmation Dialog     
   folder = opt(o,{'folder','PNG'}); 

   while (1)
      [~,list] = About(o);
      list{end+1} = ' ';
      list{end+1} = ['Folder: ',folder];
      choice = questdlg(list,'Run Batch', 'Change','Cancel', 'OK', 'OK');
      
      if ~isequal(choice,'Change')
         break;
      end
      
         % change folder name
 
       name = 'Change Folder';
       prompt = {'Folder Name for PNG Files'};
       numlines=1;
       default = {folder};

       while (1)
          answer = inputdlg(prompt,name,numlines,default);
          if ~isempty(answer)
             if ~isempty(answer{1})
                folder = answer{1};
                break;
             end
          end
       end
   end
   
   if isequal(choice,'Cancel')
      oo = [];
   else
      oo = opt(o,'folder',folder);  
   end
end
