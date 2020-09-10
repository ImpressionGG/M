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
   [cmd,obj,list,func] = dispatch(obj,varargin,{{'@','invoke'}},'Setup');
   eval(cmd);
   return
end

%==========================================================================
% Setup the Roll Down Menu
%==========================================================================

function Setup(obj)
%
% SETUP       Setup the roll down menu
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);

   ob1 = mitem(obj,'Spin');
   men = mitem(ob1);
   
   sub = uimenu(men,LB,'About Spin');
   itm = uimenu(sub,LB,'Derived From Particle Physics',CB,call('@AboutSpin'),UD,1);
   itm = uimenu(sub,LB,'Abstraction Of The Spin',CB,call('@AboutSpin'),UD,2);
   itm = uimenu(sub,LB,'Most Quantum',CB,call('@AboutSpin'),UD,3);

   sub = uimenu(men,LB,'Experiencing Spin');
   itm = uimenu(sub,LB,'Spin Measurement',CB,call('@ExperiencingSpin'),UD,1);
   itm = uimenu(sub,LB,'Random Spin',CB,call('@ExperiencingSpin'),UD,2);
   
   sub = uimenu(men,LB,'Representing Spin');
   itm = uimenu(sub,LB,'Intro',CB,call('@RepresentingSpin'),UD,1);
   itm = uimenu(sub,LB,'Up and Down Spin',CB,call('@RepresentingSpin'),UD,2);
   itm = uimenu(sub,LB,'Creating a Spin Space',CB,call('@RepresentingSpin'),UD,3);
   itm = uimenu(sub,LB,'Building the |u> and |d> Kets',CB,call('@RepresentingSpin'),UD,4);
   itm = uimenu(sub,LB,'Conjugate Transpose',CB,call('@RepresentingSpin'),UD,5);
   itm = uimenu(sub,LB,'Orthonormality of |u> and |d>',CB,call('@RepresentingSpin'),UD,6);

   sub = uimenu(men,LB,'General Spin Operator');
   itm = uimenu(sub,LB,'Spin Operators Sx, Sy, Sz',CB,call('@SpinOperator'),UD,1);
   itm = uimenu(sub,LB,'General Spin Polarization Vector',CB,call('@SpinOperator'),UD,2);
   itm = uimenu(sub,LB,'Main Spin Polarization Vectors',CB,call('@SpinOperator'),UD,3);
   itm = uimenu(sub,LB,'Eigenvectors of Sx, Sy, Sz',CB,call('@SpinOperator'),UD,4);
   
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
   evalin('base',cmd);   return
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
   obj = topic(obj,gcbo);
   
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
% Experiencing Spin
%==========================================================================
   
function ExperiencingSpin(obj)
%      
% EXPERIENCING-SPIN
%
   %Disp(obj,'');
   mode = arg(obj,1);
   switch mode
      case 1   % Spin Measurement
         setting('spin.random',0);
         apparatus(obj,'SpinMeasurement');
         return

      case 2   % Random Spin
         setting('spin.random',1);
         apparatus(obj,'SpinMeasurement');
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
   obj = topic(obj,gcbo);
   
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

%==========================================================================
% General Spin Operators
%==========================================================================
   
function SpinOperator(obj)
%      
% SPIN-OPERATORS
%
   obj = topic(obj,gcbo);
   
   Disp(obj,'');
   mode = arg(obj,1);
   switch mode
      case 1
         Disp('The general spin operator Sn can be constructed by the syntax:');
         Disp('Sn = spin(H,az,el), with azimuth angle az and elongation angle el.');
         Disp('\n');
         Disp('By proper choice of azimuth and elongation we can construct the');
         Disp('main spin operators Sx, Sy and Sz\n');
         
         Eval('H = spin(toy);          %% another way to create a spin space');
         Eval('Sx = spin(H,0,pi/2);');         
         Eval('Sy = spin(H,pi/2,pi/2);');         
         Eval('Sz = spin(H,0,0);');  
         echo

      case 2
         Disp('Besides of the general spin operator we can also calculate');
         Disp('the so called spin polarization vector\n');
         
         Eval('H = spin(toy);          %% another way to create a spin space');
         Eval('[Sn,pol] = spin(H,pi/4,pi/4)');         

         Disp('The spin polarization vector is a 3-vector in space. Once we');
         Disp('align the axis of our apparatus along the spin polarization');
         Disp('vector we always measure the value +1 or -1');
         
      case 3
         Disp('We can study the spin polarization vector for the main spin');
         Disp('states: |u>, |d>, |r>, |l>, |i> and |o>.\n');
         
         Eval('H = spin(toy);          %% another way to create a spin space');
         Eval('[su,sd,sr,sl,si,so] = ket(H,''u'',''d'',''r'',''l'',''i'',''o'');');         

         Disp('\nStates |u> and |d> are polarized along the z-axis.');
         Eval('spin(su)');
         Eval('spin(sd)');
         Disp('\nStates |r> and |l> are polarized along the x-axis.');
         Eval('spin(sr)');
         Eval('spin(sl)');
         Disp('\nStates |i> and |o> are polarized along the y-axis.');
         Eval('spin(si)');
         Eval('spin(so)');
         
      case 4
         Disp('We can calculate the eigen vectors of the main spin operators.');
         Disp('\n');
         Disp('This time we use the spin polarization vector.');
         Echo;
         Eval('H = spin(toy);          %% another way to create a spin space');
         Eval('Sx = spin(H,[1 0 0]);');         
         Eval('Sy = spin(H,[0 1 0]);');         
         Eval('Sz = spin(H,[0 0 1]);');  
         Echo
         Eval('[su,sd] = spin(Sz);');  
         Eval('[sr,sl] = spin(Sx);');  
         Eval('[si,so] = spin(Sy);');
         Echo
         Echo('Verification of eigen vectors')
         Echo
         Eval('check1 = [Sz*su == su, Sz*sd == -sd];'); 
         Eval('check2 = [Sx*sr == sr, Sx*sl == -sl];'); 
         Eval('check3 = [Sy*si == si, Sy*so == -so];');
         Echo
         Eval('disp([check1, check2, check3])');
  end
   return
end