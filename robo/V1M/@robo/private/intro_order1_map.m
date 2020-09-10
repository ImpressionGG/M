% intro_order1_map
echo on
%
% CALCULATE A LINEAR MAP
% ======================
%
% Now we have original coordinates (vector set V - the black picture) and
% a transformed picture (vector set F - generated as a foto of our
% original). As we have chosen the map from V to F is nonlinear, since we
% have some non-linear perspective deformation.
%
% One could ask now for a linear map from V to F. This is not possible, as
% we know the map must be non-linear. But we could ask for a linear map 
%
%     C1: V -> F1    (linear map)
%
% where F2 is a best-case approximation of F with respect of all second 
% order maps. Such kind of map can be easily found:
%
;; C1 = map(V,F,1);   % the 2 (3rd arg) means an order-2 (second order) map
;; F1 = map(C1,V);    % apply map C1 to our original vector set V to get F2
%
% Let's see how this approximated image matches our original image F
%
;; hold on            % hold previous graphics; don't replace
;; vplt(F1,'m');      % plot vector set (describing image of linear map)
%
% We see that the linearly mapped image does not exactly fit the original
% image. Let's calculate the mapping error
%
;; dF = F-F1;                 % difference
;; dF(find(isnan(dF))) = [];  % delete all NaN's
%
;; err1 = norm(dF);        % mapping error
;; title(sprintf('Mapping Error = %g',err1));
%
[];
[];