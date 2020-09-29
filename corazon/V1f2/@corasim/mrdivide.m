function oo = mrdivide(o1,o2)
%
% MRDIVIDE Overloaded operator / for CORASIM objects
%
%             o1 = system(o,{[1],[2 3]});
%             o2 = system(o,{[1 4],[2 3 5]});
%
%             oo = o1 / o2;            % divide two trfs
%             oo = o1 / 7;             % divide real number with trf
%             oo = 5 / o2;             % divide trf with real number
%
%          Copyright(c): Bluenetics 2020
%
%          See also: CORASIM, PLUS, MINUS, MTIMES, MRDIVIDE
%
   oo = o1 * inv(o2);
end
