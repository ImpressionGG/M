function oo = step(o,name,duration,level,color,text)
%
% STEP   Create a step object used for discrete process simulation
%      
%            oo = step(o,name,duration,level,color);  % create step object
%
%        Examples:
%
%           oo = step(o,'S1');              % duration = 10, level = [0 1] 
%           oo = step(o,'S1',20,[1 2],'r'); % 20 ms, level: 1->2, color red 
%
%        See also: CARASIM, SEQUENCE, PROCESS, PLOT
%
   if (nargin < 2)
      error('must provide a name!');
   end
   if (nargin < 3)
      duration = 10;
   end
   if (nargin < 4)
      level = [0 1];
   end
   if (nargin < 5)
      color = 'y';
   end
   if (nargin < 6)
      text = '';
   end

   if (length(level) > 2 || length(level) < 1)
      error('arg3 must be scalar or 2-vector!');
   end
   
   oo = init(carasim('step'));
   oo.data.name = name;
   oo.data.text = text;
   oo.data.duration = duration;
   oo.data.level = level;
   oo.data.color = color;
   oo.data.kind = oo.type;
end
