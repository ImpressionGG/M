function out = robo(varargin)
%
% ROBO   Robotics Toolbox. ROBO objects are more or less dummy objects to
%        provide class methods. ROBO objects are derived shell objects
%        which allows an easy support of a tutorial
%
%           obj = robo;    % generic robo object
%           robo;          % launch ROBO tutorial shell
%
%        Methods
%
%           tutorial    (+) ROBO tutorial
%           version     (+) ROBO toolbox version & release notes/known bugs
%           menu        (-) Menu for ROBO object
%
%        See also: SHELL 
%
%
% Vectors, vector sets and coordinates
% ====================================
%
%    Vectors are represented by n x 1 matrices, where n = 2,3,4.
%
%       2 x 1 column vectors: represent 2D-vectors
%       3 x 1 column vectors: represent 3D-vectors
%       4 x 1 column vectors: represent 4H-vectors (homogeneous coordinates)
%
%    Vector sets ar sets of n vectors v1,v2,...,vm. A vector set is
%    represented by a n x m matrix, where n = 2,3,4. The meaning 
%    of n is the same as with vector representations. The vectors
%    of a vector set may be separated by NANs, which can be used to
%    group vectors to represent connected line shapes.
%
%
% Homgeneous Coordinates (4H-coordinates)
% =======================================
%
%    HOM       convert to homogeneous 4H vector or transformation matrix
%    H2M       convert to homogeneous 3H vector or transformation matrix
%    IHOM      inverse homogeneous transformation
%
% Scale and Share Matrices
% ========================
%
%    SCALE     Scale Matrix
%    SHEAR     Shear Matrix
%
% Rotation Matrices
% =================
%
%    ROT       2D rotation
%    ROTX      3D-x-axis rotation
%    ROTY      3D-y-axis rotation
%    ROTZ      3D-z-axis rotation
%    RPY       Roll-Pitch-Yaw rotation matrix
%
% Homogeneous coordinate transformation (4H matrices)
% ===================================================
%
%    HTRAN     2D or 3D-Translation
%    HROTX     3D-x-axis rotation (homogeneous coordninates)
%    HROTY     3D-y-axis rotation (homogeneous coordninates)
%    HROTZ     3D-z-axis rotation (homogeneous coordninates)
%    HRPY      Roll-Pitch-Yaw rotation matrix (homogeneous coordninates)
%
% Decomposition
% =============
%
%    RKS       RKS factorization of a matrix (rotation, scale and shear)
%    SKR       SKR factorization of a matrix (shear, scale and rotation)
%    HRKS      RKS-factorization of a 3H or 4H matrix
%    HSKR      SKR-factorization of a 3H or 4H matrix
%    HVDR      VDR-factorization of a 3H or 4H matrix
%
% Projection Matrices
% ===================
%
%    PRXY      x-y-plane projection
%    PRYZ      y-z-plane projection
%    PRZX      z-x-plane projection
%
%    EXTZ      extend 2-D-vectors to 3-D-vectors by z-coordinate
%
%    HPROJ     perspective projection matrix (homogeneous coordninates)
%
% Camera operations
% =================
%
%    CAMERA    defnition of a caera coordinate frame
%    PHOTO     photo projection (with respect to a camera)
%
% Vector sets
% ===========
%
%    VSET      Create a vector set
%    VCAT      Vector concatenation separated by NANs
%    VMOVE     Move a vector set
%    VPLT      draw a plot of a vector set
%    VRECT     Vector set representing rectangle
%    VCIRC     Vector set representing circle
%    VTEXT     Vector set representing text
%    VCHIP     Vector set representing a virtual chip
%    VELIM     Eliminate all columns with NANs of a vector set
%    VSAME     Vector set consisting of the same columns
%
% Mapping
% =======
%
%    MAP       General mapping and map calculation
%    NLMAP     Nonlinear mapping
%    LIP       Linear interpolation
%    ILIP      Inverse linear interpolation
%    RESI      residual vector set of a mapping
%
% Analysis
% ========
%
%    DEVI      Devations of an error vector set
%    GANA      Graphical analysis of an error vector set
%    ANALYZE   Analyze a given vector set
%    CAPXYB    Capability analysis x/y - ball plot
%    CAPXYH    Capability analysis x/y - histogram
%    PLANARITY Analyse planarity deviations of a surface
%
% Miscellaneous
% =============
%
%    CORNERS   Get corner indies of a vector set
%    MAPDEMO   Demonstrates several kinds of mapping and map calculation
%    MATRIX    get matrix representation of a vector set
%    REORDER   reorder a vector set from rowwise to column wise point order
%    RSTD      radial standard deviation
%    XPROD     ex-product (outer product) of two 3D vectors
%
   [obj,she] = derive(shell(varargin),mfilename);    % simple derivation
   obj = class(obj,obj.tag,she);                    % make a class object
   
% apply menu method when nargout = 0;

   if (nargout == 0)
      tutorial(obj);
   else
      out = obj;    % otherwise assign obj to output arg
   end
   return


% eof
