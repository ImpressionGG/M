function save(obj,fout)
%
% SAVE     Save a SHELL object to M-file
%
%             save(obj,'streams-Aug-15');   % create M-file 
%             save(obj,fid);                % save according to file handle
%
%          See also: SMART COMPOSE
%

   if (nargin < 2) error('At least 2 args expected!'); end

   if (isa(fout,'double'))
      total = 0;           % only partial saving
      if (length(fout) ~= 1)
         error('save(): file handle expected for arg2!');
      end
   elseif (~isstr(fout))
      error('save(): file handle or file name expected for arg2!');
   end
   
% deal with output file names

   if (isstr(fout))
      total = 1;              % indicates total saving
      outname = fout;

      if isempty(findstr(outname,'.m'))
         outname = [outname,'.m'];
      end
  
         % open outputfile
   
      fout = fopen(outname,'wt+');
      if (fout < 0)
         error(['Cannot open ',outname,'!']);
      end

         % extract filename core (without extension)
      
      name = outname;
      idx = findstr(name,'.');
      if ~isempty(idx)
         name(max(idx):end) = [];   % remove extension
      end
   end

% start writing
   
   if (total)               % in case of total saving start with header 

      fmt = format(obj);
      title = property(obj,'title');
      comment = property(obj,'comment');

      clname = class(obj);
      %if isempty(tag)       % then object is not derived
      %   tag = 'shell';     % default is SHELL object (if no tag specified)
      %end

      [p,fname,ext] = fileparts(name);

         % write mfile function head ...
         
      fprintf(fout,['function out = ',fname,'\n']);
      fprintf(fout,'%%\n');

      blank = setstr(zeros(1,length(fname)+3)+' ');
      idt = ['%% ',blank];    % indent

         % write mfile help info ...
      
      fprintf(fout,['%% ',upper(fname),...
         '   MFILE representation of %s((%s) object\n'],...
         upper(clname),fmt);
      fprintf(fout,'%%\n');

      %fprintf(fout,[idt,'Object Information\n']);
      %fprintf(fout,[idt,'==================\n']);
      fprintf(fout,[idt,'#  %s\n'],info(obj));
      if ~isempty(comment)
         for (i=1:length(comment))
            fprintf(fout,[idt,'#     %s\n'],comment{i});
         end
      end
      fprintf(fout,'%%\n');

      fprintf(fout,[idt,'Execution of this mfile will create the object.\n']);
      fprintf(fout,[idt,'Optionally according figure/menu will be launched if\n']);
      fprintf(fout,[idt,'the return value of the mfile function is not assigned.\n']);
      fprintf(fout,[idt,'\n']);
      fprintf(fout,[idt,'   obj = %s;   %% load and create object\n'],fname);
      fprintf(fout,[idt,'   %s;         %% load & open shell menu\n'],fname);
      fprintf(fout,[idt,'\n']);
      fprintf(fout,[idt,'See also: %s MENU\n'],upper(clname));
      fprintf(fout,[idt,'\n']);

   end
   
% write core data ...

   savedata(fout,format(obj),'   format');
   fprintf(fout,'\n');
   savedata(fout,get(obj),'   parameter')
   fprintf(fout,'\n');
   savedata(fout,data(obj),'   data')
   fprintf(fout,'\n\n');
      
% write footer ...

   fprintf(fout,'   obj = %s(format,parameter,data);\n\n',clname);
   
   fprintf(fout,'   stack = dbstack;\n');
   fprintf(fout,'   name = stack.name;\n');
   fprintf(fout,'   [path,name,ext] = fileparts(which(name));\n\n');
   
   fprintf(fout,'   obj = set(obj,''mfile.path'',[path,''/'']);\n');
   fprintf(fout,'   obj = set(obj,''mfile.name'',mfilename);\n\n');
   
   fprintf(fout,'   if (nargout == 0)\n');
   fprintf(fout,'      handle(obj);  %% open a shell menu if no out args\n');
   fprintf(fout,'   else\n');
   fprintf(fout,'      out = obj;    %% assign obj to out arg\n');
   fprintf(fout,'   end\n');
   fprintf(fout,'   return;\n\n%%eof\n');

   if (total)
      fclose(fout);
   end
   
   return
   
%==========================================================================
% Auxillary Functions
%==========================================================================

function print(fout,strings)
%
% PRINT    Print a sequence of strings to file
%
   for (i=1:length(strings))
      fprintf(fout,strings{i});
   end
   return
   
% eof   
% eof      
   
