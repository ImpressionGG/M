function oo = shell(o,varargin)        % Tiny Shell for CARACOW Class  
% 
% SHELL  Open new figure and setup menu for a CARACOW object
%      
%           o = caracow      % create a CARACOW object
%           shell(o)         % open a tiny CARACOW shell
%
%        Code lines: 36
%
%        See also: CARACOW
%
   [func,o] = manage(o,varargin,@Shell,@Shit);
   oo = func(o);
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
%
   o = Init(o);                        % init object   
   
   o = menu(o,'Begin');                % begin menu setup
   oo = menu(o,'File');                % add File menu
   oo = Animation(o);                  % add Animation menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end

function o = Init(o)                   % Init Object                   
   if isempty(get(o,'title'))
      o = set(o,'title','Caracow Shell');
      [d.X,d.Y,d.Z] = sphere(75);      % surf plot data
      d.Z = d.Z / 10;                  % make the ball flat
      o.data = d;
   end
   o = refresh(o,{'shell','Shit','r',3});  % provide refresh callback
end

%==========================================================================
% Animation Menu
%==========================================================================

function oo = Animation(o)             % File Menu                     
   oo = mitem(o,'Animation');          % add roll down header item
   ooo = mitem(oo,'Red Carabao Shit',  {@Shit,'r',3});
   ooo = mitem(oo,'Green Carabao Shit',{@Shit,'g',2});
   ooo = mitem(oo,'Blue Carabao Shit', {@Shit,'b',5});
end

function o = Shit(o)                   % Shit Animation Callback       
   col = arg(o,1);                     % arg 1 is color
   rough = arg(o,2);                   % arg 2 is roughness
   refresh(o,{'shell','Shit',col,rough}); 

   d = data(o);                        % get all data
   animate(carabull,d.X,d.Y,d.Z,col,rough);
end
