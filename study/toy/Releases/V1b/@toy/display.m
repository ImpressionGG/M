function display(obj,typ)
%
% DISPLAY    Display a toy object
%
%    syntax
%       x = toy;
%       display(x);
%       display(x,'#TENSOR');
%       display(x,'#LIST');
%       display(x,'#SPACE');
%
%    See also: TOY, DISP, INFO
%
   typ = type(obj);
   switch typ
      case '#GENERIC'
         fprintf('   <generic toy>\n');
         return
         
      case '#VECTOR'
         S = space(obj);
         %fprintf(['   <vector: ',info(S),'>\n']);
         mat = matrix(obj);
         %disp(mat);
         
         labels = property(obj,'labels');
         %[index,jdx,s] = find(mat(:));
         [idx,jdx,s] = find(mat);
         
         [mo,no] = size(labels);
         
         if isempty(idx) || all(abs(s) < 30*eps)
            if data(obj,'vector.bra')
               fprintf('   <%gx%g null|\n',mo,no);
            else
               fprintf('   |%gx%g null>\n',mo,no);
            end
         else
            for (i=1:length(idx))
               if (abs(s(i)) >= 30*eps)
                  sym = labels{idx(i),jdx(i)};
                  if property(obj,'ket?')
                     k = (jdx(i)-1)*mo + idx(i);
                     itxt = sprintf('                      [%g] ',k);
                     itxt = itxt(end-10:end);
                     if imag(s(i)) == 0
                        txt = sprintf(['%12g * |',sym,'>',itxt],s(i));
                     elseif abs(s(i)-(+sqrt(-1))) < 30*eps
                        txt = sprintf(['           i * |',sym,'>',itxt]);
                     elseif abs(s(i)-(-sqrt(-1))) < 30*eps
                        txt = sprintf(['          -i * |',sym,'>',itxt]);
                     elseif imag(s(i)) > 0
                        txt = sprintf(['%12g + %g i * |',sym,'>',itxt],real(s(i)),abs(imag(s(i))));
                     else
                        txt = sprintf(['%12g - %g i * |',sym,'>',itxt],real(s(i)),abs(imag(s(i))));
                     end
                     fprintf([txt,'@ (%g,%g)\n'],jdx(i),idx(i));
                  else
                     k = (jdx(i)-1)*mo + idx(i);
                     itxt = sprintf('                      [%g] ',k);
                     itxt = itxt(end-10:end);
                     if imag(s(i)) == 0
                        txt = sprintf(['%12g * <',sym,'|',itxt],s(i));
                     elseif imag(s(i)) > 0
                        txt = sprintf(['%12g + %g i * <',sym,'|',itxt],real(s(i)),abs(imag(s(i))));
                     else
                        txt = sprintf(['%12g - %g i * <',sym,'|',itxt],real(s(i)),abs(imag(s(i))));
                     end
                     fprintf([txt,'@ (%g,%g)\n'],idx(i),jdx(i));
                  end
               end
            end % for i
         end
         return

      case '#OPERATOR' 
         if either(option(obj,'weight'),0)
            weight = norm(obj)^2;
            fprintf('   <weight %3.2f>\n',weight);
            return
         end

         n = dim(obj);
         M = matrix(obj);
         sym = property(obj,'symbol');
         
         S = operator(space(obj),'>>');

         if property(S'*obj,'eye?')
            fprintf('   <operator [>>] (%g)>\n',n);
            return         
         elseif property(S*obj,'eye?')
            fprintf('   <operator [<<] (%g)>\n',n);
            return         
%          elseif property(obj,'eye?')
%             fprintf('   <operator [1] (%g)>\n',n);
%             return         
%          elseif property(S*obj,'null?')
%             fprintf('   <operator [0] (%g)>\n',n);
%             return         
         end
         
         if ~isempty(sym)
            fprintf(['   <operator: %gx%g [',sym,']>\n'],n,n);
         elseif ~any(any(abs(M)>=30*eps))
            fprintf('   <null operator: %gx%g>\n',n,n);
         elseif ~any(any(abs(M-matrix(eye(obj))) >= 30*eps))
            fprintf('   <identity operator: %gx%g>\n',n,n);
         else
            fprintf('   <operator: %gx%g>\n',n,n);
         end
         return
               
      case '#PROJECTOR' 
         txt = info(obj);
         fprintf(['   <projector: ',txt,'>\n']);
%          symbols = property(obj,'symbols'); 
%          index = data(obj,'proj.index');
%          symbols = symbols(index);
%          
%          for i=1:length(symbols)
%             fprintf([symbols{i}]);
%             if (i<length(symbols))
%                fprintf(',');
%             end
%          end
%          fprintf(']>\n');
         return
      
      case '#SPACE'
         fprintf(['   <space: ',info(obj),'>\n']);
         return
         
      case '#SPLIT'
         [txt,txt1] = info(obj);
         fprintf(['   ',txt1,'\n']);
         
      case '#UNIVERSE'
         [m,n] = dim(obj);
         list = property(obj,'list');
         fprintf('   <universe %gx%g (%g)>\n',m,n,length(list));
         for (i=1:length(list))
            S = list{i};
            fprintf(['      split(%g): ',info(S),'\n'],i);
         end

      case '#HISTORY'
         [~,txt1] = info(obj);
         fprintf(['   ',txt1,'\n']);
         
   end

   return
end   