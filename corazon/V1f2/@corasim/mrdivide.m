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
   if isa(o1,'double')
      if (size(o1,1) ~= 1)
         error('arg1 must be scalar or row vector');
      end
      o1 = trf(corasim,o1);
   end
   
   if isa(o2,'double')
      if (size(o2,1) ~= 1)
         error('arg2 must be scalar or row vector');
      end
      o2 = trf(corasim,o2);
   end
   
   oo = o1 * inv(o2);
end
