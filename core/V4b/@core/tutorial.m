function tutorial(obj,varargin)
% 
% TUTORIAL   CORE Tutorial
%
%    Open new figure and setup a tutorial menu for a CORE object
%      
%       tutorial(obj)           % open a menu shell with tutorial menu
%
%       tutorial(obj,'')        % open a menu shell with tutorial menu
%       tutorial(obj,'Intro')   % add INTRO roll down menu
%       tutorial(obj,'Core')    % add CORE roll down menu
%
%    See also: CORE DEMO
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{{'!','Execute'}},'Setup');
   eval(cmd)
   return
end

%==========================================================================
% Execute a Callback
%==========================================================================

function Execute(obj)
%
% EXECUTE   Execute a callback
%
   [cmd,obj,list,func] = dispatch(obj);
   clc
   eval(func);               % necessary for scripts
   return
end

%==========================================================================
% Menu Setup
%==========================================================================

function Setup(obj)   % Setup all standard menus
%
% SETUP    Setup menu
%
%    Perform the following steps:
%    1) Setup title & comment (if you go with menu(obj,'Home') for refresh)
%    2) Setup the specific launch function to launch a new figure with menu
%    3) Open a figure with empty menu & setup the roll down menus
%    4) Push the object into figure
%    5) Setup a refresh function and refresh
%
   obj = set(obj,'title','CORE Tutorial');
   obj = set(obj,'comment',{'How to utilize the power of CORE objects',...
                            'Introduction into CORE class','Have fun!'});

      % Never forget to setup the launch function
      
   obj = launch(obj,mfilename);  % use this mfile for launch function
                         
      % Launch function, title and comment are prepared now
      % Now setup the whole roll down menu
      
   menu(obj,'Empty');            % open figure & setup an empty menu
   menu(obj,'File');             % add the standard file roll down menu
   tutorial(obj,'Intro');        % add tutorial intro roll down menu
   tutorial(obj,'Core');         % add tutorial intro roll down menu
   menu(obj,'XInfo');            % add extended info menu
   
      % Push the object into figure
      
   gfo(obj);
   
      % Refresh figure and implicitely setup refresh function
      
   if isempty(refresh(obj))      % refresh & check whether refresh worked
      menu(obj,'Home');          % call Home function which sets up refresh
   end
   return                     
end
   
%==========================================================================      
% Setup INTRO Demo Roll Down Menu
%==========================================================================      

function Intro(obj)
%
% INTRO   Setup INTRO demo roll down menu
%
   ob1 = mitem(obj,'Intro');
  
   ob2 = mitem(ob1,'Core Introduction');
         mitem(ob2,'Core Toolbox Introduction',call,'!intro_toolbox');
         mitem(ob2,'Introduction to CORE Objects',call,'!intro_core');

   ob2 = mitem(ob1,'The Sine Demo');
         mitem(ob2,'Sine Demo - At a Glance',call,'!intro_sinedemo');
         mitem(ob2,'---');
         mitem(ob2,'Playing with Sine Demo',call,'!intro_playing');
         mitem(ob2,'Dealing with an Object',call,'!intro_dealing');
         
   ob2 = mitem(ob1,'---');
   ob2 = mitem(ob1,'Understanding Sine Demo');
         mitem(ob2,'Understanding Sine Demo',call,'!intro_understand');
         mitem(ob2,'Open a Shell to Play',call,'!intro_openshell');
         
   ob2 = mitem(ob1,'Context Settings');
         mitem(ob2,'Add Color Setting Menu Items',call,'!intro_colorsetting');
         mitem(ob2,'Add Menu Stuff',call,'!intro_addmenus');
         mitem(ob2,'Context Settings',call,'!intro_setting');
   
   return
end

%==========================================================================      
% Setup CORE Demo Roll Down Menu
%==========================================================================      

function Core(obj)
%
% CORE   Setup CORE demo roll down menu
%
   ob1 = mitem(obj,'Core');
         mitem(ob1,'About CORE objects','!cons_shell');
         mitem(ob1,'Simple CORE Construction','!cons_simple');

   return
end

