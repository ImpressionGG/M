function o = comp(o,x,y)               % Compare Two Rational Objects  
%
% COMP    Compare two rational objects
%
%            sgn = comp(o,x,y);        % compare two mantissa
%
%         Return value:
%
%            +1: for x > y
%             0: for x = y
%            -1: for x < y
%
%         See also: RAT, TRIM, SUB
%
   if (nargin == 3)
      o = Comp(o,x,y);
   end
end

%==========================================================================
% Compare Two Mantissa
%==========================================================================

function sgn = Comp(o,x,y)             % Compare Mantissas             
   if all(x>=0) && any(y<0)
      sgn = +1;
   elseif any(x<0) && all(y>=0)
      sgn = -1;
   elseif any(x<0) && any(y<0)
      sgn = Comp(o,-y,-x);
   else
      [x,y] = form(o,x,y,0);
      sgn = sign(x-y);
      idx = [find(sgn~=0), 1];         % make sure that idx is not empty!
      sgn = sgn(idx(1));
   end
end
