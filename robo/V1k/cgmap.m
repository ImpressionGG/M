function Cyx = cgmap(X,Y)
%
% CGMAP   Calculate a congruence map from [x1,x2] to [y1 y2] where x1,x2 
%         and y1,y2 are 2d-vectors. The congruence map Cyx is represented
%         as H3 matrix and consists only of rotation and translation.
%
%         Example:
%
%             Tyx = hom(rot(pi/8),[7;3])  % this is a congruence map
%             X = magic(2);
%             Y = map(Tyx,X);
%
%             Cyx = cgmap(X,Y)     % reconstruct congruence map 
%             norm(Tyx-Cyx)
%

% Change history
%    2009-11-29 created (Robo/V1k)

    [mx,nx] = size(X);  [my,ny] = size(Y);
    if (any([ mx nx my ny]~=2))
        error('arg1 & arg2 must be 2 x 2 matrices');
    end
    
    x = X(:,2) - X(:,1);    phiX = atan2(x(2),x(1));
    y = Y(:,2) - Y(:,1);    phiY = atan2(y(2),y(1));

    R = rot(phiY-phiX);                      % Rotationsmatrix
    Y0 = Y - R*X;                            % Offset von [x1,x2]
    y0 = mean(Y0')';                         % y0 = (y1+y2)/2
    Cyx = hom(R,y0);                         % Kongruenztransformation

%eof    