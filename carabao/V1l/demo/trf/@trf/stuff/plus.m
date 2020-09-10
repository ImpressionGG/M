function obj = plus(obj1,obj2)
%
% PLUS     Overloaded operator + for TFF objects (transfer functions)
%
%             G1 = tff(1,[1 1]);
%             G2 = tff([1 1/T1],[1 1/T2]);
%
%             G = G1 + G2;     % add transfer functions
%
%          See also: TFF, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if (~isa(obj2,'tff'))
      obj2 = tff(obj2);
   end
   
   G1 = data(obj1);
   G2 = data(obj2);
   G = tffadd(G1,G2);
   
   obj = tff(G);
%   