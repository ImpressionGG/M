function [z,idx] = add(o,x,y)                % Add Polynomials               
%
% ADD   Add polynomials
%
%          z = add(o,x,y);
%          z = add(o,[2 3],[1 5 6]);
%          z = add(o,[1 5 6],[2 3]);
%
%       Remark: corasim/add overloads corazon/add, thus we have to delegate
%       the following call to corazon/add
%
%          [o,idx] = add(o,list)       % delegate to corazon/add
%  
%       Copyright(c): Bluenetics 2020
%
%       See also: CORASIM, ADD, SUB, MUL, DIV, TRIM, CAN
%
   if (nargin == 2)                    % delegate to corazon/add method
      [oo,idx] = add(corazon(o),x);    % delegate ...
      z = corasim(oo);                 % cast resulting obj back to CORASIM
      return
   end
   
   nx = length(x);  ny = length(y);  n = max(nx,ny);
   z = [zeros(1,n-nx) x] + [zeros(1,n-ny) y];
   
   idx = find(z~=0);
   if isempty(idx)
      z = 0;
   else
      z = z(idx(1):end);
   end
end
