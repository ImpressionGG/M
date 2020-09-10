function oo = read(o,varargin)         % Read TRADE Object From File
%
% READ   Read a TRADE object from file.
%
%             oo = read(o,'ReadLogLog',path) % .log data read driver
%             oo = read(o,'ReadTradeCsv',path) % .csv trading view read driver
%             oo = read(o,'ReadChartCsv',path) % .csv chart data read driver
%
%          See also: TRADE, IMPORT
%
   [gamma,oo] = manage(o,varargin,@ReadLogLog,@ReadChartCsv,@ReadTradeCsv);
   oo = gamma(oo);
end

%==========================================================================
% Read Driver for Log Data
%==========================================================================

function oo = ReadLogLog(o)            % Read Driver for .log Data
   path = arg(o,1);
   [x,y,par] = Read(path);

   oo = trade('log');
   oo.data.x = x;
   oo.data.y = y;
   oo.par = par;
   return

   function [x,y,par] = Read(path)        % read log data (v1a/read.m)
      fid = fopen(path,'r');
      if (fid < 0)
         error('cannot open log file!');
      end
      par.title = fscanf(fid,'$title=%[^\n]');
      log = fscanf(fid,'%f',[2 inf])';    % transpose after fscanf!
      x = log(:,1); y = log(:,2);
   end
end

%==========================================================================
% Read Driver for Log Data
%==========================================================================

function oo = ReadChartCsv(o)          % Read Driver for .csv Chart Data
   path = arg(o,1);

   fid = fopen(path,'r');
   if (fid < 0)
      oo = [];
      error('cannot open log file!');
   end
   
   oo = trade('chart');
   oo = log(o,'t,open,high,low,close,volume');
 
   while (1)
      line = fgetl(fid);
      if isequal(line,-1)
         break;
      end
            
      while (~isempty(line) && line(1) == ',')
         line(1) = [];
      end
      
      idx = [find(line==','),length(line)+1];
      name = lower(line(1:idx(1)-1));      
      
      switch name
         case {'ticker','name','isin','from','to'}
            if ~isempty(idx)
               line = line(idx(1)+1:end);
               idx = find(line==',');
               value = line(1:idx(1)-1);
               
               if isequal(name,'to') || isequal(name,'from')
                  value = datestr(datevec(value),1);
               end
               
               eval(['oo.par.',name,'=','''',value,''';']);   
            end
                           
         case 'chart data'
            break;
      end
   end
   
   line = fgetl(fid);                  % eat
    
   k = 0;  
   while (1)
      k = k+1;
      line = fgetl(fid);
      if isequal(line,-1)
         break;
      end
      
      line = [',',line,','];
      idx = find(line==',');
     
         % extract date 
         
      if (k == 1)
         date = line(idx(1)+1:idx(2)-1);
         oo.par.date = date;
      end
      
         % scan data
         
      data = k;
      for (j=1:5)
         chunk = line(idx(1+j)+1:idx(2+j)-1);
         data(j+1) = sscanf(chunk,'%f');
      end
      
      oo = log(oo,data(1),data(2),data(3),data(4),data(5),data(6));
   end
   
   if ~isempty(get(oo,'ticker'))
      oo.par.title = ['[',get(oo,'ticker'),'] ',get(oo,'name')];
   end
   fclose(fid);
end
function oo = ReadTradeCsv(o)          % Read Driver for .csv Chart Data
   path = arg(o,1);

   fid = fopen(path,'r');
   if (fid < 0)
      oo = [];
      error('cannot open log file!');
   end
   
   oo = trade('chart');
   oo = log(o,'t,open,high,low,close,volume');
 
   line = fgetl(fid); 
   
      % line = 'time,open,high,low,close'
      
   k = 0;
   
   while (1)
      k = k+1;
      line = fgetl(fid);
      if isequal(line,-1)
         break;
      end
      
      line = [',',line,','];
      idx = find(line==',');
     
         % extract date 
         
      if (k == 1)
         date = line(idx(1)+1:idx(2)-1);
         oo.par.date = date;
      end
      
         % scan data
         
      data = k;
      for (j=1:4)
         chunk = line(idx(1+j)+1:idx(2+j)-1);
         data(j+1) = sscanf(chunk,'%f');
      end
      data(6) = 0;    % dummy volume
      
      oo = log(oo,data(1),data(2),data(3),data(4),data(5),data(6));
   end
   
   if ~isempty(get(oo,'ticker'))
      oo.par.title = ['[',get(oo,'ticker'),'] ',get(oo,'name')];
   end
   fclose(fid);
end
