function o = clean(o)
% 
% CLEAN   Clean a QUARK object, e.g. for preventing to save unnecessary
%         bulk data to file. CLEAN is implicitely called in SAVE and GFO.
%      
%             o = clean(o);
%
%         By default CLEAN removes all working data except options.
%
%         See also: QUARK, SAVE, GFO, WORK
%
   options = opt(o);                   % save options
   o = work(o,[]);                     % cleanup all work variables
   o = opt(o,options);                 % restore options

   o = control(o,'plugin',[]);         % clean plugin control option
   o = balance(o);                     % re-establish balance
%
% if object is a container then clean all objects in the container
%   
   if container(o)
      for (i=1:data(o,inf))
         oo = data(o,i);
         if isa(oo,'quark')
            oo = clean(oo);
            o = data(o,i,oo);
         end
      end
   end
end
