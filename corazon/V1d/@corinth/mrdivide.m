function oo = mrdivide(o1,o2)
%
% MRDIVIDE Overloaded operator / for CORINTH objects (rational objects)
%
%             o1 = corinth(1,6);       % ratio 1/6
%             o2 = corinth(2,6);       % ratio 2/6
%
%             oo = o1 / o2;            % divide two ratios
%             oo = o1 / 7;             % divide real number to ratio
%             oo = 5 / o2;             % divide ratio to real number
%
%          See also: CORINTH, PLUS, MINUS, MTIMES, MRDIVIDE
%
   if (~isa(o1,'corinth'))
      o1 = corinth(o2,o1);
   elseif (~isa(o2,'corinth'))
      o2 = corinth(o1,o2);
   end
   
   oo = div(o1,o2);
end