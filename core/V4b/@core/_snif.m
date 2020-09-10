function [out,format,cycles] = snif(chameo,filename,verbose,maxcycles)
%
% SNIF      Open file and check for $Version inside which will be returned
%           in format output arg. Count all lines.
%
%              [lines,format,cycles] = snif(shell,filename,verbose)
%
%           See also: SHELL, OPEN
%
   profiler('snif',1);

   VERBOSE_RESULT = 1;         % verbose level for life signals
   VERBOSE_ALIFE = 2;          % verbose level for life signals
   MODULUS_ALIFE = 20000;      % life signal traced each 500 times

   cycles = 0;                 % init
   tstart = clock;
   if (nargin < 3) verbose = 1; end
   if (nargin < 4) maxcycles = inf; end
   
   if (verbose >= VERBOSE_RESULT)
       fprintf(['Sniffing file ',filename,' ...\n']);
   end

   fid = fopen(filename,'rt');
   if (fid < 0)
      error(['Cannot open ',filename,'!']);
   end

   lines = 0;
   format = '';
   
   while (1)                   % read until EOF found
      line = fgets(fid);       % read new line
      if ~isstr(line)
         break;                % done - EOF reached      
      end
      lines = lines + 1;       % count lines

      if (verbose >= VERBOSE_ALIFE & rem(lines,MODULUS_ALIFE) == 0)
         fprintf('   %7.0f lines scanned\n',lines)
      end
   end

   fclose(fid);
   
   tell = etime(clock,tstart);
   if (verbose >= VERBOSE_RESULT)
      fprintf(['File ',filename,' has in total %g lines (ellapsed time: %g s)\n'],lines,tell);
   end
   
   if (nargout > 0)
      out = lines;
   end
   
   profiler('snif',0);
   return

%eof   
