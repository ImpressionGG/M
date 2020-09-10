function o = export(o,driver,ext)      % Export CAPPUCCINO Object To File
%
% EXPORT   Export a CAPPUCCINO object to file.
%
%             oo = export(o,'WriteStuffLog','.log')
%             oo = export(o,'LogData','.log')
%
%          See also: CAPPUCCINO, IMPORT
%
   name = get(o,{'title',''});
   caption = sprintf('Export CAPPUCCINO object to %s file',ext);
   [file, dir] = fselect(o,'e',[lower(name),ext],caption);
   
   oo = [];                            % empty by default
   if ~isempty(file)
      oo = write(o,driver,[dir,file]); % actual export to file
   end
end
