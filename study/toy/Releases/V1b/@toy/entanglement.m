function entanglement(obj,varargin)
% 
% ENTANGLEMENT   Entanglement demos (from Susskind's theoretical minimum)
%
%    Setup demo menu & handle menu callbacks of user defined menu items
%    The function needs creation and setup of a chameo object:
%
%       entanglement(toy)           % open menu and add demo menus
%       entanglement(toy,'Setup')   % add demo menus to existing menu
%       entanglement(toy,func)      % handle callbacks
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
% SETUP       Setup the roll down menu
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);

   %men = mount(obj,'<main>',LB,'Entanglement');
   ob1 = mitem(obj,'Entanglement');
   men = mitem(ob1);
   
   sub = uimenu(men,LB,'Meet Alice & Bob');
   itm = uimenu(sub,LB,'True Geek Superheroes',CB,call('@AliceAndBob'),UD,1);

   sub = uimenu(men,LB,'Product States');
   itm = uimenu(sub,LB,'The Simplest Composite State',CB,call('@ProductStates'),UD,1);

   sub = uimenu(men,LB,'Alice & Bob''s Observables');
   itm = uimenu(sub,LB,'Using Their Apparatuses A & B',CB,call('@Observables'),UD,1);
   itm = uimenu(sub,LB,'Alice'' Aparatus A',CB,call('@Observables'),UD,2);
   itm = uimenu(sub,LB,'Bob''s Aparatus B',CB,call('@Observables'),UD,3);

   sub = uimenu(men,LB,'Observables on the Composite Space');
   itm = uimenu(sub,LB,'Alice'' Aparatus A',CB,call('@Observables'),UD,4);
   itm = uimenu(sub,LB,'Bob''s Aparatus B',CB,call('@Observables'),UD,5);

   
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
% Alice and Bob
%==========================================================================
   
function AliceAndBob(obj)
%      
% ALICE-AND-BOB
%
   Disp(obj,'');
   mode = arg(obj,1);
   switch mode
      case 1
         Disp('We can think of Alice and Bob as purveyors of composite systems');
         Disp('and laboratory setups of every description. ');
         Disp('\n');
         Disp('Their inventory and expertise are only limited by our imaginations,');
         Disp('and they gladly tackle difficult or dangerous assignments like');
         Disp('jumping into black holes.');
         Disp('\n');
         Disp('They''re true geek superheroes!');
         
      case 2
         Disp('Let''s study the action of Alice'' spin operators\n');
         
         Eval('Ha = space(''spin'')           %% create Alice'' Hilbert space');  
         Eval('[u,d] = ket(Ha,''u'',''d'');     %% up vector |u> & down vector |d>');
         Eval('[Sax,Say,Saz] = operator(Ha,''Sx'',''Sy'',''Sz'');  %% spin operators');
         Echo
         Eval('Saz*u               %% Saz * |u> = |u>');
         Eval('Saz*d               %% Saz * |d> = -|d>');
         Eval('Sax*u               %% Sax * |u> = |d>');
         Eval('Sax*d               %% Sax * |d> = |u>');
         Eval('Say*u               %% Say * |u> = i*|d>');
         Eval('Say*d               %% Say * |d> = -i*|d>');
         
      case 3
         Disp('Let''s also study the action of Bob''s spin operators\n');
         
         Eval('Hb = space(''spin'')''          %% create Bob''s Hilbert space');  
         Eval('[u,d] = ket(Hb,''u'',''d'');     %% up vector |u> & down vector |d>');
         Eval('[Sbx,Sby,Sbz] = operator(Hb,''Sx'',''Sy'',''Sz'');  %% spin operators');
         Echo
         Eval('Sbz*u               %% Sbz * |u> = |u>');
         Eval('Sbz*d               %% Sbz * |d> = -|d>');
         Eval('Sbx*u               %% Sbx * |u> = |d>');
         Eval('Sbx*d               %% Sbx * |d> = |u>');
         Eval('Sby*u               %% Sby * |u> = i*|d>');
         Eval('Sby*d               %% Sby * |d> = -i*|d>');
         return
   end
   return
end


%==========================================================================
% Product States
%==========================================================================
   
function ProductStates(obj)
%      
% OBSERVABLES
%
   Disp(obj,'');
   mode = arg(obj,1);
   switch mode
      case 1
         Disp('The simplest type of state for the composite system is called.');
         Disp('a product state.');
         Disp('\n');
         Disp('A product state is the result of completely independent prepa-');
         Disp('rations by Alice and Bob, in which each uses his or her own');
         Disp('apparatus to prepare a spin.');
         
   end
   return
end

%==========================================================================
% Alice and Bob's Observables
%==========================================================================
   
function Observables(obj)
%      
% OBSERVABLES
%
   Disp(obj,'');
   mode = arg(obj,1);
   switch mode
      case 1
         Disp('Alice and Bob can measure the components of ''their'' spins.');
         Disp('\n');
         Disp('If their systems would be completely separated, then Alice''s');
         Disp('measurements with Aparatus A would be described by the spin');
         Disp('operators Sax, Say & Saz on ''her'' Hilbert space Ha.');
         Disp('\n');
         Disp('And Bob''s measurements with his Aparatus B would be described');
         Disp('by the spin operators Sbx, Sby & Sbz on ''his'' Hilbert space Hb.');
         
      case 2
         Disp('Let''s study the action of Alice'' spin operators\n');
         
         Eval('Ha = space(''spin'')           %% create Alice'' Hilbert space');  
         Eval('[u,d] = ket(Ha,''u'',''d'');     %% up vector |u> & down vector |d>');
         Eval('[Sax,Say,Saz] = operator(Ha,''Sx'',''Sy'',''Sz'');  %% spin operators');
         Echo
         Eval('Saz*u               %% Saz * |u> = |u>');
         Eval('Saz*d               %% Saz * |d> = -|d>');
         Eval('Sax*u               %% Sax * |u> = |d>');
         Eval('Sax*d               %% Sax * |d> = |u>');
         Eval('Say*u               %% Say * |u> = i*|d>');
         Eval('Say*d               %% Say * |d> = -i*|d>');
         
      case 3
         Disp('Let''s also study the action of Bob''s spin operators\n');
         
         Eval('Hb = space(''spin'')''          %% create Bob''s Hilbert space');  
         Eval('[u,d] = ket(Hb,''u'',''d'');     %% up vector |u> & down vector |d>');
         Eval('[Sbx,Sby,Sbz] = operator(Hb,''Sx'',''Sy'',''Sz'');  %% spin operators');
         Echo
         Eval('Sbz*u               %% Sbz * |u> = |u>');
         Eval('Sbz*d               %% Sbz * |d> = -|d>');
         Eval('Sbx*u               %% Sbx * |u> = |d>');
         Eval('Sbx*d               %% Sbx * |d> = |u>');
         Eval('Sby*u               %% Sby * |u> = i*|d>');
         Eval('Sby*d               %% Sby * |d> = -i*|d>');
         return

      case 4
         Disp('Consider Alice'' spin operators on the composite space\n');
         
         Eval('H = space(''twin'') %% create a ''twin'' space');  
         Eval('[uu,ud,du,dd] = ket(H,''uu'',''ud'',''du'',''dd'');');
         Eval('[Ax,Ay,Az] = operator(H,''Ax'',''Ay'',''Az'');  %% spin operators');
         Echo
         Eval('Az*uu               %% Az * |uu> = |uu>');
         Eval('Az*du               %% Az * |du> = -|du>');
         Eval('Ax*ud               %% Ax * |ud> = |dd>');
         Eval('Ax*dd               %% Ax * |dd> = |ud>');
         Eval('Ay*uu               %% Ay * |uu> = i*|du>');
         Eval('Ay*du               %% Ay * |du> = -i*|uu>');
         
      case 5
         Disp('Consider Bob''s spin operators on the composite space\n');
         
         Eval('H = space(''twin'') %% create a ''twin'' space');  
         Eval('[uu,ud,du,dd] = ket(H,''uu'',''ud'',''du'',''dd'');');
         Eval('[Bx,By,Bz] = operator(H,''Bx'',''By'',''Bz'');  %% spin operators');
         Echo
         Eval('Bz*uu               %% Bz * |uu> = |uu>');
         Eval('Bz*du               %% Bz * |du> = |du>');
         Eval('Bx*ud               %% Bx * |ud> = |uu>');
         Eval('Bx*du               %% Bx * |du> = |dd>');
         Eval('By*uu               %% By * |uu> = i*|ud>');
         Eval('By*dd               %% By * |dd> = -i*|du>');
         
   end
   return
end

