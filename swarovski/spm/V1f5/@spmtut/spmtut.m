classdef spmtut < corazon                 % SPMTUTClass Definition
%
% SPMTUT  SPMTUT is the constructor for SPMTUT class instances (objects),
%         which is the basis for SPM Tutorial shell
%
%            spmtut     open spm tutorial shell
%
   methods                             % public methods
      function o = spmtut(arg)         % spm tutorial constructor
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
