function [ob1,ob2] = ramp(dp,durat,level,col)
%
% RAMP   Ramp modifyer for Discrete Process Object
%      
%            dp = ramp(dproc('A1'),duration,level);  % create ramp DPO
%            dp = ramp(dproc('A1'));  % duration = 1, level = 1 
%
%            [dp1,dp2] = ramp(dproc('A1'),mo,level);  % create two ramp DPO, described by MOTI object mo
%
%        Meaning of arguments
%            duration:    duration of ramp
%            level:       scalar:   relative ramp height
%                         2-vector: absolute ramp levels (begin and end level)
%
%        Examples:
%
%            ramp(dproc('A1',20,[0 1]));  % ramp from 0 to 1 in 20 time units
%            ramp(dproc('A2',50,-1);      % relative ramp decreasing by -1 in 50 time units
%
%   See also   DISCO, DPROC

   if (~isa(dp,'dproc')) error('arg1: DPROC object expected!'); end

% Define default property values

   dat = data(dp);
   dat.type = 'ramp';
   dat.kind = 'ramp';
   if (nargin >= 4)
      dat.color = col;
   end

% defaults

   if (nargin < 2) durat = 1; end
   if (nargin < 3) level = 1; end

% check

   if (length(level) > 2 | length(level) < 1)
      error('arg3 must be scalar or 2-vector!');
   end

% set parameters

   switch class(durat)
   case 'cell'
      dat.idx = durat{1};
      dat.moti = durat{2};
      dat.duration = round(duration(dat.moti,dat.idx)*1000);
   case 'moti'
      dat.moti = durat;
      dat.duration = round(duration(dat.moti)*1000);
   otherwise
      dat.duration = durat;
   end
   
  dat.level = level;

% create class object

   if (nargout == 2)
      tm = round(duration(dat.moti,[1 2])*1000);
      nam = dat.name;
      
      dat.idx = 1;
      dat.duration = tm(1);
      dat.name = [nam,'(1)'];
      ob1.data = dat;
      ob1.work = [];             % work properties
      ob1 = class(ob1,'dproc');  % convert to class object
      
      dat.idx = 2;
      dat.duration = tm(2);
      dat.name = [nam,'(2)'];
      ob2.data = dat;
      ob2.work = [];             % work properties
      ob2 = class(ob2,'dproc');  % convert to class object
   else
      ob1.data = dat;
      ob1.work = [];             % work properties
      ob1 = class(ob1,'dproc');  % convert to class object
   end
   
% eof
