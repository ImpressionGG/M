classdef caramel < carabao             % Caramel Class Definition
%
% CARAMEL   Basis class (derived from CARABAO) to provide 1D and 2D based
%           data analysis capabilities.
%
%    Important methods
%
%       read, write:              % import/export driver and building block
%       cook:                     % data pre-processing for plotting
%       config, category, subplot % configuration for plotting
%
%    CARAMEL also provides a couple of plugins:
%
%       simple(caramel)           % plugin for SIMPLE & PLAIN typed objects
%       pbi(caramel)              % post bond analysis (x/y/theta)
%       dana(caramel)             % 2D based data analysis (x/y)
%       vibration(caramel)        % vibration analysis (x,y)
%
%    See also: CARABAO
%
   methods                             % public methods                
      function o = caramel(arg)        % caramel constructor  
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
      [date,time] = now(stamp,time)    % date & time of now
      [date,time] = filedate(filepath) % get date/time of file     
      [td,acont,du] = duty(smax,vmax,amax,ts,unit,infotext)
      motmenu(obj,mode,callback)       % motion menu
   end
end
