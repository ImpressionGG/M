function oo = package(o,list)
%
% PACKAGE   compatibility method to create a container, or return status
%           whether object is a container object?
%
%                o = package(carabao,{o1,o2,...});   % create a container  
%                ok = package(o)           % is object a container object?
%
%           Important note: this method will be obsoleted in future. Use
%           CONTAINER method instead of PACKAGE method!
%
%           See also: CARABAO, CONTAINER
%
   fprintf('*** Carabao method PACKAGE (carabao/package) will be obsoleted\n');
   fprintf('*** in future. Use method CONTAINER (carabao/container) instead!\n');

   if (nargin == 1)
      oo = container(o);
   else
      oo = container(o,list);
   end
end
