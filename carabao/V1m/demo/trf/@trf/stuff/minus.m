function obj = minus(obj1,obj2)
%
% MINUS    Overloaded operator - for TFF objects (transfer functions)
%
%             G1 = tff(1,[1 1]);
%             G2 = tff([1 1/T1],[1 1/T2]);
%
%             G = G1 - G2;     % subtract transfer functions
%
%          See also: TFF, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if (~isa(obj2,'tff'))
      obj2 = tff(obj2);
   end

   G1 = data(obj1);
   G2 = data(obj2);
   G = tffsub(G1,G2);
   
   obj = tff(G);
%   