classdef corasim < corazon             % Corasim Class Definition
%
% CORASIM   Class objects for linear & nonlinear system simulation
%
%           Supported types:
%
%              css:          continuous state space representation
%              dss:          discrete state space representation
%              strf:         s-transfer function
%              ztrf:         z-transfer function
%              motion:       motion objects
%
%           Copyright(c): Bluenetics 2020
%
%           See also: CORAZON, SYSTEM, PEEK, SIM, PLOT, MODAL
%
   methods                             % public methods
      function o = corasim(arg)        % corasim constructor
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
end
