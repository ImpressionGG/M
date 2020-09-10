function profiling(obj,mode)
%
% PROFILING Start/stop profiling. The function call is only active if 
%           option 'profiler' is true.
%
%              profiling(obj,'start');   % start profiling
%              profiling(obj,'stop');    % stop profiling & print results
%
%        See also: SHELL, PROFILER, OPTION
%
   if ~option(obj,'profiling')
      return
   end

   switch mode
      case 'start'
         if option(obj,'verbose') >= 1
            fprintf('Start profiling ...\n');
         end
         profiler([]);
      case 'stop'
         profiler;
      otherwise
         error(['bad mode: ',mode]);
   end
   return
   
%eof   