function out = update(obj,hdl)
%
% UPDATE    Update graphics for continuous animation. UPDATE keeps track
%           of old graphics handles and deletes these objects. In addition
%           UPDATE implicitely calls 'plot on'.
%
%           A typical example (running wave) is:
%
%              z = 1:0.1:20;
%              t = 0;  dt = 0.1;             % initialize time & interval
%              smo = timer(core,dt);         % create a core object
%
%              while (~stop(smo))
%                 smo = update(smo);         % sync call to UPDATE (!!!!!) 
%
%                 hdl = plot(z,sin(z-t));
%                 smo = update(smo,hdl);     % keeps track & cleans up
%
%                 hdl = plot(z,cos(z-t));
%                 smo = update(smo,hdl);     % keeps track & cleans up
%
%                 smo = wait(smo);
%                 t = t+dt;
%              end
%
%           Alternatively (use of gao)
%
%              z = 1:0.1:20;
%              [t,dt] = timer(gao,0.1);      % create a smart object
%
%              while (~stop(gao))
%                 update(gao);               % sync call to UPDATE (!!!!!) 
%
%                 hdl = plot(z,sin(z-t));
%                 update(gao,hdl);           % keeps track & cleans up
%
%                 hdl = plot(z,cos(z-t));
%                 update(gao,hdl);           % keeps track & cleans up
%
%                 [t,dt] = wait(gao);
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
%           See also: CORE, TIMER, WAIT, TERMINATE, STOP
%
   profiler('update',1);
   if (nargout == 0)
      obj = gao;
   end
   
   if (nargin == 1)   % sync call
      hdls = get(obj,'update.new');
      obj = set(obj,'update.old',hdls);    % these handles become now old
      obj = set(obj,'update.new',[]);      % no new handles currently
   elseif (any(any(isinf(hdl))))
      old = get(obj,'update.old');
      delete(old);                         % cleanup
      obj = set(obj,'update.old',[]);      % set old handles empty
   else
      hdl = hdl(:);
      n = length(hdl);

      old = get(obj,'update.old');
      new = get(obj,'update.new');
      
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
      obj = set(obj,'update.new',new);
   end
   
   if (nargout == 0)
      gao(obj);
   else
      out = obj;
   end
   
   profiler('update',0);
   return

%eof