function oo = system(o)
%
% SYSTEM  Create a CORASIM state space system from an SPM object according
%         to selected contact points.
%
%            oo = system(o)
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, COOK
%
   error('obsolete');
 
   [A,B1,B2,C1,C2] = cook(o,'A,B1,B2,C1,C2');
   
      % use system with selected contact points. This is represented 
      % only by partial matrices B1,B2, C1, C2
      
   oo = system(corasim,A,[B1;B2],[C1,C2]);
   
   oo = inherit(oo,o);
end
