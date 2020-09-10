function list = import(o,driver,ext)   % Import ESPRESSO Object From File       
%
% IMPORT   Import ESPRESSO object(s) from file
%
%             list = import(o,'LogData','.log')
%
%          See also: ESPRESSO, EXPORT
%
   caption = sprintf('Import object from %s file',ext);
   [files, dir] = fselect(o,'i',ext,caption);
   
   list = {};                          % init: empty object list
   gamma = eval(['@',driver]);
   for (i=1:length(files))
      oo = gamma(o,[dir,files{i}]);   % call import driver function
      list{end+1} = oo;                % add imported object to list
   end
end

function oo = LogData(o,path)          % Import Driver For .log File
   [x,y,par] = read(path);             % read log data
   oo = espresso;                      % construct espresso object
   oo.data.x = x; oo.data.y = y;       % set data
   oo.par = par;                       % set parameters
end
