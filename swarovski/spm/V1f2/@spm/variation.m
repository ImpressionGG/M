function vtab = variation(o,vtab)
%
% VARIATION   Set specific variations for eigenfrequency and damping of 
%             particular modes. These specific variations act in addition
%             to a global variation.
%
%             1) set variation accordiong to variation table (vtab)
%
%                vtab = [0 0, 1 0.5; 9 12, 1 0.8; 15 24, 1 0.8]
%                variation(o,vtab)     % set variations according to vtab
%
%             Remarks:
%             a) Each line in vtab describes a mode range (from ... to) 
%                and variation constants komega,kzeta for omega and zeta
%                variation in the designated range. Lines are processed top
%                down and it is possible that variations in upper lines
%                are redefinedf (over-written) by definitions in lower
%                lines.
%
%             b) If object (arg1) can be identified by object id as either
%                the shell object or a shell's child object then variation
%                table is permanently stored as 'variation' parameter in
%                the particular shell object or shell's child object
%
%             c) In order that variation gets into effect the according
%                settings must be enabled. The 
%
%             Example 1: (3 column vtab)
%
%                vtab = ...
%                [
%                   0  0,  1  0.5   % omega*1, zeta*0.5 for all modes
%                   9 12,  1  0.8   % omega*1, zeta*0.8 for modes 9:12
%                  15 24,  1  0.8   % omega*1, zeta*0.8 for modes 15:24 
%                ];
%
%             Copyright(c): Bluenetics 2021
%
%             See also: SPM
%

end
