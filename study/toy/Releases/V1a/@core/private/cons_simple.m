% cons_simple
echo on;
%
% SIMPLE SHELL CONSTRUCTION
% =========================
%
% This demo shows how a SHELL object can be created in the simplest way:
%
;; she = shell   % create a SHELL object with #GENERIC format
%
% We can display the contents of the SHELL object by using the disp()
% method.
%
;; disp(she)
%
% As we can see the internal data structure of a SHELL object consists of
% four components: tag, format, parameter and data
%
[];