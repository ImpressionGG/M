% startup.m - Octave startup file
%
% Startup file for Windows, copy into home directory. You examine the 
% home directory path by starting Octave and entering 'pwd'!
%
    clc
    fprintf('Octave %s on Windows for Hux\n',version);
    addpath('z:/Schreibtisch/Home/m/site/windows');
    addpath('z:/Schreibtisch/Home/m/use');
    cd z:/Schreibtisch/Home/m/work
    use;

% eof
