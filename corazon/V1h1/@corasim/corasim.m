classdef corasim < corazon             % Corasim Class Definition
%
% CORASIM   Class objects for linear & nonlinear system simulation
%
%           Supported types:
%
%              css:          continuous state space representation
%              dss:          discrete state space representation
%              modal:        modal state space system (continuous)
%              strf:         s-transfer function (rational function)
%              ztrf:         z-transfer function (rational function)
%              qtrf:         q-transfer function (rational function)
%              szpk:         s-transfer function (zero/pole/K)
%              zzpk:         z-transfer function (zero/pole/K)
%              qzpk:         q-transfer function (zero/pole/K)
%              fqr:          frequency response representatiomns
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
