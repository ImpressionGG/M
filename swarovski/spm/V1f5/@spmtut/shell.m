function oo = shell(o,varargin)        % SPM Shell                     
   [gamma,o] = manage(o,varargin,@Shell);
   oo = gamma(o);                      % invoke local function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = Init(o);                        % init object

   o = menu(o,'Begin');                % begin menu setup
%  oo = File(o);                       % add File menu
   oo = Chapter1(o);                   % add chapter 1 menu
   o = menu(o,'End');                  % end menu setup (will refresh)
end
function o = Init(o)                   % Init Object                   
   o = dynamic(o,false);               % setup as a dynamic shell
   o = launch(o,mfilename);            % setup launch function
   o = control(o,{'dark'},1);          % run in dark mode
   o = control(o,{'verbose'},0);       % no verbose talking
   o = control(o,{'ui'},1);            % create UI figure

   o = provide(o,'par.title','SPM Tutorial');
   o = provide(o,'par.comment',{});
   o = refresh(o,{'menu','About'});    % provide refresh callback function
end
function list = Dynamic(o)             % List of Dynamic Menus         
   list = {};
end

%==========================================================================
% Launch Function
%==========================================================================

function o = Show(o)
   file = arg(o,1);
   docpath = [folder(spm),'/doc'];
   addpath(docpath);
   
   file = publish(file);
   
   cls(o);
   fig = figure(o);  
   h = uihtml(fig);
 
   pos = get(fig,'Position');
   h.Position = [0 0 pos(3:4)];
   
   h.HTMLSource = file;
end

%==========================================================================
% File Menu
%==========================================================================

function oo = File(o)                  % File Menu                     
   oo = menu(o,'File');                % add File menu
end

%==========================================================================
% Chapter 1 Menu
%==========================================================================

function oo = Chapter1(o)                     
   oo = mhead(o,'Chapter 1');          % add roll down header menu item
   ooo = mitem(oo,'1.1 A Sample System',{@Show 'c1_1_sample_system'});
end

%==========================================================================
% Helper
%==========================================================================

