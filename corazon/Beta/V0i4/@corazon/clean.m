function o = clean(o)
% 
% CLEAN   Clean a CORAZON object, e.g. for preventing to save unnecessary
%         bulk data to file. CLEAN is implicitely called in SAVE and GFO.
%      
%             o = clean(o);
%
%         By default CLEAN removes all working data except options and
%         cache
%
%         Copyright(c): Bluenetics 2020 
%
%         See also: CORAZON, SAVE, GFO, WORK
%
   options = opt(o);                   % save options
   cache = work(o,'cache');            % save cache
   
   o = work(o,[]);                     % cleanup all work variables
   if ~isempty(options)
      o = opt(o,options);              % restore options
   end
   if ~isempty(cache)
      o = work(o,'cache',cache);       % restore cache
   end

   o = control(o,'plugin',[]);         % clean plugin control option
   o = balance(o);                     % re-establish balance
%
% if object is a container then clean all objects in the container
%   
   if container(o)
      for (i=1:data(o,inf))
         oo = data(o,i);
         if isa(oo,'corazon')
            oo = clean(oo);
            o = data(o,i,oo);
         end
      end
   end
end
