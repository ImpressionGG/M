function oo = export(o,driver,ext)     % Export Object To File
%
% EXPORT   Export an ESPRESSO object to a log file.
%
%             oo = export(o,'WriteStuffTxt','.txt') % export object to file
%
%          Copyright(c): Bluenetics 2020 
%
%          See also: CORAZON, WRITE, IMPORT
%
   name = get(o,{'title',''});
   caption = sprintf('Export object to %s file',ext);
   [file, dir] = fselect(o,'e',[name,ext],caption);
   
   oo = [];                            % empty by default
   if ~isempty(file)
      oo = write(o,driver,[dir,file]); % actual export to file
   end
end
