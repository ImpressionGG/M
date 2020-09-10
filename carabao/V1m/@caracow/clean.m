function o = clean(o)
% 
% CLEAN   Clean a CORE object, e.g. for preventing to save unnecessary
%         bulk data to file. CLEAN is implicitely called in SAVE and GFO.
%      
%             o = clean(o);
%
%         By default CLEAN removes all working data except options.
%
%         See also: CARACOW, SAVE, GFO, WORK
%
   options = opt(o);                   % save options
   o = work(o,[]);                     % cleanup all work variables
   o = opt(o,options);                 % restore options

   o = balance(o);                     % re-establish balance
end
