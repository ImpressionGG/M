function [o1,o2,o3] = cost(o,arg1)
%
% COST    Deal with machine cost
%
%            [costs,labels,tags] = cost(o)       % get nominal cost
%            [costs,labels] = cost(o,relcost)    % get specific costs
%
%         Copyright(c): Bluenetics 2020
%
%         See also: ULED
%
   if (nargin <= 1)
      [o1,o2,o3] = Cost(o);
   elseif (nargin == 2)
      [o1,o2] = Specific(o,arg1)
   else
      error('1 or 2 input args expected');
   end
end

%==========================================================================
% Nominal Costs
%==========================================================================

function [costs,labels,tags] = Cost(o)
   table = {
               {'wh', 'Wafer Handling',       10}
               {'ph', 'Panel Handling',       20}
               {'in', 'Inspection',           15}
               {'mt', 'MPA Tool',             31}
               {'bh', 'Rest of Bond Head',    45}
               {'pi', 'Post Inspection',      58}
               {'bm', 'Bad Material Handling',88}
               {'d1', 'Divers 1',             55}
               {'d2', 'Divers 2',            769}
           };
        
   for (i=1:length(table))
      entry = table{i};
      tags{1,i} = entry{1};
      labels{1,i} = entry{2};
      costs(1,i) = entry{3};
   end
end
