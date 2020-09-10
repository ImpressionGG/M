function out = camera(varargin)
%
% CAMERA  Camera operations; Global data is stored in user data of axis.
%         In addition camer provides timer functions
%
%            camera;              % same as camera('pin');
%            camera('pin')        % pin down camera home position
%                                 % mind nominal position according
%                                 % to current view settings
%
%            camera('home')       % restore camera home position
%
%            camera('timer',0.1); % camera timer with waiting interval 0.1
%
%            camera('wait')       % wait until next timer tic ready
%                                 % also show graphics
%
%            camera('spin',+5)    % change azimuth angle by relativ
%                                 % +5° with respect to current
%
%            camera('lift',+3)    % change relative elevation angle 
%                                 % by +3° with respect to current
%
%            camera('target',[0 0 0])   % set camera target position
%            tgt = camera('target');
%            tgt = camera('target',[]);   % return current camera target
%
%            camera('position',[8 7 9])   % set camera position
%            pos = camera('position');
%
%            camera('zoom',2)     % zoom in  x 2
%            camera('zoom',1/2)   % zoom out x 1/2
%
%            camera('light',[1 0.5])  % place a camera light
%                                     % [deltax,deltay]
%
%            camera('play');          % plot a graphics to play around
%                                     % calls camera('ready')
%
%            camera('spinning',[dt dphi]);  % camera spinning
%            camera('spinning',[0.1 2]);    % default camera spinning
%            camera('spinning',0.1);        % dphi = 2°
%            camera('spinning');            % dt = 0.1s, dphi = 0.2°
%                                                
%         Demos:
%
%            camera('play','light',[],'spinning');
%            camera('play','light',[1 0.5; -1 -0.5],'spinning');
%
%         Example:
%
%            camera('play','light');
%            camera('home');
%            camera('target',[0 0 0],'timer',0.1)  % mind and set timer
%            while (~stop(gao))                    % still continue 
%               % do some graphics
%               camera('spin',+2,'wait');          % spin another +5°
%            end
%
%         See also: CORE, WAIT, STOP
%
   len = length(varargin);

   if (len == 0)         % pin down camera home position
      camera('pin');
      return             % that's it!
   end
   
      % process args
      
   i = 1;
   while (i <= len)
      mode = varargin{i};  i = i+1;
      if (i <= len)
         arg = varargin{i}; 
      else
         arg = [];
      end
      i = i+1;
       
      if (~ischar(mode))
         error(sprintf('string expected for arg%g!',i));
      end
      
      switch mode
         case 'pin'            % pin down camera home position
            i = i-1;           % no input arg
            [az0,el0] = view;  % get current view parameters
            gao('camera.az0',az0, 'camera.el0',el0);

            position = get(gca,'cameraposition');
            gao('camera.position',position);
            set(gca,'camerapositionmode','manual');

            target = get(gca,'cameratarget');
            gao('camera.target',target);
            set(gca,'cameratargetmode','manual');

            viewangle = get(gca,'cameraviewangle');
            gao('camera.vangle',viewangle);
            set(gca,'cameraviewanglemode','manual');

            gao('camera.zoom',1.0);        % init zoom factor
            
         case 'home'           % restore camera home position
            i = i-1;           % no input arg
            
            az0 = gao('camera.az0');
            el0 = gao('camera.el0');
            view(az0,el0);   % restore view
            
            position = gao('camera.position');
            set(gca,'cameraposition',position);
            set(gca,'camerapositionmode','manual');

            target = gao('camera.target');
            set(gca,'cameratarget',target);
            set(gca,'cameratargetmode','manual');

            viewangle = gao('camera.vangle');
            set(gca,'cameraviewangle',viewangle);
            set(gca,'cameraviewanglemode','manual');

            gao('camera.zoom',1.0);        % init zoom factor
            
         case 'timer'                      % set timer
            if (~isa(arg,'double'))
               error(sprintf('double expected for arg%g!',i-1));
            end
            smo = timer(gao,arg);
            gao(smo);                      % push into axis user data
            camera                         % mind everything
            
         case 'target'                     % set camera target
            out = get(gca,'cameratarget');
            if (isempty(arg))
               return                      % return current target
            end
            
            if (~isa(arg,'double'))
               error(sprintf('double expected for arg%g!',i-1));
            end
            target = arg(:)';
            if (length(target(:)) ~= 3)
               error(sprintf('3-vector expected for arg%g!',i-1));
            end
               
            set(gca,'cameratarget',target);
            gao('camera.target',target);
            set(gca,'cameratargetmode','manual');
            if (nargout > 0)
               out = target;
            end
            
         case 'position'                     % set camera target
            out = get(gca,'cameraposition');
            if (isempty(arg))
               return                        % return current position
            end
            
            if (~isa(arg,'double'))
               error(sprintf('double expected for arg%g!',i-1));
            end
            position = arg(:)';
            if (length(position(:)) ~= 3)
               error(sprintf('3-vector expected for arg%g!',i-1));
            end
               
            set(gca,'cameraposition',position);
            gao('camera.position',position);
            set(gca,'camerapositionmode','manual');
            if (nargout > 0)
               out = position;
            end
            
         case 'spin'                     % spin relative
            if (~isa(arg,'double'))
               error(sprintf('double expected for arg%g!',i-1));
            end
            if (length(arg) ~= 1)
               error(sprintf('scalar expected for arg%g!',i-1));
            end
            
            position = get(gca,'cameraposition');
            arg = arg * pi/180;                % convert to radians
            T = [cos(arg) -sin(arg); sin(arg) cos(arg)];
            position(1:2) = (T*position(1:2)')';
            set(gca,'camerapositionmode','manual');
            set(gca,'cameraposition',position);

         case 'lift'                     % lift camera relative
            if (~isa(arg,'double'))
               error(sprintf('double expected for arg%g!',i-1));
            end
            if (length(arg) ~= 1)
               error(sprintf('scalar expected for arg%g!',i-1));
            end
               
            target = get(gca,'cameratarget');
            viewangle = gao('camera.vangle');
            [az,el] = view;              % get current parameters
            el = el + arg;
            view(az,el);
            if (nargout > 0)
               out = [az,el];
            end
            set(gca,'cameratarget',target);
            set(gca,'cameratargetmode','manual');
            
         case 'zoom'                     % camera zoom
            if (~isa(arg,'double'))
               error(sprintf('double expected for arg%g!',i-1));
            end
            if (length(arg) ~= 1)
               error(sprintf('scalar expected for arg%g!',i-1));
            end
               
            factor = arg;
            viewangle = gao('camera.vangle');
            if (isempty(viewangle))
               viewangle = get(gca,'cameraviewangle');
            end
            viewangle = viewangle/factor;
            set(gca,'cameraviewangle',viewangle);
            if (nargout > 0)
               out = viewangle;
            end
            
         case 'light'                    % place alight
            if (isempty(arg))
               arg = [ 1 +0.5; -1 -0.5];
            end
            
            if (~isa(arg,'double'))
               error(sprintf('double expected for arg%g!',i-1));
            end
            [m,n] = size(arg);
            if (size(arg,2) ~= 2)
               error(sprintf('2-vector expected for arg%g!',i-1));
            end
               
            pos = camera('position');
            tar = camera('target');
            r = pos - tar;  r = r(:);    % distance vector
            z = [0 0 1]';                % vector in z-direction
            
            if ((r'*z) == 0)             % degenerate
               r(1) = 100*eps;
            end
            
            nx = null([r,z]') * norm(r); % normal vector x
            ny = null([r,nx]')* norm(r); % normal vector y

            hdl = gao('camera.light');
            for (j=1:m)
               lpos = pos(:) + arg(j,1)*nx/2 + arg(j,2)*ny/2;
               lhdl = [hdl; light('position',lpos,'color',[1 1 1])];
            end
            gao('camera.light',hdl);
            
         case 'play'                     % draw an object for playing around
            i = i-1;                     % no further arguments
            cls;
            [x,y,z] = sphere(20);
            surf(x,y,z);
            axis off
            camera('pin','home');
            shg

         case 'demo'                     % spin and zoom the play object
            i = i-1;                     % no further arguments
            camera('play','pin');        % setup sceene & make camera ready
            [t,dt] = timer(gao,0.04);
            while(~stop(gao))
               camera('zoom',1+sin(t)/2,'spin',1, 'lift', 0.5*cos(t/2));
               [t,dt] = wait(gao);
            end

         case 'spinning'                % spinning in an endless loop
            if (isempty(arg))
               arg = [0.1 2];           % default
            end
            if (~isa(arg,'double'))
               error(sprintf('double expected for arg%g!',i-1));
            end
            if (length(arg) == 1)
               arg(2) = 2;
            end
            if (length(arg(:)) ~= 2)
               error(sprintf('2-vector expected for arg%g!',i-1));
            end
            
            set(gcf,'WindowButtonDownFcn','terminate(gao)');
            camera('pin');
            [t,dt] = timer(gao,arg(1));
            while (~stop(gao))
               camera('spin',arg(2));
               wait(gao);
            end
            
         otherwise
            mode, error('bad mode!');
      end
   end
   return
      
% eof   