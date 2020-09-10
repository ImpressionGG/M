function demo(obj,varargin)
% 
% DEMO   Tensor Demo
%
%        Setup demo menu & handle menu callbacks of user defined menu items
%        The function needs creation and setup of a chameo object:
%
%             demo(tensor)             % open menu and add demo menus
%             demo(tensor,'Setup')     % add demo menus to existing menu
%             demo(tensor,func)        % handle callbacks
%
%             obj = gfo;               % retrieve obj from menu's user data
%
%        Subdemo fuctions
%
%             probability              % probability demos
%             toy                      % toy model demos
%
%        See also   TENSOR, SHELL, MENU, GFO, PROBABILITY, TOY
%
   [cmd,obj,list,func] = dispatch(obj,varargin,{{'@','invoke'}},'Setup');
   eval(cmd);
   return
end

%==========================================================================
% User Defined Menu Setup
%==========================================================================

function obj = LaunchMenu(obj)      % only called for stand-alone menu
%
% LaunchMenu   Add object info and launch menu
%
   title = 'Tensor Demo Shell';
   comment = {'Working with tensor objects'
             };

   obj = set(obj,'title',title,'comment',comment,'menu',{'file'});
   menu(obj);                          % open menu
   return
end

%==========================================================================
% Setup the Roll Down Menu
%==========================================================================

function Setup(obj)
%
% SETUP       Setup the roll down menu for Alastair
%
   obj = LaunchMenu(obj);

   BasicsMenu(obj);                    % setup Basics roll down menu
   probability(obj,'Setup');           % setup Probability roll down menu
   toymodel(obj,'Setup');              % setup Toy Models roll down menu
   contextual(obj,'Setup');            % setup Contextual roll down menu
   return
end

%==========================================================================
% Setup Basics Menu
%==========================================================================
   
function BasicsMenu(obj)
%
% SETUP-BASICS
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);

   men = mount(obj,'<main>',LB,'Basics');
   sub = uimenu(men,LB,'Generic Tensors');
   itm = uimenu(sub,LB,'Create Generic Tensor',CB,call('@GenericTensors'),UD,0);
   itm = uimenu(sub,LB,'Create Generic Space',CB,call('@GenericTensors'),UD,1);
   itm = uimenu(sub,LB,'Create Generic Projector',CB,call('@GenericTensors'),UD,2);

   sub = uimenu(men,LB,'Simple Vector Space');
   itm = uimenu(sub,LB,'Create Vector Space',CB,call('@SimpleSpace'),UD,0);
   itm = uimenu(sub,LB,'Display Space Structure',CB,call('@SimpleSpace'),UD,1);
   itm = uimenu(sub,LB,'Display Space Data',CB,call('@SimpleSpace'),UD,2);
   itm = uimenu(sub,LB,'Property ''space''',CB,call('@SimpleSpace'),UD,3);
   itm = uimenu(sub,LB,'Property ''simple''',CB,call('@SimpleSpace'),UD,4);

   sub = uimenu(men,LB,'Simple Matrix Space');
   itm = uimenu(sub,LB,'Create Matrix Space',CB,call('@MatrixSpace'),UD,0);
   itm = uimenu(sub,LB,'Projectors on Matrix Space',CB,call('@MatrixSpace'),UD,1);
   itm = uimenu(sub,LB,'Floating Point Labels',CB,call('@MatrixSpace'),UD,2);
   
   sub = uimenu(men,LB,'Spin Space');
   itm = uimenu(sub,LB,'Create Spin Space',CB,call('@SpinSpace'),UD,0);
   itm = uimenu(sub,LB,'Basis Vector by Index',CB,call('@SpinSpace'),UD,1);
   itm = uimenu(sub,LB,'Basis Vector by Label',CB,call('@SpinSpace'),UD,2);
   itm = uimenu(sub,LB,'List of Basis Vectors & Labels',CB,call('@SpinSpace'),UD,3);
   itm = uimenu(sub,LB,'Basis Vector Matrix',CB,call('@SpinSpace'),UD,4);
   
   sub = uimenu(men,LB,'Projectors');
   itm = uimenu(sub,LB,'Create Projector by Symbolic Labels',CB,call('@Projectors'),UD,0);
   itm = uimenu(sub,LB,'Create Projector by Numeric Index',CB,call('@Projectors'),UD,1);
   itm = uimenu(sub,LB,'Get Projector Matrix',CB,call('@Projectors'),UD,2);
   itm = uimenu(sub,LB,'Projectors based on General Basis',CB,call('@Projectors'),UD,3);

   sub = uimenu(men,LB,'Tensor Product');
   itm = uimenu(sub,LB,'Create a Tensor Product Space',CB,call('@TensorProduct'),UD,0);
   itm = uimenu(sub,LB,'Operator Tensor Product 1',CB,call('@TensorProduct'),UD,1);
   itm = uimenu(sub,LB,'Operator Tensor Product 2',CB,call('@TensorProduct'),UD,2);
   itm = uimenu(sub,LB,'Operator Tensor Product 3',CB,call('@TensorProduct'),UD,3);
   itm = uimenu(sub,LB,'Vector Tensor Product 1',CB,call('@TensorProduct'),UD,4);
   itm = uimenu(sub,LB,'Vector Tensor Product 2',CB,call('@TensorProduct'),UD,5);
   itm = uimenu(sub,LB,'Vector Tensor Product 3',CB,call('@TensorProduct'),UD,6);
   itm = uimenu(sub,LB,'Operator Application to Vector 1',CB,call('@TensorProduct'),UD,7);
   
   sub = uimenu(men,LB,'Operators');
   itm = uimenu(sub,LB,'Create Standard Operators',CB,call('@Operators'),UD,0);
   itm = uimenu(sub,LB,'Operator Application to Vector',CB,call('@Operators'),UD,1);
   itm = uimenu(sub,LB,'*** Create a Customized Operators',CB,call('@Operators'),UD,2);
   itm = uimenu(sub,LB,'*** Tensor Product of Operators',CB,call('@Operators'),UD,3);

   sub = uimenu(men,LB,'Short Hands');
   itm = uimenu(sub,LB,'Construction Short Hands',CB,call('@ShortHands'),UD,1);
   
   sub = uimenu(men,LB,'Transitions');
   itm = uimenu(sub,LB,'Shift Transition',CB,call('@Transitions'),UD,0);
   itm = uimenu(sub,LB,'Growth Transition',CB,call('@Transitions'),UD,1);
   itm = uimenu(sub,LB,'Phase Transition',CB,call('@Transitions'),UD,2);

   sub = uimenu(men,LB,'Splits');
   itm = uimenu(sub,LB,'Split Into Ray Projectors',CB,call('@Splits'),UD,0);
   itm = uimenu(sub,LB,'Non Ray Projector Split',CB,call('@Splits'),UD,1);
   itm = uimenu(sub,LB,'Split based on Special Rays',CB,call('@Splits'),UD,2);
   itm = uimenu(sub,LB,'Autocompletion of Split',CB,call('@Splits'),UD,3);
   itm = uimenu(sub,LB,'Split Regarding Initial State',CB,call('@Splits'),UD,4);

   sub = uimenu(men,LB,'Histories');
   itm = uimenu(sub,LB,'Partial Inconsistency',CB,call('@Histories'),UD,1);
   
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

%==========================================================================
% Create Generic Tensors
%==========================================================================
   
function GenericTensors(obj)
%      
% GENERIC-TENSORS
%
   mode = args(obj,1);
   switch mode
      case 0
         Echo('Construct a generic tensor');
         Echo;
         Eval('T = tensor');
         Echo;
         Eval('disp(T)');
         Echo;
         return
      case 1
         Echo('Construct a generic space');
         Echo;
         Eval('S = tensor(''#SPACE'')');
         Echo;
         %Eval('disp(S)');
         %Echo;
         Eval('data(S,''space'')');
         Echo;
         return
      case 2
         Echo('Construct a generic projector');
         Echo;
         Eval('P = tensor(''#PROJECTOR'')');
         Echo;
         %Eval('disp(P)');
         %Echo;
         Eval('data(P,''proj'')');
         Echo;
         return
   end
   return
end

%==========================================================================
% Create A Simple Hilbert Space
%==========================================================================
   
function SimpleSpace(obj)
%      
% SIMPLE-SPACE
%
   mode = args(obj,1);

   Echo('Construct a simple Hilbert space of dimension 7');
   if (mode == 0)
      Echo('Use data(S) to see more details about internal data management!');
   end
   Echo;
   Eval('S = space(tensor,1:7)');
   Echo;

   switch mode
      case 0
         Echo('Display labels');
         Eval('property(S,''labels'')');
         Echo;
         return
      case 1
         Echo('Display space structure');
         Echo;
         Eval('disp(S)');
         Echo;
         return 
      case 2
         Echo('Display space data');
         Echo;
         Eval('data(S,''space'')');
         Echo;
         return 
      case 3
         Echo('Property ''space''');
         Echo;
         Eval('isspace = property(S,''space'')');
         Echo;
         return 
      case 4
         Echo('Property ''simple''');
         Echo;
         Eval('issimple = property(S,''simple'')');
         Echo;
         return 
   end
   return
end

%==========================================================================
% Simple Matrix Space
%==========================================================================
   
function MatrixSpace(obj)
%      
% MATRIX-SPACE
%
   mode = args(obj,1);

   if (mode > 2)
      Echo('Construct a simple 2x2 matrix Hilbert space (dimension 4)');
      Echo;
      Eval('M = space(tensor,[11 12; 21 22])');
      Echo;
   end
   
   switch mode
      case 0
         Echo;
         Echo('Be aware of the 4x4 basis vector matrix');
         Echo;
         Eval('matrix(M)+0');
         Echo
         Echo('Display label matrix');
         Echo;
         Eval('property(M,''labels'')');
         Echo
         return
      case 1
         Echo;
         Echo('Create two projectors');
         Echo;
         Eval('P12 = projector(M,''12'')');
         Eval('P21 = projector(M,''21'')');
         Echo
         Echo('Display projector matrices');
         Echo;
         Eval('M12 = matrix(P12)+0');
         Eval('M21 = matrix(P21)+0');
         return 
      case 2
         Echo;
         Echo('Use floating point labels');
         Echo;
         Eval('S = space(tensor,[1.1 1.2; 2.1 2.2])');
         Echo
         Echo('Display labels');
         Echo;
         Eval('property(S,''labels'')');
         Echo
         return 
   end
   return
end

%==========================================================================
% Create A Spin Space
%==========================================================================
   
function SpinSpace(obj)
%      
% SIMPLE-SPACE
%
   mode = args(obj,1);
   
   Echo('Construct a spin space as simple Hilbert space of dimension 2.');
   if (mode == 0)
      Echo('Use labels ''u'' (up) and ''d'' (down) for symbolic indices');
   end
   Echo;
   Eval('S = space(tensor,{''u'',''d''})');
   Echo;
   
   switch mode
      case 0
         return
      case 1
         Echo('Get 1st and 2nd basis vector');
         Echo;
         Eval('b1 = basis(S,1)');
         Eval('b2 = basis(S,2)');
         Echo;
         return 
      case 2
         Echo('Get 1st and 2nd basis vector by labels');
         Echo;
         Eval('b1 = basis(S,''u'')');
         Eval('b2 = basis(S,''d'')');
         Echo;
         return
      case 3
         Echo('List of basis vectors & labels');
         Echo;
         Eval('[blist,labels] = basis(S)');
      case 4
         Echo('Get basis matrix');
         Echo;
         Eval('B = basis(S,[])');
         Echo;
         return
   end
   return
end

%==========================================================================
% Projectors
%==========================================================================
   
function Projectors(obj)
%      
% PROJECTORS
%
   mode = args(obj,1);
   
   if (mode < 3)
      Echo('Construct a Hilbert (spin) space as a pre-requisite');
      Echo;
      Eval('S = space(tensor,{''u'',''d''})');
      Echo;
   end
   
   switch mode
      case 0
         Echo('Now create projectors according to basis vectors |u> and |d>:');
         Echo
         Eval('Pu = projector(S,''u'')');
         Eval('Pd = projector(S,''d'')');
         Echo
         Echo('We can create projectors of higher dimensions')
         Echo('The order of labels does not care')
         Echo
         Eval('Pud = projector(S,''u'',''d'')');
         Eval('Pud = projector(S,{''u'',''d''})');
         Echo;
         return 

      case 1
         Echo('We can create projectors according to numeric indices of basis vectors:');
         Echo
         Eval('Pu = projector(S,1)');
         Eval('Pd = projector(S,2)');
         Echo
         Echo('We can create projectors of higher dimensions')
         Echo('The order of labels does not care')
         Echo
         Eval('Pud = projector(S,1,2)');
         Eval('Pud = projector(S,[1,2])');
         Eval('Pud = projector(S,{1,2})');
         Echo;
         Echo('Taking space R as the space refrence yields different labeling')
         Echo
         Eval('R = space(tensor,[0:1])');
         Eval('P0 = projector(R,1)');
         Eval('P1 = projector(R,2)');
         Eval('P0 = projector(R,''0'')');
         Eval('P1 = projector(R,''1'')');
         Echo
         return
         
      case 2
         Echo('Construct projectors');
         Echo;
         Eval('Pu = projector(S,1)');
         Eval('Pd = projector(S,2)');
         Echo
         Echo('Get projector matrix');
         Echo
         Eval('Mu = matrix(Pu)');
         Eval('Md = matrix(Pd)');
         Echo
         return
         
      case 3
         Echo('Construct an orthonormal basis V based on');
         Echo('the eigen vectors of a swymmetric (hermitan) matrix');
         Echo('Construct a Hilbert space provided with the orthonormal basis V');
         Echo
         Eval('[V,E] = eig(magic(3)+magic(3));  %% orthonormal basis V');
         Eval('H = space(tensor,-1:1,V);        %% 3 dimensional Hilbert space');
         Echo
         Echo('Define two projectors which project in a 1-dim and 2-dim subspace');
         Echo
         Eval('P1 = projector(H,1)');
         Eval('P23 = projector(H,[2 3])');
         Echo
         Echo('Projector matrices');
         Echo
         Eval('M1 = matrix(P1)');
         Eval('M23 = matrix(P23)');
         Eval('M1*M23                %% expected to be zero since orthonormal');
         Echo
         return         
   end
   return
end

%==========================================================================
% Tensor Product
%==========================================================================
   
function TensorProduct(obj)
%      
% TENSOR-PRODUCT
%
   mode = args(obj,1);

   Echo('Construct two Hilbert spaces and create a tensor product space');
   Echo;
   Eval('S1 = space(tensor,{''a'',''b''});');
   Eval('S2 = space(tensor,{''u'',''v'',''w''});');
   
   switch mode
      case 0
         Echo
         Eval('R = S1.*S2      %% tensor product space');
         Eval('disp(labels(R)) %% display labels of tensor product space');
         Eval('S = S1''.*S2     %% tensor product space');
         Eval('disp(labels(S)) %% display labels of tensor product space');
         Eval('T = S1.*S2''     %% tensor product space');
         Eval('disp(labels(T)) %% display labels of tensor product space');

      case 1
         Echo
         Echo('Operator Tensor Product - Version 1');
         Echo
         Eval('A = operator(S1,[1 2;3 4])       %% operator on space S1');
         Eval('disp(labels(A))                  %% display labels of operator A');
         Eval('matrix(A)+0                      %% matrix of operator A')
         Eval('B = operator(S2,''backward'')    %% operator on space S2');
         Eval('disp(labels(B))                  %% display labels of operator B');
         Eval('matrix(B)+0                      %% matrix of operator B')
         Eval('C1 = A.*B                        %% operator tensor product');
         Eval('disp(labels(C1))                 %% display labels of operator C1');
         Eval('M1 = matrix(C1)+0                %% matrix of operator C1')

      case 2
         Echo
         Echo('Operator Tensor Product - Version 2');
         Echo
         Eval('A = operator(S1,[1 2;3 4])       %% operator on space S1');
         Eval('disp(labels(A))                  %% display labels of operator A');
         Eval('matrix(A)+0                      %% matrix of operator A')
         Eval('B = operator(S2,''backward'')    %% operator on space S2');
         Eval('disp(labels(B))                  %% display labels of operator B');
         Eval('matrix(B)+0                      %% matrix of operator B')
         Eval('C2 = A''.*B                       %% operator tensor product');
         Eval('disp(labels(C2))                 %% display labels of operator C2');
         Eval('M2 = matrix(C2)+0                %% matrix of operator C2')

      case 3
         Echo
         Echo('Operator Tensor Product - Version 3');
         Echo
         Eval('A = operator(S1,[1 2;3 4])       %% operator on space S1');
         Eval('disp(labels(A))                  %% display labels of operator A');
         Eval('matrix(A)+0                      %% matrix of operator A')
         Eval('B = operator(S2,''backward'')    %% operator on space S2');
         Eval('disp(labels(B))                  %% display labels of operator B');
         Eval('matrix(B)+0                      %% matrix of operator B')
         Eval('C3 = A.*B''                       %% operator tensor product');
         Eval('disp(labels(C3))                 %% display labels of operator C3');
         Eval('M3 = matrix(C3)+0                %% matrix of operator C3')

      case 4
         Echo
         Echo('Vector Tensor Product - Version 1');
         Echo
         Eval('S = S1.*S2                       %% tensor product space');
         Eval('V1 = vector(S1,[5 6])            %% vector on space S1');
         Eval('V2 = vector(S2,[2 3 4])          %% vector on space S1');
         Eval('V = V1.*V2                       %% vector tensor product');
         Eval('disp(V+0)')
         Eval('disp(labels(V1))')
         Eval('disp(labels(V2))')
         Eval('disp(labels(V))')

      case 5
         Echo
         Echo('Vector Tensor Product - Version 2');
         Echo
         Eval('S = S1''.*S2                      %% tensor product space');
         Eval('V1 = vector(S1'',[5 6]'')          %% vector on space S1''');
         Eval('V2 = vector(S2,[2 3 4])          %% vector on space S1');
         Eval('V = V1.*V2                       %% vector tensor product');
         Eval('disp(V+0)')
         Eval('disp(labels(V1))')
         Eval('disp(labels(V2))')
         Eval('disp(labels(V))')

      case 6
         Echo
         Echo('Vector Tensor Product - Version 3');
         Echo
         Eval('S = S1.*S2''                      %% tensor product space');
         Eval('V1 = vector(S1,[5 6])            %% vector on space S1');
         Eval('V2 = vector(S2'',[2 3 4]'')        %% vector on space S2''');
         Eval('V = V1.*V2                       %% vector tensor product');
         Eval('disp(V+0)')
         Eval('disp(labels(V1))')
         Eval('disp(labels(V2))')
         Eval('disp(labels(V))')

      case 7
         Echo
         Echo('Operator Application to Vector - Version 1');
         Echo
         Eval('A = operator(S1,[1 2;3 4])       %% operator on space S1');
         Eval('B = operator(S2,''backward'');   %% operator on space S2');
         Eval('C1 = A.*B;                       %% operator tensor product');
         Eval('M1 = matrix(C1)+0;               %% matrix of operator C1')
         Echo
         Eval('S = S1.*S2''                      %% tensor product space');
         Eval('V1 = vector(S1,[5 6])            %% vector on space S1');
         Eval('V2 = vector(S2,[2 3 4])          %% vector on space S2''');
         Eval('V = V1.*V2                       %% vector tensor product');
         Eval('disp(V+0)')
         Eval('disp(labels(V1))')
         Eval('disp(labels(V2))')
         Eval('disp(labels(V))')
   end
   return
end

%==========================================================================
% Operators
%==========================================================================
   
function Operators(obj)
%      
% OPERATORS
%
   mode = args(obj,1);

   Echo('Construct a Hilbert space as a pre-requisite');
   Echo;
   Eval('S = space(tensor,{''a'',''b'',''c''})');
   Echo;
   
   switch mode
      case 0
         Echo('Create standard operators:');
         Echo
         Eval('I = operator(S,''eye'')');
         Eval('matrix(I)+0');
         Echo
         Eval('F = operator(S,''forward'')    %% forward shift operator');
         Eval('matrix(F)+0');
         Echo
         Eval('B = operator(S,''backward'')   %% backward shift operator');
         Eval('matrix(B)+0');
         Echo

      case 1
         Echo('Operator application to a vector');
         Echo
         Eval('F = operator(S,''forward'')    %% forward shift operator');
         Eval('V = vector(S,''a'')            %% create a vector');
         Echo
         Eval('F*V                            %% apply to vector ');
         Eval('F*F*V                          %% apply twice to vector ');
         Eval('F*F*F*V                        %% apply three times to vector ');
         return
         
      case 2
         Echo('Construct projectors');
         Echo;
         Eval('Pu = projector(S,1)');
         Eval('Pd = projector(S,2)');
         Echo
         Echo('Get projector matrix');
         Echo
         Eval('Mu = matrix(Pu)');
         Eval('Md = matrix(Pd)');
         Echo
         return
         
      case 3
         Echo('Construct an orthonormal basis V based on');
         Echo('the eigen vectors of a swymmetric (hermitan) matrix');
         Echo('Construct a Hilbert space provided with the orthonormal basis V');
         Echo
         Eval('[V,E] = eig(magic(3)+magic(3));  %% orthonormal basis V');
         Eval('H = space(tensor,-1:1,V);        %% 3 dimensional Hilbert space');
         Echo
         Echo('Define two projectors which project in a 1-dim and 2-dim subspace');
         Echo
         Eval('P1 = projector(H,1)');
         Eval('P23 = projector(H,[2 3])');
         Echo
         Echo('Projector matrices');
         Echo
         Eval('M1 = matrix(P1)');
         Eval('M23 = matrix(P23)');
         Eval('M1*M23                %% expected to be zero since orthonormal');
         Echo
         return         
   end
   return
end

%==========================================================================
% ShortHands
%==========================================================================
   
function ShortHands(obj)
%      
% SHORTHANDS
%
   mode = args(obj,1);

   switch mode
      case 1
         Echo('Construction of Hilbert space');
         Echo;
         Eval('H = tensor(1:5);');
         Eval('H = tensor({''a'',''b'',''c''});');
         Echo;
         Echo('Construction of operators');
         Echo;
         Eval('T = tensor(1:5,''>>'')               %% shift operator');
         Echo;
         Eval('I = tensor({''a'',''b'',''c''},1)        %% identity operator');
         Echo;
         Eval('N = tensor({''a'',''b'',''c''},0)        %% null operator');
         Echo
   end
   return
end

%==========================================================================
% Transitions
%==========================================================================
   
function Transitions(obj)
%      
% TRANSITIONS
%
   mode = args(obj,1);

   Echo('Construct a Hilbert space as a pre-requisite');
   Echo;
   Eval('S = space(tensor,{''a'',''b'',''c''})');
   Echo;
   
   switch mode
      case 0
         Echo('Shift transition:');
         Echo
         Eval('O = operator(S,''>>'');');
         Eval('V = vector(S,1);');
         Echo
         Eval('[V,chain] = transition(O,V)    %% 1 transition, store in chain');
         Echo
         Eval('transition(O,V,3)      %% 3 transitions');

      case 1
         Echo('Growth transition:');
         Echo
         Eval('O = operator(S,2);');
         Eval('V = vector(S,1);');
         Echo
         Eval('transition(O,V,5)      %% 5 transitions');
         Echo
         Echo('Growth/shift transition');
         Echo
         Eval('O = 2*operator(S,''>>'');');
         Eval('transition(O,V,5)      %% 5 transitions');

      case 2
         Echo('Phase transition:');
         Echo
         Eval('O = operator(S,i);');
         Eval('V = vector(S,1);');
         Echo
         Eval('transition(O,V,5)      %% 5 transitions');
         Echo
         Echo('Phase/shift transition');
         Echo
         Eval('O = i*operator(S,''>>'');');
         Eval('transition(O,V,5)      %% 5 transitions');
   end
   return
end

%==========================================================================
% Splits (Hilbert Space Decompositions)
%==========================================================================
   
function Splits(obj)
%      
% SPLITS   Decompositions of Hilbert spaces
%
   mode = args(obj,1);

   if (mode <= 2)
      Echo('Construct a Hilbert space as a pre-requisite');
      Echo;
      Eval('H = space(tensor,{''a'',''b'',''c''})');
      Echo;
   end
   
   switch mode
      case 0
         Echo('Split into ray projectors:');
         Echo
         Eval('S = split(H,{''a'',''b'',''c''})');
         Echo
         Eval('S = split(H,labels(H))');

      case 1
         Echo('Non ray projector splits:');
         Echo
         Eval('S = split(H,{''a'',{''b'',''c''}})');
         Echo
         Eval('S = split(H,{{''a'',''b'',''c''}})');
         Echo
         Eval('S = split(H,{{''a'',''b''},''c''})');
   
      case 2
         Echo;
         Echo('Special ray projector splits:');
         Echo
         Eval('H = setup(H,''X'',normalize(vector(H,''b'')+vector(H,''c'')));');
         Eval('H = setup(H,''Y'',normalize(vector(H,''b'')-vector(H,''c'')));');
         Echo
         Eval('vector(H,''X'')');
         Echo
         Eval('vector(H,''Y'')');
         Echo
         Eval('S = split(H,{''a'',''b'',''c''})');
         Echo
         Eval('S = split(H,{''a'',''X'',''Y''})');
         Echo

      case 3
         Echo;
         Echo('Auto completion of a split:');
         Echo
         Eval('H = space(tensor,{''a'',''b'',''c'',''d''})');
         Echo
         Eval('S = split(H,{''a'',{''b'',''c''},''*''})');
         Echo
         Eval('labels(S)                  %% display labels of the split');
         Echo
         Eval('Sa = projector(S,''a'')      %% access the complementary projector');
         Echo
         Eval('Sbc = projector(S,''b,c'')   %% access the complementary projector');
         Echo
         Eval('Sz = projector(S,''*'')      %% access the complementary projector');
         Echo
         Eval('Sa*Sz                      %% needs to be orthogonal');
         Eval('Sz*Sa                      %% needs to be orthogonal');
         Eval('Sa+Sbc+Sz                  %% add up to identity');

      case 4
         Echo;
         Echo('Split regarding initial vector:');
         Echo
         Eval('H = space(tensor,{''a'',''b'',''c'',''d''})');
         Eval('H = setup(H,''psi0'',normalize(vector(H,''a'')+vector(H,''b'')));');
         Echo
         Echo('At time zero we split into [psi0] and [*]');
         Echo
         Eval('S0 = split(H,{''psi0'',''*''})');
         Echo
         Eval('S1 = split(H,{''a'',{''b'',''c''},''*''})');
         Echo
         Eval('P0 = projector(S0,''psi0'')  %% initial state projector');
         Eval('P0+0                       %% show matrix');
         Eval('Pz = projector(S0,''*'')     %% complementary projector');
         Eval('Pz+0                       %% show matrix');
         
      end
   return
end

%==========================================================================
% Histories
%==========================================================================
   
function Histories(obj)
%      
% HISTORIES   Dealing with histories & families of histories
%
   mode = args(obj,1);

   switch mode
      case 1
         Echo('Construct a Hilbert space, transition operator and universe');
         Echo;
         Eval('H = space(tensor,0:5);');
         Eval('T = operator(H,''>>'')');
         Eval('S0=split(space(T),{''1'',''2'',''*''});');
         Eval('S1=split(space(T),{''1'',''2'',''3'',''*''});');
         Echo
         Eval('U=T*S0*S1*S1*S1');
         Echo
         Eval('family(U,{''1'',''2''})');
         Echo
         Eval('family(U,{''1'',''*''})');
         Echo
         Eval('[Y1,Y2,Y3,Y4] = family(U,{''1'',''*''})');
         Echo
         Eval('Y1''                     %% conjugate transpose of a history');
         Echo
         Eval('Y1''*Y2                  %% like <Y1,Y2>, expected to be orthogonal');
         
   end
   return
end
