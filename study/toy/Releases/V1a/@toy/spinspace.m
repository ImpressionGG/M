function spinspace(obj,varargin)
% 
% SPINSPACE   Spin space demos (from Susskind's theoretical minimum)
%
%    Setup demo menu & handle menu callbacks of user defined menu items
%    The function needs creation and setup of a chameo object:
%
%       spinspace(toy)              % open menu and add demo menus
%       spinspace(toy,'Setup')      % add demo menus to existing menu
%       spinspace(toy,func)         % handle callbacks
%
%    See also: TOY, CORE, MENU, GFO
%
   obj = topic(obj,gcbo);
   
   [cmd,obj,list,func] = dispatch(obj,varargin,{{'@','invoke'}},'Setup');
   eval(cmd);
   return
end

%==========================================================================
% Setup the Roll Down Menu
%==========================================================================

function Setup(obj)
%
% SETUP       Setup the roll down menu for Alastair
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);

   men = mount(obj,'<main>',LB,'Spin');
   
   sub = uimenu(men,LB,'About Spin');
   
   itm = uimenu(sub,LB,'Derived From Particle Physics',CB,call('@AboutSpin'),UD,1);
   itm = uimenu(sub,LB,'Abstraction Of The Spin',CB,call('@AboutSpin'),UD,2);
   itm = uimenu(sub,LB,'Most Quantum',CB,call('@AboutSpin'),UD,3);

   sub = uimenu(men,LB,'Representing Spin');
   itm = uimenu(sub,LB,'Intro',CB,call('@RepresentingSpin'),UD,1);
   itm = uimenu(sub,LB,'Up and Down Spin',CB,call('@RepresentingSpin'),UD,2);
   itm = uimenu(sub,LB,'Creating a Spin Space',CB,call('@RepresentingSpin'),UD,3);
   itm = uimenu(sub,LB,'Building the |u> and |d> Kets',CB,call('@RepresentingSpin'),UD,4);
   itm = uimenu(sub,LB,'Conjugate Transpose',CB,call('@RepresentingSpin'),UD,5);
   itm = uimenu(sub,LB,'Orthonormality of |u> and |d>',CB,call('@RepresentingSpin'),UD,6);
   
   return
end

%==========================================================================
% Evaluate & Echo
%==========================================================================

function Eval(cmd)
%
% EVAL    Evaluate in base work space
%
   fprintf(['>> ',cmd,'\n']);
   evalin('base',cmd);
   return
end

function Echo(line)
%
% ECHO   Echo a line
%
   if (nargin == 0)
      fprintf('%%\n');
   else
      fprintf(['%% ',line,'\n']);
   end
   return
end

function Disp(arg1,arg2)
%
% DISP  Display a text line in window
%
%          Disp;                      % clear screen and initialize
%          Disp('my text');           % display text
%          Disp(obj,'My Heading');    % display a heading
%
   if (nargin == 0)
      cls;
      text(gao,'','position','home');
   elseif (nargin == 1)
      line = arg1;  text(gao,[line,'\n']);
      idx = find(line=='§');  line(idx) = [];
      Echo(line);
   elseif (nargin == 2)
      heading = get(arg1,'task');
      topic(arg1);  Disp(['§§',heading,'\n']);  shg;
   end
   return
end

%==========================================================================
% About Spin
%==========================================================================
   
function AboutSpin(obj)
%      
% ABOUT-SPIN
%
   Disp(obj,'');
   mode = arg(obj,1);
   switch mode
      case 1
         Disp('The concept of spin is derived from particle physics. Particles');
         Disp('have properties in addition to their location in space.');
         Disp('\n');
         Disp('For example. they may or may not have electric charge, or mass.');
         Disp('Attached to the electron is an extra degree of freedom, called');
         Disp('its spin.');
         return

      case 2
         Disp('We can and will abstract the idea of the spin, and forget that it');
         Disp('is attached to an electron.');
         Disp('\n');
         Disp('The quantum spin is a system that can be studied on its own right.');
         return

      case 3
         Disp('In fact, the quantum spin, isolated from the electron that carries it');
         Disp('through space, is both the simplest and the most quantum of systems.');
         return
   end
   return
end

%==========================================================================
% Representing Spin
%==========================================================================
   
function RepresentingSpin(obj)
%      
% REPRESENTING-SPIN
%
   Disp(obj,'');
   mode = arg(obj,1);
   switch mode
      case 1
         Disp('Our goal is to build a representation that captures everything');
         Disp('we know about the behaviour of spins.');
         Disp('\n');
         Disp('We will try to put things intuitively together, the best we can.');
         
      case 2
         Disp('Let''s begin by labeling the possible spin states.');
         Disp('\n');
         Disp('If the apparatus A is oriented along the z-axis the two possible');
         Disp('states that can be prepared correspond to Sz = +1 and Sz = -1.');
         Disp('\n');
         Disp('Let''s call these states ''up'' and ''down'' and denote them by ket');
         Disp('vectors |u> and |d>');
         
      case 3
         Disp('Following this idea we begin with the creation of a Hilbert');
         Disp('space H which is provided with two kets labeled  |u> and  |d>\n');
         
         Eval('H = space(''spin'')            %% create a Hilbert space');  
         Echo
         Eval('list = labels(H)             %% list of provided symbols');

      case 4
         Disp('Once having created a Hilbert space H we can access basis kets');
         Disp(' by symbolic indexing\n');
         
         Eval('H = space(''spin'');           %% create a Hilbert space');  
         Echo
         Eval('u = ket(H,''u'')               %% up-vector');
         Echo
         Eval('d = ket(H,''d'')               %% down-vector');
         Echo
         Echo('There is a more compact form for accessing more than 1 vectors');
         Echo
         Eval('[u,d] = ket(H,''u'',''d'')       %% get |u> and |d> kets');
         
      case 5
         Disp('Conjugate transpose converts a ket vector into a bra');
         Disp('vector and vice versa.\n');
         
         Eval('H = space(''spin'');           %% create a Hilbert space');  
         Eval('[u,d] = ket(H,''u'',''d'');      %% get |u> and |d> kets');
         Echo
         Eval('u                            %% ket vector');
         Eval('d''                           %% bra vector (conjugate transpose)');
         Echo
         Eval('d''*u                         %% dot product');
         Echo
         
      case 6
         Disp('The two basis vectors |u> and |d> of our spin space H build');
         Disp('an orthonormal basis.\n');
         
         Eval('H = space(''spin'');           %% create a Hilbert space');  
         Eval('[u,d] = ket(H,''u'',''d'');      %% get |u> and |d> kets');
         Echo
         Disp('We can easily check this by building the various dot products.\n');
         Eval('disp(u''*u)                   %% <u|u> = 1');
         Eval('disp(d''*u)                   %% <d|u> = 0');
         Eval('disp(u''*d)                   %% <u|d> = 0');
         Eval('disp(d''*d)                   %% <d|d> = 1');
         
         return
   end
   return
end

