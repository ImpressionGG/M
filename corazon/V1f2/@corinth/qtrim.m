function x = qtrim(o,x)
%
% QTRIM  Quick trimming of mantissa (resolves overflows)
%
%           x = qtrim(o,x)             % quick trimming of mantissa
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORINTH, QADD, QMUL
%
   if any(x < 0)
      x = -x;  sgn = -1;
   else
      sgn = +1;
   end 
   
      % fetch base and calc carry
   
   b = o.data.base;                 % fetch base
   c = floor(x/b);                  % carry

      % as long as we have non zero carry we have to process carry
      
   while any(c)                     % while any non processed carry
      x = [0 x-c*b];                % selective subtract carry*base
      c = [c 0];                    % left shift carry 
      x = x + c;                    % add shifted carry to result
      c = floor(x/b);               % calculate new carry
   end

   idx = find(x~=0);
   if ~isempty(idx)
      x(1:idx(1)-1) = [];
   end
   
   if (sgn < 0)
      x = -x;
   end
end
