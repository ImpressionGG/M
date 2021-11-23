function oo = construct(o,arg)
%
% CONSTRUCT   Construct an object from bag
%
%                o = construct(corazito,'corazon')
%                o = construct(corazito,bag)
%
%             Copyright(c): Bluenetics 2020 
%
%             See also: CORAZITO, PACK
%
   if ischar(arg)
      oo = eval(arg);                  % construct object
   elseif isstruct(arg)
      bag = arg;
      gamma = eval(['@',bag.tag]);     % constructor function handle
      oo = gamma(bag);                 % construct object
   else
      error('char or struct expected for arg2!');
   end
end