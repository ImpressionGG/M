function [str,clk] = clock(format)
%
% CLOCK  Current clock information (static method)
%
%   Get date/time information in readable format based on current clock
%   reading
%
%      str = o.clock('DD-Mmm-YYYY,hh:mm:ss');   % current clock info
%      str = o.clock;                           % same as above
%
%      date = o.clock('DD-Mmm-YYYY');           % current date
%      date = o.clock('DD-MMM-YYYY');           % current date
%
%      time = o.clock('hh-mm-ss');              % current time
%      time = o.clock('hh-mm-ss.msec');         % current time
%
%   See also: CARALOG, NOW
%
   if (nargin < 2)
      format = 'DD-Mmm-YYYY,hh:mm:ss';
   end
   
   clk = clock;                    % read current value of the clock
   str = datestr(clk);             % e.g.: '05-Jul-2015 12:09:06'
   vec = datevec(str);
   
   DD = str(1:2);                  % day
   MMM = upper(str(4:6));          % month in uppercase letters
   Mmm = [MMM(1),lower(MMM(2:3))]; % month in upper/lowercase letters
   MM = sprintf('%02f',clk(2));    % month in digits
   YYYY = str(8:11);               % year
   hh = str(13:14);                % hour
   mm = str(16:17);                % minute
   ss = str(19:20);                % second
   msc = sum(clk-vec);             % mili second
   
% construct the assoc table
      
   table = {{'DD',DD},{'MMM',MMM},{'Mmm',Mmm},{'MM',MM},{'YYYY',YYYY},...
            {'hh',hh},{'mm',mm},{'ss',ss},{'msc',msc},''};
            
% build up the string with the clock info. Add a stopper '|' to the format
% so we do not fall out of the while loop
      
   str = '';  
   format = [format,'|'];                % add a stopper
   ident = '';  chunk = '';
   
   for (i=1:length(format))
      uppercase = ('A' <= format(i) && format(i) <= 'Z');
      lowercase = ('a' <= format(i) && format(i) <= 'z');
      if (uppercase || lowercase)
         ident(end+1) = format(i);
         chunk = assoc(ident,table);
         if isempty(chunk)
            continue
         end
      end
      
      if is(chunk)
         str = [str,chunk];
         ident = '';  chunk = '';
         continue
      end
      
      if (i < length(format))           % do not add stopper to str
         str(end+1) = format(i); 
      end
   end
end   
