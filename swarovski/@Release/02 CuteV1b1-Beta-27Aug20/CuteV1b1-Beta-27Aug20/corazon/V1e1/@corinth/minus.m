function oo = minus(o1,o2)
%
% MINUS    Overloaded operator + for CORINTH objects (rational objects)
%
%             o1 = corinth(1,6);       % rational number 1/6
%             o2 = corinth(2,6);       % rational number 2/6
%
%             oo = o1 - o2;            % subtract two ratios
%             oo = o1 - 7;             % subtract real number to ratio
%             oo = 5 - o2;             % subtract ratio to real number
%
%          See also: CORINTH, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if (~isa(o1,'corinth'))
      o1 = corinth(o2,o1);
   elseif (~isa(o2,'corinth'))
      o2 = corinth(o1,o2);
   end
    
   oo = sub(o1,o2);
end