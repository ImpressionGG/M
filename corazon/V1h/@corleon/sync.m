function list = sync(o,filepath)
%
% SYNC   Sync the file system 
%
%    Given a filepath for a .MAT file which has been modified (created) the
%    function sync will update the 'modified date' of all parent and parent
%    of parent directories up to (and including) the next mount point di-
%    rectory '[...]' (characterized by a leading '[' and trailing ']') 
%
%       list = sync(o,filepath)
%
%    If '[Corleon]' is not contained in the filepath then the whole function
%    call will be ignored. SYNC returns a list of filepathes to the direc-
%    tories which have been modified.
%
%    Remark: the method SYNC will be called implicitely by corleon/save
%    method
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORLEON, SAVE, MOUNTABLE
%
   list = Directories(o,filepath);     % extract directories to be modified
   
   for (i=1:length(list))
      path = list{i};
      entry.path = path;
      entry.datenum = Dirty(path);     % make directory dirty
      when = datestr(entry.datenum);   % easier to debug
      list{i} = entry;
   end
end

%==========================================================================
% Auxillary Functions
%==========================================================================

function list = Directories(o,path)    % Extract Directories to Modify 
%
   list = {};  old = '';
   
   %while ~isempty(path) && ~isempty(find(path=='['))
   while ~isempty(path)
      [path,fnam,ext] = fileparts(path);
      dir = [fnam,ext];                % re-compine directory name
      
      if mountable(o,dir)
         return           % reached at a mount point directory we are done
      end
      
      if ~isempty(path) && ~isequal(path,old) 
         list{end+1} = path;  old = path;
      else
         break
      end
   end
%
% coming to this point means that directory '[Corleon]' has not been found
% Clear list to indicate that no directories have to be modified
%
   list = {};  
end

function stamp = Dirty(path)           % make directory dirty
%
% DIRTY   Make directory dirty. We do this by creating and deleting a file
%         dirty.txt in the specified directory
%
   filepath = [path,'/dirty.txt'];
   
   fid = fopen(filepath,'w');          % create dirty file
   if (fid < 1)
      error(['cannot create dirty file: ',filepath,'!']);
   end
   fclose(fid);
   delete(filepath);                   % delete dirty file again
   
   di = dir(path);                     % get file information of dirty file
   
   for (i=1:length(di))
      if strcmp(di(i).name,'.')
         stamp = di(i).datenum;
         return;
      end
   end
%
% if we come to this ponit then stamp could not be deetermined correctly
%
   error('could not determine time stamp of directory!');
end   
