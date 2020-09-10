function oo = menu(o,varargin)         % CUT Menu Building Blocks
% 
% MENU   Package to provides building blocks for shell menu
%      
%           menu(o,locfunc)            % call local function 
%
%        File Menu
%           oo = menu(o,'File');       % add standard File menu
%
%           oo = menu(o,'New');        % add New menu item
%           oo = menu(o,'Rebuild');    % add Rebuild menu item
%           oo = menu(o,'CloseOther'); % add CloseOther menu item
%           oo = menu(o,'Close');      % add Close menu item
%           oo = menu(o,'Exit');       % add Exit menu item
%
%        See also: CUT, SHELL
%
   [func,o] = manage(o,varargin,@Begin,@End,@File,@New,@Close,@CloseOther,...
                                @Exit,@Title);               
   oo = func(o);
end

%==========================================================================
% Basic Menu Setup
%==========================================================================
      
function oo = Begin(o)                 % Begin Menu                       
   o = cast(o,"quark");                % cast to quark object
   oo = menu(o,"Begin");               % invoke quark/menu method
end  

function oo = End(o)                   % End Menu Setup                
   o = cast(o,"quark");                % cast to quark object
   oo = menu(o,"End");                 % invoke quark/menu method
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = mitem(o,'File');               % add roll down header item
%  ooo = menu(oo,'New');               % add new menu item
%  ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'CloseOther');        % add CloseOther menu item
   ooo = menu(oo,'Close');             % add Close menu item
   ooo = mitem(oo,'-');                % separator
   ooo = menu(oo,'Exit');              % add Exit menu item
end

function oo = New(o)                   % Add New Menu                  
   oo = mhead(o,'New');                % Add New Menu item heaD
   ooo = mitem(oo,'Demo Object',{@NewCb,1});
   ooo = mitem(oo,'60-er Kugel',{@NewCb,2});
end

function oo = NewCb(o)                 % New Callback
   mode = arg(o,1);
   switch mode
      case 1
         oo = uni(cut,"demo");
         shell(oo);
   case 2
         oo = uni(cut,"60er");
         shell(oo);
   end
   oo = o;                             % launch a new shell
end

function oo = Close(o)                 % Close Menu Setup                
   o = cast(o,"quark");                % cast to quark object
   oo = menu(o,"Close");               % invoke quark/menu method
end

function oo = CloseOther(o)            % CloseOther Menu Setup                
   o = cast(o,"quark");                % cast to quark object
   oo = menu(o,"CloseOther");          % invoke quark/menu method
end

function oo = Exit(o)                  % Exit Menu Setup                
   o = cast(o,"quark");                % cast to quark object
   oo = menu(o,"Exit");                % invoke quark/menu method
end

%==========================================================================
% Miscellaneous
%==========================================================================

function oo = Title(o)                 % Set Figure Title                
   o = cast(o,"quark");                % cast to quark object
   oo = menu(o,"Title");               % invoke quark/menu method
end
