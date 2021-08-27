function oo = batch(o,varargin)        % Batch figure printing
%
% BATCH Batch figure generation
%
%       oo = batch(o,'Menu')           % setup Batch menu
%
%       oo = batch(o,func)             % call local batch function
%
%    See also: SPM, PLOT, ANALYSIS
%
   [gamma,o] = manage(o,varargin,@Error,@Menu,@WithCuo,@WithSho,@WithBsk,...
                        @RunAll,@About,...
                        @StabilityMargin,@CriticalOverview,...
                        @CriticalSensitivity,@DampingSensitivity,...
                        @SetupStudy);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Study Menu              
   setting(o,{'batch.stabilitymargin'},1);
   setting(o,{'batch.criticaloverview'},1);
   setting(o,{'batch.dampingsensitivity'},0);
   setting(o,{'batch.criticalsensitivity'},0);
   setting(o,{'batch.setupstudy'},0);
   setting(o,{'batch.cleanup'},0);     % cache cleanup
   
   co = current(o);
   
      % batch config
      
   oo = mitem(o,'Batch Config');
   ooo = mitem(oo,'Stability Margin',{},'batch.stabilitymargin');
         check(ooo,{@Cb});
   ooo = mitem(oo,'Critical Overview',{},'batch.criticaloverview');
         check(ooo,{@Cb});
   mitem(oo,'-');
   ooo = mitem(oo,'Damping Sensitivity',{},'batch.dampingsensitivity');
         check(ooo,{@Cb});
   ooo = mitem(oo,'Critical Sensitivity',{},'batch.criticalsensitivity');
         check(ooo,{@Cb});
   mitem(oo,'-');
   ooo = mitem(oo,'Setup Study',{},'batch.setupstudy');
         check(ooo,{@Cb});

   mitem(oo,'-');
   ooo = mitem(oo,'Cache Cleanup',{},'batch.cleanup');
        choice(ooo,{{'Off',0},{'On',1}});

      % run batch
      
   oo = mitem(o,'Run Batch',{@WithSho,'RunAll'});
   
      % auxillary menu items
      
   oo = mitem(o,'-');
   oo = mitem(o,'Stability Margin',{@WithCuo,'StabilityMargin'});
   oo = mitem(o,'Critical Overview',{@WithCuo,'CriticalOverview'});
   oo = mitem(o,'-');
   oo = mitem(o,'Damping Sensitivity',{@WithCuo,'DampingSensitivity'});
   oo = mitem(o,'Critical Sensitivity',{@WithCuo,'CriticalSensitivity'});
   oo = mitem(o,'-');
   oo = mitem(o,'Setup Study',{@WithCuo,'SetupStudy'});
        
   function o = Cb(o)
      o = About(o);
   end
end
function o = About(o)                  % About Batch Configuration     
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
   
   cls(o);
   message(o,'Batch Configuration',comment);
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
   
      % print/display end message
      
   msg = o.iif(stop(o),'batch processing stopped',...
                       'batch processing complete');
   message(o,msg);
   fprintf('%s\n',msg);
end
function o = RunPkg(o)                 % Run a Single Package          
   assert(type(o,{'pkg'}));
   batch = opt(o,'batch');

      % individual package specific plots

   if (batch.stabilitymargin)
      StabilityMarginPkg(oo);
      if stop(o)
         return
      end
   end
   
      % individual SPM specific plots
    
   list = children(o);                 % get list of SPM objects 
   for (i=1:length(list))
      oo = list{i};

         % stability margin
         
      if (batch.stabilitymargin)
         StabilityMarginSpm(oo);
         if stop(o)
            return
         end
      end
      
         % critical overview
         
      if (batch.criticaloverview)
         CriticalOverviewSpm(oo);
         if stop(o)
            return
         end
      end
      
         % damping sensitivity
         
      if (batch.dampingsensitivity)
         DampingSensitivitySpm(oo);
         if stop(o)
            return
         end
      end
      
         % critical sensitivity
         
      if (batch.criticalsensitivity)
         CriticalSensitivitySpm(oo);
         if stop(o)
            return
         end
      end
      
         % setup study
         
      if (batch.setupstudy)
         SetupStudySpm(oo);
         if stop(o)
            return
         end
      end
      
         % cache cleanup
         
      if (batch.cleanup)
         cache(o,o,[]);                % cache hard clear
      end
   end
   
      % setup overview for the package
      
   if (batch.setupstudy)
      SetupStudyPackageOnly(o);
      if stop(o)
         return
      end
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

   fprintf('   plot Stability Margin diagram ...\n');
   analyse(o,'StabilityMargin');

   fprintf('   create PNG file ...\n');
   png(o,sprintf('Stability Margin - %s',id(o)));
end
function o = StabilityMarginSpm(o)                                     
   assert(type(o,{'spm'}));
   menu(o,'About');
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
   
      % forward cutting
      
   cls(o);
   tag = sprintf('Critical Overview (Forward) - %s',id(o));
   fprintf('   plot %s diagram ...\n',tag);
   
   o = opt(o,'view.cutting',+1);
   analyse(o,'Critical','Overview');

   fprintf('   create PNG file ...\n');
   png(o,tag);

      % backward cutting
      
   cls(o);
   tag = sprintf('Critical Overview (Backward) - %s',id(o));
   fprintf('   plot %s diagram ...\n',tag);

   o = opt(o,'view.cutting',-1);
   analyse(o,'Critical','Overview');

   fprintf('   create PNG file ...\n');
   png(o,tag);
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
   
      % forward cutting
      
   cls(o);
   tag = sprintf('Damping Sensitivity (Forward) - %s',id(o));
   fprintf('   plot %s diagram ...\n',tag);
   
   o = opt(o,'view.cutting',+1);
   sensitivity(o,'Damping');

   fprintf('   create PNG file ...\n');
   png(o,tag);
return;

      % backward cutting
      
   cls(o);
   tag = sprintf('Damping Sensitivity (Backward) - %s',id(o));
   fprintf('   plot %s diagram ...\n',tag);

   o = opt(o,'view.cutting',-1);
   sensitivity(o,'Damping');

   fprintf('   create PNG file ...\n');
   png(o,tag);
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
   
      % forward cutting
      
   cls(o);
   tag = sprintf('Critical Sensitivity (Forward) - %s',id(o));
   fprintf('   plot %s diagram ...\n',tag);
   
   o = opt(o,'view.cutting',+1);
   o = opt(o,'pareto',opt(o,{'sensitivity.pareto',1.0}));
   sensitivity(o,'Critical');

   fprintf('   create PNG file ...\n');
   png(o,tag);
return;

      % backward cutting
      
   cls(o);
   tag = sprintf('Critical Sensitivity (Backward) - %s',id(o));
   fprintf('   plot %s diagram ...\n',tag);

   o = opt(o,'view.cutting',-1);
   o = opt(o,'pareto',opt(o,{'sensitivity.pareto',1.0}));
   sensitivity(o,'Critical');

   fprintf('   create PNG file ...\n');
   png(o,tag);
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
   cls(o);
   tag = sprintf('Setup Study - %s',id(o));
   fprintf('   plot %s diagram ...\n',tag);
   
   analyse(o,'SetupAnalysis','basic',3);

   fprintf('   create PNG file ...\n');
   png(o,tag);      
end
function o = SetupStudySpm(o)                                          
   assert(type(o,{'spm'}));
   
   cls(o);
   tag = sprintf('Setup Study - %s',id(o));
   fprintf('   plot %s diagram ...\n',tag);
   
   analyse(o,'SetupAnalysis','basic',3);

   fprintf('   create PNG file ...\n');
   png(o,tag);
end

