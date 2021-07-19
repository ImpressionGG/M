function lines = snif(o,path,n)
%
% SNIF   Snif n lines into text file and return first n lines as a list
%        of text strings. If text file has less than n lines than empty
%        strings are returned
%
%           lines = snif(o,path,n)     % snif n lines
%           lines = snif(o,path)       % snif 10 lines
%
%        By setting verbose option >= 3 read lines are echoed to console
%
%           lines = snif(opt(o,'verbose',3),path)
%
%        Options:
%           verbose          % echoing read lines (default: 0)
%
%        Copyright(c): Bluenetics 2020
%
%        See also: CORAZON, IMPORT, READ
%
   verbose = (opt(o,{'verbose',0}) >= 3);
   lines = {};                         % default init
   
   if (nargin < 3)
      n = 10;
   end
   
   if (verbose)
      fprintf('sniffing %d lines of file: %s ...\n',n,path);
   end
   
      % open file for read
      
   fid = fopen(path,'r');
   if isequal(fid,-1)
      return
   end
   
      % read lines
      
   for (i=1:n) 
      line = fgetl(fid);
      if isequal(line,-1)
         lines{i} = '';
         if (verbose)
            fprintf('Line %03d: %s\n',i,'*EOF*');
         end
      else
         lines{i} = line;
         if (verbose)
            fprintf('Line %03d: %s\n',i,line);
         end
      end
   end
   
   fclose(fid);
end
