function oo = study(o,varargin)        % Study Menu                    
%
% STUDY   Manage Study menu
%
%           study(o,'Setup');          %  Setup STUDY menu
%
%           study(o,'Study1');         %  Study 1
%           study(o,'Study2');         %  Study 2
%           study(o,'Study3');         %  Study 3
%           study(o,'Study4');         %  Study 4
%
%           study(o,'Signal');         %  Setup STUDY specific Signal menu
%
%        See also: DISRUPTIVE, SHELL, PLOT
%
   [gamma,oo] = manage(o,varargin,@Setup,@Config,@Signal,...
                                  @Study1,@Study2,@Study3,@Study4);
   oo = gamma(oo);
end

%==========================================================================
% Setup Study Menu
%==========================================================================

function o = Setup(o)                  % Setup Study Menu              
   Register(o);
   
   oo = mhead(o,'Study');
   ooo = mitem(oo,'200nm Process (Upper Right)',{@Study1,'Upper Right Corner','r'});
   ooo = mitem(oo,'200nm Process (Lower Left)',{@Study1,'Lower Left Corner','b'});
   ooo = mitem(oo,'-');
   ooo = Parameters(oo);
end
function o = Register(o)               % Register Some Stuff           
   Config(type(o,'trigo'));            % register 'trigo' configuration
   Config(type(o,'expo'));             % register 'expo' configuration
   name = class(o);
   plugin(o,[name,'/shell/Signal'],{mfilename,'Signal'});
end

%==========================================================================
% Configuration
%==========================================================================

function o = Signal(o)                 % Study Specific Signal Menu    
%
% SIGNAL   The Signal function is setting up type specific Signal menu 
%          items which allow to change the configuration.
%
   switch active(o);                   % depending on active type
      case {'trigo','expo','study'}
         oo = mitem(o,'X',{@Config},'X');
         oo = mitem(o,'Y',{@Config},'Y');
         oo = mitem(o,'X/Y',{@Config},'XY');
         oo = mitem(o,'X and Y',{@Config},'XandY');
   end
end
function o = Config(o)                 % Install a Configuration       
%
% CONFIG Setup a configuration
%
%           Config(type(o,'mytype'))   % register a type specific config
%           oo = Config(arg(o,{'XY'})  % change configuration
%
   mode = o.either(arg(o,1),'XandY');  % get mode or provide default

   o = config(o,[],active(o));         % set all sublots to zero
   o = subplot(o,'Layout',1);          % layout with 1 subplot column   
   o = subplot(o,'Signal',mode);       % set signal mode   
   o = category(o,1,[200],[],'nm');    % setup category 1
   o = category(o,2,[200],[],'nm');    % setup category 2
   
   switch type(o)                      % depending on active type
      case 'expo'
         colx = 'm';  coly = 'c';
      otherwise
         colx = 'r';  coly = 'b';
   end
      
   switch mode
      case {'X'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
      case {'Y'}
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      case {'XY'}
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{1,coly});   % configure 'y' for 2nd subplot
      otherwise
         o = config(o,'x',{1,colx});   % configure 'x' for 1st subplot
         o = config(o,'y',{2,coly});   % configure 'y' for 2nd subplot
   end
   change(o,'Config');
end

%==========================================================================
% Study
%==========================================================================

function o = Study1(o)                 % Study 1                       
%
% STUDY1 Simulation data is stored in a DISRUPTIVE object of type 'study',
%        stored into clipboard for potential paste and plotted. If
%        pasted (with Edit>Paste) object can be further analyzed using
%        'Plot>Stream Plot'.
%        Use 'Plot>Stream Plot X', 'Plot>Stream Plot Y' or 'Plot/Scatter
%        Plot' for plotting, or use 'Plot>Basic>Stream' for plotting
%        while switching signal configurations in View/Signal menu.
%
   oo = disruptive('study');           % create a 'study' typed object
   oo = log(oo,'t','x','y');           % setup a data log object

      % setup parameters and system matrix
      
   o = with(o,'study');                % setup 'study' context
   [sigx,sigy] = opt(o,'sigx','sigy'); % get sigma parameters
   [offx,offy] = opt(o,'offx','offy'); % get offset parameters

   offx = o.iif(randn>0,offx,-offx);
   offy = o.iif(randn>0,offy,-offy);

      % run the simulation
      
   T = 3.2;                            % sample time 1.6s  
   for k = 1:500;
      t = k*T;                         % actual time stamp
      x = offx + sigx*randn;           % x placement error
      y = offy + sigy*randn;           % y placement error
      
      oo = log(oo,t,x,y);              % record log data
   end
   
      % define as working object, provide title and plot graphics
      
   oo = set(oo,'title',['200nm Glass-on-Glass Alignment (',arg(o,1),')']);
   oo = set(oo,'color',arg(o,2));
   plot(oo);                           % plot graphics
end

%==========================================================================
% Parameters
%==========================================================================

function oo = Parameters(o)            % Parameters Sub Menu           
   setting(o,{'study.sigx'},42);
   setting(o,{'study.sigy'},54);
   setting(o,{'study.offx'},38);
   setting(o,{'study.offy'},-23);

   oo = mitem(o,'Parameters');
   ooo = mitem(oo,'Sigma X [nm]','','study.sigx'); 
         charm(ooo,{});
   ooo = mitem(oo,'Sigma Y [nm]','','study.sigy'); 
         charm(ooo,{});
   ooo = mitem(oo,'Offset X [nm]','','study.offx'); 
         charm(ooo,{});
   ooo = mitem(oo,'Offset Y [nm]','','study.offy'); 
         charm(ooo,{});
end

