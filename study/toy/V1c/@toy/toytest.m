function toytest(obj,varargin)
% 
% TOY-TESTS  Toy test routines
%
%    Setup demo menu & handle menu callbacks of user defined menu items
%    The function needs creation and setup of a chameo object:
%
%       toytest(toy)               % open menu and add demo menus
%       toytest(toy,'Setup')       % add demo menus to existing menu
%       toytest(toy,func)          % handle callbacks
%
%    See also   TOY, CORE, DEMO, MENU, GFO
%
   obj = navigation(obj,'Test','Info');

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
% Setup Roll Down Menu
%==========================================================================
   
function Setup(obj)
%
% SETUP Setup roll down menu
%
   ob1 = mitem(obj,'Test');

   TwinSpaceOperator(ob1);
   TripleSpaceOperator(ob1);
   CompleteObservableSet(ob1);

   return
end

%==========================================================================
% Twin Space Operators
%==========================================================================
   
function TwinSpaceOperator(obj)
%      
% TWIN-SPACE-OPERATOR
%
   TopicTask(obj);     % clear screen/command window & display topic/task
   switch arg(obj,1)
      case ''          % Setup
         ob1 = mitem(call(obj,{'@'}),'Twin Space Operators');
            ob2 = mitem(ob1,'Test All Operators on All Bases',{'all'});
            
      case 'all'
         toybasics(obj,'TwinSpaceOperator','all');
   end
   return
end

%==========================================================================
% Triple Space Operators
%==========================================================================
   
function TripleSpaceOperator(obj)
%      
% TRIPLE-SPACE-OPERATOR
%
   TopicTask(obj);     % clear screen/command window & display topic/task
   switch arg(obj,1)
      case ''          % Setup
         ob1 = mitem(call(obj,{'@'}),'Triple Space Operators');
            ob2 = mitem(ob1,'Test All Operators on All Bases',{'all'});
            
      case 'all'
         toybasics(obj,'TrippleSpaceOperator','all');
   end
   return
end

%==========================================================================
% Set of Complete Observables
%==========================================================================
   
function CompleteObservableSet(obj)
%      
% COMPLETE-OBSERVABLE-SET
%
   TopicTask(obj);     % clear screen/command window & display topic/task
   switch arg(obj,1)
      case ''          % Setup
         obj = topic(obj,'','');  % avoid scr. flickering: clear topic/task
         
         ob1 = mitem(call(obj,{'@'}),'Set of Complete Observables');
            ob2 = mitem(ob1,'Test on Single Space');
               ob3 = mitem(ob2,'Spin Operator Sz Space',{1.1});
               ob3 = mitem(ob2,'Spin Operator Sx Space',{1.2});
               ob3 = mitem(ob2,'Spin Operator Sy Space',{1.3});
            ob2 = mitem(ob1,'Test on Twin Space');
               ob3 = mitem(ob2,'Twin Space 2x1°2x1 @ Sz,Sx',{2.2121,'Sz','Sx'});
               ob3 = mitem(ob2,'Twin Space 2x1°1x2 @ Sz,Sx',{2.2112,'Sz','Sx'});
               ob3 = mitem(ob2,'Twin Space 1x2°2x1 @ Sz,Sx',{2.1221,'Sz','Sx'});
               ob3 = mitem(ob2,'Twin Space 1x2°1x2 @ Sz,Sx',{2.1212,'Sz','Sx'});
               ob3 = mitem(ob2,'-');
               ob3 = mitem(ob2,'Twin Space 2x1°1x2 @ Sz,Sz',{2.2112,'Sz','Sz'});
               ob3 = mitem(ob2,'Twin Space 1x2°2x1 @ Sz,Sz',{2.1221,'Sz','Sz'});
               ob3 = mitem(ob2,'-');
               ob3 = mitem(ob2,'Twin Space 2x1°1x2 @ Sx,Sx',{2.2112,'Sx','Sx'});
               ob3 = mitem(ob2,'Twin Space 1x2°2x1 @ Sx,Sx',{2.1221,'Sx','Sx'});
               ob3 = mitem(ob2,'-');
               ob3 = mitem(ob2,'Twin Space 2x1°1x2 @ Sy,Sy',{2.2112,'Sy','Sy'});
               ob3 = mitem(ob2,'Twin Space 1x2°2x1 @ Sy,Sy',{2.1221,'Sy','Sy'});
               
            ob2 = mitem(ob1,'Tests on Triple Space');
               ob3 = mitem(ob2,'Triple Space 2x1°2x1°2x1 @ Sz,Sx,Sy',{3.212121,'Sz','Sx','Sy'});
               ob3 = mitem(ob2,'Triple Space 2x1°2x1°1x2 @ Sz,Sx,Sy',{3.212112,'Sz','Sx','Sy'});
               ob3 = mitem(ob2,'Triple Space 2x1°1x2°2x1 @ Sz,Sx,Sy',{3.211221,'Sz','Sx','Sy'});
               ob3 = mitem(ob2,'Triple Space 2x1°1x2°1x2 @ Sz,Sx,Sy',{3.211212,'Sz','Sx','Sy'});
               ob3 = mitem(ob2,'-');
               ob3 = mitem(ob2,'Triple Space 1x2°2x1°2x1 @ Sz,Sx,Sy',{3.122121,'Sz','Sx','Sy'});
               ob3 = mitem(ob2,'Triple Space 1x2°2x1°1x2 @ Sz,Sx,Sy',{3.122112,'Sz','Sx','Sy'});
               ob3 = mitem(ob2,'Triple Space 1x2°1x2°2x1 @ Sz,Sx,Sy',{3.121221,'Sz','Sx','Sy'});
               ob3 = mitem(ob2,'Triple Space 1x2°1x2°1x2 @ Sz,Sx,Sy',{3.121212,'Sz','Sx','Sy'});
            
            ob2 = mitem(ob1,'More Tests on Triple Space');
               ob3 = mitem(ob2,'Triple Space 1x2°2x1°1x2 @ Sz,Sz,Sz',{3.122112,'Sz','Sz','Sz'});
               ob3 = mitem(ob2,'Triple Space 2x1°1x2°2x1 @ Sz,Sz,Sz',{3.211221,'Sz','Sz','Sz'});
               ob3 = mitem(ob2,'-');
               ob3 = mitem(ob2,'Triple Space 1x2°2x1°1x2 @ Sx,Sx,Sx',{3.122112,'Sx','Sx','Sx'});
               ob3 = mitem(ob2,'Triple Space 2x1°1x2°2x1 @ Sx,Sx,Sx',{3.211221,'Sx','Sx','Sx'});
               ob3 = mitem(ob2,'-');
               ob3 = mitem(ob2,'Triple Space 1x2°2x1°1x2 @ Sy,Sy,Sy',{3.122112,'Sy','Sy','Sy'});
               ob3 = mitem(ob2,'Triple Space 2x1°1x2°2x1 @ Sy,Sy,Sy',{3.211221,'Sy','Sy','Sy'});
               ob3 = mitem(ob2,'-');

      case 1.1
         Eval('H = space(toy,''spin'');     %% create a spin space');
         Eval('Sz = operator(H,''Sz'');     %% get spin operator Sz');
         Print
         Disp('Create extened ''Sz space''');
         Print
         Eval('X = space(H,Sz);           %% construct a Sz based extended space');
         Eval('disp(labels(X));           %% display labels');
         Eval('disp(matrix(X));           %% display eigen vector matrix');
         Print;
         Disp('Perform eigen vector tests');
         Print
         Eval('N = Sz*ket(X,{-1}) - (-1)*ket(X,{-1});  %% must be null operator');
         evalin('base','assert(property(N,''null?''));');
         Eval('N = Sz*ket(X,{+1}) - (+1)*ket(X,{+1});  %% must be null operator');
         evalin('base','assert(property(N,''null?''));');
         
      case 1.2
         Eval('H = space(toy,''spin'');     %% create a spin space');
         Eval('Sx = operator(H,''Sx'');     %% get spin operator Sx');
         Print
         Disp('Create extened ''Sx space''');
         Print
         Eval('X = space(H,Sx);           %% construct a Sx based extended space');
         Eval('disp(labels(X));           %% display labels');
         Eval('disp(matrix(X));           %% display eigen vector matrix');
         Print;
         Disp('Perform eigen vector tests');
         Print
         Eval('N = Sx*ket(X,{-1}) - (-1)*ket(X,{-1});  %% must be null operator');
         evalin('base','assert(property(N,''null?''));');
         Eval('N = Sx*ket(X,{+1}) - (+1)*ket(X,{+1});  %% must be null operator');
         evalin('base','assert(property(N,''null?''));');
         
      case 1.3
         Eval('H = space(toy,''spin'');     %% create a spin space');
         Eval('Sy = operator(H,''Sy'');     %% get spin operator Sy');
         Print
         Disp('Create extened ''Sy space''');
         Print
         Eval('X = space(H,Sy);           %% construct a Sy based extended space');
         Eval('disp(labels(X));           %% display labels');
         Eval('disp(matrix(X));           %% display eigen vector matrix');
         Print;
         Disp('Perform eigen vector tests');
         Print
         Eval('N = Sy*ket(X,{-1}) - (-1)*ket(X,{-1});  %% must be null operator');
         evalin('base','assert(property(N,''null?''));');
         Eval('N = Sy*ket(X,{+1}) - (+1)*ket(X,{+1});  %% must be null operator');
         evalin('base','assert(property(N,''null?''));');

      case 2.2121
         TwinSpaceTests(obj,'twin2121');         
      case 2.2112
         TwinSpaceTests(obj,'twin2112');         
      case 2.1221
         TwinSpaceTests(obj,'twin1221');         
      case 2.1212
         TwinSpaceTests(obj,'twin1212');         
         
      case 3.212121
         TripleSpaceTests(obj,'triple212121');         
      case 3.212112
         TripleSpaceTests(obj,'triple212112');         
      case 3.211221
         TripleSpaceTests(obj,'triple211221');         
      case 3.211212
         TripleSpaceTests(obj,'triple211212');
         
      case 3.122121
         TripleSpaceTests(obj,'triple122121');         
      case 3.122112
         TripleSpaceTests(obj,'triple122112');         
      case 3.121221
         TripleSpaceTests(obj,'triple121221');         
      case 3.121212
         TripleSpaceTests(obj,'triple121212');
         
   end
   return
end

%==========================================================================
% Twin Space Tests
%==========================================================================

function TwinSpaceTests(obj,kind)
%
% TWIN-SPACE-TESTS  Perform twin space tests
%
%    TwinSpaceTests(obj,'twin2121');
%    TwinSpaceTests(obj,'twin2112');
%    TwinSpaceTests(obj,'twin1221');
%    TwinSpaceTests(obj,'twin1212');
%
   Op1 = arg(obj,2);  Op2 = arg(obj,3);
   
   Eval(['H = space(toy,''',kind,''');     %% create a twin space']);
   
   Eval('list = property(H,''list'');     %% get list of spaces');
   Eval([Op1,'1 = operator(list{1},''',Op1,''');  %% get spin operator ',Op1,'1']);
   Eval([Op2,'2 = operator(list{2},''',Op2,''');  %% get spin operator ',Op2,'2']);
   Eval('IA = eye(list{1});               %% identity operators on 1st space');
   Eval('IB = eye(list{2});               %% identity operators on 2nd space');
   Print
   Disp(['Create extened ''',Op1,'1°',Op2,'2 space''']);
   Eval(['X = space(H,',Op1,'1,',Op2,'2);    %% construct an extended space']);
   Print;
   Disp('Perform eigen vector tests: {-1,-1}');
   Print
   Eval('V = ket(X,{-1,-1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB)*V - (-1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2)*V - (-1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;
   Disp('Perform eigen vector tests: {-1,+1}');
   Print
   Eval('V = ket(X,{-1,+1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB)*V - (-1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2)*V - (+1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;
   Disp('Perform eigen vector tests: {+1,-1}');
   Print
   Eval('V = ket(X,{+1,-1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB)*V - (+1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2)*V - (-1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;
   Disp('Perform eigen vector tests: {+1,+1}');
   Print
   Eval('V = ket(X,{+1,+1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB)*V - (+1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2)*V - (+1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print
   Eval('disp(labels(X));               %% display labels');
   Eval('disp(reshape(space(X),labels(X)));  %% display reshaped labels');
   Eval('disp(matrix(X));               %% display eigen vector matrix');
   return
end

%==========================================================================
% Triple Space Tests
%==========================================================================

function TripleSpaceTests(obj,kind)
%
% TWIN-SPACE-TESTS  Perform twin space tests
%
%    TripleSpaceTests(obj,'triple212121');
%    TripleSpaceTests(obj,'triple212112');
%    TripleSpaceTests(obj,'triple211221');
%    TripleSpaceTests(obj,'triple211212');
%    TripleSpaceTests(obj,'triple122121');
%    TripleSpaceTests(obj,'triple122112');
%    TripleSpaceTests(obj,'triple121221');
%    TripleSpaceTests(obj,'triple121212');
%
   Op1 = arg(obj,2);  Op2 = arg(obj,3);  Op3 = arg(obj,4);
   
   Eval(['H = space(toy,''',kind,''');     %% create a twin space']);
   
   Eval('list = property(H,''list'');     %% get list of spaces');
   Eval([Op1,'1 = operator(list{1},''',Op1,''');  %% get spin operator ',Op1,'1']);
   Eval([Op2,'2 = operator(list{2},''',Op2,''');  %% get spin operator ',Op2,'2']);
   Eval([Op3,'3 = operator(list{3},''',Op3,''');  %% get spin operator ',Op3,'3']);
   Eval('IA = eye(list{1});               %% identity operators on 1st space');
   Eval('IB = eye(list{2});               %% identity operators on 2nd space');
   Eval('IC = eye(list{3});               %% identity operators on 3rd space');
   Print
   Disp(['Create extened ''',Op1,'1°',Op2,'2°',Op3,'3 space''']);
   Print;
   Eval(['X = space(H,',Op1,'1,',Op2,'2,',Op3,'3);   %% construct an extended space']);
   Print
   
   Disp('Perform eigen vector tests: {-1,-1,-1}');
   Print
   Eval('V = ket(X,{-1,-1,-1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB.*IC)*V - (-1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2.*IC)*V - (-1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*IB.*',Op3,'3)*V - (-1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;

   Disp('Perform eigen vector tests: {-1,-1,+1}');
   Print
   Eval('V = ket(X,{-1,-1,+1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB.*IC)*V - (-1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2.*IC)*V - (-1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*IB.*',Op3,'3)*V - (+1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;
   
   Disp('Perform eigen vector tests: {-1,+1,-1}');
   Print
   Eval('V = ket(X,{-1,+1,-1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB.*IC)*V - (-1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2.*IC)*V - (+1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*IB.*',Op3,'3)*V - (-1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;
   
   Disp('Perform eigen vector tests: {-1,+1,+1}');
   Print
   Eval('V = ket(X,{-1,+1,+1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB.*IC)*V - (-1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2.*IC)*V - (+1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*IB.*',Op3,'3)*V - (+1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;

      % next 4 tests
      
   Disp('Perform eigen vector tests: {+1,-1,-1}');
   Print
   Eval('V = ket(X,{+1,-1,-1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB.*IC)*V - (+1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2.*IC)*V - (-1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*IB.*',Op3,'3)*V - (-1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;
   
   Disp('Perform eigen vector tests: {+1,-1,+1}');
   Print
   Eval('V = ket(X,{+1,-1,+1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB.*IC)*V - (+1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2.*IC)*V - (-1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*IB.*',Op3,'3)*V - (+1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;
   
   Disp('Perform eigen vector tests: {+1,+1,-1}');
   Print
   Eval('V = ket(X,{+1,+1,-1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB.*IC)*V - (+1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2.*IC)*V - (+1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*IB.*',Op3,'3)*V - (-1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;
   
   Disp('Perform eigen vector tests: {+1,+1,+1}');
   Print
   Eval('V = ket(X,{+1,+1,+1});            %% get indexed basis vector');
   Eval(['N = (',Op1,'1.*IB.*IC)*V - (+1)*V;      %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*',Op2,'2.*IC)*V - (+1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Eval(['N = (IA.*IB.*',Op3,'3)*V - (+1)*V;     %% must be null operator']);
   evalin('base','assert(property(N,''null?''));');
   Print;
   
   Disp('Display egen vector matrix and labels');
   Print;
   Eval('disp(matrix(X));               %% display eigen vector matrix');
   Eval('disp(labels(X));               %% display labels');
   Eval('disp(reshape(space(X),labels(X)));  %% display reshaped labels');
   Print('Done!');   
   return
end