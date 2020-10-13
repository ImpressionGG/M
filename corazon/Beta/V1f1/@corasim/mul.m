function z = mul(o,x,y)                % Multiply Polynomials          
%
% MUL   Multiply polynomials
%
%          z = mul(o,x,y);
%          z = mul(o,[2 3],[1 5 6]);
%          z = mul(o,[1 5 6],[2 3]);
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORASIM, ADD, SUB, MUL, DIV, TRIM, CAN
%
   z = conv(x,y);
   
   idx = find(z~=0);
   if isempty(idx)
      z = 0;
   else
      z = z(idx(1):end);
   end
end
