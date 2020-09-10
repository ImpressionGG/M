function [x,y] = form(o,x,y,m)         % Form to Sizes of Operands       
%
% FORM    Adjust sizes of two mantissas to achieve matching sizes
%         and optionally add m leading zeros
%
%            [x,y] = form(o,x,y)
%            [x,y] = form(o,x,y,0)    % same as above
%            [x,y] = form(o,x,y,m)    % additionally add n leading zeros 
%       
   nx = length(x);  
   ny = length(y);
   n = max(nx,ny);
   
   x = [zeros(1,n-nx+m),x];
   y = [zeros(1,n-ny+m),y];
end
