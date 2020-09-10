function o = system(o,A,B,C,D,T)
%
% SYSTEM   Setup a system for simulation
%
%             o = system(o,A,B,C,D)    % continuous state space system
%             o = system(o,A,B,C,D,T)  % dscrete state space system
%            
%          Remark:
%             
%             Discrete state space systems will be marked with type 'dss'
%             and continuous state space systems will be marked with type 
%             'css'
%
%          See also: SIMU
%
   o.argcheck(3,6,nargin);
   
   if (nargin < 4)
      C = [];  D = [];
   elseif (nargin < 5)
      D = zeros(size(C,1),size(B,2));
   end
   
   abcdcheck(o,A,B,C,D);
   
   if (nargin == 6)
      o = type(o,'dss');
      o = set(o,'system','A,B,C,D,T', A,B,C,D,T);
      o.data = [];
   else
      o = type(o,'css');
      o = set(o,'system', 'A,B,C,D', A,B,C,D);
      o.data = [];
   end
end