classdef spm < corazon                 % Spm Class Definition
%
% SPM   SPM is the constructor for SPM class instances (objects)
%
%       The following types are supported:
%
%          'spm':       SPM data objects
%          'pkg':       SPM data packages
%          'shell':     SPM shell object
%
%       Key Methods:
%
%          shell:       construction of SPM (toobox) shell
%
%          cook:        cook up key variables like system matrices
%                       (A,B,C,D), critical frequency and gain (f0,f180,
%                       K0,K180), characteristic functions (l0) and many
%                       others. The cook method is basically reading out
%                       the proper cache segments, which are calculated by
%                       brew.
%
%          brew:        data brewing method, mainly to calculate cache
%                       contents
%
%          diagram:     plot many of the supported diagrams
%
%          damping:     manually override damping values of A-matrix
%
%          system:      create a CORASIM system representation based on
%                       original SPM matrices (A,B,C,D) under the following
%                       modifications:
%                          - parameter variations (omega,zeta)
%                          - time normalization
%                          - coordinate transformation
%                          - contact based selection
%
%          principal:  calculate principal system L0 as a state space
%                      representation 
%
%          critical:   calculate critical quantities (K0,f0,K180,f180,L0)
%
%          lambda:     calculate spectral frequency responses (lambda0) and
%                      related quantities (g31,g33,PsiW31,PsiW33)
%
%          gamma:      critical spectral quantity, also carrying critical
%                      gain and frequency, as well as psion functions
%                      and spectral frequency responses. gamma is the
%                      fastest way to calculate critical quantities
%
%          sensitivity: calculate/plot weight and damping sensitivity
%
%          png:        export current figure contents to .png file in
%                      standard PNG directory
%
   methods                             % public methods
      function o = spm(arg)            % spm constructor
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
