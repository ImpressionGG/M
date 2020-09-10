function contextual(obj,varargin)
% 
% CONTEXTUAL  Contextual dependency demos
%
%    Setup demo menu & handle menu callbacks of user defined menu items
%    The function needs creation and setup of a chameo object:
%
%       contextual(tensor)          % open menu and add demo menus
%       contextual(tensor,'Setup')  % add demo menus to existing menu
%       contextual(tensor,func)     % handle callbacks
%
%    See also   TENSOR, SHELL, MENU, GFO
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

   ob1 = mitem(obj,'Contextual');
   men = mitem(ob1);
   
   sub = uimenu(men,LB,'An Example');
   itm = uimenu(sub,LB,'Space Creation',CB,call('@AnExample'),UD,1);

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
      topic(arg1);  Disp(['§§',heading]);
   end
   return
end

%==========================================================================
% An Example
%==========================================================================
   
function AnExample(obj)
%      
% AN-EXAMPLE
%
   Disp(obj,'');
   mode = arg(obj,1);
   switch mode
      case 1
         Echo('Use a spin space with spin x and spin z projectors as a basis');
         Echo('Hilbert space H and consider the tensor product space L = H°H');
         Echo
         Eval('global H L IH IL A AN B BN');  
               global H L IH IL A AN B BN

         H = space({'z+','z-'});
         H = setup(H,'x+',unit(ket(H,'z+')+ket(H,'z-')));
         H = setup(H,'x-',unit(ket(H,'z+')-ket(H,'z-')));
         
         Echo
         Eval('disp(symbols(H))      %% basis Hilbert space');
         
         L = H.*H;
         L = setup(L,'x+°z-',unit(ket(H,'x+').*ket(H,'z-')));
         L = setup(L,'x-°z-',unit(ket(H,'x-').*ket(H,'z-')));

         Eval('disp(symbols(L))      %% tensor product space L = H°H');
         
         Echo
         Echo('Now define projectors A = [z+]°I, AN = I-A, B = [z+] and BN = I-B.');
         Echo
         
         A = projector(H,'z+').*eye(H);
         AN = eye(A) - A;
         B = eye(H).*projector(H,'z+');
         BN = eye(B) - B;

         Eval('A');
         Eval('AN');
         Eval('B');
         Eval('BN');
         return
   end
   return
end

