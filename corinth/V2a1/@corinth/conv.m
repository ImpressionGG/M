function z = conv(o,x,y)
%
% CONV   Variable precision arithmetic convolution
%
%           z = conv(o,x,y)
%           z = conv(o,[1 2],[1 5 6])
%           z = conv(o,vpa([1 2]),vpa([1 5 6]))
%           z = conv(o,vpa([1 2]),[1 5 6])
%           z = conv(o,[1 2],vpa([1 5 6]))
%
%        Example:
%
%           x = [1 2 3];       % s^2 + 2*s + 3
%           y = [1 5 6 8];     % s^3 + 5*s^2 + 6*s + 8
%           z = conv(o,x,y)    % s^5 + 7*s^4 + 19*s^3 + 35*s^2 + 34*s + 24
%
%        Algorithm:
%
%                                       [ 1 2 3 0 0 0 ]
%                                       [ 0 1 2 3 0 0 ]
%           conv(x,y) = [1 5 6 8 0 0] * [ 0 0 1 2 3 0 ]
%                                       [ 0 0 0 1 2 3 ]
%                                       [ 0 0 0 0 1 2 ]
%                                       [ 0 0 0 0 0 1 ]
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, TRF, POLY, VPA
%
   if (size(x,1) ~= 1)
      error('row vector expected for arg2');
   end
   if (size(y,1) ~= 1)
      error('row vector expected for arg3');
   end
   
      % casting necessary? 
   
   if ~isa(x,'sym')
      x = vpa(x);                      % cast to VPA
   end
   if ~isa(y,'sym')
      y = vpa(y);                      % cast to VPA
   end
   
      % convolution
      
   if length(x) <= length(y)
      z = Conv(o,x,y);
   else
      z = Conv(o,y,x);
   end
   
   z = Trim(o,z);
end

%==========================================================================
% Convolution for MPA objects
%==========================================================================

function z = Conv(o,x,y)
   nx = length(x);  ny = length(y);  n = nx+ny-1;
   assert(nx<=ny);
   
   zero = zeros(1,nx+ny-1);
   
   v = [zeros(1,n-nx), x(nx:-1:1), zeros(1,n)].';
   w = [y zeros(1,nx-1)];
   
   for (i=1:nx+ny-1)
      k = n-i+1;
      vi = v(k:k+n-1);
      z(i) = w*vi;
   end
end

%==========================================================================
% Trim Mantissa
%==========================================================================

function y = Trim(o,x)                 % Trim Mantissa                 
%
% TRIM    Trim mantissa: remove leading mantissa zeros
%
   idx = find(x~=0);
   if isempty(idx)
      y = 0;
   else
      y = x(idx(1):end);
   end
end