function o = toybasics(o,varargin)
% 
% TOY-BASICS  Toy basics demos
%
%    Setup demo menu & handle menu callbacks of user defined menu items
%    The function needs creation and setup of a chameo object:
%
%       toybasics(toy)             % open menu and add demo menus
%       toybasics(toy,'Setup')     % add demo menus to existing menu
%       toybasics(toy,func)        % handle callbacks
%
%    See also   TOY, CORE, MENU, GFO
%
   [cmd,o] = arguments(o,varargin,'Setup');
   o = eval(cmd);
   return
end

%% Short Hands

function Disp(varargin)   % display text on screen
   tutor(core('display'),varargin); return;
end
function Print(varargin)  % print text to command window
   tutor(core('print'),varargin); return
end
function Eval(varargin)   % evaluate expression in base environment
   tutor(core('command'),varargin); return
end

%% Setup Menu
   
function o = Setup(o)
%
% SETUP Setup roll down menu
%
   oo = mitem(o,'Basics');
   ooo = GenericToy(oo);
   ooo = SimpleSpaceMenu(oo);
   ooo = MatrixSpaceMenu(oo);
   ooo = SpinSpaceMenu(oo);

%    sub = uimenu(men,LB,'Projectors');
%    itm = uimenu(sub,LB,'Create Projector by Symbolic Labels',CB,call('@Projectors'),UD,1);
%    itm = uimenu(sub,LB,'Create Projector by Numeric Index',CB,call('@Projectors'),UD,2);
%    itm = uimenu(sub,LB,'Get Projector Matrix',CB,call('@Projectors'),UD,3);
% 
%    sub = uimenu(men,LB,'Tensor Product');
%    itm = uimenu(sub,LB,'Create a Tensor Product Space',CB,call('@TensorProduct'),UD,1);
%    itm = uimenu(sub,LB,'Operator Tensor Product 1',CB,call('@TensorProduct'),UD,2);
%    itm = uimenu(sub,LB,'Operator Tensor Product 2',CB,call('@TensorProduct'),UD,3);
%    itm = uimenu(sub,LB,'Operator Tensor Product 3',CB,call('@TensorProduct'),UD,4);
%    itm = uimenu(sub,LB,'Vector Tensor Product 1',CB,call('@TensorProduct'),UD,5);
%    itm = uimenu(sub,LB,'Vector Tensor Product 2',CB,call('@TensorProduct'),UD,6);
%    itm = uimenu(sub,LB,'Vector Tensor Product 3',CB,call('@TensorProduct'),UD,7);
%    itm = uimenu(sub,LB,'Operator Application to Vector 1',CB,call('@TensorProduct'),UD,8);

   ooo = Operators(oo);


%    sub = uimenu(men,LB,'Twin Space Operators');
%          %uimenu(sub,LB,'All Operators on All Bases',CB,call('@TwinSpaceOperator'),UD,'all');
%    itm = uimenu(sub,LB,'Twin Space [2 1]°[2 1]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TwinSpaceOperator'),UD,'UD2121');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TwinSpaceOperator'),UD,'RL2121');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TwinSpaceOperator'),UD,'IO2121');
%    itm = uimenu(sub,LB,'Twin Space [2 1]°[1 2]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TwinSpaceOperator'),UD,'UD2112');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TwinSpaceOperator'),UD,'RL2112');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TwinSpaceOperator'),UD,'IO2112');
%    itm = uimenu(sub,LB,'Twin Space [1 2]°[2 1]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TwinSpaceOperator'),UD,'UD1221');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TwinSpaceOperator'),UD,'RL1221');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TwinSpaceOperator'),UD,'IO1221');
%    itm = uimenu(sub,LB,'Twin Space [1 2]°[1 2]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TwinSpaceOperator'),UD,'UD1212');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TwinSpaceOperator'),UD,'RL1212');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TwinSpaceOperator'),UD,'IO1212');
%    
%    sub = uimenu(men,LB,'Triple Space Operators');
%          %uimenu(sub,LB,'All Operators on All Bases',CB,call('@TripleSpaceOperator'),UD,'all');
% 
%    itm = uimenu(sub,LB,'Triple Space [2 1]°[2 1]°[2 1]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD212121');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL212121');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO212121');
%    itm = uimenu(sub,LB,'Triple Space [2 1]°[2 1]°[1 2]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD212112');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL212112');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO212112');
%    itm = uimenu(sub,LB,'Triple Space [2 1]°[1 2]°[2 1]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD211221');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL211221');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO211221');
%    itm = uimenu(sub,LB,'Triple Space [2 1]°[1 2]°[1 2]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD211212');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL211212');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO211212');
% 
%    itm = uimenu(sub,LB,'Triple Space [1 2]°[2 1]°[2 1]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD122121');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL122121');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO122121');
%    itm = uimenu(sub,LB,'Triple Space [1 2]°[2 1]°[1 2]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD122112');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL122112');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO122112');
%    itm = uimenu(sub,LB,'Triple Space [1 2]°[1 2]°[2 1]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD121221');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL121221');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO121221');
%    itm = uimenu(sub,LB,'Triple Space [1 2]°[1 2]°[1 2]');
%          uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD121212');
%          uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL121212');
%          uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO121212');
%          
%    sub = uimenu(men,LB,'Short Hands');
%    itm = uimenu(sub,LB,'Construction Short Hands',CB,call('@ShortHands'),UD,1);
%    
%    sub = uimenu(men,LB,'Transitions');
%    itm = uimenu(sub,LB,'Shift Transition',CB,call('@Transitions'),UD,1);
%    itm = uimenu(sub,LB,'Growth Transition',CB,call('@Transitions'),UD,2);
%    itm = uimenu(sub,LB,'Phase & Phase/Shift Transition',CB,call('@Transitions'),UD,3);
% 
%    sub = uimenu(men,LB,'Splits');
%    itm = uimenu(sub,LB,'Split Into Ray Projectors',CB,call('@Splits'),UD,1);
%    itm = uimenu(sub,LB,'Non Ray Projector Split',CB,call('@Splits'),UD,2);
%    itm = uimenu(sub,LB,'Split based on Special Rays',CB,call('@Splits'),UD,3);
%    itm = uimenu(sub,LB,'Autocompletion of Split',CB,call('@Splits'),UD,4);
%    itm = uimenu(sub,LB,'Split Regarding Initial State',CB,call('@Splits'),UD,5);
% 
%    sub = uimenu(men,LB,'Histories');
%    itm = uimenu(sub,LB,'Partial Inconsistency',CB,call('@Histories'),UD,1);
   
   return
end

%% Create Generic Toy Objects

function o = GenericToy(o)
%      
% GENERIC-TOY
%
   topic(o);          % clear screen/command window & display topic/task
   switch arg(o,1)
      case ''          % Setup
         oo = mitem(call(o,{'@'}),'Generic Toys');
            ooo = mitem(oo,'Create Generic Toy Object',{0});
            ooo = mitem(oo,'Create Generic Space',{1});
            ooo = mitem(oo,'Create Generic Projector',{2});
            ooo = mitem(oo,'Create Generic Operator',{3});
            ooo = mitem(oo,'Create Generic Split',{4});
            ooo = mitem(oo,'Create Generic Universe',{5});
            ooo = mitem(oo,'Create Generic History',{6});
            
      case 0
         Eval('T = toy            %% construct generic toy object');
         Print;
         Disp('Display internal data structure');
         Print;
         Eval('disp(T)            %% display internal data structure');
         Print;
         return
         
      case 1
         Eval('H = toy(''#SPACE'')    %% construct a generic Hilbert space');
         Print;
         Disp('Display internal data structure');
         Print;
         Eval('data(H,''space'')      %% display specific internal data');
         Print;
         return
         
      case 2
         Eval('P = toy(''#PROJECTOR'')  %% construct a generic projector');
         Print;
         Disp('Display internal data structure');
         Print;
         Eval('data(P,''proj'')         %% display specific internal data');
         Print;
         return

      case 3
         Eval('O = toy(''#OPERATOR'')   %% construct a generic operator');
         Print;
         Disp('Display internal data structure');
         Print;
         Eval('data(O,''oper'')         %% display specific internal data');
         Print;
         return

      case 4
         Eval('S = toy(''#SPLIT'')      %% construct a generic split');
         Print;
         Disp('Display internal data structure');
         Print;
         Eval('data(S,''split'')        %% display specific internal data');
         Print;
         return

      case 5
         Eval('S = toy(''#UNIVERSE'')   %% construct a generic universe');
         Print;
         Disp('Display internal data structure');
         Print;
         Eval('data(S,''uni'')          %% display specific internal data');
         Print;
         return

      case 6
         Eval('S = toy(''#HISTORY'')    %% construct a generic history');
         Print;
         Disp('Display internal data structure');
         Print;
         Eval('data(S,''history'')      %% display specific internal data');
         Print;
         return
      end
   return
end

%% Create A Simple Hilbert Space

function o = SimpleSpaceMenu(o)
%      
% SIMPLE-SPACE-MENU
%
   oo = mitem(o,'Simple Hilbert Space');
   ooo = mitem(oo,'Create Hilbert Space',call,{'@SimpleSpace',0});
   ooo = mitem(oo,'Display Space Structure',call,{'@SimpleSpace',1});
   ooo = mitem(oo,'Display Space Data',call,{'@SimpleSpace',2});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Property ''space?''',call,{'@SimpleSpace',3});
   ooo = mitem(oo,'Property ''simple?''',call,{'@SimpleSpace',4});
   return
end

function o = SimpleSpace(o)
%      
% SIMPLE-SPACE
%
   topic(o);          % clear screen/command window & display topic/task
   mode = arg(o,1);

   Disp('Construct a (simple) Hilbert space of dimension 7\n');
   if (mode == 0)
      Print('Use data(S) to see more details about internal data management!');
   end
   %Print;
   Eval('H = toy(1:7)');          % create a toy space
   Print;

   switch mode
      case 0
         Print('Display labels');
         Eval('labels(H)');
         Print;
         return
         
      case 1
         Print('Display space structure');
         Print;
         Eval('disp(H)');
         Print;
         return
         
      case 2
         Print('Display space data');
         Print;
         Eval('data(H,''space'')');
         Print;
         return 
         
      case 3
         Print('Property ''space?''');
         Print;
         Eval('isspace = property(H,''space?'')');
         Print;
         return 
         
      case 4
         Print('Property ''simple?''');
         Print;
         Eval('issimple = property(H,''simple?'')');
         Print;
         return 
   end
   return
end

%% Simple Matrix Space

function o = MatrixSpaceMenu(o)
%      
% MATRIX-SPACE-MENU
%
   oo = mitem(o,'The Basis Vector Matrix');
   ooo = mitem(oo,'Investigate Basis Vector Matrix',call,{'@MatrixSpace',0});
   ooo = mitem(oo,'Projectors on Matrix Space',call,{'@MatrixSpace',1});
   ooo = mitem(oo,'Floating Point Labels',call,{'@MatrixSpace',2});
   return
end

function o = MatrixSpace(o)
%      
% MATRIX-SPACE
%
   topic(o);          % clear screen/command window & display topic/task
   mode = arg(o,1);

   if (mode <= 1)
      Print('Construct a simple 2x2 matrix Hilbert space (dimension 4)');
      Print;
      Eval('H = space(toy,[11 12; 21 22])');
      Print;
   end
   
   switch mode
      case 0
         Print;
         Print('Investigate the 4x4 basis vector matrix');
         Print;
         Eval('matrix(H)+0');
         Print
         Print('Display label matrix');
         Print;
         Eval('property(H,''labels'')');
         Print
         return
         
      case 1
         Print;
         Print('Create two projectors');
         Print;
         Eval('P12 = projector(H,''12'')');
         Eval('P21 = projector(H,''21'')');
         Print
         Print('Display projector matrices');
         Print;
         Eval('M12 = matrix(P12)+0');
         Eval('M21 = matrix(P21)+0');
         return 
         
      case 2
         Print;
         Print('Use floating point labels');
         Print;
         Eval('H = space(toy,[1.1 1.2; 2.1 2.2])');
         Print
         Print('Display labels');
         Print;
         Eval('property(H,''labels'')');
         Print
         return 
   end
   return
end

%% Create A Spin Space

function o = SpinSpaceMenu(o)
%
% SPIN-SPACE-MENU
%
   oo = mitem(o,'Spin Space');
   ooo = mitem(oo,'Create Spin Space',call,{'@SpinSpace',0});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Basis Vector by Index',call,{'@SpinSpace',1});
   ooo = mitem(oo,'Basis Vector by Label',call,{'@SpinSpace',2});
   ooo = mitem(oo,'List of Basis Vectors & Labels',call,{'@SpinSpace',3});
   ooo = mitem(oo,'-');
   ooo = mitem(oo,'Basis Vector Matrix',call,{'@SpinSpace',4});
   ooo = mitem(oo,'Short Form',call,{'@SpinSpace',5});
   return
end

function o = SpinSpace(o)
%      
% SIMPLE-SPACE
%
   topic(o);          % clear screen/command window & display topic/task
   mode = arg(o,1);
   
   Disp('Construct a spin space as simple Hilbert space of dimension 2.');
   if (mode == 0)
      Disp('Use labels ''u'' (up) and ''d'' (down) for symbolic indices');
   end
   Print;
   Eval('H = space(toy,{''u'';''d''})');
   Print;
   
   global H;  evalin('base','global H');
   
   switch mode
      case 0
         return
      case 1
         Disp('Get 1st and 2nd basis (ket) vector by numeric index');
         Print;
         Eval('u = ket(H,1)');
         Eval('d = ket(H,2)');
         Print;
         Disp('Short form to get 1st and 2nd basis (ket) vector by numeric index');
         Print;
         fprintf('>> u = H(1)\n');  display(ket(H,1));
         fprintf('>> u = H(2)\n');  display(ket(H,2));
         Print;
         return 
         
      case 2
         Disp('Get 1st and 2nd basis (ket) vector by labels');
         Print;
         Eval('u = ket(H,''u'')');
         Eval('d = ket(H,''d'')');
         Print;
         Disp('Short form to get 1st and 2nd basis (ket) vector by labels');
         Print;
         fprintf('>> u = H(''u'')\n');  display(ket(H,'u'));
         fprintf('>> u = H(''d'')\n');  display(ket(H,'d'));
         Print;
         return

      case 3
         Disp('List of basis vector columns & labels');
         Print;
         Eval('[blist,labs] = basis(H)');
         
      case 4
         Disp('Get basis vector matrix');
         Disp('Matrices are usually stored in sparse form.');
         Print;
         Eval('B = basis(H,[])');
         Print;
         return
         
      case 5
         Disp('Add a zero (0) to display the basis vector matrix in usual form.');
         Print;
         Eval('B = H+0');
         Print;
         return
   end
   return
end

%% Projectors
   
function o = Projectors(o)
%      
% PROJECTORS
%
   topic(o);          % clear screen/command window & display topic/task
   mode = arg(o,1);

   if (mode < 4)
      Print('Construct a Hilbert (spin) space as a pre-requisite');
      Print;
      Eval('H = space(toy,{''u'';''d''})');
      Print;
   end
   
   switch mode
      case 1
         Print('Now create projectors according to basis vectors |u> and |d>:');
         Print
         Eval('Pu = projector(H,''u'')');
         Eval('Pd = projector(H,''d'')');
         Print
         Print('We can create projectors of higher dimensions')
         Print('The order of labels does not care')
         Print
         Eval('Pud = projector(H,''u'',''d'')');
         Eval('Pud = projector(H,{''u'',''d''})');
         Eval('Pud = projector(H,{''d'',''u''})');
         Print;
         return 

      case 2
         Print('We can create projectors according to numeric indices of basis vectors:');
         Print
         Eval('Pu = projector(H,1)');
         Eval('Pd = projector(H,2)');
         Print
         Print('We can create projectors of higher dimensions')
         Print('The order of labels does not care')
         Print
         Eval('Pud = projector(H,1,2)');
         Eval('Pud = projector(H,[1,2])');
         Eval('Pud = projector(H,{1,2})');
         Print;
         Print('Taking space R as the space refrence yields different labeling')
         Print
         Eval('R = space(toy,[0:1])');
         Eval('P0 = projector(R,1)');
         Eval('P1 = projector(R,2)');
         Eval('P0 = projector(R,''0'')');
         Eval('P1 = projector(R,''1'')');
         Print
         return
         
      case 3
         Print('Construct projectors');
         Print;
         Eval('Pu = projector(H,1)');
         Eval('Pd = projector(H,2)');
         Print
         Print('Get projector matrix');
         Print
         Eval('Mu = matrix(Pu)');
         Eval('Md = matrix(Pd)');
         Print
         return
   end
   return
end

%% Tensor Product
   
function o = TensorProduct(o)
%      
% TENSOR-PRODUCT
%
   topic(o);          % clear screen/command window & display topic/task
   mode = arg(o,1);
   
   Print('Construct two Hilbert spaces and create a tensor product space');
   Print;
   Eval('S1 = space(toy,{''a'',''b''});');
   Eval('S2 = space(toy,{''u'',''v'',''w''});');
   
   switch mode
      case 1
         Print
         Eval('R = S1.*S2      %% tensor product space');
         Eval('disp(labels(R)) %% display labels of tensor product space');
         Eval('S = S1''.*S2     %% tensor product space');
         Eval('disp(labels(S)) %% display labels of tensor product space');
         Eval('T = S1.*S2''     %% tensor product space');
         Eval('disp(labels(T)) %% display labels of tensor product space');

      case 2
         Print
         Print('Operator Tensor Product - Version 1');
         Print
         Eval('A = operator(S1,[1 2;3 4])       %% operator on space S1');
         Eval('disp(labels(A))                  %% display labels of operator A');
         Eval('matrix(A)+0                      %% matrix of operator A')
         Eval('B = operator(S2,''<<'')          %% operator on space S2');
         Eval('disp(labels(B))                  %% display labels of operator B');
         Eval('matrix(B)+0                      %% matrix of operator B')
         Eval('C1 = A.*B                        %% operator tensor product');
         Eval('disp(labels(C1))                 %% display labels of operator C1');
         Eval('M1 = matrix(C1)+0                %% matrix of operator C1')

      case 3
         Print
         Print('Operator Tensor Product - Version 2');
         Print
         Eval('A = operator(S1,[1 2;3 4])       %% operator on space S1');
         Eval('disp(labels(A))                  %% display labels of operator A');
         Eval('matrix(A)+0                      %% matrix of operator A')
         Eval('B = operator(S2,''<<'')          %% operator on space S2');
         Eval('disp(labels(B))                  %% display labels of operator B');
         Eval('matrix(B)+0                      %% matrix of operator B')
         Eval('C2 = A''.*B                       %% operator tensor product');
         Eval('disp(labels(C2))                 %% display labels of operator C2');
         Eval('M2 = matrix(C2)+0                %% matrix of operator C2')

      case 4
         Print
         Print('Operator Tensor Product - Version 3');
         Print
         Eval('A = operator(S1,[1 2;3 4])       %% operator on space S1');
         Eval('disp(labels(A))                  %% display labels of operator A');
         Eval('matrix(A)+0                      %% matrix of operator A')
         Eval('B = operator(S2,''<<'')          %% operator on space S2');
         Eval('disp(labels(B))                  %% display labels of operator B');
         Eval('matrix(B)+0                      %% matrix of operator B')
         Eval('C3 = A.*B''                       %% operator tensor product');
         Eval('disp(labels(C3))                 %% display labels of operator C3');
         Eval('M3 = matrix(C3)+0                %% matrix of operator C3')

      case 5
         Print
         Print('Vector Tensor Product - Version 1');
         Print
         Eval('S = S1.*S2                       %% tensor product space');
         Eval('V1 = ket(S1,[5 6])               %% vector on space S1');
         Eval('V2 = ket(S2,[2 3 4])             %% vector on space S1');
         Eval('V = V1.*V2                       %% vector tensor product');
         Eval('disp(V+0)')
         Eval('disp(labels(V1))')
         Eval('disp(labels(V2))')
         Eval('disp(labels(V))')

      case 6
         Print
         Print('Vector Tensor Product - Version 2');
         Print
         Eval('S = S1''.*S2                      %% tensor product space');
         Eval('V1 = ket(S1'',[5 6]'')            %% vector on space S1''');
         Eval('V2 = ket(S2,[2 3 4])             %% vector on space S1');
         Eval('V = V1.*V2                       %% vector tensor product');
         Eval('disp(V+0)')
         Eval('disp(labels(V1))')
         Eval('disp(labels(V2))')
         Eval('disp(labels(V))')

      case 7
         Print
         Print('Vector Tensor Product - Version 3');
         Print
         Eval('S = S1.*S2''                      %% tensor product space');
         Eval('V1 = ket(S1,[5 6])               %% vector on space S1');
         Eval('V2 = ket(S2'',[2 3 4]'')           %% vector on space S2''');
         Eval('V = V1.*V2                       %% vector tensor product');
         Eval('disp(V+0)')
         Eval('disp(labels(V1))')
         Eval('disp(labels(V2))')
         Eval('disp(labels(V))')

      case 8
         Print
         Print('Operator Application to Vector - Version 1');
         Print
         Eval('A = operator(S1,[1 2;3 4])       %% operator on space S1');
         Eval('B = operator(S2,''<<'');         %% operator on space S2');
         Eval('C1 = A.*B;                       %% operator tensor product');
         Eval('M1 = matrix(C1)+0;               %% matrix of operator C1')
         Print
         Eval('S = S1.*S2''                      %% tensor product space');
         Eval('V1 = ket(S1,[5 6])               %% vector on space S1');
         Eval('V2 = ket(S2,[2 3 4])             %% vector on space S2''');
         Eval('V = V1.*V2                       %% vector tensor product');
         Eval('disp(V+0)')
         Eval('disp(labels(V1))')
         Eval('disp(labels(V2))')
         Eval('disp(labels(V))')
   end
   return
end

%% Operators Menu

function o = Operators(o)
%
% OPERATORS   Operators Menu
%
   if is(arg(o,1))
      oo = mitem(call(o,{'@'}),'Operators');
      ooo = mitem(oo,'Create Standard Operators',{1});
      ooo = mitem(oo,'Operator Application to Vector',{2});
      ooo = mitem(oo,'*** Create a Customized Operators',{3});
      ooo = mitem(oo,'*** Tensor Product of Operators',{4});
      return
   end

   topic(o);          % clear screen/command window & display topic/task
   
   Print('Construct a simple Hilbert space of dimension 3.');
   Print;
   Eval('H = space(toy,{''a'',''b'',''c''})');
   Print;
   
   global H;  evalin('base','global H');
   
   switch arg(o,1)
      case 1
         Disp('Create an identity operator');
         Print;
         Eval('I = operator(H,''eye'')      %% eye (identity) operator');
         Print
         Disp('Create a null operator');
         Print;
         Eval('O = operator(H,''null'')     %% null operator');
         Print;
         Disp('Create a forward shift operator');
         Print;
         Eval('F = operator(H,''>>'')       %% forward shift operator');
         Print
         Disp('Create a backward shift operator');
         Print;
         Eval('B = operator(H,''<<'')       %% backward shift operator');
         Print
         return 
         
      case 2
         Disp('Create a forward shift operator');
         Print;
         Eval('F = operator(H,''>>'');      %% forward shift operator');
         Eval('B = operator(H,''<<'');      %% backward shift operator');
         Print;
         Disp('Get some kets by labels: |a> and |b>');
         Print;
         Eval('a = ket(H,''a'');');
         Eval('b = ket(H,''b'');');
         Print;
         Disp('Apply forward shift operator F to kets |a> and |b>');
         Print;
         Eval('F*a                          %% F*|a> = |b>');
         Eval('F*b                          %% F*|b> = |c>');
         Print;
         Disp('Undo forward shift by a backward shift');
         Print;
         Eval('B*(F*a)                      %% B*(F*|a>) = |a>');
         Eval('B*(F*b)                      %% B*(F*|b>) = |b>');
         Print;
         return

      case 3
         Print('List of basis vector columns & labels');
         Print;
         Eval('[blist,labs] = basis(H)');
         
      case 4
         Print('Get basis vector matrix');
         Print;
         Eval('B = basis(H,[])');
         Print;
         return
         
   end
   return
end

%% Twin Space Operators
   
function o = TwinSpaceOperator(o,mode)
%      
% TWIN-SPACE-OPERATOR
%
   topic(o);          % clear screen/command window & display topic/task
   if (nargin < 2)
      mode = arg(o,1);
   end
   
   switch mode
      case 'all'
         TwinSpaceOperator(o,'UD2121');
         TwinSpaceOperator(o,'RL2121');
         TwinSpaceOperator(o,'IO2121');

         TwinSpaceOperator(o,'UD2112');
         TwinSpaceOperator(o,'RL2112');
         TwinSpaceOperator(o,'IO2112');

         TwinSpaceOperator(o,'UD1221');
         TwinSpaceOperator(o,'RL1221');
         TwinSpaceOperator(o,'IO1221');

         TwinSpaceOperator(o,'UD1212');
         TwinSpaceOperator(o,'RL1212');
         TwinSpaceOperator(o,'IO1212');
         
      case {'UD2121','UD2112','UD1221','UD1212'}
         type = ['twin',mode(3:end)];
         Disp('Composite Spin Operators acting on Up-Down Basis\n');
         
         tabx = {'uu','ud','du','dd'};
         taby = {'Az','Ax','Ay','Bz','Bx','By'};
         tab  = {
                 {+1 'uu'}, {+1 'ud'}, {-1 'du'}, {-1 'dd'}
                 {+1 'du'}, {+1 'dd'}, {+1 'uu'}, {+1 'ud'}
                 {+i 'du'}, {+i 'dd'}, {-i 'uu'}, {-i 'ud'}

                 {+1 'uu'}, {-1 'ud'}, {+1 'du'}, {-1 'dd'}
                 {+1 'ud'}, {+1 'uu'}, {+1 'dd'}, {+1 'du'}
                 {+i 'ud'}, {-i 'uu'}, {+i 'dd'}, {-i 'du'}
                };
         VerifyTwinTable(o,type,tabx,taby,tab)

      case {'RL2121','RL2112','RL1221','RL1212'}
         type = ['twin',mode(3:end)];
         Disp('Composite Spin Operators acting on Right-Left Basis\n');
         
         tabx = {'rr','rl','lr','ll'};
         taby = {'Az','Ax','Ay','Bz','Bx','By'};
         tab  = {
                 {+1 'lr'}, {+1 'll'}, {+1 'rr'}, {+1 'rl'}
                 {+1 'rr'}, {+1 'rl'}, {-1 'lr'}, {-1 'll'}
                 {-i 'lr'}, {-i 'll'}, {+i 'rr'}, {+i 'rl'}

                 {+1 'rl'}, {+1 'rr'}, {+1 'll'}, {+1 'lr'}
                 {+1 'rr'}, {-1 'rl'}, {+1 'lr'}, {-1 'll'}
                 {-i 'rl'}, {+i 'rr'}, {-i 'll'}, {+i 'lr'}
                };
         VerifyTwinTable(o,type,tabx,taby,tab)
         
      case {'IO2121','IO2112','IO1221','IO1212'}
         type = ['twin',mode(3:end)];
         Disp('Composite Spin Operators acting on In-Out Basis\n');
         
         tabx = {'ii','io','oi','oo'};
         taby = {'Az','Ax','Ay','Bz','Bx','By'};
         tab  = {
                 {+1 'oi'}, {+1 'oo'}, {+1 'ii'}, {+1 'io'}
                 {+i 'oi'}, {+i 'oo'}, {-i 'ii'}, {-i 'io'}
                 {+1 'ii'}, {+1 'io'}, {-1 'oi'}, {-1 'oo'}

                 {+1 'io'}, {+1 'ii'}, {+1 'oo'}, {+1 'oi'}
                 {+i 'io'}, {-i 'ii'}, {+i 'oo'}, {-i 'oi'}
                 {+1 'ii'}, {-1 'io'}, {+1 'oi'}, {-1 'oo'}
                };
         VerifyTwinTable(o,type,tabx,taby,tab)

   end
   Print('Done!');
   return
end

function o = VerifyTwinTable(o,type,tabx,taby,tab)
%
% VERIFY-TWIN-TABLE
%
   global H uu ud du dd rr rl lr ll ii io oi oo Ax Ay Az Bx By Bz
   evalin('base','global H uu ud du dd rr rl lr ll ii io oi oo Ax Ay Az Bx By Bz');

   Eval(['H = space(toy,''',type,''') %% create a ''twin'' space']);  
   Eval('[uu,ud,du,dd] = ket(H,''uu'',''ud'',''du'',''dd'');');
   Eval('[rr,rl,lr,ll] = ket(H,''rr'',''rl'',''lr'',''ll'');');
   Eval('[ii,io,oi,oo] = ket(H,''ii'',''io'',''oi'',''oo'');');
   Eval('[Ax,Ay,Az] = operator(H,''Ax'',''Ay'',''Az'');  %% spin operators');
   Eval('[Bx,By,Bz] = operator(H,''Bx'',''By'',''Bz'');  %% spin operators');

   for (k=1:length(taby))
      Print;

      op = taby{k};
      cmd = [op,' = operator(H,''',op,''');   %% spin operator ',op];
      Eval(cmd);

      for (j=1:length(tabx))
         sym = tabx{j};
         pair = tab{k,j};
         if (pair{1} == 1)
            sgn = ''; 
         elseif (pair{1} == -1)
            sgn = '-'; 
         elseif (pair{1} == +i)
            sgn = 'i'; 
         elseif (pair{1} == -i)
            sgn = '-i';
         else
            sgn = '???';
         end
         result = pair{2};
         cmd = [op,'*',sym,'               %% ',...
                op,' * |',sym,'> = ',sgn,'|',result,'>'];
         Eval(cmd);

         sgn = pair{1};

         cmd = ['result = ket(H,''',pair{2},''');'];
         eval(cmd);
         result = pair{1} * result;
         cmd = ['assert(',op,'*',sym,' == result);'];
         eval(cmd);
      end
   end
   Print
   Eval('labels(H)     %% display labels of twin space');
   return
end

%% Triple Space Operators
   
function o = TripleSpaceOperator(o,mode)
%      
% TRIPLE-SPACE-OPERATOR
%
   topic(o);          % clear screen/command window & display topic/task
   if (nargin < 2)
      mode = arg(o,1);
   end
   
   switch mode
      case 'all'
         TripleSpaceOperator(o,'UD212121');
         TripleSpaceOperator(o,'RL212121');
         TripleSpaceOperator(o,'IO212121');

         TripleSpaceOperator(o,'UD212112');
         TripleSpaceOperator(o,'RL212112');
         TripleSpaceOperator(o,'IO212112');
         
         TripleSpaceOperator(o,'UD211221');
         TripleSpaceOperator(o,'RL211221');
         TripleSpaceOperator(o,'IO211221');
          
         TripleSpaceOperator(o,'UD211212');
         TripleSpaceOperator(o,'RL211212');
         TripleSpaceOperator(o,'IO211212');
         
         TripleSpaceOperator(o,'UD122121');
         TripleSpaceOperator(o,'RL122121');
         TripleSpaceOperator(o,'IO122121');

         TripleSpaceOperator(o,'UD122112');
         TripleSpaceOperator(o,'RL122112');
         TripleSpaceOperator(o,'IO122112');
         
         TripleSpaceOperator(o,'UD121221');
         TripleSpaceOperator(o,'RL121221');
         TripleSpaceOperator(o,'IO121221');
          
         TripleSpaceOperator(o,'UD121212');
         TripleSpaceOperator(o,'RL121212');
         TripleSpaceOperator(o,'IO121212');
         
      case {'UD212121','UD212112','UD211221','UD211212','UD122121','UD122112','UD121221','UD121212'}
         type = ['triple',mode(3:end)];
         Disp('Composite Spin Operators acting on Up-Down Basis\n');
         
         tabx = {'uuu','uud','udu','udd','duu','dud','ddu','ddd'};
         taby = {'Az','Ax','Ay','Bz','Bx','By','Cz','Cx','Cy'};
         tab  = {
                 {+1 'uuu'}, {+1 'uud'}, {+1 'udu'}, {+1 'udd'}, {-1 'duu'}, {-1 'dud'}, {-1 'ddu'}, {-1 'ddd'}
                 {+1 'duu'}, {+1 'dud'}, {+1 'ddu'}, {+1 'ddd'}, {+1 'uuu'}, {+1 'uud'}, {+1 'udu'}, {+1 'udd'}
                 {+i 'duu'}, {+i 'dud'}, {+i 'ddu'}, {+i 'ddd'}, {-i 'uuu'}, {-i 'uud'}, {-i 'udu'}, {-i 'udd'}
                 {+1 'uuu'}, {+1 'uud'}, {-1 'udu'}, {-1 'udd'}, {+1 'duu'}, {+1 'dud'}, {-1 'ddu'}, {-1 'ddd'}
                 {+1 'udu'}, {+1 'udd'}, {+1 'uuu'}, {+1 'uud'}, {+1 'ddu'}, {+1 'ddd'}, {+1 'duu'}, {+1 'dud'}
                 {+i 'udu'}, {+i 'udd'}, {-i 'uuu'}, {-i 'uud'}, {+i 'ddu'}, {+i 'ddd'}, {-i 'duu'}, {-i 'dud'}
                 {+1 'uuu'}, {-1 'uud'}, {+1 'udu'}, {-1 'udd'}, {+1 'duu'}, {-1 'dud'}, {+1 'ddu'}, {-1 'ddd'}
                 {+1 'uud'}, {+1 'uuu'}, {+1 'udd'}, {+1 'udu'}, {+1 'dud'}, {+1 'duu'}, {+1 'ddd'}, {+1 'ddu'}
                 {+i 'uud'}, {-i 'uuu'}, {+i 'udd'}, {-i 'udu'}, {+i 'dud'}, {-i 'duu'}, {+i 'ddd'}, {-i 'ddu'}
                };
         VerifyTripleTable(o,type,tabx,taby,tab)

      case {'RL212121','RL212112','RL211221','RL211212','RL122121','RL122112','RL121221','RL121212'}
         type = ['triple',mode(3:end)];
         Disp('Composite Spin Operators acting on Right-Left Basis\n');
         
         tabx = {'rrr','rrl','rlr','rll', 'lrr','lrl','llr','lll'};
         taby = {'Az','Ax','Ay','Bz','Bx','By','Cz','Cx','Cy'};
         tab  = {
                 {+1 'lrr'}, {+1 'lrl'}, {+1 'llr'}, {+1 'lll'},   {+1 'rrr'}, {+1 'rrl'}, {+1 'rlr'}, {+1 'rll'}
                 {+1 'rrr'}, {+1 'rrl'}, {+1 'rlr'}, {+1 'rll'},   {-1 'lrr'}, {-1 'lrl'}, {-1 'llr'}, {-1 'lll'}
                 {-i 'lrr'}, {-i 'lrl'}, {-i 'llr'}, {-i 'lll'},   {+i 'rrr'}, {+i 'rrl'}, {+i 'rlr'}, {+i 'rll'}
      
                 {+1 'rlr'}, {+1 'rll'}, {+1 'rrr'}, {+1 'rrl'},   {+1 'llr'}, {+1 'lll'}, {+1 'lrr'}, {+1 'lrl'}
                 {+1 'rrr'}, {+1 'rrl'}, {-1 'rlr'}, {-1 'rll'},   {+1 'lrr'}, {+1 'lrl'}, {-1 'llr'}, {-1 'lll'}
                 {-i 'rlr'}, {-i 'rll'}, {+i 'rrr'}, {+i 'rrl'},   {-i 'llr'}, {-+i 'lll'}, {+i 'lrr'}, {+i 'lrl'}

                 {+1 'rrl'}, {+1 'rrr'}, {+1 'rll'}, {+1 'rlr'},   {+1 'lrl'}, {+1 'lrr'}, {+1 'lll'}, {+1 'llr'}
                 {+1 'rrr'}, {-1 'rrl'}, {+1 'rlr'}, {-1 'rll'},   {+1 'lrr'}, {-1 'lrl'}, {+1 'llr'}, {-1 'lll'}
                 {-i 'rrl'}, {+i 'rrr'}, {-i 'rll'}, {+i 'rlr'},   {-i 'lrl'}, {+i 'lrr'}, {-i 'lll'}, {+i 'llr'}
                 };
         VerifyTripleTable(o,type,tabx,taby,tab)
         
      case {'IO212121','IO212112','IO211221','IO211212','IO122121','IO122112','IO121221','IO121212'}
         type = ['triple',mode(3:end)];
         Disp('Composite Spin Operators acting on In-Out Basis\n');
         
         tabx = {'iii','iio','ioi','ioo', 'oii','oio','ooi','ooo'};
         taby = {'Az','Ax','Ay','Bz','Bx','By','Cz','Cx','Cy'};
         tab  = {
                 {+1 'oii'}, {+1 'oio'}, {+1 'ooi'}, {+1 'ooo'},  {+1 'iii'}, {+1 'iio'}, {+1 'ioi'}, {+1 'ioo'}
                 {+i 'oii'}, {+i 'oio'}, {+i 'ooi'}, {+i 'ooo'},  {-i 'iii'}, {-i 'iio'}, {-i 'ioi'}, {-i 'ioo'}
                 {+1 'iii'}, {+1 'iio'}, {+1 'ioi'}, {+1 'ioo'},  {-1 'oii'}, {-1 'oio'}, {-1 'ooi'}, {-1 'ooo'}

                 {+1 'ioi'}, {+1 'ioo'}, {+1 'iii'}, {+1 'iio'},  {+1 'ooi'}, {+1 'ooo'}, {+1 'oii'}, {+1 'oio'}
                 {+i 'ioi'}, {+i 'ioo'}, {-i 'iii'}, {-i 'iio'},  {+i 'ooi'}, {+i 'ooo'}, {-i 'oii'}, {-i 'oio'}
                 {+1 'iii'}, {+1 'iio'}, {-1 'ioi'}, {-1 'ioo'},  {+1 'oii'}, {+1 'oio'}, {-1 'ooi'}, {-1 'ooo'}

                 
                 {+1 'iio'}, {+1 'iii'}, {+1 'ioo'}, {+1 'ioi'},  {+1 'oio'}, {+1 'oii'}, {+1 'ooo'}, {+1 'ooi'}
                 {+i 'iio'}, {-i 'iii'}, {+i 'ioo'}, {-i 'ioi'},  {+i 'oio'}, {-i 'oii'}, {+i 'ooo'}, {-i 'ooi'}
                 {+1 'iii'}, {-1 'iio'}, {+1 'ioi'}, {-1 'ioo'},  {+1 'oii'}, {-1 'oio'}, {+1 'ooi'}, {-1 'ooo'}
                 };
         VerifyTripleTable(o,type,tabx,taby,tab)
   end
   Print('Done!');
   return
end

function o = VerifyTripleTable(o,type,tabx,taby,tab)
%
% VERIFY-TRIPLE-TABLE
%
   global H Ax Ay Az Bx By Bz Cx Cy Cz
   global uuu uud udu udd duu dud ddu ddd 
   global rrr rrl rlr rll lrr lrl llr lll
   global iii iio ioi ioo oii oio ooi ooo
   
   evalin('base','global H Ax Ay Az Bx By Bz Cx Cy Cz');
   evalin('base','global uuu uud udu udd duu dud ddu ddd');
   evalin('base','global rrr rrl rlr rll lrr lrl llr lll');
   evalin('base','global iii iio ioi ioo oii oio ooi ooo');

   Eval(['H = space(toy,''',type,''') %% create a ''triple'' space']);  
   Eval('[uuu,uud,udu,udd] = ket(H,''uuu'',''uud'',''udu'',''udd'');');
   Eval('[duu,dud,ddu,ddd] = ket(H,''duu'',''dud'',''ddu'',''ddd'');');
   Eval('[rrr,rrl,rlr,rll] = ket(H,''rrr'',''rrl'',''rlr'',''rll'');');
   Eval('[lrr,lrl,llr,lll] = ket(H,''lrr'',''lrl'',''llr'',''lll'');');
   Eval('[iii,iio,ioi,ioo] = ket(H,''iii'',''iio'',''ioi'',''ioo'');');
   Eval('[oii,oio,ooi,ooo] = ket(H,''oii'',''oio'',''ooi'',''ooo'');');
   Eval('[Ax,Ay,Az] = operator(H,''Ax'',''Ay'',''Az'');  %% spin operators');
   Eval('[Bx,By,Bz] = operator(H,''Bx'',''By'',''Bz'');  %% spin operators');
   Eval('[Cx,Cy,Cz] = operator(H,''Cx'',''Cy'',''Cz'');  %% spin operators');

   for (k=1:length(taby))
      Print;

      op = taby{k};
      cmd = [op,' = operator(H,''',op,''');   %% spin operator ',op];
      Eval(cmd);

      for (j=1:length(tabx))
         sym = tabx{j};
         pair = tab{k,j};
         if (pair{1} == 1)
            sgn = ''; 
         elseif (pair{1} == -1)
            sgn = '-'; 
         elseif (pair{1} == +i)
            sgn = 'i'; 
         elseif (pair{1} == -i)
            sgn = '-i';
         else
            sgn = '???';
         end
         result = pair{2};
         cmd = [op,'*',sym,'               %% ',...
                op,' * |',sym,'> = ',sgn,'|',result,'>'];
         Eval(cmd);

         sgn = pair{1};

         cmd = ['result = ket(H,''',pair{2},''');'];
         eval(cmd);
         result = pair{1} * result;
         cmd = ['assert(',op,'*',sym,' == result);'];
         eval(cmd);
      end
   end
   Print
   Eval('labels(H)     %% display labels of twin space');

   return
end

%% ShortHands
   
function o = ShortHands(o)
%      
% SHORTHANDS
%
   topic(o);          % clear screen/command window & display topic/task
   mode = arg(o,1);
   
   switch mode
      case 1
         Print('Construction of Hilbert space');
         Print;
         Eval('H = toy(1:5)                 %% construct a 5D Hilbert space');
         Print
         Eval('H = toy({''a'',''b'',''c''})       %% construct a 3D Hilbert space');
         Print;
         Print('Construction of operators');
         Print;
         Eval('T = toy(1:5,''>>'')            %% shift operator on 5D Hilbert space');
         Print;
         Eval('I = toy({''a'',''b'',''c''},1)     %% identity operator on 3D Hilbert space');
         Print;
         Eval('N = toy({''a'',''b'',''c''},0)     %% null operator on 3D Hilbert space');
         Print
   end
   return
end

%% Transitions
   
function o = Transitions(o)
%      
% TRANSITIONS
%
   topic(o);          % clear screen/command window & display topic/task
   mode = arg(o,1);

   Print('Construct a Hilbert space as a pre-requisite');
   Print;
   Eval('H = space(toy,{''a'',''b'',''c''})');
   Print;
   
   switch mode
      case 1
         Print('Shift transition:');
         Print
         Eval('O = operator(H,''>>'');');
         Eval('V = ket(H,1);');
         Print
         Eval('[V,seq] = transition(O,V)      %% 1 transition, store in seq');
         Print
         Eval('transition(O,V,3)      %% 3 transitions');

      case 2
         Print('Growth transition:');
         Print
         Eval('O = operator(H,2);     %% same as eye(H)*i');
         Eval('V = ket(H,''a'');        %% initial vector |a>');    
         Print
         Eval('transition(O,V,5)      %% 5 transitions');
         Print
         Print('Growth/shift transition');
         Print
         Eval('O = 2*operator(H,''>>'');');
         Eval('transition(O,V,5)      %% 5 transitions');

      case 3
         Print('Phase transition:');
         Print
         Eval('i = sqrt(-1);          %% imaginary unit');
         Eval('O = operator(H,i);');
         Eval('V = ket(H,1);');
         Print
         Eval('transition(O,V,5)      %% 5 transitions');
         Print
         Print('Phase/shift transition');
         Print
         Eval('O = i*operator(H,''>>'');');
         Eval('transition(O,V,5)      %% 5 transitions');
   end
   return
end

%% Splits (Hilbert Space Decompositions)
   
function o = Splits(o)
%      
% SPLITS   Decompositions of Hilbert spaces
%
   topic(o);          % clear screen/command window & display topic/task
   mode = arg(o,1);

   if (mode <= 2)
      Print('Construct a Hilbert space as a pre-requisite');
      Print;
      Eval('H = space(toy,{''a'',''b'',''c''})');
      Print;
   end
   
   switch mode
      case 1
         Print('Split into ray projectors:');
         Print
         Eval('S = split(H,{''a'',''b'',''c''})');
         Print
         Eval('S = split(H,labels(H))');

      case 2
         Print('Non ray projector splits:');
         Print
         Eval('S = split(H,{''a'',{''b'',''c''}})');
         Print
         Eval('S = split(H,{{''a'',''b'',''c''}})');
         Print
         Eval('S = split(H,{{''a'',''b''},''c''})');
   
      case 3
         Print;
         Print('Special ray projector splits:');
         Print
         Eval('H = setup(H,''X'',unit(ket(H,''b'')+ket(H,''c'')));');
         Eval('H = setup(H,''Y'',unit(ket(H,''b'')-ket(H,''c'')));');
         Print
         Eval('ket(H,''X'')');
         Print
         Eval('ket(H,''Y'')');
         Print
         Eval('S = split(H,{''a'',''b'',''c''})');
         Print
         Eval('S = split(H,{''a'',''X'',''Y''})');
         Print

      case 4
         Print;
         Print('Auto completion of a split:');
         Print
         Eval('H = space(toy,{''a'',''b'',''c'',''d''})');
         Print
         Eval('S = split(H,{''a'',{''b'',''c''},''*''})');
         Print
         Eval('labels(S)                  %% display labels of the split');
         Print
         Eval('Sa = projector(S,''a'')      %% access the complementary projector');
         Print
         Eval('Sbc = projector(S,''b,c'')   %% access the complementary projector');
         Print
         Eval('Sz = projector(S,''*'')      %% access the complementary projector');
         Print
         Eval('Sa*Sz                      %% needs to be orthogonal');
         Eval('Sz*Sa                      %% needs to be orthogonal');
         Eval('Sa+Sbc+Sz                  %% add up to identity');

      case 5
         Print;
         Print('Split regarding initial vector:');
         Print
         Eval('H = space(toy,{''a'',''b'',''c'',''d''})');
         Eval('H = setup(H,''psi0'',unit(ket(H,''a'')+ket(H,''b'')));');
         Print
         Print('At time zero we split into [psi0] and [*]');
         Print
         Eval('S0 = split(H,{''psi0'',''*''})');
         Print
         Eval('S1 = split(H,{''a'',{''b'',''c''},''*''})');
         Print
         Eval('P0 = projector(S0,''psi0'')  %% initial state projector');
         Eval('P0+0                       %% show matrix');
         Eval('Pz = projector(S0,''*'')     %% complementary projector');
         Eval('Pz+0                       %% show matrix');
         
      end
   return
end

%% Histories
   
function o = Histories(o)
%      
% HISTORIES   Dealing with histories & families of histories
%
   topic(o);          % clear screen/command window & display topic/task
   mode = arg(o,1);

   switch mode
      case 1
         Print('Construct a Hilbert space, transition operator and universe');
         Print;
         Eval('H = space(toy,0:5);');
         Eval('T = operator(H,''>>'')');
         Eval('S0=split(space(T),{''1'',''2'',''*''});');
         Eval('S1=split(space(T),{''1'',''2'',''3'',''*''});');
         Print
         Eval('U=T*S0*S1*S1*S1');
         Print
         Eval('family(U,{''1'',''2''})');
         Print
         Eval('family(U,{''1'',''*''})');
         Print
         Eval('[Y1,Y2,Y3,Y4] = family(U,{''1'',''*''})');
         Print
         Eval('Y1''                     %% conjugate transpose of a history');
         Print
         Eval('Y1''*Y2                  %% like <Y1,Y2>, expected to be orthogonal');
         
   end
   return
end
