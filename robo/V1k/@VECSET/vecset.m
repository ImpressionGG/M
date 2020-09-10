function obj = vecset(Vx,Vy)
%
% VECSET    Constructor for vector sets
%
%              v = vecset(Vx,Vy)       % construct matrix based vector set
%              v = vecset(obj)         % copy constructor
%
%           VECSET Methods
%
%              data     retrieve vector set data
%              dim      matrix dimension, in case of a matrix
%              mul      trafo multiplication
%              add      add another vector set or offset to vector set
%
%           See also: ROBO DATA DIM ADD MUL
%
   obj.V = vset(Vx,Vy);
   V = class(obj,'
   
   obj = class(obj,'vecset');  % convert to class object
