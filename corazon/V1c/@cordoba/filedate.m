function [date,time] = filedate(filepath)
%
% FILEDATE   Get modified date/time of a file or directory
%
%    Syntax:
%
%       datenum = filedate(o,filepath);     % file date in datenum format
%       [date,time] = filedate(o,filepath); % file date as date/time
%   
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA 
%
   stamp = 0;                          % init by default
   if exist(filepath)
      info = dir(filepath);            % get file information of dirty file

      switch length(info)
         case 0
            error('cannot be!');

         case 1
            stamp = info.datenum;

         otherwise
            [~,name,ext] = fileparts(filepath);
            if ~isempty(ext)
               name = [name,ext];      % reconstruct file name
            end

            for (i=1:length(info))
               if strcmp(info(i).name,'.')
                  stamp = info(i).datenum;
                  break;
               end
            end
      end
   end
%
% set output args
%
   if (nargout == 1)
      date = stamp;
   else
      if (stamp)
         str = datestr(stamp);
         date = str(1:11);  time = str(13:20);
      else
         date = '';  time = '';
      end
   end
end   
