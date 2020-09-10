function x = rand(o,seed)
%
% RAND   Normal distributed pseudo random generator
%
%            x = random(o)
%            x = random(o,seed)     % reset seed to arg value
%
   global RANDOMSEED

   if (nargin >= 2)
      RANDOMSEED = seed;
   end
   
   prime1 = 2*3*5*7*11*13*17*19 - 1;
   prime2 = (prime1+1)*23*29;
   
   RANDOMSEED = rem(RANDOMSEED*prime1,prime2);
   x = RANDOMSEED/prime2;
return 