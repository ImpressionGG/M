function z = sub(o,x,y)                % Add Polynomials               
%
% SUB   Subtract polynomials
%
%          z = sub(o,x,y);
%          z = sub(o,[2 3],[1 5 6]);
%          z = sub(o,[1 5 6],[2 3]);
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORASIM, ADD, SUB, MUL, DIV, TRIM, CAN
%
   nx = length(x);  ny = length(y);  n = max(nx,ny);
   z = [zeros(1,n-nx) x] - [zeros(1,n-ny) y];
   
   idx = find(z~=0);
   if isempty(idx)
      z = 0;
   else
      z = z(idx(1):end);
   end   
end
