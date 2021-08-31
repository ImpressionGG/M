function oo = shell(o,varargin)        % Tiny Shell for CORSHITO Class 
% 
% SHELL  Open new figure and setup menu for a CORSHITO object
%      
%           o = corshito     % create a CORSHITO object
%           shell(o)         % open a tiny CORSHITO shell
%
%        Copyright(c): Bluenetics 2020 
%
%        See also: CORSHITO
%
   [func,o] = manage(o,varargin,@Shell,@Dynamic,@Plot,@Shit);
   oo = func(o);
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
%
   o = Init(o);                        % init shell                    
   
   o = menu(o,'Begin');                % begin menu setup
   oo = menu(o,'File');                % add File menu
   oo = menu(o,'Edit');                % add Edit menu
   oo = Plot(o);                       % add Plot menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end

function list = Dynamic(o)             % List of Dynamic Corshito Menus
   list = {'Plot'};
end

function o = Init(o)                   % Init Shell         
   if isempty(get(o,'title'))
      o = set(o,'title','Corshito Object');
      [X,Y,Z] = sphere(75);                 % surf plot data
      o = data(o,'X',X,'Y',Y,'Z',Z/10);
   end
   o = refresh(o,{'shell','Shit','r',3});   % provide refresh callback
   o = launch(o,mfilename);            % use this mfile as launch function
end

%==========================================================================
% Plot Menu
%==========================================================================

function oo = Plot(o)                  % Plot Menu                
   oo = mhead(o,'Plot'); 
   dynamic(oo);                        % make this a dynamic menu
   ooo = mitem(oo,'Red Corazon Shit',  {@Shit,'r',3});
   ooo = mitem(oo,'Green Corazon Shit',{@Shit,'g',1});
   ooo = mitem(oo,'Blue Corazon Shit', {@Shit,'b',5});
end

function o = Shit(o)                   % Shit Animation Callback  
   col = arg(o,1);                     % arg 1 is color
   rough = arg(o,2);                   % arg 2 is roughness
   refresh(o,{'shell','Shit',col,rough}); 

   list = basket(o);
   if isempty(list)
      message(o,'Empty Basket!','Change some basket settings!');
   else
      oo = list{1};
      [X,Y,Z] = data(oo,'X','Y','Z');
      animate(o,X,Y,Z,col,rough);
   end
end
