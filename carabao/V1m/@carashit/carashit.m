classdef carashit < carabao            % v1c/@carashit/carashit.m
   methods                             % public methods                
      function o = carashit(arg)       % carashit constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@carabao(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
   methods (Static)
      [title,text] = lorem(m,i1,i2)    % lorem ipsum generator
   end   
end
