function display(o,s)
%
% DISPLAY   Display a QUARK object
%
%              display(o)     % display QUARK object
%              display(o,s)   % display another structure
%
%           Code lines: 30
%
%           See also: QUARK
%
   if (nargin == 2)
      Disp(s,"    ");
      return
   end

   fprintf('%s object\n',upper(class(o)));
   tags = {'tag','typ','par','dat'};
   fprintf('  MASTER Properties:\n');
   for (i=1:length(tags))
      tag = tags{i};
      value = prop(o,tag);

      fprintf('    %s: ',tag);
      if isstruct(value)
         fprintf('\n');  Disp(value,"      ");
      elseif isa(value,'cell')
         fprintf('{');
         sep = '';
         for (i=1:length(value))
            oo = value{i};
            fprintf("%s<%s: %s>",sep,class(o),type(o));
            sep = ',';
         end
         fprintf('}\n'); 
      elseif isa(value,'char')
         fprintf('''''\n');
      elseif ~isempty(value)
         disp(value); 
      else
         fprintf('[]\n');
      end
   end
%
% Now print the work properties
%
   fprintf('  WORK Property:');
   bag = work(o);
   if isstruct(bag)
      fprintf('\n');  Disp(bag);
   elseif ~isempty(bag)
       disp(bag); 
   else
       fprintf('\n    []\n');
   end
end

function Disp(bag, indent)
   if (nargin == 1)
      indent = "    ";
   end
   tags = fieldnames(bag);
   for (i=1:length(tags))
      tag = tags{i};
      fprintf("%s%s:",indent,tag);
      value = eval(["bag.",tag]);
      if (isa(value,"double"))
         if (length(value) == 0)
            fprintf(" []\n");
         elseif (length(value)==1)
            fprintf(" %g\n",value);
         elseif (length(value(:))<=10)
            fprintf(" [");
            rsep = ""; csep = "";
            [m,n] = size(value);
            for (i=1:m)
               fprintf("%s",rsep);  
               rsep = ";";             % row separator
               for (j=1:n)
                  fprintf("%s%g",csep,value(i,j)); 
                  csep = " ";
               end 
            end
            fprintf("]\n");
         else
            fprintf(" [%gx%g]\n",size(value,1),size(value,2));
         end
      elseif (isa(value,"char"))
         if (size(value,1)==1)
            fprintf(" \"%s\"\n",value)
         else
            fprintf(" \"%gx%g\"\n",size(value,1),size(value,2));
         end        
      elseif (isa(value,"struct"))
         fprintf("\n");
         Disp(value,[indent,"  "]);
      elseif (isa(value,"quark"))
         fprintf(" <%s: %s>\n",class(value),type(value));
      elseif (isobject(value))
         fprintf(" <object %s>\n",class(value));
      elseif (iscell(value))
         fprintf("CELL\n");
      elseif (isa(value,"function_handle"))
         fprintf(" %s\n",char(value));
      else
         fprintf("\n");
      end
   end
end
