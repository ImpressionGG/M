function oo = read(o,varargin)         % Read CARABAO Object From File 
%
% READ   Read a CARABAO object from file.
%
%             oo = read(o,'ReadLogLog',path) % .log data read driver
%
%          See also: CARABAO, IMPORT
%
   [gamma,oo] = manage(o,varargin,@ReadImgTif);
   oo = gamma(oo);
end

%==========================================================================
% Read Driver for Tif Data
%==========================================================================

function oo = ReadImgTif(o)            % Read Driver for .tif Data     
   path = arg(o,1);
   img = imread(path);
   par.path = path;
   
   [dir,file] = fileparts(path);
    
   i0 = 310;  j0 = 3700;  w = 330;  h = w;
   d = w/5;
   i0 = i0+2*d;     w = d;
   j0 = j0+4*d-10;  h = d;

   cmap = ColorMap;
   oo = image(cesar('image'),'Create',img,cmap);

   idx = i0:i0+w;  idy = j0:j0+h;
   fiducial = img(idx,idy);
   
   par.title = file;
   par.xrange = [idx(1),idx(end)];
   par.yrange = [idy(1),idy(end)];
   par.fiducial = fiducial;
   oo.par = par;
end
function cmap = ColorMap
   level = (0:255)'/255;
   cmap = level*[1 1 1];
end
