function oo = shell(o,varargin)        % Tiny Shell for CUT Class  
% 
% SHELL  Open new figure and setup menu for a CUT object
%      
%           shell(cut)         % open a tiny CUT shell
%
%        See also: CUT, DEMO
%
   [func,o] = manage(o,varargin,@Shell);
   oo = func(o);
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   if isequal(type(o),"demo")
      demo(o);
   elseif isequal(type(o),"60mm")
      demo(o);
   else
      o = Init(o);                     % init object   
      
      o = menu(o,'Begin');             % begin menu setup
      oo = menu(o,'File');             % add File menu
      oo = Parameter(o);               % add Parameter menu
      oo = Study(o);                   % add Study menu
      o = menu(o,'End');               % end menu setup (will refresh)
   end
end

function o = Init(o)                   % Init Object                   
   if isempty(get(o,'title'))
      o = set(o,'title','Cutting Simulation Shell');
   end
   %o = refresh(o,{'shell','Shit','r',3});  % provide refresh callback
end

%==========================================================================
% Parameter Menu
%==========================================================================

function oo = Parameter(o)             % Parameter Menu
   setting(o,{"color"},"r");           % provide default setting
   
   oo = mitem(o,'Parameter');          % add roll down header item
   ooo = mitem(oo,'Color',{},'color');   
   choice(ooo,{{"Red","r"},{"Blue","b"}});
end

%==========================================================================
% Simulation Menu
%==========================================================================

function oo = Study(o)            % Study Menu                     
   oo = mitem(o,'Study');         % add roll down header item
   
   ooo = mitem(oo,'Uni Demos',{@StudyCb,1});   
   ooo = mitem(oo,'60er-Kugel',{@StudyCb,2});
end

function o = StudyCb(o)           % Study Callback        
   number = arg(o,1);             % arg 1 is example number

   switch number
      case 1
         oo = uni(o,"demo");
         demo(oo);
      case 2
         oo = uni(o,"60mm");
         demo(oo);
   end
end
