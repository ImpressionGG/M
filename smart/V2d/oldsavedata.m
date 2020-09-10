function savedata(fout,arg,varname)
%
% SAVEDATA    Depending on the data class save data
%
%                savedata(fout,arg)           % pure data
%                savedata(fout,arg,varname)   % include varname to save
%
%             Example 1:
%                a = magic(3);
%                savedata(1,a);
%                savedata(1,a,'a');
%
%             Example 2:
%                s.e = exp(1);  s.pi = pi;
%                savedata(1,s,'s');
%
%             see also: SMART SAVE

   if (isempty(arg))
      kind = 'empty';   
   elseif (isobject(arg))
      kind = 'object';
   else
      kind = class(arg);
   end

   if (nargin >= 3)
      blanks = indent(varname);
      assignment = any(varname~=' ');  % assignment only for non-blank varname
   else
      blanks = '';
      assignment = 0;
   end
      
   if (assignment & ~strcmp(kind,'struct') & ~isobject(arg))
      fprintf(fout,[varname,' =']);
   end
   
   [m,n] = size(arg);
   switch kind
       case 'empty'
          if isstr(arg)
             fprintf(fout,' ''''');
          else
             fprintf(fout,' []');
          end
       case {'double','logical'}
          if (length(arg) ~= 1) fprintf(fout,' ['); end
          for (i=1:m)
             for (j=1:n)
                if isa(arg(i,j),'logical')
                   fprintf(fout,' %g',arg(i,j));
                elseif arg(i,j) == round(arg(i,j))
                   fprintf(fout,' %g',arg(i,j));
                else
                   fprintf(fout,' %2.16e',arg(i,j));
                end
             end
             if (i < m) fprintf(fout,['\n',blanks]); end
          end
          if (length(arg) ~= 1)
             if (m <= 1)
                fprintf(fout,']');
             else
                space = blanks(1:length(blanks)-1);
                fprintf(fout,['\n',space,']']);
             end
          end

       case 'cell'
          fprintf(fout,' {');
          for (i=1:m)
             for (j=1:n)
                argij = arg{i,j};
                if ~isa(argij,'struct')
                   savedata(fout,argij);
                else
                   savestruct(fout,argij,blanks);
                end
             end
             if ~isa(argij,'struct')
                fprintf(fout,['\n',blanks]);
             end
          end
          fprintf(fout,'}');
          
       case 'char'
          if (m == 1)
             if (any(arg < ' ' | arg > 'z' | arg == '%'))
                fprintf(fout,' setstr([');        
                for (j=1:n)
                   fprintf(fout,'%g ',arg(j)+0);
                end
                fprintf(fout,'])');
             else
                fprintf(fout,' ''%s''',arg);
             end
          else
             fprintf(fout,' setstr(');        
             savedata(fout,arg+0);
             fprintf(fout,')');
          end

       case 'struct'
          if (nargin < 3)
             error('savedata(): 3 args expected for saving structures!');
          end
          
          flds = fieldnames(arg);
          
          for (i=1:length(flds))
             member = ['arg.',flds{i}];
             val = eval(member);
             
             if isobject(val)
                fprintf('*** warning: ignore to save object!\n');
                varassign = [varname,'.',flds{i},' ='];
                fprintf(fout,varassign);
                savedata(fout,val,indent(varassign));
                fprintf(fout,';\n');
             elseif isa(val,'struct')
                if all(varname == ' ')
                   savestruct(fout,val,varname)
                else
                   savedata(fout,val,[varname,'.',flds{i}]);
                end
             else
                if all(varname == ' ')
                   savedata(fout,val,[varname,'.',flds{i}]);
                else
                   varassign = [varname,'.',flds{i},' ='];
                   fprintf(fout,varassign);
                   savedata(fout,val,indent(varassign));
                   fprintf(fout,';\n');
                end
             end
          end

      case 'object'
          if (nargin < 3)
             error('savedata(): 3 args expected for saving objects!');
          end
          
          flds = fieldnames(arg);
          
          for (i=1:length(flds))
             try
                val = field(arg,flds{i});
             catch
                fprintf('*** warning: ignore object during saving\n');
                val = [];
             end
             
             if (isa(val,'struct') | isobject(val))
                if all(varname == ' ')
                   savestruct(fout,val,varname)
                else
                   savedata(fout,val,[varname,'.',flds{i}]);
                end
             else
                varassign = [varname,'.',flds{i},' ='];
                fprintf(fout,varassign);
                savedata(fout,val,indent(varassign));
                fprintf(fout,';\n');
             end
          end
          cls = class(arg);
          fprintf(fout,[varname,' = ',lower(cls),'(',ltrim(varname),');  %% copy constructor\n']);
          
       otherwise
          error(['savedata(): class ',class(arg),' not supported!']);
   end
   
   if (assignment & ~strcmp(kind,'struct') & ~isobject(arg))
      fprintf(fout,';\n');
   end
   
   return

%==========================================================================
% Auxillary Functions
%==========================================================================

function savestruct(fout,arg,blanks);
%
% SAVESTRUCT   Save argument as a constructor for a structure
%
   %xblanks = ['   ',blanks];
   xblanks = indent(blanks);
   flds = fieldnames(arg);

   fprintf(fout,['struct(...\n',xblanks]);
   n = length(flds);   
   for (i=1:n)
      member = ['arg.',flds{i}];
      val = eval(member);
      fprintf(fout,['''',flds{i},''',']);
      savedata(fout,val,blanks);
      if i == n
         fprintf(fout,[' ...\n',xblanks]);
      else
         fprintf(fout,[',...\n',xblanks]);
      end
   end
   fprintf(fout,[')...\n',blanks]);
   %fprintf(fout,[') ',blanks]);
   return
   
function blanks = indent(varname)
%
% INDENT    Depending on leading blanks return an indentation string
%           of proper length for new lines.
%
%              blanks = indent(varname)
%
   n = 0;
   for (i=1:length(varname))
      if (varname(i) == ' ')
         n = i;
      else
         break     % no more chance if not leading blank
      end
   end
    
   n = length(varname) + 1;
   blanks = setstr(zeros(1,n)+' ');
   return

function s = ltrim(s)
%
% LTRIM     Left trim of a string (remove leading blanks)
%
%              s = ltrim(s)
%
   n = 0;
   for (i=1:length(s))
      if (s(i) == ' ')
         n = i;
      else
         break     % no more chance if not leading blank
      end
   end
    
   s(1:n) = [];    % left trim
   return
   
%eof    