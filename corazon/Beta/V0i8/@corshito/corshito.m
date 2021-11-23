classdef corshito < corazon            % CORSHITO class constructor
%
%  Copyright(c): Bluenetics 2020 
%
   methods                             % public methods                
      function o = corshito(arg)       % corshito constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@corazon(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
   methods (Static)
      [title,text] = lorem(m,i1,i2)    % lorem ipsum generator
   end   
end
