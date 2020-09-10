function obj = minus(obj1,obj2)
%
% MINUS   Overloaded operator - for TRF objects (transfer functions)
%
%             G1 = trf(1,[1 1]);
%             G2 = trf([1 1/T1],[1 1/T2]);
%
%             G = G1 - G2;     % subtract transfer functions
%
%          See also: TRF, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if (~isa(obj1,'trf'))
      obj1 = trf(obj1);
   end
   if (~isa(obj2,'trf'))
      obj2 = trf(obj2);
   end
   
   G1 = data(obj1);
   G2 = data(obj2);
   G = tffsub(G1,G2);
   
   obj = trf(G);
end