% startup.m - Matlab startup file
%
% STARTUP   For a very new Matlab installation proceed as follows:
%              - in the MATLAB command shell enter "edit startup"
%              - copy the text of tis file into the MATLAB staretup file
%              - save file (startup.m should be saved in your home directory)
%              - restart MATLAB
%
%           See also: USE, MHOME
%
    clc
    fprintf('MATLAB %s on OsX for Hux\n',version);
    addpath('/users/hux/Documents/Bluenetics/Git/M/site/macml');
    addpath('/users/hux/Documents/Bluenetics/Git/M/use');
    cd([mhome,'/work']);
    use;

% eof
