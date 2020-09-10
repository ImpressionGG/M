classdef caravel < carabao             % Caravel Class Definition
%
% CARAVEL   Basis class (derived from CARABAO) to provide alternative
%           data objects like image objects.
%
%    CARAVEL data is always a structure containing a kind member which
%    describes the data kind.
%
%       show(caravel,'@caravel/image/caravel.png')
%
%    See also: CARABAO, SHOW
%
   methods                             % public methods                
      function o = caravel(arg)        % caravel constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@carabao(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
end
