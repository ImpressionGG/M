function list = import(o,driver,ext)   % Import CARMA Object From File       
%
% IMPORT   Import CARMA object(s) from file
%
%             list = import(o,'LogData','.log')
%
%          See also: CARMA, EXPORT, READ
%
   caption = sprintf('Import object from %s file',ext);
   [files, dir] = fselect(o,'i',ext,caption);
   
   list = {};                          % init: empty object list
   for (i=1:length(files))
      path = [dir,files{i}];           % construct path
      oo = read(o,driver,path);        % call read driver function
      
         % returned object can either be container (kids list appends to
         % list) or non-container (which goes directly into list)
      
      if container(oo)
         list = [list,data(oo)];       % append container's kids to list
      else
         list{end+1} = oo;             % add imported object to list
      end
   end
end
