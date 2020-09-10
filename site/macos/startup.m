% startup.m - Octave startup file
%
% Startup file for OsX, copy into home directory. You examine the 
% home directory path by starting Octave and entering 'pwd'!
%
    clc
    fprintf('Octave %s on OsX for Hux\n',version);
    addpath('/users/hux/Desktop/Home/m/site/macos');
    addpath('/users/hux/Desktop/Home/m/use');
    cd(mhome);
    use;

% eof
