classdef caracow
   properties
      tag                              % usually holding class name
      type                             % determines data interpretation
      par                              % parameters
      data                             % data
      work                             % working variables
   end
   methods
      function o = caracow(arg)        % Caracow Class Constructor      
         tag = mfilename;              % our class tag
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         
            % dispatch on argument class
            
         if ischar(arg)                % construct a typed CARACOW object
            o.tag = tag;               % tag holds class name
            o.type = arg;              % object type
            o.par = [];                % parameter property
            o.data = {};               % data property
            o.work = [];               % work property
         else
            if isobject(arg)
               o.tag = arg.tag;
               o.type = arg.type;
               o.par = arg.par;
               o.data = arg.data;
               o.work = arg.work;
            elseif isstruct(arg)
               o.tag = arg.tag;        % tag holds class name
               o.type = arg.type;      % object type
               o.par = arg.par;        % parameter property
               o.data = arg.data;      % data property
               o.work = arg.work;      % work property
            else
               error('bad argument class (arg1)!');
            end
         end
      end
   end
end
