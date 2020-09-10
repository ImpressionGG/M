function sceene(obj,mode,varargin)
%
% SCEENE   After clearing the screen (with CLS) a 3D sceene is setup
%          with proper view parameters (for 3D rotation) and light 
%          placements. Global parameters are stored in userdata of GCA.
%
%             sceene(quantana,mode,...)
%
%          Modes:
%             sceene(quantana,'psi',zspace)  % 1D dimensional function
%             sceene(quantana,'sphere',r)    % 3D sphere setup
%
%          Example
%
%             sceene(quantana,'psi',-5:5);
%             sceene(quantana,'sphere',r);
%
%          Options: set the 'debug' option of obj to see the internals,
%          e.g.
%                sceene(option(quantana,'debug',1),'psi',-5:5)
%
%          See also: QUANTANA, VIEW, ZOOM, CLS
%
   if (nargin < 2)
      error('mode (arg2) required!');
   end
   
   cls;             % clear screen
   gao(smart);      % push an empty SMART object to axis user data
   
   switch mode
      case 'psi'
         if (length(varargin) < 1)
            varargin{1} = -5:0.1:5;        % default zspace
         end
         sceenepsi(obj,varargin{1});
      case 'sphere'
         if (length(varargin) < 1)
            varargin{1} = 1;               % default radius
         end
         sceenesphere(obj,varargin{1});
      otherwise
         mode, error('bad mode!');
   end
   
   shg
   return
   
%==========================================================================

function sceenepsi(obj,z)
%
% SCEENEPSI   Setup sceene for 1D psi visualization
%             x and y axes are scaled from -0.1 ... 0.1
%
   debug = either(option(obj,'debug'),0);
   x1 = min(z);  x2 = max(z);  p =  0.2;
    
  [z,y,x] = cylinder(p,20);
   x = x1 + (x2-x1)*x;
   hdl = surf(x,y,z);

   obj = cmap(obj,'jolly');
   
   set(gca,'dataaspect',[1 1 1]);
   view(20,30);  hold on;
   dark; axis off;
   
   camera('pin');                      % pin down home position
   camera('light',[1 0.5; -1 -0.5]);
   lighting phong;  material dull;
    
   set(hdl,'visible','off');
   return;

%==========================================================================

function sceenesphere(obj,r)
%
% SCEENESPHERE   Setup sceene for 3D visualization of sphere
%
   debug = either(option(obj,'debug'),0);

   [x,y,z] = sphere(20);
   hdl = surf(r*x,r*y,r*z,'FaceColor',[0 0 0]);
   
   %obj = cmap(obj,'jolly');
   
   set(gca,'dataaspect',[1 1 1]);
   view(20,5);  hold on;
   dark; axis off;
   
   camera('pin');                      % pin down home position

   if (~debug)
      set(hdl,'visible','off');
   end
   
   camera('light',[1 0.5; -1 -0.5]);
   lighting phong;  material dull;
   return;

%eof   