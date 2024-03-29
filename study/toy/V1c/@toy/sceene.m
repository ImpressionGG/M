function done = sceene(o,mode,varargin)
%
% SCEENE   Setup 3D Sceene.
%
%    After clearing the screen (with CLS) a 3D sceene is setup
%    with proper view parameters (for 3D rotation) and light 
%    placements. Global parameters are stored in userdata of GCA.
%
%       sceene(quantana,mode,...)
%
%    Modes:
%       sceene(toy,'psi',zspace)      % 1D dimensional function
%       sceene(toy,'sphere',r)        % 3D sphere setup
%
%       sceene(toy,'2D');             % default setup for 2D
%
%       sceene(toy,'3D');             % default setup for 3D
%       sceene(toy);                  % same as sceene(toy,'3D')
%
%    Check if sceene has been setup:
%
%       done = sceene(toy);           % 1 if setup, otherwise 0
%
%    Example
%
%       sceene(quantana,'psi',-5:5);
%       sceene(quantana,'sphere',r);
%
%    Options: set the 'debug' option of obj to see the internals,
%    e.g.
%       sceene(opt(quantana,'debug',1),'psi',-5:5)
%
%    See also: TOY, VIEW, ZOOM, CLS
%
   if (nargin == 1 && nargout == 1)
      cam = get(gao,'camera');
      done = iif(isempty(cam),0,1);
      return;
   end
   
   if (nargin < 2)
      mode = '3D';
   end
   
   cls(o);         % clear screen
   gao(core);      % push an empty SMART object to axis user data
   
   switch mode
      case 'bion'
         if (length(varargin) < 1)
            varargin{1} = -1:0.1:1;        % default zspace
         end
         sceenebion(o,varargin{1});
      case '3D'
         if (length(varargin) < 1)
            varargin{1} = -1:0.1:1;        % default zspace
         end
         sceene3D(o,varargin{1});
      case 'psi'
         if (length(varargin) < 1)
            varargin{1} = -5:0.1:5;        % default zspace
         end
         sceenepsi(o,varargin{1});
      case 'sphere'
         if (length(varargin) < 1)
            varargin{1} = 1;               % default radius
         end
         sceenesphere(o,varargin{1});
      otherwise
         mode, error('bad mode!');
   end
   
   shg
   return

%==========================================================================

function sceenebion(o,z)
%
% SCEENEBION  Default setup of a sceene for 3D visualization
%             x and y axes are scaled from -0.1 ... 0.1
%
   debug = either(opt(o,'debug'),0);
    
   caxis manual;  caxis([0 1]);
   [x,y,z] = sphere(10);
   
   C = cindex(o,ones(size(z)),'k');       % color indices

   R = 1e-10;
   hdl = surf(R*x,R*y,R*z,C,'edgecolor','none');
   alpha(hdl,0);
   caxis([0 1]);                            % since surf changes caxis

   %o = cmap(o,'jolly');
   o = cmap(o,'alpha');
   
   set(gca,'dataaspect',[1 1 1]);
   view(-20,10);  hold on;
   dark; axis off;
   
   %camera('pin');                          % pin down home position
   camera('light',[1 0.5; -1 -0.5]);
   lighting gouraud;
    
   %set(hdl,'visible','off');
   return;

%==========================================================================

function sceene3D(o,z)
%
% SCEENE3D    Default setup of a sceene for 3D visualization
%             x and y axes are scaled from -0.1 ... 0.1
%
   debug = either(opt(o,'debug'),0);
   %R = 1e-10;
   R = 1.2*max(abs(z(:)));
    
   caxis manual;  caxis([0 1]);
   [x,y,z] = sphere(10);
   
   C = cindex(o,ones(size(z)),'k');     % color indices

   hdl = surf(R*x,R*y,R*z,C,'edgecolor','none');
   alpha(hdl,0.0);
   caxis([0 1]);                          % since surf changes caxis

   % o = cmap(o,'jolly');
   
   set(gca,'dataaspect',[1 1 1]);
   view(-20,30);  hold on;
   dark(o); axis off;
   
   %camera('pin');                      % pin down home position
   camera('light',[1 0.5; -1 -0.5]);
   lighting gouraud;
    
   %set(hdl,'visible','off');
   return;

%==========================================================================

function sceenepsi(o,z)
%
% SCEENEPSI   Setup sceene for 1D psi visualization
%             x and y axes are scaled from -0.1 ... 0.1
%
   debug = either(opt(o,'debug'),0);
   x1 = min(z);  x2 = max(z);  p =  0.2;
    
  [z,y,x] = cylinder(p,20);
   x = x1 + (x2-x1)*x;
   hdl = surf(x,y,z);

   o = cmap(o,'jolly');
   
   set(gca,'dataaspect',[1 1 1]);
   view(20,30);  hold on;
   dark; axis off;
   
   camera('pin');                      % pin down home position
   camera('light',[1 0.5; -1 -0.5]);
   lighting phong;  material dull;
    
   set(hdl,'visible','off');
   return;

%==========================================================================

function sceenesphere(o,r)
%
% SCEENESPHERE   Setup sceene for 3D visualization of sphere
%
   debug = either(opt(o,'debug'),0);

   [x,y,z] = sphere(20);
   hdl = surf(r*x,r*y,r*z,'FaceColor',[0 0 0]);
   
   %o = cmap(o,'jolly');
   
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