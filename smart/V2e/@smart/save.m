function save(obj,fout)
%
% SAVE     Save a SMART object to M-file
%
%             save(obj,'gma1_347_000222a'); % create M-file 
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
   
      % write header ...

   if (total)               % in case of total saving start with header 
      fprintf(fout,['function obj = ',name,';\n']);
      fprintf(fout,'%%\n');
      fprintf(fout,['%% ',upper(name),'  MFILE representation of SMART object\n']);
      fprintf(fout,'%%\n');
   end
   
      % write core data ...

   savedata(fout,format(obj),'format');
   fprintf(fout,'\n');
   savedata(fout,get(obj),'parameter')
   fprintf(fout,'\n');
   savedata(fout,data(obj),'data')
   fprintf(fout,'\n');
      
      % write footer ...

   fprintf(fout,'\nobj = smart(format,parameter,data);\nreturn;\n\n');
   fprintf(fout,'%%eof\n');

   if (total)
      fclose(fout);
   end
   
   return
% eof      
   
