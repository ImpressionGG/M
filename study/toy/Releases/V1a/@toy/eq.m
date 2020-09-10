function same = eq(ob1,ob2)
% 
% EQ      TOY object equality
%
%             H1 = space(toy,1:3);
%             H2 = space(toy,1:3);
%
%             same = (S1==S2); 
%
%         See also: TOY, PLUS, MINUS, MTIMES, TIMES
%
   typ1 = type(ob1);  typ2 = '';
   
   if isa(ob2,'toy')
      typ2 = type(ob2);
   end
   
   if ~strcmp(typ1,typ2)
      same = 0;             % not equal!
      return
   end
   
% dispatch type of ob1

   switch [typ1,typ2]
      case {'#VECTOR#VECTOR'}
         same = 1;
         same = same && (space(ob1) == space(ob2));
         
         [m1,n1] = dim(ob1);
         [m2,n2] = dim(ob2);
         same = same && (m1 == m2) && (n1 == n2);
         same = same && [(ket(ob1) && ket(ob2)) || (bra(ob1) && bra(ob2))];
         if (same)
            M1 = matrix(ob1);
            M2 = matrix(ob2);
            same = same && (all(all(abs(M1-M2) < 30*eps)) + 0);
         end
         return
         
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
