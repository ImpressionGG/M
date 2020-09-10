function list = import(o,driver,ext)   % Import CARASTEAK Object From File       
%
% IMPORT   Import CARASTEAK object(s) from file
%
%             list = import(o,'LogData','.log')
%
%          See also: CARASTEAK, EXPORT
%
   caption = sprintf('Import object from %s file',ext);
   [files, dir] = fselect(o,'i',ext,caption);
   
   list = {};                          % init: empty object list
   func = eval(['@',driver]);        % import driver function handle
   for (i=1:length(files))
      oo = func(o,[dir,files{i}]);   % call import driver function
      list{end+1} = oo;                % add imported object to list
   end
end

function oo = LogData(o,path)          % Import Driver For .log File
   fid = fopen(path,'r');              % open log file for write
   if (fid < 0)
      error('cannot open export file');
   end
   % add code for import               % put your own code here
   fclose(fid);
   oo = shell(o,'Create','weird');     % put your own code here
end
