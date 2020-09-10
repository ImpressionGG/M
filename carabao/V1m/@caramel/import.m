function list = import(o,driver,ext,gamma) % Import CARAMEL Obj. From File       
%
% IMPORT   Import CARAMEL object(s) from file
%
%    A call with 3 input args advises to use the object's READ method
%    which dispatches on the read driver function
%
%       list = import(o,'ReadGenDat','.dat')    % import data file
%       list = import(o,'ReadPkgPkg','.pkg')    % import data file
%
%    A 4th input arg overwrites the standard READ method with any
%    specific read method which provides a read driver. This is
%    widely the case for plugin implementation (see SIMPLE, BASIS)
%
%       list = import(o,'ReadGenDat','.dat',@sample)   % import log file
%
%    See also: CARAMEL, EXPORT, READ, SIMPLE, BASIS
%
   if (nargin < 4)
      gamma = @read;                   % read function handle
   end
   
   caption = sprintf('Import object from %s file',ext);
   [files, dir] = fselect(o,'i',ext,caption);
   
   list = {};                          % init: empty object list
   for (i=1:length(files))
      path = o.upath([dir,files{i}]);  % construct path substituting '\'
      oo = gamma(o,driver,path);       % call read driver function
      if ~isempty(oo)
         oo = launch(oo,launch(o));    % inherit launch function
      
            % returned object can either be container (kids list appends
            % to list) or non-container (which goes directly into list)
      
         if container(oo)
            list = [list,data(oo)];    % append container's kids to list
         else
            list{end+1} = oo;          % add imported object to list
         end
      end
   end
end
