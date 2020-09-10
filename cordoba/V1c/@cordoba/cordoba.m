classdef cordoba < corazon             % Cordoba Class Definition
%
% CORDOBA   Basis class (derived from corazon) to provide 1D and 2D based
%           data analysis capabilities.
%
%    Important methods
%
%       read, write               % import/export driver and building block
%       cook                      % data pre-processing for plotting
%       config, category, subplot % configuration for plotting
%
%    CORDOBA also provides a couple of plugins:
%
%       simple(cordoba)           % plugin for SIMPLE & PLAIN typed objects
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA, CORAZON
%
   methods                             % public methods                
      function o = cordoba(arg)        % cordoba constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@corazon(arg);               % construct base object
         o.tag = mfilename;            % tag must equal derived class name
         
         if (nargout == 0)
            launch(o);
            clear o;
         end
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
