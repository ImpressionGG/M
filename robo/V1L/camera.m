function [C,cu] = camera(r0,geometry,mrpy,cu)
%
% CAMERA    Definition of a camera corrdinate frame as a homogeneous
%           coordinate matrix.
%
%              C = camera(r0,[lambda,h],[roll,pitch,yaw],cu)
%              [C,cu] = camera(r0,[lambda,h],[roll,pitch,yaw])   % cu = lambda/h
%              [C,cu] = camera(r0,[lambda,h])                    % roll=pitch=yaw=0
%              C = camera                                        % camera to play (see example)
%
%           Meaning of the arguments
%
%              C: homogeneous coordinate frame matrix of camera
%              r0: 2D,3D or 4H vector of rotation point of camera axis (row or column)
%              lambda: image plane distance to lense center
%              h: object distance to lense center
%              roll:  roll angle  [rad] (z-axis-rotation)
%              pitch: pitch angle [rad] (y-axis-rotation)
%              yaw:   yaw angle   [rad] (x-axis rotation)
%              cu: camera unit, expressed in world coordinate units
%
%           If one chooses cu = lambda/h (default if argument is omitted)
%           the image of the photo projection is congruent to the
%           original if in addition roll = pitch = yaw = 0.
%
%           Theory:
%
%              1) rK = RPY(roll,pitch,yaw)*[0 0 -(h+lambda)]'
%              2) TU = RPY(roll,pitch,yaw)*diag([-cu -cu cu])
%              3) C = hproj(lambda/cu)*inv(hom(TU,r0+rK))
%
%           Example 1:
%
%              [C,cu] = camera([0 2 0],[80 40],[30 30 30]*deg);
%              V = vchip;
%              F = photo(C,V);
%              vplt(F);
%
%           Example 2:
%
%              C = camera([0.2 0.2 0],[82.6 37.9],[35 30 25]*deg);
%
%           Example 3:
%
%              C = camera([0.2 0.2 0],[80 40]);
%
%           Example 4:
%
%              C = camera   % same as C=camera([0.2 0.2 0],[80 40],[35 30 25]*deg);
%
%           See also: ROBO, HOM, IHOM, PRXY, PHOTO, VPLT
%
   if ( nargin == 0)
      C = camera([0.2 0.2 0],[80 40],[35 30 25]*deg);  % camera to play
      return
   end
   
   if (nargin < 2)
      error('At least two input args expected!')
   end
   
   lambda = geometry(1);  h = geometry(2);
   
   if (nargin < 3) mrpy = [0 0 0]'; end
   if (nargin < 4) cu = lambda/h;  end
   
   if (length(mrpy) ~= 3) error('arg3 must be a 3-vector!'); end
   roll = mrpy(1);
   pitch = mrpy(2);
   yaw = mrpy(3);
   
   if ( length(r0) < 2 | length(r0) > 4 )
      error('arg1 must be 2-,3- or 4-vector!')
   end
   
   r0 = r0(:);
   if ( length(r0) == 2 )
      r0 = [r0;0];
   elseif ( length(r0) == 4 )
      r0 = ihom(r0);
   end
   
% do calculations

   Trpy = rpy(roll,pitch,yaw);
   rK = Trpy*[0 0 -(h+lambda)]';
   TU = Trpy*diag([-cu -cu cu]);
   C = hproj(lambda/cu)*inv(hom(TU,r0+rK));
   
% eof
   