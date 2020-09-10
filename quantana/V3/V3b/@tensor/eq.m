function same = eq(ob1,ob2)
% 
% EQ      Tensor equality
%
%             S1 = space(tensor,1:3);
%             S2 = space(tensor,1:3);
%
%             same = (S1==S2); 
%
%         See also: TENSOR, PLUS, MINUS, MTIMES, TIMES
%
   fmt1 = format(ob1);  fmt2 = '';
   
   if isa(ob2,'tensor')
      fmt2 = format(ob2);
   end
   
   if ~strcmp(fmt1,fmt2)
      same = 0;             % not equal!
      return
   end
   
% dispatch format of ob1

   switch [fmt1,fmt2]
      case {'#SPACE#SPACE'}
         sp1 = data(ob1,'space');
         sp2 = data(ob2,'space');

         same = 1;
         same = same && all(size(sp1.list)==size(sp2.list));
         same = same && all(size(sp1.size)==size(sp2.size));
         same = same && all(size(sp1.basis)==size(sp2.basis));
         same = same && all(size(sp1.labels)==size(sp2.labels));
         
            % next check is a check on top level, but we do not
            % check equality in nested levels
            
         if (same)
            for (i=1:length(sp1.labels(:)))
               if ischar(sp1.labels{i})
                  same = same && ischar(sp2.labels{i});
                  if (same)
                     same = same && strcmp(sp1.labels{i},sp2.labels{i});
                  end
               end
            end
         end
         return
   end
   
   error('cannot perform tensor equality!');
end
