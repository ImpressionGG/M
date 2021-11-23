%
% PROFILER   Collect/display profiling info
%
%    First arg is a smart object which has so far no meaning except enable
%    access to CORE method profile()
%
%       old = o.profiler('on');        % switch profiler on
%       old = o.profiler('off');       % switch profiler off
%
%       o.profiler('debug');           % print internal structure
%
%       o.profiler([]);                % init
%
%       o.profiler('main',1)           % begin profiling
%       o.profiler('sub1',1)           % begin profiling
%       o.profiler('sub1',0)           % end profiling
%       o.profiler('sub2',1)           % begin profiling
%       o.profiler('sub2',0)           % end profiling
%       o.profiler('main',0)           % end profiling
%
%       o.profiler('load.begin')       % store time stamp
%       o.profiler('load.end')         % store time stamp
%
%       o.profiler                     % show profiling info
%
%    Profile time stamps can be nested. An internal stack tracks
%    the nesting.
%
%    Profiling demos:
%
%       o.profiler(0)                  % run profiling demo #0
%       o.profiler(1)                  % run profiling demo #1
%       o.profiler(2)                  % run profiling demo #2
%       o.profiler(5)                  % run profiling demo #5
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORAZITO
%
