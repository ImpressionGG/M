function base = baseline(obj)
% 
% BASELINE Retrieve base line coordinates
%      
%             obj = dproc(data)     % create DPROC object
%             bl = baseline(obj);
%
%          See also   DISCO, DPROC

   switch kind(obj)
      case 'process'
         chains = getp(obj,'list');
         skip = getp(obj,'baseskip');
         
         base = [];
         if ~isempty(chains)
            base = 0;
            y = 0;
            
            for (i=1:length(chains))
               rng = range(chains{i});
               rng = rng(:);
               if (all(rng<= 0))
                  y = y - max(abs(rng)) - skip;
                  y1 = y + max(abs(rng));
               elseif all(rng>=0)
                  y = y - max(rng) - skip;
                  y1 = y;
               else
                  y = y - abs(diff(rng)) - skip;
                  y1 = y - min(rng(:));
               end
               base = [base, y1];
               %base = [y1 base];
            end
         end
         base(1) = [];
         base = base - min(base(:)) + skip;
         
      otherwise
         error(['bad operation for object kind ''',kind(obj),'''']);
   end
   return
   
% eof