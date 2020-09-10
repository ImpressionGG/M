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
                       @Edit,@Plot,@Show,@Animate,@Animation,@Analyse,...
                       @Study,@Play,@Tutorial,@Plugin,@Gallery,@Figure);
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
   oo = Analyse(o);                    % add Analyse menu
   oo = Study(o);                      % add Study menu
   oo = Plugin(o);                     % add Plugin menu
   oo = Play(o);                       % add Play menu
   oo = Tutorial(o);                   % add Tutorial menu
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
   list = {'Plot','Analyse','Study','Play','Tutorial','Plugin'};
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
   ooo = mitem(oo,'Stuff');
   oooo = new(ooo,'Menu');
   plugin(oo,'corazon/shell/New');  % plug point
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

function oo = Plot(o)                  % Plot Menu (Dynamic)           
   oo = mhead(o,'Plot');
   dynamic(oo);                        % make this a dynamic menu
   ooo = plot(oo,'Menu');
end

%==========================================================================
% Analyse Menu
%==========================================================================

function oo = Analyse(o)               % Analyse Menu (Dynamic)        
   oo = mhead(o,'Analyse');
   dynamic(oo);                        % make this a dynamic menu
   ooo = analyse(oo,'Menu');
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu (Dynamic)          
   oo = mhead(o,'Study');
   dynamic(oo);                        % make this a dynamic menu
%  ooo = study(oo,'Menu');

   plugin(oo,'corazon/shell/Study');   % plug point
end

%==========================================================================
% Play Menu
%==========================================================================

function oo = Play(o)                  % Play Menu (Dynamic)           
   oo = mhead(o,'Play');
   dynamic(oo);                        % make this a dynamic menu
%  ooo = play(oo,'Menu');

   plugin(oo,'corazon/shell/Play');% plug point
end

%==========================================================================
% Tutorial Menu
%==========================================================================

function oo = Tutorial(o)              % Tutorial Menu (Dynamic)       
   oo = mhead(o,'Tutorial');
   dynamic(oo);                        % make this a dynamic menu
%  ooo = tutorial(oo,'Menu');

   plugin(oo,'corazon/shell/Tutorial');% plug point
end

%==========================================================================
% Plugin Menu
%==========================================================================

function oo = Plugin(o)                % Plugin Menu (Dynamic)         
   oo = menu(o,'Plugin');              % menu will be hidden
   dynamic(oo);                        % make this a dynamic menu
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
