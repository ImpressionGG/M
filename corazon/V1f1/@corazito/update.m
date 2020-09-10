function out = update(o,hdl)
%
% UPDATE    Update graphics for continuous animation. UPDATE keeps track
%           of old graphics handles and deletes these objects. In addition
%           UPDATE implicitely calls 'plot on'.
%
%           A typical example (running wave) is:
%
%              z = 1:0.1:20;
%              [t,dt] = timer(o,0.1);        % init timer
%
%              while (~stop(o))
%                 update(o);                 % sync call to UPDATE (!!!!!) 
%
%                 hdl = plot(z,sin(z-t));
%                 update(o,hdl);             % keeps track & cleans up
%
%                 hdl = plot(z,cos(z-t));
%                 update(o,hdl);             % keeps track & cleans up
%
%                 [t,dt] = wait(o);
%              end
%
%           Remarks:
%              1) the sync call of UPDATE must be at the begin of an
%                 animation loop, prior to any graphical operation that
%                 creates graphical objects
%              2) For all created graphical objects which needed to be 
%                 tracked and automatically earased a tracking call to 
%                 UPDATE has to be made with handing over the graphs
%                 handles
%
%           Cleanup: an update call with argument = inf cleans up
%                 everything and deletes recent plots
%               
%                 update(gao,inf);   % cleanup
%
%           Copyright(c): Bluenetics 2020 
%
%           See also: CORAZITO, TIMER, WAIT, TERMINATE, STOP
%
   o.profiler('update',1);
   if (nargout == 0)
      o = gao;
   end
   
   if (nargin == 1)   % sync call
      hdls = var(o,'update.new');
      o = var(o,'update.old',hdls);    % these handles become now old
      o = var(o,'update.new',[]);      % no new handles currently
   elseif (any(any(isinf(hdl))))
      old = var(o,'update.old');
      delete(old);                         % cleanup
      o = var(o,'update.old',[]);      % set old handles empty
   else
      hdl = hdl(:);
      n = length(hdl);

      old = var(o,'update.old');
      new = var(o,'update.new');
      
      nnew = length(new);
      idx = nnew+(1:n);
      try
         if (~isempty(old))
            delete(old(idx));
         end
      catch
         fprintf('*** warning: index issue while UPDATE attempts to delete graphics handles!\n')
      end

      new = [new; hdl];
      o = var(o,'update.new',new);
   end
   
   if (nargout == 0)
      gao(o);
   else
      out = o;
   end
   
   o.profiler('update',0);
end
