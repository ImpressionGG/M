% intro_order2_map
echo on
%
% CALCULATE A SECOND ORDER MAP
% ============================
%
% We will now see that a second order approximation improves the match.
%
%     C2: V -> F2   (second order map)
%
% where F2 is a best-case approximation of F. Such kind of map can be
% easily found:
%
;; C2 = map(V,F,2);   % the 2 (3rd arg) means an order-1 (linear) map
;; F2 = map(C2,V);    % apply map C2 to our original vector set V to get F2
%
% Let's see how this approximated image matches our original image F
%
;; hold on            % hold previous graphics; don't replace
;; vplt(F2,'r');      % plot vector set (describing image of linear map)
%
% We see that the second order image is meeting the original image much 
% better. Let's calculate the mapping error
%
;; dF = F-F2;                 % difference
;; dF(find(isnan(dF))) = [];  % delete all NaN's
%
;; err2 = norm(dF);         % mapping error
;; title(sprintf('Mapping Error = %g (versus %g before)',err2,err1));
%
[];