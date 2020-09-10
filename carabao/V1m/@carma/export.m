function oo = export(o,driver,ext)     % Export CARMA Object To File
%
% EXPORT   Export a CARMA object to file.
%
%             oo = export(o,'LogData','.log')
%
%          See also: CARMA, WRITE, IMPORT
%
   name = get(o,{'title',''});
   caption = sprintf('Export CARMA object to %s file',ext);
   [file, dir] = fselect(o,'e',[lower(name),ext],caption);
   
   oo = [];                            % empty return value if fails
   if ~isempty(file)
      path = [dir,file];               % construct path
      write(o,driver,path);            % write data to file
      oo = o;                          % successful export
   end
end
