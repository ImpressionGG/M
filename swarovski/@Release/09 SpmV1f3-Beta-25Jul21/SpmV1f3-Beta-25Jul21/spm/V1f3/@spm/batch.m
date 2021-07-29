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
                        @StabilityOverview,@ModeShapeOverview,...
                        @AllStabilityMargin,@AllCriticalSensitivity,...
                        @AllDampingSensitivity);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Menu Setup & Common Menu Callback
%==========================================================================

function oo = Menu(o)                  % Setup Study Menu              
   oo = mitem(o,'All Packages');
   ooo = mitem(oo,'Stability Margin',{@WithSho,'AllStabilityMargin'});
   ooo = mitem(oo,'Damping Sensitivity',{@WithSho,'AllDampingSensitivity'});
   ooo = mitem(oo,'Critical Sensitivity',{@WithSho,'AllCriticalSensitivity'});

   oo = mitem(o,'Mode Shapes');
   ooo = mitem(oo,'Overview',{@WithCuo,'ModeShapeOverview'});
   
   oo = mitem(o,'Stability');
   ooo = mitem(oo,'Overview',{@WithCuo,'StabilityOverview'});
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
   refresh(o,o);                       % remember to refresh here

   mode = dark(o);
   dark(o,0);
   o = dark(o,0);                      % disable dark mode for object o
   
   cls(o);                             % clear screen
 
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
   refresh(o,o);                       % remember to refresh here
   
   mode = dark(o);                     % save dark mode
   dark(o,0);                          % disable dark mode shell setting
   o = dark(o,0);                      % disable dark mode for object o
   
   cls(o);                             % clear screen
 
   oo = current(o);                    % get current object
   
      % oo = current(o) directly inherits options from shell object,
      % this we have to set dark mode option also for oo!
      
   oo = dark(oo,0);                    % disable dark mode
   
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
% For All Packages
%==========================================================================

function o = AllStabilityMargin(o)
   fprintf('Batch processing: stability margin for all package objects\n');
   list = children(o);                 % get list of package objects
   
   stop(o,'Enable');
   n = length(list);
   for (i=1:length(list))
      oo = list{i};
      fprintf('   %g of %g: %s\n',i,n,id(oo));
      cls(oo);
      
      fprintf('   plot diagram ...\n');
      analyse(oo,'StabilityMargin');

      fprintf('   create PNG file ...\n');
      png(oo,'Stability Margin @ Package');
      
      if stop(o)
         break
      end
   end
   stop(o,'Disable');
   
   o = var(o,'done','Batch processing done!');
end
function o = AllDampingSensitivity(o)
   assert(container(o));               % we HAVE a shell object!
   plist = children(o);                % get list of all packages
   
   stop(o,'Enable');
   np = length(plist);                 % number of packages
   for (i=1:np)
      po = plist{i};                   % get package object
      olist = children(po);
      no = length(olist);              % number of packages
      for (j=1:no)
         oo = olist{j};                % fetch SPM object
         fprintf('   %g/%g of %g/%g: %s\n',i,j,np,no,id(oo));
         cls(oo);

         fprintf('   damping sensitivity ...\n');
         analyse(oo,'Sensitive','damping');

         fprintf('   create PNG file ...\n');
         png(oo,sprintf('Critical Sensitivity %s',id(oo)));

         if stop(o)
            break
         end
      end
      if stop(o)
         break
      end
   end
   stop(o,'Disable');
end
function o = AllCriticalSensitivity(o)
   assert(container(o));               % we HAVE a shell object!
   plist = children(o);                % get list of all packages
   
   stop(o,'Enable');
   np = length(plist);                 % number of packages
   for (i=1:np)
      po = plist{i};                   % get package object
      olist = children(po);
      no = length(olist);                 % number of packages
      for (j=1:no)
         oo = olist{j};                % fetch SPM object
         fprintf('   %g/%g of %g/%g: %s\n',i,j,np,no,id(oo));
         cls(oo);

         fprintf('   critical sensitivity ...\n');
         sensitivity(oo,'Critical');

         fprintf('   create PNG file ...\n');
         png(oo,sprintf('Critical Sensitivity %s',id(oo)));
         if stop(o)
            break
         end
      end
      if stop(o)
         break
      end
   end
   stop(o,'Disable');
end

%==========================================================================
% Mode Shapes
%==========================================================================

function o = ModeShapeOverview(o)      % Print Mode Shape Diagrams      
   plot(o,'WithCuo','Complex');
   png(o,'Mode Shape Complex');

   plot(o,'WithCuo','Damping');
   png(o,'Mode Shape Damping');
end

%==========================================================================
% Stability
%==========================================================================

function o = StabilityOverview(o)      % Stability Overview   
   analyse(o,'WithCuo','StabilityMargin');
   png(o,sprintf('Stability Margin @ %s',id(o)));
end

