function o = export(o,driver,ext)      % Export ESPRESSO Object To File
%
% EXPORT   Export a ESPRESSO object to file.
%
%             oo = export(o,'LogData','.log')
%
%          See also: ESPRESSO, IMPORT
%
   name = get(o,{'title',''});
   caption = sprintf('Export ESPRESSO object to %s file',ext);
   [file, dir] = fselect(o,'e',[lower(name),ext],caption);
   
   oo = [];                            % empty by default
   if ~isempty(file)
      gamma = eval(['@',driver]);
      gamma(o,[dir,file]);             % call export driver function
      oo = o;                          % successful export
   end
end

function LogData(o,path)               % Export Driver For .log File
   fid = fopen(path,'w');              % open log file for write
   if (fid < 0)
      error('cannot open export file');
   end
   
   fprintf(fid,'$title=%s\n',get(o,{'title',''}));
   log = [o.data.x,o.data.y];          % compose data matrix
   fprintf(fid,'%10f %10f\n',log');    % write x/y data
   fclose(fid);                        % close export file
end
