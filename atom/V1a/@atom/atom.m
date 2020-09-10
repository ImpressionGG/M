classdef atom < baryon             % Baryon Class Definition
%
% ATOM   Basis class (derived from BARYON) to provide
%           data analysis capabilities.
%
%    Important methods
%
%       read, write:              % import/export driver and building block
%       config, category, subplot % configuration for plotting
%
%    ATOM also provides a couple of plugins:
%
%       simple(atom)              % plugin for SIMPLE & PLAIN typed objects
%
%    See also: BARYON
%
   methods                             % public methods                
      function o = atom(arg)           % atom constructor  
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         o@baryon(arg);                % construct base object
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
