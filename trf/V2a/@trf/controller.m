function oo = controller(o,varargin)   % Controller Method
%
% CONTROLLER   Create a new controller pbject
%
%           controller(o,'P')          % create P controller
%           controller(o,'PI')         % create PI controller
%           controller(o,'PD')         % create PD controller
%           controller(o,'PID')        % create PID controller
%
   [gamma,oo] = manage(o,varargin,@Controller,@P,@PI,@PD,@PID);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Controller(o)            % Controller Menu Setup              
   oo = mitem(o,'Controller');
   ooo = mitem(oo,'P Controller',{@P});
   ooo = mitem(oo,'PI Controller',{@PI});
   ooo = mitem(oo,'PD Controller',{@PD});
   ooo = mitem(oo,'PID Controller',{@PID});
end

%==========================================================================
% Actual Controller Creation
%==========================================================================

function oo = P(o)                     % New P Controller            
%
% P   Create a P controller transfer function 
%                  
%          R(s) = K                    % K = 1
%
   [K] = get(o,{'K',1});
   oo = trf(K,1);
   
   oo = set(oo,'K',K);
   oo = set(oo,'edit',{{'Gain K','K'}});
   
   head = 'P(s) = K';
   params = sprintf('K = %g',K);
   oo = finish(o,oo,'P Controller',{head,params},'g');
end
function oo = PD(o)                    % New PD Controller            
%
% PD   Create a PD controller transfer function 
%                              s*Td
%          R(s) = K * [ 1 + ------------ ]
%                            (1 + s*Tr)
%
%          K = 1, Td = 0.2, Tr = 0.02
%
   [K,Td,Tr] = get(o,{'K',1},{'Td',0.2},{'Tr',0.02});
   oo = K * [1 + trf([Td 0],[Tr 1])];
   
   oo = set(oo,'K',K,'Td',Td,'Tr',Tr);
   oo = set(oo,'edit',{{'Gain K','K'},...
                       {'Differentiation Constant Td','Td'},...
                       {'Realisation Constant Tr','Tr'}});
   
   head = 'PD(s) = K * [1 + s*Td/(1+s*Tr)]';
   params = sprintf('K = %g, Td = %g, Tr = %g',K,Td,Tr);
   oo = finish(o,oo,'PD Controller',{head,params},'g');
end
function oo = PI(o)                    % New PI Controller            
%
% PI   Create a PI controller transfer function 
%                             1
%          R(s) = K * [ 1 + ------ ]
%                            s*Ti
%
%          K = 1, Ti = 2
%
   [K,Ti] = get(o,{'K',1},{'Ti',2});
   oo = K * [1 + trf(1,[Ti 0])];
   
   oo = set(oo,'K',K,'Ti',Ti);
   oo = set(oo,'edit',{{'Gain K','K'},{'Integration Constant Ti','Ti'}});
   
   head = 'PI(s) = K * [1 + 1/(s*Ti)]';
   params = sprintf('K = %g, Ti = %g',K,Ti);
   oo = finish(o,oo,'PI Controller',{head,params},'g');
end
function oo = PID(o)                   % New PID Controller            
%
% PID   Create a PID controller transfer function 
%                             1          s*Td
%          R(s) = K * [ 1 + ------ + ------------ ]
%                            s*Ti     (1 + s*Tr)
%
%          K = 1, Ti = 2, Td = 0.2, Tr = 0.02
%
   [K,Ti,Td,Tr] = get(o,{'K',1},{'Ti',2},{'Td',0.2},{'Tr',0.02});
   oo = K * [1 + trf(1,[Ti 0]) + trf([Td 0],[Tr 1])];
   
   oo = set(oo,'K',K,'Ti',Ti,'Td',Td,'Tr',Tr);
   oo = set(oo,'edit',{{'Gain K','K'},{'Integration Constant Ti','Ti'},...
                       {'Differentiation Constant Td','Td'},...
                       {'Realisation Constant Tr','Tr'}});
   
   head = 'PID(s) = K * [1 + 1/(s*Ti) + s*Td/(1+s*Tr)]';
   params = sprintf('K = %g, Ti = %g, Td = %g, Tr = %g',K,Ti,Td,Tr);
   oo = finish(o,oo,'PID Controller',{head,params},'g');
end
