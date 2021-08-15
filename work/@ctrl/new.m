function oo = new(o,varargin)          % CTRL New Method              
%
% NEW   New CTRL object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(ctrl,'Motor')      % smotor example
%
%       See also: CTRL, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Motor,@Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Menu(o)                  % Setup Menu
   oo = mitem(o,'Motor (SS)',{@Callback,'Motor'},[]);
end
function oo = Callback(o)
   mode = arg(o,1);
   oo = new(o,mode);
   paste(o,oo);                        % paste object into shell
end

%==========================================================================
% New Motor Object
%==========================================================================

function oo = Motor(o)                 % New motor object
   J = 0.01;                           % kg*m^^2
   b = 0.1;                            % N*m/(rad/s)
   K = 0.01;                           % V/(rad/s)
   R = 1;                              % Ohm
   L = 0.5;                            % H
   
      % define state space matrices
      
   A = [-b/J K/J; -K/L -R/L];
   B = [0; 1/L];
   C = [1 0];
   D = [0];
   
   sys = ss(A,B,C,D);
   
      % pack into object

   oo = ctrl('ss');                    % state space type
   oo.par.title = 'Motor';
   oo.data.sys = sys;
end

