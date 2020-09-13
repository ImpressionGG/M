function probability(obj,varargin)
% 
% PROBABILITY  Probability Demos
%
%        Setup demo menu & handle menu callbacks of user defined menu items
%        The function needs creation and setup of a chameo object:
%
%             probability(tensor)         % open menu and add demo menus
%             probability(tensor,'Setup') % add demo menus to existing menu
%             probability(tensor,func)    % handle callbacks
%
%             obj = gfo;               % retrieve obj from menu's user data
%
%        See also   TENSOR, SHELL, MENU, GFO
%
   obj = navigation(obj,'Probability','Toy Models');

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
% SETUP       Setup the roll down menu for Alastair
%
   [LB,CB,UD,EN,CHK,CHKR,VI,CHC,CHCR,MF] = shortcuts(obj);

   ob1 = mitem(obj,'Probability');
   
   ob2 = mitem(ob1,'Born Rule');
   ob3 = mitem(ob2,'Weight Calculation',call,{'@BornRule',1});
   ob3 = mitem(ob2,'-');
   ob3 = mitem(ob2,'Wave Packet 1',call,{'@BornRule',2});
   ob3 = mitem(ob2,'Wave Packet 2',call,{'@BornRule',3});
   ob3 = mitem(ob2,'-');
   ob3 = mitem(ob2,'Probability Distribution',call,{'@BornRule',4});
   ob3 = mitem(ob2,'Odd Split',call,{'@BornRule',5});

   ob2 = mitem(ob1,'Chain Operator');
   ob3 = mitem(ob2,'Chain Operator Basics',call,{'@ChainOperator',0});
   ob3 = mitem(ob2,'Weight Calculation',call,{'@ChainOperator',1});
   
   return
end

%==========================================================================
% Born Rule Demos
%==========================================================================
   
function BornRule(obj)
%      
% BORN-RULE    Born rule demos
%
   TopicTask(obj);
   mode = arg(obj,1);
   switch mode
      case 1
         Print('Construct a Hilbert space H');
         Print;
         Eval('H = space(toy,[1 3 5; 2 4 6]);     %% our Hilbert space');
         Eval('labels(H)                          %% label matrix');
         Eval('T = operator(H,''>>'');              %% transition operator');
         Eval('psi0 = ket(H,''3'')               %% initial state');     
         Print
         Print('Assign a weight to the vector of interest according to Born rule;');
         Print
         Eval('disp(born(T,psi0,ket(H,''3'')))     %% assign Born weight');
         Eval('disp(born(T,psi0,ket(H,''4'')))     %% assign Born weight');
         Eval('disp(born(T,psi0,ket(H,''5'')))     %% assign Born weight');
         Eval('disp(born(T,psi0,ket(H,''6'')))     %% assign Born weight');
         Print
         Print('Define any ket vector of interest:');
         Print
         Eval('psi = unit(ket(H,''4'')+2*ket(H,''5''))  %% vector of interest');
         Print
         Eval('W = born(T,psi0,psi); disp(W)        %% assign Born weight');
         Eval('W = born(T*T,psi0,psi); disp(W)      %% assign Born weight');
         Print
         PlotBornRule(obj,1);                     % graphical display
         return

      case 2
         Eval('H = space(toy,[1 4 7; 2 5 8; 3 6 9]);  %% our Hilbert space');
         Eval('labels(H)                          %% label matrix');
         Eval('T = operator(H,''>>'');              %% transition operator');
         Print
         Eval('V1 = ket(H,''1'');                   %% auxillary vector');     
         Eval('V2 = ket(H,''2'');                   %% auxillary vector');     
         Eval('V3 = ket(H,''3'');                   %% auxillary vector');     
         Eval('V4 = ket(H,''4'');                   %% auxillary vector');     
         Eval('V5 = ket(H,''5'');                   %% auxillary vector');
         Eval('V6 = ket(H,''6'');                   %% auxillary vector');
         Eval('V7 = ket(H,''7'');                   %% auxillary vector');
         Print
         Eval('psi0 = unit(V1+2*V2+3*V3)          %% initial vector');     
         Eval('psi1 = unit(V5+2*V6+3*V7)          %% vector of interest');     
         Print
         Print('Assign a weight to the vector of interest according to Born rule;');
         Print
         Eval('disp(born(T,psi0,V1))              %% assign Born weight');
         Eval('disp(born(T,psi0,V2))              %% assign Born weight');
         Eval('disp(born(T,psi0,V3))              %% assign Born weight');
         Eval('disp(born(T,psi0,V4))              %% assign Born weight');
         Eval('disp(born(T,psi0,V5))              %% assign Born weight');
         Eval('disp(born(T,psi0,V6))              %% assign Born weight');
         Eval('disp(born(T,psi0,V7))              %% assign Born weight');
         Print
         PlotBornRule(obj,2);                     % graphical display
         return

      case 3
         Eval('H = space(toy,[1 4 7; 2 5 8; 3 6 9]);  %% our Hilbert space');
         Eval('labels(H)                          %% label matrix');
         Eval('T = operator(H,''>>'');              %% transition operator');
         Print
         Eval('V1 = ket(H,''1'');                   %% auxillary vector');     
         Eval('V2 = ket(H,''2'');                   %% auxillary vector');     
         Eval('V3 = ket(H,''3'');                   %% auxillary vector');     
         Eval('V5 = ket(H,''5'');                   %% auxillary vector');
         Eval('V6 = ket(H,''6'');                   %% auxillary vector');
         Eval('V7 = ket(H,''7'');                   %% auxillary vector');
         Print
         Eval('psi0 = unit(V1+2*V2+3*V3)          %% initial vector');     
         Eval('psi1 = unit(V5+2*V6+3*V7)          %% vector of interest');     
         Print
         Print('Assign a weight to the vector of interest according to Born rule;');
         Print
         Eval('disp(born(T^1,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^2,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^3,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^4,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^5,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^6,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^7,psi0,psi1))          %% assign Born weight');
         Print
         PlotBornRule(obj,3);                     % graphical display
         return

      case 4
         Print('Construct a Hilbert space H');
         Print;
         Eval('H = space(toy,[1 3 5; 2 4 6]);     %% our Hilbert space');
         Eval('labels(H)                          %% label matrix');
         Eval('T = operator(H,''>>'');              %% transition operator');
         Eval('V1 = ket(H,''1'');                   %% auxillary vector');     
         Eval('V2 = ket(H,''2'');                   %% auxillary vector');     
         Eval('V3 = ket(H,''3'');                   %% auxillary vector');     
         Eval('psi0 = unit(V1+2*V2+V3)            %% initial state');     
         Print
         Print('Construct a decomposition of the Hilbert space');
         Print
         Eval('S = split(H,labels(H))');
         Print
         Print('Calculate probabilities according to the Born rule;');
         Print
         Eval('p = born(T,psi0,S)                 %% assign Born weight');
         Print
         PlotBornRule(obj,4,{'[1]','[2]','[3]','[4]','[5]','[6]',''});                     % graphical display
         return

      case 5
         Print('Construct a Hilbert space H');
         Print;
         Eval('H = space(toy,[1 3 5; 2 4 6]);     %% our Hilbert space');
         Eval('labels(H)                          %% label matrix');
         Eval('T = operator(H,''>>'');              %% transition operator');
         Eval('V1 = ket(H,''1'');                   %% auxillary vector');     
         Eval('V2 = ket(H,''2'');                   %% auxillary vector');     
         Eval('V3 = ket(H,''3'');                   %% auxillary vector');     
         Eval('psi0 = unit(V1+2*V2+V3)            %% initial state');     
         Print
         Print('Construct an odd decomposition of the Hilbert space');
         Print
         Eval('S = split(H,{''1'',{''2'',''4''},''3'',{''5'',''6''}})');
         Print
         Print('Calculate probabilities according to the Born rule;');
         Print
         Eval('p = born(T,psi0,S)                 %% assign Born weight');
         Print
         PlotBornRule(obj,4,{'[1]','[2,4]','[3]','[5,6]',''});                     % graphical display
         return

   end
   return
end

%==========================================================================
% Plot Borne Rule
%==========================================================================

function PlotBornRule(obj,mode,xticks)
%
% PLOT-BORN-RULE
%
   TopicTask(obj);
   switch mode
      case 1
         cls;    % clear screen
         
         psi0 = evalin('base','psi0');
         psi = evalin('base','psi');
         T = evalin('base','T');
         
         y0 = psi0+0;  y0 = y0(:);
         y1 = psi+0;  y1 = y1(:);
         
         m = 2;  n = 2;  k = 0; delta = 0.1;
         idx = [1 3 2 4];
         for (j=1:n)
            for (i=1:m)
               k = k+1;
               y = T^(k-1)*psi0+0;  y = y(:);
               subplot(m,n,idx(k));
               hdl = stem((1:length(y0))-delta,y0,'k');  hold on;
               color(hdl,'y');
               stem((1:length(y)),y,'b');  
               stem((1:length(y1))+delta,y1,'r');  
               title(sprintf('born(T^%g,psi0,psi) = %g',k-1,born(T^(k-1),psi0,psi)));
               ylabel(sprintf('psi0 (g), T^%gpsi0 (b), psi (r)',k-1));
               set(gca,'xlim',[0 6]);
               set(gca,'xtick',0:6);
            end
         end
         %xlabel('psi0: gray, T^kpsi0: blue, psi1: red');
         shg;
         return

      case 2
         cls;    % clear screen
         
         psi0 = evalin('base','psi0');
         psi1 = evalin('base','psi1');
         T = evalin('base','T');
         
         y0 = psi0+0;  y0 = y0(:);
         y1 = T*psi0+0;  y1 = y1(:);
         
         m = 3;  n = 2;  k = 0; delta = 0.1;
         idx = [1 3 5 2 4 6];
         for (j=1:n)
            for (i=1:m)
               k = k+1;
               cmd = sprintf('V%g;',k);
               V = evalin('base',cmd);
               v = V+0;    v = v(:);
               subplot(m,n,idx(k));
               hdl = stem((1:length(y0))-delta,y0,'k');  hold on;
               color(hdl,'y');
               stem((1:length(y1)),y1,'b');  
               stem((1:length(v))+delta,v,'r');  
               title(sprintf('born(T,psi0,V%g) = %g',k,born(T,psi0,V)));
               ylabel(sprintf('psi0, T*psi0, V%g',k));
               set(gca,'xlim',[0 10]);
               set(gca,'xtick',0:10);
            end
         end
         shg;
         return
   
      case 3
         cls;    % clear screen
         
         psi0 = evalin('base','psi0');
         psi1 = evalin('base','psi1');
         T = evalin('base','T');
         
         y0 = psi0+0;  y0 = y0(:);
         y1 = psi1+0;  y1 = y1(:);
         
         m = 3;  n = 2;  k = 0; delta = 0.1;
         idx = [1 3 5 2 4 6];
         for (j=1:n)
            for (i=1:m)
               k = k+1;
               y = T^k*psi0+0;  y = y(:);
               subplot(m,n,idx(k));
               hdl = stem((1:length(y0))-delta,y0,'k');  hold on;
               color(hdl,'y');
               stem((1:length(y)),y,'b');  
               stem((1:length(y1))+delta,y1,'r');  
               title(sprintf('born(T^%g,psi0,psi1) = %g',k,born(T^k,psi0,psi1)));
               ylabel(sprintf('psi0, T^%g*psi0, psi1',k));
               set(gca,'xlim',[0 10]);
               set(gca,'xtick',0:10);
            end
         end
         shg;
         return

      case 4
         cls;    % clear screen
         
         psi0 = evalin('base','psi0');
         psi = evalin('base','psi');
         T = evalin('base','T');
         p = evalin('base','p');
         
         y0 = psi0+0;  y0 = y0(:);
         y1 = psi+0;  y1 = y1(:);
         
         m = 2;  n = 1;  k = 0; delta = 0.1;
         idx = [1 2];

         y = T^(k-1)*psi0+0;  y = y(:);
         subplot(2,1,1);
         stem((1:6)-delta,ones(1,6)/6,'g');        hold on;
         hdl = stem((1:length(y0))-delta,y0,'k');  hold on;
         color(hdl,'y');
         stem((1:length(y)),y,'b');  
         title(sprintf('born(T,psi0,psi) = %g',born(T^(k-1),psi0,psi)));
         ylabel(sprintf('psi0 (y), T*gpsi0 (b)'));
         set(gca,'xlim',[0 6]);
         set(gca,'xtick',0:6);

         subplot(2,1,2);
         delta = 0.05;
         stem((1:length(p(:)))+delta,p(:),'m');  hold on;
         ylabel(sprintf('S (g), probability (m)'));
         set(gca,'xlim',[0 length(xticks)],'ylim',[0 1]);
         set(gca,'xtick',1:length(xticks));
         set(gca,'xticklabel',xticks);
         
         %xlabel('psi0: gray, T^kpsi0: blue, psi1: red');
         shg;
         return

   end
   return
end

%==========================================================================
% Chain Operator
%==========================================================================
   
function ChainOperator(obj)
%      
% CHAIN-OPERATOR    Chain operator rule demos
%
   TopicTask(obj);
   mode = arg(obj,1);
   switch mode
      case 0
         Disp('Construct a Hilbert space H');
         Print;
         Eval('H = space(toy,[1 3 5; 2 4 6]);  %% our Hilbert space');
         Eval('H = setup(H,''psi0'',ket(H,''3''))');
         Eval('H = setup(H,''psi'',unit(ket(H,''4'')+2*ket(H,''5'')))');
         Print
         Eval('labels(H)                          %% label matrix');
         Eval('T = operator(H,''>>'');            %% transition operator');
         Print
         Disp('Chain operator calculation based on projectors');
         Print
         Eval('Psi0 = projector(H,''psi0'')       %% initial projector');     
         Eval('P4  = projector(H,''4'')');
         Eval('P56 = projector(H,{''5'',''6''})');
         Print
         Eval('C1 = chain(T,Psi0,P4,P56)');
         Print
         Disp('Alternative way: chain operator calculation based on labels');
         Print
         Eval('C2 = chain(T,''psi0'',''4'',''5,6'');');
         Eval('C2-C1');
         Print
         Eval('C3 = chain(T,''psi0'',''4'',{''5'',''6''});');
         Eval('C3-C1');
         Print
         
      case 1
         Disp('Construct a Hilbert space H');
         Print;
         Eval('H = space(toy,[1 3 5; 2 4 6]);  %% our Hilbert space');
         Eval('H = setup(H,''psi0'',vector(H,''3''))');
         Eval('H = setup(H,''psi'',unit(ket(H,''4'')+2*ket(H,''5'')))');
         Print
         Eval('labels(H)                          %% label matrix');
         Eval('T = operator(H,''>>'');              %% transition operator');
         Eval('psi0 = vector(H,''psi0'')            %% initial state');     
         Print
         Disp('Assign a weight to the vector of interest according to Born rule;');
         Print
         Eval('disp(born(T,psi0,vector(H,''3'')))     %% assign Born weight');
         Eval('disp(born(T,psi0,vector(H,''4'')))     %% assign Born weight');
         Eval('disp(born(T,psi0,vector(H,''5'')))     %% assign Born weight');
         Eval('disp(born(T,psi0,vector(H,''6'')))     %% assign Born weight');
         Print
         Disp('Define any vector of interest:');
         Print
         Eval('psi = vector(H,''psi'')              %% vector of interest');
         Print
         Eval('Psi0 = projector(H,''psi0'')');
         Eval('Psi  = projector(H,''psi'')');
         Print
         Eval('W1 = born(T,psi0,psi); disp(W1)       %% assign Born weight');
         Eval('C1 = chain(T,Psi0,Psi)                %% chain operator');
         Eval('W1 = norm(C1)^2; disp(W1);            %% weight by chain operator');
         Eval('C1 = chain(T,''psi0'',''psi'')            %% chain operator');
         Eval('W1 = norm(C1)^2; disp(W1);            %% weight by chain operator');
         Print
         Eval('W2 = born(T*T,psi0,psi); disp(W2)     %% assign Born weight');
         Eval('C2 = chain(T*T,Psi0,Psi)              %% chain operator');
         Eval('W2 = norm(C2)^2; disp(W2);            %% weight by chain operator');
         Eval('C2 = chain(T*T,''psi0'',''psi'')          %% chain operator');
         Eval('W2 = norm(C2)^2; disp(W2);            %% weight by chain operator');
         Print
         PlotChainOperator(obj,1);                     % graphical display
         return

      case 2
         Eval('H = space(toy,[1 4 7; 2 5 8; 3 6 9]);  %% our Hilbert space');
         Eval('labels(H)                          %% label matrix');
         Eval('T = operator(H,''>>'');              %% transition operator');
         Print
         Eval('V1 = vector(H,''1'');                %% auxillary vector');     
         Eval('V2 = vector(H,''2'');                %% auxillary vector');     
         Eval('V3 = vector(H,''3'');                %% auxillary vector');     
         Eval('V4 = vector(H,''4'');                %% auxillary vector');     
         Eval('V5 = vector(H,''5'');                %% auxillary vector');
         Eval('V6 = vector(H,''6'');                %% auxillary vector');
         Eval('V7 = vector(H,''7'');                %% auxillary vector');
         Print
         Eval('psi0 = normalize(V1+2*V2+3*V3)     %% initial vector');     
         Print
         Print('Assign a weight to the vector of interest according to Born rule;');
         Print
         Eval('disp(born(T,psi0,V1))              %% assign Born weight');
         Eval('disp(born(T,psi0,V2))              %% assign Born weight');
         Eval('disp(born(T,psi0,V3))              %% assign Born weight');
         Eval('disp(born(T,psi0,V4))              %% assign Born weight');
         Eval('disp(born(T,psi0,V5))              %% assign Born weight');
         Eval('disp(born(T,psi0,V6))              %% assign Born weight');
         Eval('disp(born(T,psi0,V7))              %% assign Born weight');
         Print
         PlotChainOperator(obj,2);                     % graphical display
         return

      case 3
         Eval('H = space(toy,[1 4 7; 2 5 8; 3 6 9]);  %% our Hilbert space');
         Eval('labels(H)                          %% label matrix');
         Eval('T = operator(H,''>>'');              %% transition operator');
         Print
         Eval('V1 = vector(H,''1'');                %% auxillary vector');     
         Eval('V2 = vector(H,''2'');                %% auxillary vector');     
         Eval('V3 = vector(H,''3'');                %% auxillary vector');     
         Eval('V5 = vector(H,''5'');                %% auxillary vector');
         Eval('V6 = vector(H,''6'');                %% auxillary vector');
         Eval('V7 = vector(H,''7'');                %% auxillary vector');
         Print
         Eval('psi0 = unit(V1+2*V2+3*V3)     %% initial vector');     
         Eval('psi1 = unit(V5+2*V6+3*V7)     %% vector of interest');     
         Print
         Print('Assign a weight to the vector of interest according to Born rule;');
         Print
         Eval('disp(born(T^1,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^2,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^3,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^4,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^5,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^6,psi0,psi1))          %% assign Born weight');
         Eval('disp(born(T^7,psi0,psi1))          %% assign Born weight');
         Print
         PlotChainOperator(obj,3);                     % graphical display
         return
   end
   return
end

%==========================================================================
% Plot Chain Operator Demos
%==========================================================================

function PlotChainOperator(obj,mode)
%
% PLOT-BORN-RULE
%
   TopicTask(obj);
   switch mode
      case 1
         cls;    % clear screen
         
         psi0 = evalin('base','psi0');
         psi = evalin('base','psi');
         T = evalin('base','T');
         
         y0 = psi0+0;  y0 = y0(:);
         y1 = psi+0;  y1 = y1(:);
         
         m = 2;  n = 2;  k = 0; delta = 0.1;
         idx = [1 3 2 4];
         for (j=1:n)
            for (i=1:m)
               k = k+1;
               y = T^(k-1)*psi0+0;  y = y(:);
               subplot(m,n,idx(k));
               hdl = stem((1:length(y0))-delta,y0,'k');  hold on;
               color(hdl,0.9*[1 1 1]);
               stem((1:length(y)),y,'b');  
               stem((1:length(y1))+delta,y1,'r');  
               title(sprintf('born(T^%g,psi0,psi) = %g',k-1,born(T^(k-1),psi0,psi)));
               ylabel(sprintf('psi0 (g), T^%gpsi0 (b), psi (r)',k-1));
               set(gca,'xlim',[0 6]);
               set(gca,'xtick',0:6);
            end
         end
         %xlabel('psi0: gray, T^kpsi0: blue, psi1: red');
         shg;
         return

      case 2
         cls;    % clear screen
         
         psi0 = evalin('base','psi0');
         psi1 = evalin('base','psi1');
         T = evalin('base','T');
         
         y0 = psi0+0;  y0 = y0(:);
         y1 = T*psi0+0;  y1 = y1(:);
         
         m = 3;  n = 2;  k = 0; delta = 0.1;
         idx = [1 3 5 2 4 6];
         for (j=1:n)
            for (i=1:m)
               k = k+1;
               cmd = sprintf('V%g;',k);
               V = evalin('base',cmd);
               v = V+0;    v = v(:);
               subplot(m,n,idx(k));
               hdl = stem((1:length(y0))-delta,y0,'k');  hold on;
               color(hdl,0.9*[1 1 1]);
               stem((1:length(y1)),y1,'b');  
               stem((1:length(v))+delta,v,'r');  
               title(sprintf('born(T,psi0,V%g) = %g',k,born(T,psi0,V)));
               ylabel(sprintf('psi0, T*psi0, V%g',k));
               set(gca,'xlim',[0 10]);
               set(gca,'xtick',0:10);
            end
         end
         shg;
         return
   
      case 3
         cls;    % clear screen
         
         psi0 = evalin('base','psi0');
         psi1 = evalin('base','psi1');
         T = evalin('base','T');
         
         y0 = psi0+0;  y0 = y0(:);
         y1 = psi1+0;  y1 = y1(:);
         
         m = 3;  n = 2;  k = 0; delta = 0.1;
         idx = [1 3 5 2 4 6];
         for (j=1:n)
            for (i=1:m)
               k = k+1;
               y = T^k*psi0+0;  y = y(:);
               subplot(m,n,idx(k));
               hdl = stem((1:length(y0))-delta,y0,'k');  hold on;
               color(hdl,0.9*[1 1 1]);
               stem((1:length(y)),y,'b');  
               stem((1:length(y1))+delta,y1,'r');  
               title(sprintf('born(T^%g,psi0,psi1) = %g',k,born(T^k,psi0,psi1)));
               ylabel(sprintf('psi0, T^%g*psi0, psi1',k));
               set(gca,'xlim',[0 10]);
               set(gca,'xtick',0:10);
            end
         end
         shg;
         return

   end
   return
end