% intro_camera
echo on
%
% CREATE A PHOTO OF OUR CHIP
% ==========================
%
% Now create a camera with proper position and view angle and let's 
% see how our fictive camera would shoot a photo of our chip.
%
;; C = camera([0 8 2],[20 40],[20 30 30]*deg); % describes our camera
;; F = photo(C,V);                             % our foto of the chip
%
% Let's see the foto
%
;; hold off                                    % don't hold exist. graphics
;; vplt(F,'b');                                % plot vector set F
;; set(gca,'DataAspectRatioMode','manual')     % set 1:1 aspect ratio
%
[];