function rng = range(obj)
% 
% RANGE    Get range of DPROC's plot
%      
%             rng = range(prc);
%
%          See also   DISCO, DPROC

   switch kind(obj)
      case 'process'
         chains = getp(obj,'chains');
         rng = [inf -inf];
         for (i=1:length(chains))
            rngi = range(chains(i));
            rng(1) = min(rng(1), rngi(1));
            rng(2) = max(rng(2), rngi(2));
         end
      case {'chain','sequence','ramp','pulse','wait','delay'}
         [x,y] = points(obj);
         if ~isempty(x) & ~isempty(y)
            rng = [min(y),max(y)];
         else
            rng = [0 0];
         end
      otherwise
         error(['bad operation for object kind ''',kind(obj),'''']);
   end
   
% eof