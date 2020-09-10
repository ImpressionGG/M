function toybasics(obj,varargin)
% 
% BASICS  Toy basics demos
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
   obj = topic(obj,gcbo);

   [cmd,obj,list,func] = dispatch(obj,varargin,{{'@','invoke'}},'Setup');
   eval(cmd);
   return
end

%==========================================================================
% Setup Roll Down Menu
%==========================================================================
   
function Setup(obj)
%
% SETUP Setup roll down menu
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);

   ob1 = mitem(obj,'Basics');
   men = mitem(ob1);
   
   ob2 = mitem(ob1,'Generic Toys');
   ob3 = mitem(ob2,'Create Generic Toy Object',call,{'@GenericTensors',0});
   ob3 = mitem(ob2,'Create Generic Space',call,{'@GenericTensors',1});
   ob3 = mitem(ob2,'Create Generic Projector',call,{'@GenericTensors',2});

   ob2 = mitem(ob1,'Simple Hilbert Space');
   ob3 = mitem(ob2,'Create Hilbert Space',call,{'@SimpleSpace',0});
   ob3 = mitem(ob2,'Display Space Structure',call,{'@SimpleSpace',1});
   ob3 = mitem(ob2,'Display Space Data',call,{'@SimpleSpace',2});
   ob3 = mitem(ob2,'Property ''space?''',call,{'@SimpleSpace',3});
   ob3 = mitem(ob2,'Property ''simple?''',call,{'@SimpleSpace',4});

   ob2 = mitem(ob1,'The Basis Vector Matrix');
   ob3 = mitem(ob2,'Investigate Basis Vector Matrix',call,{'@MatrixSpace',0});
   ob3 = mitem(ob2,'Projectors on Matrix Space',call,{'@MatrixSpace',1});
   ob3 = mitem(ob2,'Floating Point Labels',call,{'@MatrixSpace',2});
   
   ob2 = mitem(ob1,'Spin Space');
   sub = mitem(ob2);
   itm = uimenu(sub,LB,'Create Spin Space',CB,call('@SpinSpace'),UD,0);
   itm = uimenu(sub,LB,'Basis Vector by Index',CB,call('@SpinSpace'),UD,1);
   itm = uimenu(sub,LB,'Basis Vector by Label',CB,call('@SpinSpace'),UD,2);
   itm = uimenu(sub,LB,'List of Basis Vectors & Labels',CB,call('@SpinSpace'),UD,3);
   itm = uimenu(sub,LB,'Basis Vector Matrix',CB,call('@SpinSpace'),UD,4);
   
   sub = uimenu(men,LB,'Projectors');
   itm = uimenu(sub,LB,'Create Projector by Symbolic Labels',CB,call('@Projectors'),UD,1);
   itm = uimenu(sub,LB,'Create Projector by Numeric Index',CB,call('@Projectors'),UD,2);
   itm = uimenu(sub,LB,'Get Projector Matrix',CB,call('@Projectors'),UD,3);
   itm = uimenu(sub,LB,'Projectors based on General Basis',CB,call('@Projectors'),UD,4);

   sub = uimenu(men,LB,'Tensor Product');
   itm = uimenu(sub,LB,'Create a Tensor Product Space',CB,call('@TensorProduct'),UD,1);
   itm = uimenu(sub,LB,'Operator Tensor Product 1',CB,call('@TensorProduct'),UD,2);
   itm = uimenu(sub,LB,'Operator Tensor Product 2',CB,call('@TensorProduct'),UD,3);
   itm = uimenu(sub,LB,'Operator Tensor Product 3',CB,call('@TensorProduct'),UD,4);
   itm = uimenu(sub,LB,'Vector Tensor Product 1',CB,call('@TensorProduct'),UD,5);
   itm = uimenu(sub,LB,'Vector Tensor Product 2',CB,call('@TensorProduct'),UD,6);
   itm = uimenu(sub,LB,'Vector Tensor Product 3',CB,call('@TensorProduct'),UD,7);
   itm = uimenu(sub,LB,'Operator Application to Vector 1',CB,call('@TensorProduct'),UD,8);
   
   sub = uimenu(men,LB,'Operators');
   itm = uimenu(sub,LB,'Create Standard Operators',CB,call('@Operators'),UD,1);
   itm = uimenu(sub,LB,'Operator Application to Vector',CB,call('@Operators'),UD,2);
   itm = uimenu(sub,LB,'*** Create a Customized Operators',CB,call('@Operators'),UD,3);
   itm = uimenu(sub,LB,'*** Tensor Product of Operators',CB,call('@Operators'),UD,4);

   sub = uimenu(men,LB,'Twin Space Operators');
         uimenu(sub,LB,'All Operators on All Bases',CB,call('@TwinSpaceOperator'),UD,'all');
   itm = uimenu(sub,LB,'Twin Space [2 1]°[2 1]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TwinSpaceOperator'),UD,'UD2121');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TwinSpaceOperator'),UD,'RL2121');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TwinSpaceOperator'),UD,'IO2121');
   itm = uimenu(sub,LB,'Twin Space [2 1]°[1 2]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TwinSpaceOperator'),UD,'UD2112');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TwinSpaceOperator'),UD,'RL2112');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TwinSpaceOperator'),UD,'IO2112');
   itm = uimenu(sub,LB,'Twin Space [1 2]°[2 1]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TwinSpaceOperator'),UD,'UD1221');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TwinSpaceOperator'),UD,'RL1221');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TwinSpaceOperator'),UD,'IO1221');
   itm = uimenu(sub,LB,'Twin Space [1 2]°[1 2]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TwinSpaceOperator'),UD,'UD1212');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TwinSpaceOperator'),UD,'RL1212');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TwinSpaceOperator'),UD,'IO1212');
   
   sub = uimenu(men,LB,'Triple Space Operators');
         uimenu(sub,LB,'All Operators on All Bases',CB,call('@TripleSpaceOperator'),UD,'all');

   itm = uimenu(sub,LB,'Triple Space [2 1]°[2 1]°[2 1]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD212121');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL212121');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO212121');
   itm = uimenu(sub,LB,'Triple Space [2 1]°[2 1]°[1 2]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD212112');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL212112');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO212112');
   itm = uimenu(sub,LB,'Triple Space [2 1]°[1 2]°[2 1]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD211221');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL211221');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO211221');
   itm = uimenu(sub,LB,'Triple Space [2 1]°[1 2]°[1 2]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD211212');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL211212');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO211212');

   itm = uimenu(sub,LB,'Triple Space [1 2]°[2 1]°[2 1]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD122121');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL122121');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO122121');
   itm = uimenu(sub,LB,'Triple Space [1 2]°[2 1]°[1 2]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD122112');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL122112');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO122112');
   itm = uimenu(sub,LB,'Triple Space [1 2]°[1 2]°[2 1]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD121221');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL121221');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO121221');
   itm = uimenu(sub,LB,'Triple Space [1 2]°[1 2]°[1 2]');
         uimenu(itm,LB,'Acting on Up-Down Basis',CB,call('@TripleSpaceOperator'),UD,'UD121212');
         uimenu(itm,LB,'Acting on Right-Left Basis',CB,call('@TripleSpaceOperator'),UD,'RL121212');
         uimenu(itm,LB,'Acting on In-Out Basis',CB,call('@TripleSpaceOperator'),UD,'IO121212');
         
   sub = uimenu(men,LB,'Short Hands');
   itm = uimenu(sub,LB,'Construction Short Hands',CB,call('@ShortHands'),UD,1);
   
   sub = uimenu(men,LB,'Transitions');
   itm = uimenu(sub,LB,'Shift Transition',CB,call('@Transitions'),UD,1);
   itm = uimenu(sub,LB,'Growth Transition',CB,call('@Transitions'),UD,2);
   itm = uimenu(sub,LB,'Phase & Phase/Shift Transition',CB,call('@Transitions'),UD,3);

   sub = uimenu(men,LB,'Splits');
   itm = uimenu(sub,LB,'Split Into Ray Projectors',CB,call('@Splits'),UD,1);
   itm = uimenu(sub,LB,'Non Ray Projector Split',CB,call('@Splits'),UD,2);
   itm = uimenu(sub,LB,'Split based on Special Rays',CB,call('@Splits'),UD,3);
   itm = uimenu(sub,LB,'Autocompletion of Split',CB,call('@Splits'),UD,4);
   itm = uimenu(sub,LB,'Split Regarding Initial State',CB,call('@Splits'),UD,5);

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
% Create Generic Tensors
%==========================================================================
   
function GenericTensors(obj)
%      
% GENERIC-TENSORS
%
   Disp(obj,'');
   mode = arg(obj,1);
   switch mode
      case 0
         Eval('T = toy            %% construct generic toy object');

         Disp('Display internal data structure\n');
         Eval('disp(T)            %% display internal data structure');
         Echo;
         return
         
      case 1
         Eval('H = toy(''#SPACE'')    %% construct a generic Hilbert space');
         Echo;
         Eval('data(H,''space'')      %% display specific internal data');
         Echo;
         return
         
      case 2
         Eval('P = toy(''#PROJECTOR'')  %% construct a generic projector');
         Echo;
         Eval('data(P,''proj'')         %% display specific internal data');
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
   Disp(obj,'');
   mode = arg(obj,1);

   Disp('Construct a (simple) Hilbert space of dimension 7\n');
   if (mode == 0)
      Echo('Use data(S) to see more details about internal data management!');
   end
   %Echo;
   Eval('H = space(1:7)');
   Echo;

   switch mode
      case 0
         Echo('Display labels');
         Eval('labels(H)');
         Echo;
         return
         
      case 1
         Echo('Display space structure');
         Echo;
         Eval('disp(H)');
         Echo;
         return
         
      case 2
         Echo('Display space data');
         Echo;
         Eval('data(H,''space'')');
         Echo;
         return 
         
      case 3
         Echo('Property ''space?''');
         Echo;
         Eval('isspace = property(H,''space?'')');
         Echo;
         return 
         
      case 4
         Echo('Property ''simple?''');
         Echo;
         Eval('issimple = property(H,''simple?'')');
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
   Disp(obj,'');
   mode = arg(obj,1);

   if (mode <= 1)
      Echo('Construct a simple 2x2 matrix Hilbert space (dimension 4)');
      Echo;
      Eval('H = space(toy,[11 12; 21 22])');
      Echo;
   end
   
   switch mode
      case 0
         Echo;
         Echo('Investigate the 4x4 basis vector matrix');
         Echo;
         Eval('matrix(H)+0');
         Echo
         Echo('Display label matrix');
         Echo;
         Eval('property(H,''labels'')');
         Echo
         return
         
      case 1
         Echo;
         Echo('Create two projectors');
         Echo;
         Eval('P12 = projector(H,''12'')');
         Eval('P21 = projector(H,''21'')');
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
         Eval('H = space(toy,[1.1 1.2; 2.1 2.2])');
         Echo
         Echo('Display labels');
         Echo;
         Eval('property(H,''labels'')');
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
   Disp(obj,'');
   mode = arg(obj,1);
   
   Echo('Construct a spin space as simple Hilbert space of dimension 2.');
   if (mode == 0)
      Echo('Use labels ''u'' (up) and ''d'' (down) for symbolic indices');
   end
   Echo;
   Eval('H = space(toy,{''u'';''d''})');
   Echo;
   
   global H;  evalin('base','global H');
   
   switch mode
      case 0
         return
      case 1
         Echo('Get 1st and 2nd basis vector by numeric index');
         Echo;
         Eval('u = vector(H,1)');
         Eval('d = vector(H,2)');
         Echo;
         Echo('Short form to get 1st and 2nd basis vector by numeric index');
         Echo;
         fprintf('>> u = H(1)\n');  display(vector(H,1));
         fprintf('>> u = H(2)\n');  display(vector(H,2));
         Echo;
         return 
         
      case 2
         Echo('Get 1st and 2nd basis vector by labels');
         Echo;
         Eval('u = vector(H,''u'')');
         Eval('d = vector(H,''d'')');
         Echo;
         Echo('Short form to get 1st and 2nd basis vector by labels');
         Echo;
         fprintf('>> u = H(''u'')\n');  display(vector(H,'u'));
         fprintf('>> u = H(''d'')\n');  display(vector(H,'d'));
         Echo;
         return

      case 3
         Echo('List of basis vector columns & labels');
         Echo;
         Eval('[blist,labels] = basis(H)');
         
      case 4
         Echo('Get basis vector matrix');
         Echo;
         Eval('B = basis(H,[])');
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
   Disp(obj,'');
   mode = arg(obj,1);

   if (mode < 4)
      Echo('Construct a Hilbert (spin) space as a pre-requisite');
      Echo;
      Eval('H = space(toy,{''u'';''d''})');
      Echo;
   end
   
   switch mode
      case 1
         Echo('Now create projectors according to basis vectors |u> and |d>:');
         Echo
         Eval('Pu = projector(H,''u'')');
         Eval('Pd = projector(H,''d'')');
         Echo
         Echo('We can create projectors of higher dimensions')
         Echo('The order of labels does not care')
         Echo
         Eval('Pud = projector(H,''u'',''d'')');
         Eval('Pud = projector(H,{''u'',''d''})');
         Eval('Pud = projector(H,{''d'',''u''})');
         Echo;
         return 

      case 2
         Echo('We can create projectors according to numeric indices of basis vectors:');
         Echo
         Eval('Pu = projector(H,1)');
         Eval('Pd = projector(H,2)');
         Echo
         Echo('We can create projectors of higher dimensions')
         Echo('The order of labels does not care')
         Echo
         Eval('Pud = projector(H,1,2)');
         Eval('Pud = projector(H,[1,2])');
         Eval('Pud = projector(H,{1,2})');
         Echo;
         Echo('Taking space R as the space refrence yields different labeling')
         Echo
         Eval('R = space(toy,[0:1])');
         Eval('P0 = projector(R,1)');
         Eval('P1 = projector(R,2)');
         Eval('P0 = projector(R,''0'')');
         Eval('P1 = projector(R,''1'')');
         Echo
         return
         
      case 3
         Echo('Construct projectors');
         Echo;
         Eval('Pu = projector(H,1)');
         Eval('Pd = projector(H,2)');
         Echo
         Echo('Get projector matrix');
         Echo
         Eval('Mu = matrix(Pu)');
         Eval('Md = matrix(Pd)');
         Echo
         return
         
      case 4
         Echo('Construct an orthonormal basis V based on');
         Echo('the eigen vectors of a swymmetric (hermitan) matrix');
         Echo('Construct a Hilbert space provided with the orthonormal basis V');
         Echo
         Eval('[V,E] = eig(magic(3)+magic(3));  %% orthonormal basis V');
         Eval('H = space(toy,-1:1,V);        %% 3 dimensional Hilbert space');
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
         Eval('P1*P23                %% expected to be the null operator since orthonormal');
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
   Disp(obj,'');
   mode = arg(obj,1);
   
   Echo('Construct two Hilbert spaces and create a tensor product space');
   Echo;
   Eval('S1 = space(toy,{''a'',''b''});');
   Eval('S2 = space(toy,{''u'',''v'',''w''});');
   
   evalin('base','clear labels');
   
   switch mode
      case 1
         Echo
         Eval('R = S1.*S2      %% tensor product space');
         Eval('disp(labels(R)) %% display labels of tensor product space');
         Eval('S = S1''.*S2     %% tensor product space');
         Eval('disp(labels(S)) %% display labels of tensor product space');
         Eval('T = S1.*S2''     %% tensor product space');
         Eval('disp(labels(T)) %% display labels of tensor product space');

      case 2
         Echo
         Echo('Operator Tensor Product - Version 1');
         Echo
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
         Echo
         Echo('Operator Tensor Product - Version 2');
         Echo
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
         Echo
         Echo('Operator Tensor Product - Version 3');
         Echo
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

      case 6
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

      case 7
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

      case 8
         Echo
         Echo('Operator Application to Vector - Version 1');
         Echo
         Eval('A = operator(S1,[1 2;3 4])       %% operator on space S1');
         Eval('B = operator(S2,''<<'');         %% operator on space S2');
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
% Twin Space Operators
%==========================================================================
   
function TwinSpaceOperator(obj,mode)
%      
% TWIN-SPACE-OPERATOR
%
   Disp(obj,'');
   if (nargin < 2)
      mode = arg(obj,1);
   end
   
   switch mode
      case 'all'
         TwinSpaceOperator(obj,'UD2121');
         TwinSpaceOperator(obj,'RL2121');
         TwinSpaceOperator(obj,'IO2121');

         TwinSpaceOperator(obj,'UD2112');
         TwinSpaceOperator(obj,'RL2112');
         TwinSpaceOperator(obj,'IO2112');

         TwinSpaceOperator(obj,'UD1221');
         TwinSpaceOperator(obj,'RL1221');
         TwinSpaceOperator(obj,'IO1221');

         TwinSpaceOperator(obj,'UD1212');
         TwinSpaceOperator(obj,'RL1212');
         TwinSpaceOperator(obj,'IO1212');
         
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
         VerifyTwinTable(obj,type,tabx,taby,tab)

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
         VerifyTwinTable(obj,type,tabx,taby,tab)
         
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
         VerifyTwinTable(obj,type,tabx,taby,tab)

   end
   return
end

function VerifyTwinTable(obj,type,tabx,taby,tab)
%
% VERIFY-TWIN-TABLE
%
   global H uu ud du dd rr rl lr ll ii io oi oo Ax Ay Az Bx By Bz
   evalin('base','global H uu ud du dd rr rl lr ll ii io oi oo Ax Ay Az Bx By Bz');

   Eval(['H = space(''',type,''') %% create a ''twin'' space']);  
   Eval('[uu,ud,du,dd] = ket(H,''uu'',''ud'',''du'',''dd'');');
   Eval('[rr,rl,lr,ll] = ket(H,''rr'',''rl'',''lr'',''ll'');');
   Eval('[ii,io,oi,oo] = ket(H,''ii'',''io'',''oi'',''oo'');');
   Eval('[Ax,Ay,Az] = operator(H,''Ax'',''Ay'',''Az'');  %% spin operators');
   Eval('[Bx,By,Bz] = operator(H,''Bx'',''By'',''Bz'');  %% spin operators');

   for (k=1:length(taby))
      Echo;

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
   Echo
   Eval('labels(H)     %% display labels of twin space');
   return
end

%==========================================================================
% Triple Space Operators
%==========================================================================
   
function TripleSpaceOperator(obj,mode)
%      
% TRIPLE-SPACE-OPERATOR
%
   Disp(obj,'');
   if (nargin < 2)
      mode = arg(obj,1);
   end
   
   switch mode
      case 'all'
         TripleSpaceOperator(obj,'UD212121');
%        TripleSpaceOperator(obj,'RL212121');
%        TripleSpaceOperator(obj,'IO212121');

         TripleSpaceOperator(obj,'UD212112');
%        TripleSpaceOperator(obj,'RL212112');
%        TripleSpaceOperator(obj,'IO212112');
         
         TripleSpaceOperator(obj,'UD211221');
%        TripleSpaceOperator(obj,'RL211221');
%        TripleSpaceOperator(obj,'IO211221');
          
         TripleSpaceOperator(obj,'UD211212');
%        TripleSpaceOperator(obj,'RL211212');
%        TripleSpaceOperator(obj,'IO211212');
         
         TripleSpaceOperator(obj,'UD122121');
%        TripleSpaceOperator(obj,'RL122121');
%        TripleSpaceOperator(obj,'IO122121');

         TripleSpaceOperator(obj,'UD122112');
%        TripleSpaceOperator(obj,'RL122112');
%        TripleSpaceOperator(obj,'IO122112');
         
         TripleSpaceOperator(obj,'UD121221');
%        TripleSpaceOperator(obj,'RL121221');
%        TripleSpaceOperator(obj,'IO121221');
          
         TripleSpaceOperator(obj,'UD121212');
%        TripleSpaceOperator(obj,'RL121212');
%        TripleSpaceOperator(obj,'IO121212');
         
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
         VerifyTripleTable(obj,type,tabx,taby,tab)

      case {'RL212121','RL212112','RL211221','RL211212','RL122121','RL122112','RL121221','RL121212'}
         type = ['triple',mode(3:end)];
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
         VerifyTripleTable(obj,type,tabx,taby,tab)
         
      case {'IO212121','IO212112','IO211221','IO211212','IO122121','IO122112','IO121221','IO121212'}
         type = ['triple',mode(3:end)];
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
         VerifyTripleTable(obj,type,tabx,taby,tab)
   end
   return
end

function VerifyTripleTable(obj,type,tabx,taby,tab)
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

   Eval(['H = space(''',type,''') %% create a ''triple'' space']);  
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
      Echo;

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
   Echo
   Eval('labels(H)     %% display labels of twin space');

   return
end

%==========================================================================
% ShortHands
%==========================================================================
   
function ShortHands(obj)
%      
% SHORTHANDS
%
   Disp(obj,'');
   mode = arg(obj,1);
   
   switch mode
      case 1
         Echo('Construction of Hilbert space');
         Echo;
         Eval('H = toy(1:5)                 %% construct a 5D Hilbert space');
         Echo
         Eval('H = toy({''a'',''b'',''c''})       %% construct a 3D Hilbert space');
         Echo;
         Echo('Construction of operators');
         Echo;
         Eval('T = toy(1:5,''>>'')            %% shift operator on 5D Hilbert space');
         Echo;
         Eval('I = toy({''a'',''b'',''c''},1)     %% identity operator on 3D Hilbert space');
         Echo;
         Eval('N = toy({''a'',''b'',''c''},0)     %% null operator on 3D Hilbert space');
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
   Disp(obj,'');
   mode = arg(obj,1);

   Echo('Construct a Hilbert space as a pre-requisite');
   Echo;
   Eval('H = space(toy,{''a'',''b'',''c''})');
   Echo;
   
   switch mode
      case 1
         Echo('Shift transition:');
         Echo
         Eval('O = operator(H,''>>'');');
         Eval('V = vector(H,1);');
         Echo
         Eval('[V,seq] = transition(O,V)      %% 1 transition, store in seq');
         Echo
         Eval('transition(O,V,3)      %% 3 transitions');

      case 2
         Echo('Growth transition:');
         Echo
         Eval('O = operator(H,2);     %% same as eye(H)*i');
         Eval('V = vector(H,''a'');     %% initial vector |a>');    
         Echo
         Eval('transition(O,V,5)      %% 5 transitions');
         Echo
         Echo('Growth/shift transition');
         Echo
         Eval('O = 2*operator(H,''>>'');');
         Eval('transition(O,V,5)      %% 5 transitions');

      case 3
         Echo('Phase transition:');
         Echo
         Eval('i = sqrt(-1);          %% imaginary unit');
         Eval('O = operator(H,i);');
         Eval('V = vector(H,1);');
         Echo
         Eval('transition(O,V,5)      %% 5 transitions');
         Echo
         Echo('Phase/shift transition');
         Echo
         Eval('O = i*operator(H,''>>'');');
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
   Disp(obj,'');
   mode = arg(obj,1);

   if (mode <= 2)
      Echo('Construct a Hilbert space as a pre-requisite');
      Echo;
      Eval('H = space(toy,{''a'',''b'',''c''})');
      Echo;
   end
   
   switch mode
      case 1
         Echo('Split into ray projectors:');
         Echo
         Eval('S = split(H,{''a'',''b'',''c''})');
         Echo
         Eval('S = split(H,labels(H))');

      case 2
         Echo('Non ray projector splits:');
         Echo
         Eval('S = split(H,{''a'',{''b'',''c''}})');
         Echo
         Eval('S = split(H,{{''a'',''b'',''c''}})');
         Echo
         Eval('S = split(H,{{''a'',''b''},''c''})');
   
      case 3
         Echo;
         Echo('Special ray projector splits:');
         Echo
         Eval('H = setup(H,''X'',unit(vector(H,''b'')+vector(H,''c'')));');
         Eval('H = setup(H,''Y'',unit(vector(H,''b'')-vector(H,''c'')));');
         Echo
         Eval('vector(H,''X'')');
         Echo
         Eval('vector(H,''Y'')');
         Echo
         Eval('S = split(H,{''a'',''b'',''c''})');
         Echo
         Eval('S = split(H,{''a'',''X'',''Y''})');
         Echo

      case 4
         Echo;
         Echo('Auto completion of a split:');
         Echo
         Eval('H = space(toy,{''a'',''b'',''c'',''d''})');
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

      case 5
         Echo;
         Echo('Split regarding initial vector:');
         Echo
         Eval('H = space(toy,{''a'',''b'',''c'',''d''})');
         Eval('H = setup(H,''psi0'',unit(ket(H,''a'')+ket(H,''b'')));');
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
   Disp(obj,'');
   mode = arg(obj,1);

   switch mode
      case 1
         Echo('Construct a Hilbert space, transition operator and universe');
         Echo;
         Eval('H = space(toy,0:5);');
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
