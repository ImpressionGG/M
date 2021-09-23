function path = folder(o)
%
% FOLDER   Get path to parent folder of class directory from a CORAZON
%          class or CORAZON derived class
%
%             path = folder(corazon);
%
%             rapid(corazon,'espresso');
%             path = folder(espresso);
%
%          Copyright(c): Bluenetics 2021
%
%          See also: CORAZON
%
   name = class(o);
   path = which(name);
   
   idx = strfind(path,['@',name,'/',name,'.m']);
   if isempty(idx)
      idx = strfind(path,['@',name,'/',name,'.p']);
   end
   
   if isempty(idx)
      error('cannot locate class constructor');
   end
   
      % strip off tail
      
   path = path(1:idx-2);
end