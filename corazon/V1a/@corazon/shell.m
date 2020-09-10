function oo = shell(o,varargin)        % Tiny Shell for CORAZON Class  
% 
% SHELL   Open new figure and setup menu for a CORAZON object
%      
%            o = corazon     % create a CORAZON object
%            shell(o)        % open a CORAZON shell
%
%         Local function calls
%
%            oo = shell(o,'New')                       % add New Shell item
%            oo = shell(o,'New',{'weird','ball','cube')% add more New items
%            oo = shell(o,'Plugin')                    % add Plugin menu
%
%            list = shell(o,'Dynamic')                 % dynamic menu list
%            oo = shell(o,'Show')                      % show animation
%
%         Creating sample objects
%            oo = shell(o,'Create','weird') % create weird object
%            oo = shell(o,'Create','ball')  % create ball object
%            oo = shell(o,'Create','cube')  % create cube object
%
%        See also: CORAZON, MENU, SHO, CUO
%
   [gamma,oo] = manage(o,varargin,@Shell,@Dynamic,@New,@Stuff,...
                       @Edit,@Plot,@Show,@Animate,@Animation,@Analysis,...
                       @Gallery,@Plugin,@Figure);
   oo = gamma(oo);
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);   

   o = menu(o,'Begin');                % begin menu setup
   oo = File(o);                       % add File menu
   oo = Edit(o);                       % add File menu
   oo = Select(o);                     % add Select menu
   oo = Plot(o);                       % add Plot menu
   oo = Animation(o);                  % add Animation menu
   oo = Analysis(o);                   % add Analysis menu
   oo = Plugin(o);                     % add Plugin menu
   oo = Gallery(o);                    % add Gallery menu
   oo = Info(o);                       % add Info menu
   oo = Figure(o);                     % add Figure menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   if isempty(get(o,'title')) && container(o)
      o = refresh(o,{'menu','About'}); % provide refresh callback
      o = set(o,'title','Corazon Shell');
      o = set(o,'comment',{'a dynamic shell for Corazon objects'});
   end
   o = dynamic(o,true);                % setup as a dynamic shell
   o = launch(o,mfilename);            % use this mfile as launch function
end
function list = Dynamic(o)             % Get Dynamic Menu List         
   list = {'Plot','Analysis'};
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
   ooo = shell(oo,'New');              % add New menu
   ooo = Import(oo);                   % add Import menu items
   ooo = Export(oo);                   % add Export menu items
end
function oo = New(o)                   % Add New Menu                  
   oo = mseek(o,{'New'});              
   ooo = mitem(oo,'-');
   ooo = new(oo,'Menu');
end
function oo = Stuff(o,typ)             % Create New Stuff              
   if (nargin < 2)
      typ = arg(o,1);
   end
   switch typ
      case 'weird'
         oo = mitem(o,'Weird',{@NewCb,'Weird'});
      case 'ball'
         oo = mitem(o,'Ball',{@NewCb,'Ball'});
      case 'cube'
         oo = mitem(o,'Cube',{@NewCb,'Cube'});
   end
   return
   
   function oo = NewCb(o)              % Create New Stuff              
      oo = new(o);                     % create new (stuff) object
      paste(o,{oo});                   % paste object into shell
   end
end
function oo = Import(o)                % Import Menu Items             
   oo = mhead(o,'Import');             % seek Import menu header item
   ooo = mitem(oo,'Stuff (.txt)',{@ImportCb,'ReadStuffTxt','.txt'});
   plugin(oo,'corazon/shell/Import');  % plug point
   return
   
   function o = ImportCb(o)            % Import Log Data Callback
      driver = arg(o,1);
      ext = arg(o,2);
      list = import(o,driver,ext);     % import object from file
      paste(o,list);
   end
end
function oo = Export(o)                % Export Menu Items             
   oo = mhead(o,'Export');             % seek Export menu header item
   ooo = mitem(oo,'Stuff (.txt)',{@ExportCb,'WriteStuffTxt','.txt'});
   plugin(oo,'corazon/shell/Export');  % plug point
   return
   
   function oo = ExportCb(o)           % Export Log Data Callback
      oo = current(o);
      if container(oo)
         message(oo,'Select an object for export!');
      else
         driver = arg(o,1);
         ext = arg(o,2);
         export(oo,driver,ext);        % export object to file
      end
   end
end

%==========================================================================
% Edit Menu
%==========================================================================

function oo = Edit(o)                  % Edit Menu                     
   oo = menu(o,'Edit');                % add Edit menu
   plugin(oo,'corazon/shell/Edit');    % plug point
end

%==========================================================================
% Select Menu
%==========================================================================

function oo = Select(o)                % Select Menu                   
   oo = menu(o,'Select');              % add Select menu
   if isempty(oo)
      return
   end
   plugin(oo,'corazon/shell/Select');  % plug point
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu
   oo = mhead(o,'Plot');
   dynamic(oo);                        % make this a dynamic menu
   ooo = plot(oo,'Menu');
end

%==========================================================================
% Animation Menu
%==========================================================================

function oo = Animation(o)             % Animation Menu (Dynamic)      
%
% ANIMATION   Create a blind dynamic menu entry
%
   oo = mhead(o,'Animation');
   dynamic(oo);                        % make this a dynamic menu
   plugin(oo,'corazon/shell/Animation');
end

%==========================================================================
% Analysis Menu
%==========================================================================

function oo = Analysis(o)              % Analysis Menu (Dynamic)       
%
% ANIMATION   Create a blind dynamic menu entry
%
   oo = mhead(o,'Analysis');
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Weird Frequency',{@WeirdFrequency});   
   ooo = mitem(oo,'Ball Radius',{@BallRadius});   
   ooo = mitem(oo,'Cube Edge Length',{@CubeEdge});   
   plugin(oo,'corazon/shell/Analysis');% plug point
end
function o = WeirdFrequency(o)         % Weird Frequency Callback      
   refresh(o,{@WeirdFrequency});
   o = opt(o,'basket.type','weird');
   o = opt(o,'basket.collect','*');    % all traces in basket
   list = basket(o);
   if (isempty(list))
      message(o,'No weird objects in basket!');
   else
      hax = cls(o);
      G = [];
      for (i=1:length(list))
         oo = list{i};
         m = 25; n = length(oo.data.x);
         F = fft(oo.data.x + oo.data.y + oo.data.z + oo.data.w)/n;
         f = abs(F(1:length(1:m+1)));
         hdl = plot(hax,0:m,f);  hold on;
         set(hdl,'color',oo.par.color);  
         G = [G;f(:)'];
      end
      if (size(G,1) > 1)
         G = mean(G);
      end
      if opt(o,{'style.bullets',0})
         hdl = plot(hax,0:m,G,'g-', 0:m,G,'k.');
      else
         hdl = plot(hax,0:m,G,'g-');
      end
      lw = opt(o,{'style.linewidth',3});
      set(hdl,'linewidth',lw);
      title('Average Spectrum');
   end
end
function o = BallRadius(o)             % Ball Radius Callback          
   refresh(o,{@BallRadius});
   o = opt(o,'basket.type','ball');
   o = opt(o,'basket.collect','*');    % all traces in basket
   list = basket(o);
   if (isempty(list))
      message(o,'No ball objects in basket!');
   else
      hax = cls(o);
      for (i=1:length(list))
         oo = list{i};
         r(i) = oo.data.radius;
      end
      plot(hax,1:length(r),r,'b', 1:length(r),r,'k.');
      m = mean(r);  s = std(r);
      title(sprintf('Ball Radius (average %g,sigma %g)',m,s));
      set(hax,'xtick',1:length(r));
   end
end
function o = CubeEdge(o)               % Cube Edge Callback            
   refresh(o,{@CubeEdge});
   o = opt(o,'basket.type','cube');
   o = opt(o,'basket.collect','*');    % all traces in basket
   list = basket(o);
   if (isempty(list))
      message(o,'No cube objects in basket!');
   else
      hax = cls(o);
      for (i=1:length(list))
         oo = list{i};
         a(i) = 2*oo.data.radius;
      end
      plot(hax,1:length(a),a,'b', 1:length(a),a,'k.');
      m = mean(a);  s = std(a);
      title(sprintf('Cube edge length (average %g,sigma %g)',m,s));
      set(hax,'xtick',1:length(a));
   end
end

%==========================================================================
% Plugin Menu
%==========================================================================

function oo = Plugin(o)                % Plugin Menu                   
   oo = menu(o,'Plugin');              % menu will be hidden
   oo = plugin(oo,'corazon/shell/Plugin');
end

%==========================================================================
% Gallery Menu
%==========================================================================

function oo = Gallery(o)               % Gallery Menu                  
   oo = menu(o,'Gallery');             % add Gallery menu
   plugin(oo,'corazon/shell/Gallery'); % plug point
end

%==========================================================================
% Info Menu
%==========================================================================

function oo = Info(o)                  % Info Menu                     
   oo = menu(o,'Info');                % add Info menu
   plugin(oo,'corazon/shell/Info');    % plug point
end

%==========================================================================
% Figure Menu
%==========================================================================

function oo = Figure(o)                % Figure Menu                   
   oo = menu(o,'Figure');              % add Figure menu
   plugin(oo,'corazon/shell/Figure');  % plug point
end
