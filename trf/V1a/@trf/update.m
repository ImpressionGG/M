function oo = update(o,title,comment)
%
% UPDATE   Update a transfer function with title and comment
%
%             title = 'PT1 System';
%             comment = {'PT1(s) = 1/(1+s*T)};
%             list = {'V','Gain','T','Time Constant'};
%
%             oo = update(o,title,comment,list)
%
%          See also: TRF
%
   if (nargin < 2)
      title = get(o,{'title','Transfer Function'});
   end
   if (nargin < 3)
      list = get(o,{'comment',{}});
      comment = {};
      for (i=1:length(list))
         if isequal(findstr('   Transfer',list{i}),1)
            if length(comment) > 0
               comment(end) = [];
            end
            break
         else
            comment{i} = list{i};
         end
      end
   end
   
      % get description information about transfer function
      
   G = data(o);
   list = tffdisp(G);
   
   if ischar(comment)
      comment = {comment};
   end
   
   comment{end+1} = '';
   for (i=1:length(list))
      comment{end+1} = list{i};
   end
   
   oo = set(o,'title',title);
   oo = set(oo,'comment',comment);
end