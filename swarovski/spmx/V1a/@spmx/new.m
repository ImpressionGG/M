function oo = new(o,varargin)          % SPMX New Method              
%
% NEW   New SPMX object
%
%           oo = new(o,'Menu')         % menu setup
%
%           o = new(spmx,'Simple')    % some simple data
%           o = new(spmx,'Wave')      % some wave data
%           o = new(spmx,'Beat')      % some beat data
%
%       See also: SPMX, PLOT, ANALYSIS, STUDY
%
   [gamma,oo] = manage(o,varargin,@Mode3,@Academic,...
                       @Menu);
   oo = gamma(oo);
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = Callback(o)                                              
   mode = arg(o,1);
   oo = new(o,mode);
   paste(o,oo);                        % paste object into shell
end

function oo = Menu(o)                  % New Menu                      
%
% Menu   Setup New menu items
%
   oo = mitem(o,'-');
   oo = mhead(o,'Spm');
   ooo = mitem(oo,'Academic Sample',{@Create 'Academic'});
   ooo = mitem(oo,'3-Mode Sample',{@Create 'Mode3'});

   function o = Create(o)
      gamma = eval(['@',arg(o,1)]);
      oo = gamma(o);                   % create specific object
      paste(oo);                       % paste into shell
   end
end

%==========================================================================
% Menu Setup
%==========================================================================

function oo = OldAcademicSample(o)     % Academic Sample               
   omega = [1 2 3]';                   % circular eigen frequencies
   zeta = [0.1 0.15 0.2]';             % damping coefficients
   
   M = [0 -0.0072 -2.3e-11; 0.0071 0 1.8e-11; 4.2e-11 -7e-11 0];
   
      % calculate system matrices
      
   a0 = omega.*omega;                  % a0 = [1 4 9]
   a1 = 2*zeta.*omega;                 % a1 = [0.2 0.6 1.2]
   
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M];
   D = 0*M;

   oo = spm('spm');                    % new spm typed object
   oo.par.title = 'Academic Sample';
   oo.par.comment = {'A: 6x6, B: 6x3, C: 3x6, D:3x3',...
                     'omega = [1 2 3]'', zeta =[0.1 0.15 0.2]'''};
   
   oo = set(oo,'system','A,B,C,D',A,B,C,D);

   oo.data = [];                       % make a non-container object
   oo = brew(oo,'Data');               % brew up object data
   
   paste(o,oo);
end
function oo = Academic(o)              % Academic Sample               
%
% MODE3SAMPLE setup an 3-mode system according to the simulated sample
%             exported from ANSYS
%
   a0 = [7.8e6 47e6 225e6]';           % circular eigen frequencies
   a1 = [56 137 300]';                 % damping terms
   
   M = [0 -0.0072 -2.3e-11; 0.0071 0 1.8e-11; 4.2e-11 -7e-11 0];
   
      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M];
   D = 0*M;

   oo = spmx('spm');                   % new spm typed object
   oo.par.title = 'Academic Sample - 3 Modes';
   oo.par.comment = {'A: 6x6, B: 6x3, C: 3x6, D:3x3',...
                     'omega = [1 2 3]'', zeta =[0.1 0.15 0.2]'''};
   
      % finally set data
 
   oo = data(oo,'A,B,C,D',A,B,C,D);
end
function oo = Mode3(o)                 % 3-Mode Sample                 
%
% MODE3SAMPLE setup an 3-mode system according to the simulated sample
%             exported from ANSYS
%
   a0 = [7.8e6 47e6 225e6]';           % circular eigen frequencies
   a1 = [56 137 300]';                 % damping terms
   
   M = [0 -0.0072 -2.3e-11; 0.0071 0 1.8e-11; 4.2e-11 -7e-11 0];
   
      % calculate system matrices
         
   n = length(a0);
   A = [zeros(n) eye(n); -diag(a0) -diag(a1)];
   B = [0*M; M];
   C = [M' 0*M];
   D = 0*M;

   oo = spmx('spm');                   % new spm typed object
   oo.par.title = '3-Mode Sample';
    
      % finally set data
      
   oo = data(oo,'A,B,C,D',A,B,C,D);   
end
