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
   obj = navigation(obj,'Entanglement','Probability');
   
   [cmd,obj,list,func] = dispatch(obj,varargin,{{'@','invoke'}},'Setup');
   eval(cmd);
   return
end

%==========================================================================
% Short Hands
%==========================================================================

function TopicTask(obj)            % init screen/cmd window & display topic/task
   tutor(core,obj); return;   
end

function Disp(varargin)   % display text on screen
   tutor(core('display'),varargin); return;
end

function Print(varargin)  % print text to command window
   tutor(core('print'),varargin); return
end

function Eval(varargin)   % evaluate expression in base environment
   tutor(core('command'),varargin); return
end

%==========================================================================
% Setup the Roll Down Menu
%==========================================================================

function Setup(obj)
%
% SETUP       Setup the roll down menu
%
   obj = topic(obj,'','');    % avoid screen flickering: clear topic & task
   
   ob1 = mitem(obj,'Entanglement');

   AliceAndBob(ob1);   
   Observables(ob1);
   CommutingObservables(ob1);
   WaveFunctions(ob1);
   DensityMatrix(ob1);
   return
end

%==========================================================================
% Alice and Bob
%==========================================================================
   
function AliceAndBob(obj)
%      
% ALICE-AND-BOB
%
   TopicTask(obj);     % clear screen/command window & display topic/task
   switch arg(obj,1)
      case ''          % Setup
         ob1 = mitem(call(obj,{'@'}),'Meet Alice & Bob');
            ob2 = mitem(ob1,'True Geek Superheroes',{1});

      case 1
         Disp('We can think of Alice and Bob as purveyors of composite systems');
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
         Print; 
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
         Print; 
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
   TopicTask(obj);     % clear screen/command window & display topic/task
   switch arg(obj,1)
      case ''          % Setup
         ob1 = mitem(call(obj,{'@'}),'Product States');
            ob2 = mitem(ob1,'The Simplest Composite State',{1});

      case 1
         Disp('The simplest type of state for the composite system is called');
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
   TopicTask(obj);     % clear screen/command window & display topic/task
   switch arg(obj,1)
      case ''          % Setup
         ob1 = mitem(call(obj,{'@'}),'Alice & Bob''s Observables');
            ob2 = mitem(ob1,'Using Their Apparatuses A & B',{1});
            ob2 = mitem(ob1,'-');
            ob2 = mitem(ob1,'Alice''s Aparatus A',{2});
            ob2 = mitem(ob1,'Bob''s Aparatus B',{3});
            ob2 = mitem(ob1,'-');
            ob2 = mitem(ob1,'Observables on the Composite Space');
               ob3 = mitem(ob2,'Alice''s Aparatus A',{4});
               ob3 = mitem(ob2,'Bob''s Aparatus B',{5});

      case 1
         Disp('Alice and Bob can measure the components of ''their'' spins.');
         Disp('\n');
         Disp('If their systems would be completely separated, then Alice''s');
         Disp('measurements with apparatus A would be described by the spin');
         Disp('operators Sax, Say & Saz on ''her'' Hilbert space Ha.');
         Disp('\n');
         Disp('And Bob''s measurements with his apparatus B would be described');
         Disp('by the spin operators Sbx, Sby & Sbz on ''his'' Hilbert space Hb.');
         
      case 2
         Disp('Let''s study the action of Alice'' spin operators\n');
         
         Eval('Ha = space(toy,''spin'')      %% create Alice'' Hilbert space');  
         Eval('[u,d] = ket(Ha,''u'',''d'');  %% up vector |u> & down vector |d>');
         Eval('[Sax,Say,Saz] = operator(Ha,''Sx'',''Sy'',''Sz'');  %% spin operators');
         Print;
         Eval('Saz*u               %% Saz * |u> = |u>');
         Eval('Saz*d               %% Saz * |d> = -|d>');
         Eval('Sax*u               %% Sax * |u> = |d>');
         Eval('Sax*d               %% Sax * |d> = |u>');
         Eval('Say*u               %% Say * |u> = i*|d>');
         Eval('Say*d               %% Say * |d> = -i*|u>');
         
      case 3
         Disp('Let''s also study the action of Bob''s spin operators\n');
         
         Eval('Hb = space(toy,''spin'')''       %% create Bob''s Hilbert space');  
         Eval('[u,d] = ket(Hb,''u'',''d'');     %% up vector |u> & down vector |d>');
         Eval('[Sbx,Sby,Sbz] = operator(Hb,''Sx'',''Sy'',''Sz'');  %% spin operators');
         Print;
         Eval('Sbz*u               %% Sbz * |u> = |u>');
         Eval('Sbz*d               %% Sbz * |d> = -|d>');
         Eval('Sbx*u               %% Sbx * |u> = |d>');
         Eval('Sbx*d               %% Sbx * |d> = |u>');
         Eval('Sby*u               %% Sby * |u> = i*|d>');
         Eval('Sby*d               %% Sby * |d> = -i*|u>');
         return

      case 4
         Disp('Consider Alice'' spin operators on the composite space\n');
         
         Eval('H = space(toy,''twin'')   %% create a ''twin'' space');  
         Eval('[uu,ud,du,dd] = ket(H,''uu'',''ud'',''du'',''dd'');');
         Eval('[Ax,Ay,Az] = operator(H,''Ax'',''Ay'',''Az'');  %% spin operators');
         Print; 
         Eval('Az*uu               %% Az * |uu> = |uu>');
         Eval('Az*du               %% Az * |du> = -|du>');
         Eval('Ax*ud               %% Ax * |ud> = |dd>');
         Eval('Ax*dd               %% Ax * |dd> = |ud>');
         Eval('Ay*uu               %% Ay * |uu> = i*|du>');
         Eval('Ay*du               %% Ay * |du> = -i*|uu>');
         
      case 5
         Disp('Consider Bob''s spin operators on the composite space\n');
         
         Eval('H = space(toy,''twin'')    %% create a ''twin'' space');  
         Eval('[uu,ud,du,dd] = ket(H,''uu'',''ud'',''du'',''dd'');');
         Eval('[Bx,By,Bz] = operator(H,''Bx'',''By'',''Bz'');  %% spin operators');
         Print; 
         Eval('Bz*uu               %% Bz * |uu> = |uu>');
         Eval('Bz*du               %% Bz * |du> = |du>');
         Eval('Bx*ud               %% Bx * |ud> = |uu>');
         Eval('Bx*du               %% Bx * |du> = |dd>');
         Eval('By*uu               %% By * |uu> = i*|ud>');
         Eval('By*dd               %% By * |dd> = -i*|du>');
   end
   return
end

%==========================================================================
% Commuting Observables
%==========================================================================

function CommutingObservables(obj)
%
% COMMUTING-OBSERVABLES
%
   TopicTask(obj);     % clear screen/command window & display topic/task
   switch arg(obj,1)
      case ''          % Setup
         ob1 = mitem(call(obj,{'@'}),'Commuting Observables');
            ob2 = mitem(ob1,'Simple Systems');
               ob3 = mitem(ob2,'Introduction',{1.1});
               ob3 = mitem(ob2,'-');
               ob3 = mitem(ob2,'Simple System Example 1',{1.2});
               ob3 = mitem(ob2,'Simple System Example 2',{1.3});
            ob2 = mitem(ob1,'Composite Systems');
               ob3 = mitem(ob2,'Issues with Composite Systems',{2.1});
               ob3 = mitem(ob2,'-');
               ob3 = mitem(ob2,'Composite System Example 1',{2.2});
               ob3 = mitem(ob2,'Composite System Example 2',{2.3});
            ob2 = mitem(ob1,'Multiple Observables');
               ob3 = mitem(ob2,'On Game Space',{3.1});
               ob3 = mitem(ob2,'On Twin Space S°S',{3.2});
               ob3 = mitem(ob2,'On Twin Space S°S''',{3.3});
         
      case 1.1   % Simple System / Introduction
         Disp('For a simple system like a spin system the eigen values');
         Disp('of an observable are normally capable to index the full set');
         Disp('of eigenvectors of the observable.');

      case 1.2   % Simple System Example 1
         Disp('Start with a simple spin system');
         Print;
         Eval('H = space(toy,''spin'');     %% create simple spin space');
         Print;
         Disp('Now calculate the eigen values of the spin operator Sy');
         Print;
         Eval('Sy = operator(H,''Sy'');     %% get the spin operator Sy');
         Eval('eig(Sy+0)');
         Disp;
         Disp('We see two non-identical eigen values (-1,+1) which completely');
         Disp('   index the eigen vector basis (|d>, |u>).');
         Print;

      case 1.3  % Simple System Example 2
         Disp('Consider a simple (1D) toy position space');
         Print;
         Eval('H = space(toy,-3:3);         %% create simple position space');
         Print;
         Disp('Now calculate the eigen values of the forward shift operator F');
         Print;
         Eval('P = operator(H,''P'');       %% position operator P');
         Eval('eig(P+0)''');
         Disp;
         Disp('We see 7 non-identical eigen values (-3...+3) which completely');
         Disp('   index the eigen vector basis (|-3>, |-2>, ...,|+3>).');
         Print;

      case 2.1   % Composite System / Introduction
         Disp('For a composite system like two separated spin systems');
         Disp('or a quantum system representing 2D/3D space we will usually');
         Disp('be facing the issue that the set of distinct eigen values of');
         Disp('one observable may not be capable to index the full set of');
         Disp('eigenvectors of the composite basis.');
         Disp
         Disp('This gives rise to the approach of using an n-tuple of multiple');
         Disp('observable eigenvalues, which might be capable to index the complete');
         Disp('joint eigen vector basis of the composite space.');
         
      case 2.2
         Disp('Consider two separated spin systems & their tensor product space');
         Print;
         Eval('HA = space(toy,''spin'');    %% create simple spin space A');
         Eval('HB = HA'';                  %% create simple spin space B');
         Eval('H = HA.*HB;                %% tensor product space H = HA°HB');
         Print;
         Disp('Now calculate the eigen values of Alice''s spin operator SAx');
         Disp('on the composite space H = HA°HB');
         Print;
         Eval('SAx = operator(HA,''Sx'');   %% Alice''s spin operator SAx');
         Eval('Ax = SAx.*eye(HB)          %% SAx = Ax°IB');
         Eval('eig(SAx+0)''');
         Disp;
         Disp('We see 4 eigen values but only two of them are non-identical.');
         Disp('The 2 distinct eigen values of SAx (-1,+1) cannot index the whole');
         Disp('composite eigen vector basis (|u°u>, |u°d>, |d°u>, |d°d>).');
         Print;

      case 2.3
         Disp('Consider a 2D space. This can be composed as a composite space');
         Disp('H = HX°HY of two single 1D position spaces HX and HY');
         Print;
         Eval('HX = space(toy,-3:3);      %% create a 1D position space X');
         Eval('HY = HX'';                 %% create a 1D position space Y');
         Eval('H = HX.*HY;                %% tensor product space H = HX°HY');
         Eval('disp(labels(H));           %% how are the labels looking?');
         Print;
         Disp('Now calculate the eigen values of the position operator PX');
         Disp('on the composite space H = HX°HY');
         Print;
         Eval('X = operator(HX,''P'');      %% position operator on X');
         Eval('PX = X.*eye(HY)            %% PX = X°IY');
         Eval('eig(PX+0)''');
         Disp;
         Disp('We see 49 eigen values but only 7 of them are non-identical.');
         Disp('The 7 distinct eigen values of PX (-3,...,+3) cannot index the whole');
         Disp('composite eigen vector basis (|-3°-3>, |-3°-2>, ..., |3°3>).');
         Print;
         
      case 3.1   % multiple observables on game space
         Disp('Create a 2x1 quantum coin space HA and 1x6 quantum die space HB'); 
         Eval('HA = toy(''coin'');                %% quantum coin space');
         Eval('HB = toy(''die'');                 %% quantum die space');
         Print
         Disp('Create a composite quantum game space: H = HA°HB');
         Print
         Eval('H = HA.*HB;                        %% quantum game space');
         Eval('disp(labels(H))                  %% labels of quantum game space'); 
         Print
         Disp('Create natural observables OA & OB on spaces HA & HB');
         Print
         Eval('OA = operator(HA,''#'');           %% natural observable on HA');
         Eval('OB = operator(HB,''#'');           %% natural observable on HB');
         Print
         Eval('C = cspace(H,OA,OB);               %% composite space'); 

      case 3.2   % multiple observables on twin space S°S
         Disp('Create a twin space'); 
         Eval('HA = toy(''spin'');                %% simple spin space');
         Eval('HB = HA;                           %% another simple space');
         Print
         Disp('Create a composite (twin) space: H = HA°HB');
         Print
         Eval('H = HA.*HB;                        %% twin space');
         Eval('disp(labels(H))                    %% labels of twin space'); 
         Print
         Disp('Get observables SAz and SBx');
         Print
         Eval('SAz = operator(HA,''Sz'');           %% Spin-Z operator on HA');
         Eval('SBx = operator(HB,''Sx'');           %% Spin-X operator on HB');
         Print
         Eval('C = cspace(H,SAz,SBx);             %% composite space'); 
         Eval('B = property(C,''basis'')            %% get basis');
         Print
         Eval('V = vector(C,{-1,1});             %% index a basis vector'); 

      case 3.3   % multiple observables on twin space S°S'
         Disp('Create a twin space'); 
         Eval('HA = toy(''spin'');                %% simple spin space');
         Eval('HB = HA'';                         %% another simple space');
         Print
         Disp('Create a composite (twin) space: H = HA°HB');
         Print
         Eval('H = HA.*HB;                        %% twin space');
         Eval('disp(labels(H))                    %% labels of twin space'); 
         Print
         Disp('Get observables SAz and SBx');
         Print
         Eval('SAz = operator(HA,''Sz'');           %% Spin-Z operator on HA');
         Eval('SBx = operator(HB,''Sx'');           %% Spin-X operator on HB');
         Print
         Eval('C = cspace(H,SAz,SBx);             %% composite space'); 
         Eval('B = property(C,''basis'')            %% get basis');
   end
   return
end

%==========================================================================
% Wave Functions
%==========================================================================

function WaveFunctions(obj)
%      
% WAVE-FUNCTIONS
%
   TopicTask(obj);     % clear screen/command window & display topic/task
   switch arg(obj,1)
      case ''          % Setup
         ob1 = mitem(call(obj,{'@'}),'Wave Functions');
            ob2 = mitem(ob1,'Introduction',{1});
            ob2 = mitem(ob1,'Definition of the Wave Function',{2});
            ob2 = mitem(ob1,'Simple Space');
            ob2 = mitem(ob1,'Composite Space');
               ob3 = mitem(ob2,'Wave Function on Game Space',{4.1});
               ob3 = mitem(ob2,'Wave Function on Twin Space',{4.2});

      case 1
         Disp('Always keep in mind:');
         Disp('   1) in general wave functions may have nothing to do with');
         Disp('      waves.');
         Disp('   2) Wave functions are always relative to a given state and');
         Disp('      a given set of commuting observables.');
         Disp('\n');
         Disp('A wave function may be considered as a representation of the');
         Disp('expansion coefficients when a state vector is being expanded');
         Disp('in the eigen vector basis of the given commuting observables.');
         
      case 2
         Disp('Suppose |a,b,c,...> are the basis vectors of some quantum');
         Disp('system, where a,b,c,... are the eigenvalues of some complete');
         Disp('set of commuting observables A,B,C,...');
         Disp('\n');
         Disp('Any state vector |psi> can be expanded in that basis:');
         Disp('\n');
         Disp('   |psi> = Sum(a,b,c,...) psi(a,b,c,...) |a,b,c,...>');
         Disp('\n');
         Disp('The function psi(a,b,c,...) = <a,b,c,...|psi> is called the');
         Disp('wave function.');
         
      end
   return
end

%==========================================================================
% Density Matrix
%==========================================================================

function DensityMatrix(obj)
%      
% DENSITY-MATRIX
%
   TopicTask(obj);     % clear screen/command window & display topic/task
   switch arg(obj,1)
      case ''          % Setup
         ob1 = mitem(call(obj,{'@'}),'Density Matrix');
            ob2 = mitem(ob1,'Density Matrix of a Product State',{1});
      case 1
         Disp('Density Matrix of a Product State');
         Disp('\n');
         Disp('For a product state |s> = a*|1> + b*|2> the density matrix is');
         Disp('simply: rho = [a''*a, a''*b; b''*a b''*b]');
   end
   return
end

