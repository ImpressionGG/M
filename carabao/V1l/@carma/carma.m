classdef carma < carabao               % Carma Class Definition
   methods                             % public methods                
      function o = carma(arg)          % carma constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@carabao(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
      end
   end
   methods (Static)
      txt = capital(txt)               % convert to capitalized string
      [str,clk] = clock(format)        % current clock information
      olist = cons(item,list)          % construct a list
      [date,time] = now(stamp)         % date & time of now
      [td,acont,du] = duty(smax,vmax,amax,ts,unit,infotext)
      motmenu(obj,mode,callback)       % motion menu
   end
end
