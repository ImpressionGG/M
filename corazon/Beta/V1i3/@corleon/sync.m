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
