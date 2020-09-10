% test_shellcreate
echo on
%
% TEST VARIOUS MODES OF SHELL CREATION 
% ====================================
%
pause; shell test      % create & open a Test Shell ...
%
pause; delete(gcf)     % delete figure ...
%
pause; shell tutorial  % Create & open a Tutorial Shell ...
%       
pause; delete(gcf)     % delete figure ...
%
pause; shell toolbox   % Create & open a Toolbox Shell ...
%       
pause; delete(gcf)     % delete figure ...
%
% done!
[];