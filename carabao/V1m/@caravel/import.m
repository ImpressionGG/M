function oo = import(o,filepath)
%
% IMPORT   Import an image.
%
%             oo = import(caravel,filename);
%
%          This works for all of the following suffixes:
%
%             .bmp     bitmap
%             .jpg     JPG file
%             .png     portable network graphics
%
%        See also: CARAVEL, SHOW, IMAGE
%
   [dir,fname,ext] = fileparts(filepath);
   
   switch ext
      case {'.bmp','.jpg','.png'}
         oo = Image(o,filepath);
      otherwise
         error('bad extension, cannot import file!')
   end
end

%==========================================================================
% Import Image
%==========================================================================

function oo = Image(o,filepath)        % Import Image                  
   [dir,fname,ext] = fileparts(filepath);
   oo = image(o,'Load',filepath);
end
