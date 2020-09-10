function t = period(obj,step)
% 
% PERIOD  Period of a process
%      
%            period(obj,step)
%            period(obj)
%            
%         See also   DISCO, DPROC

% check arguments

	if ( nargin < 2) 
      step = [];
      error('period determination without parameter not yet implemented');
   end
   
   t0 = 0;
   
   [m n] = sizes(obj);
   
   for (i=1:m)   
      chain = element(obj,i);
      %chain
      [mc nc] = sizes(chain);
      %for(j=1:nc)
      for(j=nc:-1:1)
         elStart = getp(element(chain,j),'start');
         elName = getp(element(chain,j),'name');
         if (strcmp(elName,step))
            %fprintf('%g %s\n', elStart, elName );
            if (t0 == 0)
               t0 = elStart;
            else
               t0 = t0 - elStart;
               break;
            end
         end
      end
   end
   
   t = round(t0);

% eof