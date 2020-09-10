classdef quark
%
% QUARK  Basic class QUARK constructor
%
%           o = quark                  % type = 'shell'
%           o = quark('mytype')        % specific type
%
   properties
      tag                              % usually holding class name
      typ                              % determines data interpretation
      par                              % parameters
      dat                              % data
      wrk                              % working variables
   end
   methods
      function o = quark(arg)          % QUARK class constructor      
         tag = mfilename;              % our class tag
         if (nargin == 0)
            arg = 'shell';             % 'shell' type by default
         end
         
            % dispatch on argument class
            
         if ischar(arg)                % construct a typed CARACOW object
            o.tag = tag;               % tag holds class name
            o.typ = arg;               % object type
            o.par = [];                % parameter property
            o.dat = {};                % data property
            o.wrk = [];                % work property
         else
            if isobject(arg)
               o.tag = arg.tag;
               o.typ = arg.typ;
               o.par = arg.par;
               o.dat = arg.dat;
               o.wrk = arg.wrk;
            elseif isstruct(arg)
               o.tag = arg.tag;        % tag holds class name
               o.typ = arg.typ;        % object type
               o.par = arg.par;        % parameter property
               o.dat = arg.dat;        % data property
               o.wrk = arg.wrk;        % work property
            else
               error('bad argument class (arg1)!');
            end
         end
      end
   end
end
