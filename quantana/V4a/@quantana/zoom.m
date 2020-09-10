function zoom(obj,factor)
%
% ZOOM   Zoom into or out of sceene. Zoom requires a prior sceene setup
%
%          sceene(quantana,'psi')
%
%          zoom(quantana)       % reset to zoom factor 1
%          zoom(quantana,2)     % zoom in (factor 2)
%          zoom(quantana,1/2)   % zoom out factor 1/2
%
%        See also: QUANTANA, VIEW, ZOOM, CLS
%
   if (nargin < 2)
      factor = 1;
   end
   
   if (factor <= 0)
      error('factor (arg2) must be positive!');
   end
   
   vangle = gao('quantana.vangle');
   if (isempty(vangle))
      error('zoom requires a previous setup call to SCEENE!');
   end
   
   set(gca,'cameraviewangle',vangle/factor);
   gao('quantana.zoom',factor);
   
   return
   
   
   