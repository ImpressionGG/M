function obj = pulse(dp,durat,level)
%
% PULSE  Pulse modifyer for Discrete Process Object
%      
%            dp = pulse(dproc('P1'),duration,level);  % create pulse DPO
%            dp = pulse(dproc('P2'));  % duration = 1, level = 1 
%
%        Meaning of arguments
%            duration:    duration of ramp
%            level:       pulse height
%                         2-vector: absolute ramp levels (begin and end level)
%
%        Examples:
%
%            pulse(dproc('A1',20,[0 1]));  % pulse from 0 to 1 in 20 time units
%            pulse(dproc('A2',50,-1);      % relative pulse decreasing by -1 in 50 time units
%
%   See also   DISCO, DPROC

   if (~isa(dp,'dproc')) error('arg1: DPROC object expected!'); end

% Define default property values

   dat = data(dp);
   dat.type = 'pulse';
   dat.kind = 'pulse';

% defaults

   if (nargin < 2) durat = 1; end
   if (nargin < 3) level = 1; end

% check

   if (length(level) > 2 | length(level) < 1)
      error('arg3 must be scalar or 2-vector!');
   end

% set parameters

   if iscell(durat)
      dat.idx = durat{1};
      dat.moti = durat{2};
      dat.duration = round(duration(dat.moti,dat.idx)*1000);
    else
      dat.duration = durat;
   end
   
   dat.level = level;

% create class object

   obj.data = dat;
   obj = class(obj,'dproc');  % convert to class object

% eof
