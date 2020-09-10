function toymodel(obj,varargin)
% 
% TOYMODEL   Toy Model Demos
%
%    Setup demo menu & handle menu callbacks of user defined menu items
%    The function needs creation and setup of a chameo object:
%
%       toymodel(tensor)              % open menu and add demo menus
%       toymodel(tensor,'Setup')      % add demo menus to existing menu
%       toymodel(tensor,func)         % handle callbacks
%
%          obj = gfo;                 % retrieve obj from menu's user data
%
%   See also: TENSOR, SHELL, MENU, GFO
%
   obj = navigation(obj,'Toy Models','Contextual');

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

   ob1 = mitem(obj,'Toy Models');
   men = mitem(ob1);
   
   sub = uimenu(men,LB,'Simple Detector');
   itm = uimenu(sub,LB,'Simple Detector Demo',CB,call('@SimpleDetector'),UD,'Demo');
         uimenu(sub,LB,'______________________________',EN,'off');   
   itm = uimenu(sub,LB,'Space Creation',CB,call('@SimpleDetector'),UD,1);
   itm = uimenu(sub,LB,'Tensor Space',CB,call('@SimpleDetector'),UD,2);
   itm = uimenu(sub,LB,'Location Shift Transformation',CB,call('@SimpleDetector'),UD,3);
   itm = uimenu(sub,LB,'Detector Toggle Transition',CB,call('@SimpleDetector'),UD,4);
   itm = uimenu(sub,LB,'Transition Operator',CB,call('@SimpleDetector'),UD,5);
   itm = uimenu(sub,LB,'Transition Chain',CB,call('@SimpleDetector'),UD,6);
   itm = uimenu(sub,LB,'Wave Packet',CB,call('@SimpleDetector'),UD,7);
   itm = uimenu(sub,LB,'Wave Packet Transition 1',CB,call('@SimpleDetector'),UD,8);

   sub = uimenu(men,LB,'Alpha Decay');
   itm = uimenu(sub,LB,'Space Creation',CB,call('@AlphaDecay'),UD,1);
   itm = uimenu(sub,LB,'Transition Operator',CB,call('@AlphaDecay'),UD,2);
   itm = uimenu(sub,LB,'Transition of Initial State',CB,call('@AlphaDecay'),UD,3);
   itm = uimenu(sub,LB,'Repeated Alpha Decay',CB,call('@AlphaDecay'),UD,4);
   itm = uimenu(sub,LB,'Alpha Recovery',CB,call('@AlphaDecay'),UD,5);

   sub = uimenu(men,LB,'Mach Zehnder Interferometer');
   itm = uimenu(sub,LB,'Space Creation',CB,call('@MachZehnder'),UD,1);
   itm = uimenu(sub,LB,'Transition Operator',CB,call('@MachZehnder'),UD,2);
   itm = uimenu(sub,LB,'Transition Chain',CB,call('@MachZehnder'),UD,3);
   itm = uimenu(sub,LB,'Use Special Vectors',CB,call('@MachZehnder'),UD,4);
   itm = uimenu(sub,LB,'Universe Creation',CB,call('@MachZehnder'),UD,5);
         uimenu(sub,LB,'______________________________',EN,'off');   
   itm = uimenu(sub,LB,'Family {Ye,Yf}',CB,call('@MachZehnder'),UD,6);

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
% Simple Detector Toy Model
%==========================================================================
   
function SimpleDetector(obj)
%      
% SIMPLE-DETECTOR
%
   TopicTask(obj);     % clear screen/command window & display topic/task 
   mode = arg(obj,1);
   switch mode
      case 'Demo'
         detector(obj,'Demo');
         
      case 1
         Print('Construct Detector Space D and Location Space L');
         Print;
         Eval('D = space([0;1])            %% detector space');
         Eval('L = space(-1:5)             %% location space');
         Print
         Eval('property(D,''labels'')')
         Eval('property(L,''labels'')')
         Print;
         return
      case 2
         Print('Construct Tensor space H = L°D');
         Print;
         Eval('D = space([0;1]);           %% detector space');
         Eval('L = space(-1:5);            %% location space');
         Eval('H = L .* D;                 %% H = L°D');
         Print
         Eval('property(H,''labels'')')
         Print;
         Eval('psi0 = ket(H,''0°0'')')
         Print;
         return

      case 3
         Eval('D = space([0;1]);           %% detector space');
         Eval('L = space(-1:5);            %% location space');
         Eval('H = L .* D;                 %% H = L°D');
         Print
         Eval('s0 = ket(L,''0'').*ket(D,''0'')    %% initial state');
         Print;
         Print('Define a forward shift operator on L');
         Print
         Eval('SL = operator(L,''>>'')       %% forward shift operator on L');
         Eval('S = SL.*eye(D)              %% forward shift operator on LD');
         Print
         Print('Transition')
         Print
         Eval('s1 = S*s0                      %% unitary transition');
         Eval('s2 = S*s1                      %% unitary transition');
         Eval('s3 = S*s2                      %% unitary transition');
         return

      case 4
         Eval('D = space([0;1]);              %% detector space');
         Eval('L = space(-1:5);               %% location space');
         Eval('H = space(L,D);                %% H = l°D');
         Print
         Print('Define a detector toggle operator on L');
         Print
         Eval('R = eye(H);                    %% start with identity matrix');
         Eval('R = matrix(R,{''2°0'',''2°0''},0);');
         Eval('R = matrix(R,{''2°1'',''2°1''},0);');
         Eval('R = matrix(R,{''2°1'',''2°0''},1);');
         Eval('R = matrix(R,{''2°0'',''2°1''},1);');
         Print
         Print('Transition')
         Print
         Eval('s10 = ket(L,''1'').*ket(D,''0'')    %% initial state');
         Eval('r10 = R*s10                     %% unitary transition');
         Eval('s20 = ket(L,''2'').*ket(D,''0'')    %% initial state');
         Eval('r20 = R*s20                     %% unitary transition');
         Eval('s21 = ket(L,''2'').*ket(D,''1'')    %% initial state');
         Eval('r21 = R*s21                     %% unitary transition');
         Print
         Eval('matrix(R)+0                     %% display transition matrix');
         return

      case 5
         Eval('D = space([0;1]);              %% detector space');
         Eval('L = space(-1:5);               %% location space');
         Eval('H = space(L,D);                %% H = l°D');
         Print
         Print('Define a forward shift operator on L');
         Print
         Eval('SL = operator(L,''forward'')   %% forward shift operator on L');
         Eval('S = SL.*eye(D)                 %% forward shift operator on LD');
         Print
         Print('Define a detector toggle operator on L');
         Print
         Eval('R = eye(H);                    %% start with identity matrix');
         Eval('R = matrix(R,{''2°0'',''2°0''},0);');
         Eval('R = matrix(R,{''2°1'',''2°1''},0);');
         Eval('R = matrix(R,{''2°1'',''2°0''},1);');
         Eval('R = matrix(R,{''2°0'',''2°1''},1);');
         Print
         Print('Total Transition')
         Print
         Eval('T = S*R                        %% total transition operator');
         Print
         Eval('s00 = ket(L,''0'').*ket(D,''0'')     %% initial state');
         Eval('s10 = T*s00');
         Eval('s20 = T*s10');
         Eval('s31 = T*s20');
         Eval('s41 = T*s31');
         Eval('s51 = T*s41');
         Eval('s61 = T*s51');
         Print
         Eval('s01 = T*s61');
         Eval('s11 = T*s01');
         Eval('s21 = T*s11');
         Eval('s30 = T*s21');
         Eval('s40 = T*s30');
         Eval('s50 = T*s40');
         Eval('s60 = T*s50');
         Eval('s00 = T*s60');
         Print
         Print('Unitarity of transition operator T');
         Print
         Eval('T''*T        %% expected to be the identity');
         Print
         return

      case 6
         Eval('D = space([0;1]);              %% detector space');
         Eval('L = space(-1:5);               %% location space');
         Eval('H = space(L,D);                %% H = L°D');
         Print
         Print('Define a forward shift operator on L');
         Print
         Eval('SL = operator(L,''forward'')     %% forward shift operator on L');
         Eval('S = SL.*eye(D)                 %% forward shift operator on LD');
         Print
         Print('Define a detector toggle operator on L');
         Print
         Eval('R = eye(H);                    %% start with identity matrix');
         Eval('R = matrix(R,{''2°0'',''2°0''},0);');
         Eval('R = matrix(R,{''2°1'',''2°1''},0);');
         Eval('R = matrix(R,{''2°1'',''2°0''},1);');
         Eval('R = matrix(R,{''2°0'',''2°1''},1);');
         Print
         Print('Total Transition Chain')
         Print
         Eval('T = S*R                        %% total transition operator');
         Print
         Eval('s0 = ket(L,''-1'').*ket(D,''0'') %% initial state');
         Eval('transition(T,s0,7)             %% display transition chain');
         Print
         Eval('s = transition(T,s0,7);        %% transition chain');
         Eval('transition(T,s,7)              %% transition chain');
         Print
         return

      case 7
         Eval('D = space([0;1]);              %% detector space');
         Eval('L = space(-1:5);               %% location space');
         Eval('H = space(L,D);                %% H = l°D');
         Print
         Print('Define a forward shift operator on L');
         Print
         Eval('SL = operator(L,''forward'')   %% forward shift operator on L');
         Eval('S = SL.*eye(D)                 %% forward shift operator on LD');
         Print
         Print('Define a detector toggle operator on L');
         Print
         Eval('R = eye(H);                    %% start with identity matrix');
         Eval('R = matrix(R,{''2°0'',''2°0''},0);');
         Eval('R = matrix(R,{''2°1'',''2°1''},0);');
         Eval('R = matrix(R,{''2°1'',''2°0''},1);');
         Eval('R = matrix(R,{''2°0'',''2°1''},1);');
         Print
         Print('Total Transition')
         Print
         Eval('T = S*R                        %% total transition operator');
         Print
         Eval('s01 = ket(L,1).*ket(D,1);            %% |-1°0>');
         Eval('s02 = ket(L,2).*ket(D,1);            %% |0°0>');
         Eval('s03 = ket(L,3).*ket(D,1);            %% |1°0>');
         Eval('s0=0.25*s01+0.5*s02+0.25*s03               %% initial state');
         Eval('s1=T*s0                                    %% transition');
         Eval('s2=T*s1                                    %% transition');
         Eval('s3=T*s2                                    %% transition');
         Eval('s4=T*s3                                    %% transition');
         Eval('s5=T*s4                                    %% transition');
         return

      case 8
         Eval('D = space([0;1]);              %% detector space');
         Eval('L = space(-1:5);               %% location space');
         Eval('H = space(L,D);                %% H = l°D');
         Print
         Print('Define a forward shift operator on L');
         Print
         Eval('SL = operator(L,''forward'')   %% forward shift operator on L');
         Eval('S = SL.*eye(D)                 %% forward shift operator on LD');
         Print
         Print('Define a detector toggle operator on L');
         Print
         Eval('R = eye(H);                    %% start with identity matrix');
         Eval('R = matrix(R,{''2°0'',''2°0''},0);');
         Eval('R = matrix(R,{''2°1'',''2°1''},0);');
         Eval('R = matrix(R,{''2°1'',''2°0''},1);');
         Eval('R = matrix(R,{''2°0'',''2°1''},1);');
         Print
         Print('Total Transition')
         Print
         Eval('T = S*R                        %% total transition operator');
         Print
         Eval('s01 = ket(L,1).*ket(D,1);      %% |-1°0>');
         Eval('s0 = ket(L,2).*ket(D,1);       %% |0°0>');
         Eval('s03 = ket(L,3).*ket(D,1);      %% |1°0>');
         Eval('s=0.25*s01+0.5*s02+0.25*s03    %% initial state');
         Print
         Print('Display transition chain')
         Print
         Eval('for (i=1:14) transition(T,s); s=transition(T,s); end');
         return
   end
   return
end

%==========================================================================
% Alpha Decay Toy Model
%==========================================================================
   
function AlphaDecay(obj)
%      
% ALPHA-DECAY
%
   TopicTask(obj);     % clear screen/command window & display topic/task 
   mode = arg(obj,1);
   switch mode
      case 1
         Print('Construct Location Space L');
         Print;
         Eval('L = space(-4:4)                   %% location space');
         Print
         Eval('property(S,''labels'')')
         Print;
         return

      case 2
         Eval('L = space(-4:4);                    %% location space');
         Print;
         Print('Define a forward shift operator on L');
         Print
         Eval('S = operator(L,''>>'')              %% forward shift operator on L');
         Print
         Print('Modify S to get the alpha decay transition Operator')
         Print
         Eval('alpha = 0.6; beta = sqrt(1-abs(alpha)^2); gamma = -beta; delta = alpha;');
         Eval('U = [alpha,beta; gamma,delta];');
         Eval('U''*U                                %% cherck unitarity of matrix U');
         Print
         Eval('T = S;                              %% use the shift operator as default');
         Eval('T = matrix(T,{''0'',''0''},alpha);  %% T|0>  = alpha*|0> + beta*|1>');
         Eval('T = matrix(T,{''1'',''0''},beta);   %% T|0>  = alpha*|0> + beta*|1>');
         Eval('T = matrix(T,{''0'',''-1''},gamma); %% T|-1> = gamma*|0> + delta*|1>');
         Eval('T = matrix(T,{''1'',''-1''},delta); %% T|-1> = gamma*|0> + delta*|1>');
         Print
         Eval('matrix(T)+0')
         Print('Check unitarity of T');
         Print
         Eval('T''*T                                %% unitary?');
         return

      case 3
         Eval('L = space(-4:4);                    %% location space');
         Eval('S = operator(L,''>>'')              %% forward shift operator on L');
         Print
         Print('Modify S to get the alpha decay transition Operator')
         Print
         Eval('alpha = 0.6; beta = sqrt(1-abs(alpha)^2); gamma = -beta; delta = alpha;');
         Eval('T = S;                              %% use the shift operator as default');
         Eval('T = matrix(T,{''0'',''0''},alpha);  %% T|0>  = alpha*|0> + beta*|1>');
         Eval('T = matrix(T,{''1'',''0''},beta);   %% T|0>  = alpha*|0> + beta*|1>');
         Eval('T = matrix(T,{''0'',''-1''},gamma); %% T|-1> = gamma*|0> + delta*|1>');
         Eval('T = matrix(T,{''1'',''-1''},delta); %% T|-1> = gamma*|0> + delta*|1>');
         Print
         Print('Transition of initial state');
         Print
         Eval('s = ket(L,''0'')                   %% initial state');
         Eval('transition(T,s)');
         Print
         Eval('transition(T,s,2)');
         Print
         Eval('transition(T,s,3)');
         return

      case 4
         Eval('L = space(-4:4);                    %% location space');
         Eval('S = operator(L,''>>'')              %% forward shift operator on L');
         Print
         Print('Modify S to get the alpha decay transition Operator')
         Print
         Eval('alpha = 0.6; beta = sqrt(1-abs(alpha)^2); gamma = -beta; delta = alpha;');
         Eval('T = S;                              %% use the shift operator as default');
         Eval('T = matrix(T,{''0'',''0''},alpha);  %% T|0>  = alpha*|0> + beta*|1>');
         Eval('T = matrix(T,{''1'',''0''},beta);   %% T|0>  = alpha*|0> + beta*|1>');
         Eval('T = matrix(T,{''0'',''-1''},gamma); %% T|-1> = gamma*|0> + delta*|1>');
         Eval('T = matrix(T,{''1'',''-1''},delta); %% T|-1> = gamma*|0> + delta*|1>');
         Print
         Eval('s = option(ket(L,''0''),''space'',1); %% initial state');
         Print
         Print('Repeated alpha decay');
         Print
         Eval('for (i=1:7) disp(info(s)); s=transition(T,s); end');
         Print
         return

      case 5
         Eval('L = space(-4:4);                    %% location space');
         Eval('S = operator(L,''>>'')              %% forward shift operator on L');
         Print
         Print('Modify S to get the alpha decay transition Operator')
         Print
         Eval('alpha = 0.6; beta = sqrt(1-abs(alpha)^2); gamma = -beta; delta = alpha;');
         Eval('T = S;                              %% use the shift operator as default');
         Eval('T = matrix(T,{''0'',''0''},alpha);  %% T|0>  = alpha*|0> + beta*|1>');
         Eval('T = matrix(T,{''1'',''0''},beta);   %% T|0>  = alpha*|0> + beta*|1>');
         Eval('T = matrix(T,{''0'',''-1''},gamma); %% T|-1> = gamma*|0> + delta*|1>');
         Eval('T = matrix(T,{''1'',''-1''},delta); %% T|-1> = gamma*|0> + delta*|1>');
         Print
         Eval('s = option(ket(L,''-4''),''space'',1); %% initial state');
         Print
         Print('Alpha recovery');
         Print
         Eval('for (i=1:7) disp(info(s)); s=transition(T,s); end');
         Print
         return
   end
   return
end

%==========================================================================
% Mach Zehnder Interferometer
%==========================================================================
   
function MachZehnder(obj)
%      
% MACH-ZEHNDER
%
   TopicTask(obj);     % clear screen/command window & display topic/task 
   mode = arg(obj,1);
   switch mode
      case 0
         global H T
         evalin('base','global H T');
         
         Print('Construct a Hilbert space H for Mach Zehnder Interferometer');
         Print('with vectors -1a .. 5e and -1b .. 5f, define special vectors');
         Print('1A .. 3A, 1B..3B, 4C,5C and 4D,5D. Setup a shift operatot T');
         Print('on H.');
         Print;
         
         list1 = {'-1a','0a','1c','2c','3c','4e','5e'};
         list2 = {'-1b','0b','1d','2d','3d','4f','5f'};
         
         L = space([list1;list2]);              % location space
         L = option(L,'space',1);               % setup spacing option

            % Use special vector setup
         
         L = setup(L,'1A',unit(+ket(L,'1c')+ket(L,'1d')));
         L = setup(L,'2A',unit(+ket(L,'2c')+ket(L,'2d')));
         L = setup(L,'3A',unit(+ket(L,'3c')+ket(L,'3d')));

         L = setup(L,'1B',unit(-ket(L,'1c')+ket(L,'1d')));
         L = setup(L,'2B',unit(-ket(L,'2c')+ket(L,'2d')));
         L = setup(L,'3B',unit(-ket(L,'3c')+ket(L,'3d')));

         L = setup(L,'4C',unit(+ket(L,'4e')+ket(L,'4f')));
         L = setup(L,'5C',unit(+ket(L,'5e')+ket(L,'5f')));

         L = setup(L,'4D',unit(-ket(L,'4e')+ket(L,'4f')));
         L = setup(L,'5D',unit(-ket(L,'5e')+ket(L,'5f')));

         H = L;                         % H is equal to the location space
         
            % Define a transition operator
            
         T = operator(H,'>>');          %% start with shift operator');
         T = T*T;                       %% square the shift operator');
         
         T = matrix(T,{'1c','0a'},1/sqrt(2));
         T = matrix(T,{'1d','0a'},1/sqrt(2));
         T = matrix(T,{'4e','3c'},1/sqrt(2));
         T = matrix(T,{'4f','3c'},1/sqrt(2));
         
         T = matrix(T,{'1c','0b'},-1/sqrt(2));
         T = matrix(T,{'1d','0b'},+1/sqrt(2));
         T = matrix(T,{'4e','3d'},-1/sqrt(2));
         T = matrix(T,{'4f','3d'},+1/sqrt(2));
         
         %transition(T,ket(L,1),7);
         %transition(T,ket(L,2),7);
         
         Print('labels(H)');
         disp(labels(H));

         Eval('transition(T,ket(H,''0a''),7)');
         Eval('transition(T,ket(H,''0b''),7)');
         Print
         return
         
      case 1
         Print('Construct Location Space L for Mach Zehnder Interferometer');
         Print;
         Eval('list1 = {''-1a'',''0a'',''1c'',''2c'',''3c'',''4e'',''5e''};');
         Eval('list2 = {''-1b'',''0b'',''1d'',''2d'',''3d'',''4f'',''5f''};');
         Eval('L = space([list1;list2]);            %% location space');
         Print
         Eval('property(L,''labels'')')
         Print;
         return

      case 2
         Print('Construct Location Space L for Mach Zehnder Interferometer');
         Print;
         Eval('list1 = {''-1a'',''0a'',''1c'',''2c'',''3c'',''4e'',''5e''};');
         Eval('list2 = {''-1b'',''0b'',''1d'',''2d'',''3d'',''4f'',''5f''};');
         Eval('L = space([list1;list2]);            %% location space');
         Print
         Print('Define a transition operator');
         Print
         Eval('T = operator(L,''>>'');                %% start with shift operator');
         Eval('T = T*T;                             %% square the shift operator');
         Eval('transition(T,ket(L,1),7)');
         Eval('transition(T,ket(L,2),7)');
         Print
         Eval('T = matrix(T,{''1c'',''0a''},1/sqrt(2));');
         Eval('T = matrix(T,{''1d'',''0a''},1/sqrt(2));');
         Eval('T = matrix(T,{''4e'',''3c''},1/sqrt(2));');
         Eval('T = matrix(T,{''4f'',''3c''},1/sqrt(2));');
         Print
         Eval('T = matrix(T,{''1c'',''0b''},-1/sqrt(2));');
         Eval('T = matrix(T,{''1d'',''0b''},+1/sqrt(2));');
         Eval('T = matrix(T,{''4e'',''3d''},-1/sqrt(2));');
         Eval('T = matrix(T,{''4f'',''3d''},+1/sqrt(2));');
         Print
         Eval('unitary = property(T,''unitary?'')     %% check unitarity');
         Print
         Eval('transition(T,ket(L,1),3)');
         Eval('transition(T,ket(L,2),3)');
         Print
         return

      case 3
         Print('Construct Location Space L for Mach Zehnder Interferometer');
         Print;
         Eval('list1 = {''-1a'',''0a'',''1c'',''2c'',''3c'',''4e'',''5e''};');
         Eval('list2 = {''-1b'',''0b'',''1d'',''2d'',''3d'',''4f'',''5f''};');
         Eval('L = space([list1;list2]);            %% location space');
         Print
         Print('Define a transition operator');
         Print
         Eval('T = operator(L,''>>'');                %% start with shift operator');
         Eval('T = T*T;                             %% square the shift operator');
         Eval('transition(T,ket(L,1),7)');
         Eval('transition(T,ket(L,2),7)');
         Print
         Eval('T = matrix(T,{''1c'',''0a''},1/sqrt(2));');
         Eval('T = matrix(T,{''1d'',''0a''},1/sqrt(2));');
         Eval('T = matrix(T,{''4e'',''3c''},1/sqrt(2));');
         Eval('T = matrix(T,{''4f'',''3c''},1/sqrt(2));');
         Print
         Eval('T = matrix(T,{''1c'',''0b''},-1/sqrt(2));');
         Eval('T = matrix(T,{''1d'',''0b''},+1/sqrt(2));');
         Eval('T = matrix(T,{''4e'',''3d''},-1/sqrt(2));');
         Eval('T = matrix(T,{''4f'',''3d''},+1/sqrt(2));');
         Print
         Eval('s = option(ket(L,''-1a''),''space'',1)    %% initial state ');
         Eval('for (i=1:8) transition(T,s); s = transition(T,s); end');
         Print
         Eval('s = option(ket(L,''-1b''),''space'',1)    %% initial state ');
         Eval('for (i=1:8) transition(T,s); s = transition(T,s); end');
         Print
         Eval('s = option(ket(L,''2c''),''space'',1)    %% initial state ');
         Eval('for (i=1:8) transition(T,s); s = transition(T,s); end');
         Print
         return

      case 4
         MachZehnderSetup(obj)
         Print
         Eval('transition(T,ket(L,''-1a''),8);  %% transition chain');
         Print
         Eval('transition(T,ket(L,''-1b''),8);  %% transition chain');
         Print
         return

      case 5
         MachZehnderSetup(obj)
         Print
         Print('Definition of splits');
         Print
         Eval('L = setup(L,''psi0'',ket(L,''0a''));');
         Eval('S0 = split(L,{''psi0'',''*''})');
         Eval('S1 = split(L,{''1c'',''1d'',''*''})');
         Eval('S2 = split(L,{''2c'',''2d'',''*''})');
         Print
         Print('Create a universe');
         Print
         Eval('U1 = T*S0*S1*S2;');
         Print
         Eval('C1 = chain(U1,''psi0'',''1c'',''2c'')');
         Eval('C2 = chain(U1,''psi0'',''1d'',''2d'')');
         Print
         Eval('A1 = split(L,{''1A'',''1B'',''*''})');
         Eval('A2 = split(L,{''2A'',''2B'',''*''})');
         Print
         Print('Create a universe');
         Print
         Eval('U2 = T*S0*A1*A2;');
         Print
         Eval('CA = chain(U2,''psi0'',''1A'',''2A'')');
         Eval('CB = chain(U2,''psi0'',''1B'',''2B'')');
         Print
         
      case 6  % Histories Yc, Yd
         global H T U S Yc Yd
         evalin('base','global H T U S Yc Yd');
         
         MachZehnder(arg(obj,{0}));       % setup space H, transition T

         S = split(H,{'0a','0b','1c','1d','2c','2d','3c','3d',...
                     '4C','4D','5C','5D','*'});

         S = split(H,{'0a','0b','1c','1d','2c','2d','3c','3d',...
                     '4e','4f','5e','5f','*'});
         Print
         Eval('U = T*S^6');
         
         %Yc = history(U,{'0a','1c','2c','3c','4C','5C'});
         %Yd = history(U,{'0a','1d','2d','3d','4D','5D'});

         Yc = history(U,{'0a','1c','2c','3c','4e','5e'});
         Yd = history(U,{'0a','1d','2d','3d','4f','5f'});
         
         Eval('Yc');
         Eval('Yd');
   end
   return
end

%==========================================================================
% Mach Zehnder Setup
%==========================================================================

function MachZehnderSetup(obj)
%
% MACH-ZEHNDER-SETUP
%
   Print('Construct Location Space L for Mach Zehnder Interferometer');
   Print;
   Eval('list1 = {''-1a'',''0a'',''1c'',''2c'',''3c'',''4e'',''5e''};');
   Eval('list2 = {''-1b'',''0b'',''1d'',''2d'',''3d'',''4f'',''5f''};');
   Eval('L = space([list1;list2]);              %% location space');
   Eval('L = option(L,''space'',1);             %% setup spacing option');
   Print
   Print('Use special ket setup');
   Print
   Eval('L = setup(L,''1A'',unit(+ket(L,''1c'')+ket(L,''1d'')));');
   Eval('L = setup(L,''2A'',unit(+ket(L,''2c'')+ket(L,''2d'')));');
   Eval('L = setup(L,''3A'',unit(+ket(L,''3c'')+ket(L,''3d'')));');
   Print
   Eval('L = setup(L,''1B'',unit(-ket(L,''1c'')+ket(L,''1d'')));');
   Eval('L = setup(L,''2B'',unit(-ket(L,''2c'')+ket(L,''2d'')));');
   Eval('L = setup(L,''3B'',unit(-ket(L,''3c'')+ket(L,''3d'')));');
   Print
   Eval('L = setup(L,''4C'',unit(+ket(L,''4e'')+ket(L,''4f'')));');
   Eval('L = setup(L,''5C'',unit(+ket(L,''5e'')+ket(L,''5f'')));');
   Print
   Eval('L = setup(L,''4D'',unit(-ket(L,''4e'')+ket(L,''4f'')));');
   Eval('L = setup(L,''5D'',unit(-ket(L,''5e'')+ket(L,''5f'')));');
   Print
   Print('Define a transition operator');
   Print
   Eval('T = operator(L,''>>'');                %% start with shift operator');
   Eval('T = T*T;                             %% square the shift operator');
   Print
   Eval('T = matrix(T,{''1c'',''0a''},1/sqrt(2));');
   Eval('T = matrix(T,{''1d'',''0a''},1/sqrt(2));');
   Eval('T = matrix(T,{''4e'',''3c''},1/sqrt(2));');
   Eval('T = matrix(T,{''4f'',''3c''},1/sqrt(2));');
   Print
   Eval('T = matrix(T,{''1c'',''0b''},-1/sqrt(2));');
   Eval('T = matrix(T,{''1d'',''0b''},+1/sqrt(2));');
   Eval('T = matrix(T,{''4e'',''3d''},-1/sqrt(2));');
   Eval('T = matrix(T,{''4f'',''3d''},+1/sqrt(2));');
   Print
   Eval('transition(T,ket(L,1),7)');
   Eval('transition(T,ket(L,2),7)');
   Print
   return
end
