function oo = shell(o,varargin)        % Tiny Shell for CORAZITA Class  
% 
% SHELL  Open new figure and setup menu for a CORAZITA object
%      
%           o = corazita     % create a CORAZITA object
%           shell(o)         % open a tiny CORAZITA shell
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORAZITA, MENU, SHO, CUO
%
   [gamma,o] = manage(o,varargin,@Shell,@Shit);
   oo = gamma(o);
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
   oo = menu(o,'End');                 % end menu setup (will refresh)
end

function o = Init(o)                   % Init Object                   
   if isempty(get(o,'title'))
      o = set(o,'title','Corazita Shell');
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
   ooo = mitem(oo,'Red Corazon Shit',  {@Shit,'r',3});
   ooo = mitem(oo,'Green Corazon Shit',{@Shit,'g',2});
   ooo = mitem(oo,'Blue Corazon Shit', {@Shit,'b',5});
end

function o = Shit(o)                   % Shit Animation Callback       
   col = arg(o,1);                     % arg 1 is color
   rough = arg(o,2);                   % arg 2 is roughness
   refresh(o,{'shell','Shit',col,rough}); 

   d = data(o);                        % get all data
   animate(corazito,d.X,d.Y,d.Z,col,rough);
end
