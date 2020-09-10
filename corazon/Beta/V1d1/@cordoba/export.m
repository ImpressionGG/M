function oo = export(o,driver,ext,gamma) % Export CARMA Object To File
%
% EXPORT   Export a CORDOBA object to file.
%
%             oo = export(o,'WriteUniDat','.dat')  % export to data file
%             oo = export(o,'WritePkgPkg','.pkg')  % export package info
%
%          A 4th input arg overwrites the standard READ method with any
%          specific read method which provides a read driver. This is
%          widely the case for plugin implementation (see SIMPLE, BASIS)
%
%             oo = export(o,'WriteUniDat','.dat',@simple) 
%             oo = export(o,'WriteUniDat','.dat',@basis) 
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORDOBA, IMPORT, WRITE, ISIMPLE, BASIS
%
   if (nargin < 4)
      gamma = @write;                  % write function handle
   end
   
   name = get(o,{'title',''});
   caption = sprintf('Export CORDOBA object to %s file',ext);
   [file, dir] = fselect(o,'e',[name,ext],caption);
   
   oo = [];                            % empty return value if fails
   if ~isempty(file)
      path = o.upath([dir,file]);      % construct path substituting '\'
      gamma(o,driver,path);            % write data to file
      oo = o;                          % successful export
   end
end
