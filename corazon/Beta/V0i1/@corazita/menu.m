function oo = menu(o,varargin)         % Carbonara Menu Building Blocks
% 
% MENU   Package to provides building blocks for shell menu
%      
%           menu(o,locfunc)            % call local function 
%
%        Basic Menu Setup
%           oo = menu(o,'Begin');      % begin menu setup
%           oo = menu(o,'End');        % end menu setup
%
%        File Menu
%           oo = menu(o,'File');       % add standard File menu
%
%           oo = menu(o,'New');        % add New menu item
%           oo = menu(o,'Open');       % add Open menu item
%           oo = menu(o,'Save');       % add Save menu item
%           oo = menu(o,'Import',caption,cblist); % add Import menu item
%           oo = menu(o,'Export',caption,cblist); % add Export menu item
%           oo = menu(o,'Clone');      % add Clone menu item
%           oo = menu(o,'Rebuild');    % add Rebuild menu item
%           oo = menu(o,'CloseOther'); % add CloseOther menu item
%           oo = menu(o,'Close');      % add Close menu item
%           oo = menu(o,'Exit');       % add Exit menu item
%
%        Edit Menu
%           oo = menu(o,'Edit');       % add standard Edit menu
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA, SHELL
%
   [gamma,o] = manage(o,varargin,@Begin,@End,@File,@New,@Open,@Save,...
                     @Import,@Export,@Clone,@Rebuild,@CloseOther,...
                     @Close,@Exit,@Edit);
   oo = gamma(o);
end

%==========================================================================
% Basic Menu Setup
%==========================================================================
      
function oo = Begin(o)                 % Begin Menu                    
   if isempty(work(o,'rebuild'))       % if not a menu rebuild process
%     curfig = gcf(o);                 % current figure handle
      curfig = gcf(corazito);          % current figure handle

      fig = figure;                    % open a new figure
      set(fig,'menubar','none');       % no standard menubar
      set(fig,'numbertitle','off');    % no number titles in figure
      title = get(o,{'title',''});     % get object title
      set(fig,'name',title);           % set figure title
      set(fig,'color',[1 1 1]);        % white background color

      if isempty(curfig)
         screen = get(0,'ScreenSize');
         set(fig,'Position',[1/6*screen(3:4) 2/3*screen(3:4)]);
      else
         pos = get(curfig,'position'); % get current figure position
         pos(1:2) = pos(1:2)+[25,-25]; % shift by 25 pixels
         set(fig,'position',pos);      % update new figure position
      end

      o = figure(o,fig);               % store figure handle in object

      opts = opt(o);                   % full bag of options
      setting(o,opts);                 % initialize settings with options
      o = push(o);                     % push object into figure
   end
   %oo = mitem(o);                     % init for top level (figure handle)
   oo = mitem(o,gcf);                  % init for top level (figure handle)
end  
function oo = End(o)                   % End Menu Setup                
   if ~var(o,{'rebuild',0})            % if not a menu rebuild process
      refresh(o);                      % refresh figure
   end
   oo = o;                             % copy input to output object
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = mitem(o,'File');               % add roll down header item
   ooo = menu(oo,'New');               % add new menu item
   ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'Open');              % add Open menu item
   ooo = menu(oo,'Save');              % add Save menu item
   ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'Clone');             % add Clone menu item
   ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'CloseOther');        % add CloseOther menu item
   ooo = menu(oo,'Close');             % add Close menu item
   ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'Exit');              % add Exit menu item
end
function oo = New(o)                   % Add New Menu                  
%  oo = mhead(o,'New');                % Add New Menu item head
   oo = mitem(o,'New');                % Add New Menu item head
   ooo = mitem(oo,'Shell',{@ShellCb}); % open another corazon shell
   return
   
   function oo = ShellCb(o)            % Shell Callback                
      tag = class(o);
      oo = eval(tag);                  % new empty container object
      oo.type = o.type;                % copy type
      launch(oo);                      % launch a new shell
   end
end
function oo = Open(o)                  % Add Open Menu Item            
   oo = mitem(o,'Open ...',{@OpenCallback});
   return
   
   function o = OpenCallback(o)        % Open Callback
%     bag = load(corazita);             % load an object, using CORAZITA load
%     oo = launch(o,bag);              % launch a proper shell
      open(o);
   end
end
function oo = Save(o)                  % Add Save Menu Item            
   oo = mitem(o,'Save ...',{@SaveCallback});
   return
   
   function o = SaveCallback(o)        % Save Callback
      bag = setting(o);                % fetch full bag of settings
      o = opt(o,bag);                  % copy settings into options
      o = clean(o);                    % clean object before saving
      save(corazita,pack(o));           % save object, using CORAZITA save
   end
end
function oo = Import(o)                % Add Import Menu Item          
%
% IMPORT   Add Import menu item
%
%             oo = menu(o,'Import','Log Data',{@ImportCb,...}
%
   label = arg(o,1);
   cblist = arg(o,2);
   oo = mseek(o,{'Import'});           % seek Import menu item
   ooo = mitem(oo,label,cblist);
 end
function oo = Export(o)                % Add Import Menu Item          
%
% EXPORT   Add Export menu item
%
%             oo = menu(o,'Export','Log Data',{@ExportCb,...}
%
   label = arg(o,1);
   cblist = arg(o,2);
   oo = mseek(o,{'Export'});           % seek Export menu item
   ooo = mitem(o,label,cblist);
 end
function oo = Clone(o)                 % Add Clone Menu Item           
   oo = mitem(o,'Clone',{@CloneCb});
   return
   
   function oo = CloneCb(o)            % Clone Callback          
      o = pull(o);                     % refetch object from figure
      
      oo = arg(o,{});                  % clear arg list
      oo = figure(oo,[]);              % also clear figure handle
      launch(oo);                      % launch object
   end
end
function oo = Rebuild(o)               % Add Rebuild Menu Item         
   oo = mitem(o,'Rebuild',{@RebuildCb});
   return
   
   function o = RebuildCb(o)           % Rebuild Callback          
      rebuild(o);                      % rebuild menu structure
   end
end
function oo = Close(o)                 % Add Close Menu Item           
   oo = mitem(o,'Close',{@CloseCallback});
   return
   
   function o = CloseCallback(o)       % Close Callback           
      delete(figure(o));               % close this figure
   end
end
function oo = CloseOther(o)            % Add CloseOther Menu Item      
   oo = mitem(o,'Close Other',{@CloseOtherCallback});
   return
   
   function oo = CloseOtherCallback(o) % CloseOther Callback           
      oo = o;                          % copy by default
      kids = get(0,'children');        % get all figures
      for (i=1:length(kids))
         fig = kids(i);
         if ~isequal(fig,figure(o))
            delete(fig);               % close other figs
         end
      end
   end
end
function oo = Exit(o)                  % Add Exit Menu Item            
   oo = mitem(o,'Exit',{@ExitCallback});
   return
   
   function oo = ExitCallback(o)       % Exit Shell Callback           
      oo = o;                          % copy by default
      while ~isempty(gcf(corazito))
         fig = gcf(corazito);
         delete(fig);                  % close figs
      end
   end
end
