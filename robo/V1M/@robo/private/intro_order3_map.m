% intro_order3_map
echo on
%
% CALCULATE A THIRD ORDER MAP
% ============================
%
% We will now see that a second order approximation improves the match.
%
%     C3: V -> F3   (third order map)
%
% where F3 is a best-case approximation of F. Such kind of map can be
% easily found:
%
;; C3 = map(V,F,3);   % the 1 (3rd arg) means an order-1 (linear) map
;; F3 = map(C3,V);    % apply map C3 to our original vector set V to get F3
%
% Let's see how this approximated image matches our original image F
%
;; hold on            % hold previous graphics; don't replace
;; vplt(F3,'g');      % plot vector set (describing image of linear map)
%
% We see that the second order image is meeting the original image much 
% better. Let's calculate the mapping error
%
;; dF = F-F3;                 % difference
;; dF(find(isnan(dF))) = [];  % delete all NaN's
%
;; err3 = norm(dF);         % mapping error
;; title(sprintf('Mapping Error = %g (versus %g before)',err3,err2));
%
[];