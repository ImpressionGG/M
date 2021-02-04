function oo = system(o)
%
% SYSTEM  Create a CORASIM state space system from an SPM object
%
%            oo = system(o)
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, COOK
%
   [A,B,C,D] = cook(o,'A,B,C,D');
   oo = system(corasim,A,B,C,D);
   oo = inherit(oo,o);
end
