function oo = read(o,varargin)         % Read SPM Object From File
%
% READ   Read a SPM object from file.
%
%             oo = read(o,'ReadLogLog',path) % .log data read driver
%
%          See also: SPM, IMPORT
%
   [gamma,oo] = manage(o,varargin,@ReadLogLog,@ReadSpmSpm);
   oo = gamma(oo);
end

%==========================================================================
% Read Driver for Log Data
%==========================================================================

function oo = ReadLogLog(o)            % Read Driver for .log Data
   path = arg(o,1);
   [x,y,par] = Read(path);

   oo = spm('log');
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
% Read Driver for Spm Data
%==========================================================================

function oo = ReadSpmSpm(o)            % Read Driver for .spm File     
   path = arg(o,1);                    % get path arg
   [dir,file,ext] = fileparts(path);
   
   try
      [~,package,pxt] = fileparts(dir);
      [package,typ,name,run,machine] = split(o,[package,pxt]);
   catch
      machine = '';
   end
   
   
   oo = construct(o,class(o));    % create class object of type 'SPM'
   oo.type = 'spm';
   
   fid = fopen(path,'r');
   while (1)
      line = fgetl(fid);
      if (~ischar(line))
         break;
      end
      
      if (strfind(line,'//  Format') == 1)
         oo.par.format = line(13:end);
      elseif (strfind(line,'//  Title') == 1)
         oo.par.title = oo.trim(line(12:end));
      elseif (strfind(line,'//  Date') == 1)
         oo.par.date = [line(17:20),'-',line(14:15),'-',line(11:12)];
      elseif (strfind(line,'//  Time') == 1)
         oo.par.time = line(11:18);
      elseif (strfind(line,'//  Notes') == 1)
         oo.par.notes = oo.trim(line(12:end));
      end

      if isequal(line,'//END ANSOFT HEADER')
         break;
      end
   end

   while (1)
      line = fgetl(fid);
      if (strfind(line,'MatrixA') ~= 0)
         break;
      end
   end
   
       % read matrix A
       
   A = [];
   while (1)
      line = fgetl(fid);
      if (line(end) == '\')
         line(end) == [];
      end
      aT = sscanf(line,'%f')';
      A = [A; aT];
      [m,n] = size(A);
      if (m == n)
         break;
      end
   end
   
   while (1)
      line = fgetl(fid);
      if (strfind(line,'MatrixB') ~= 0)
         break;
      end
   end
   
      % read matrix B
      
   B = [];
   for (i=1:n)
      line = fgetl(fid);
      if (line(end) == '\')
         line(end) == [];
      end
      bT = sscanf(line,'%f')';
      B = [B; bT];
   end
   
   while (1)
      line = fgetl(fid);
      if (strfind(line,'MatrixC') ~= 0)
         break;
      end
   end
   
      % read matrix C
      
   C = [];
   while (1)
      line = fgetl(fid);
      if (strfind(line,')') > 0)
         break;
      end
      if (line(end) == '\')
         line(end) == [];
      end
      cT = sscanf(line,'%f')';
      C = [C; cT];
   end
   
   if (size(B,2) == 1)
      %B = [0*B, 0*B, B];
   end
   if (size(C,1) == 1)
      %C = [(+1).^(1:length(C))/100; (-1).^(1:length(C))/100; C];
   end
   D = zeros(size(C,1),size(B,2));
   
   fclose(fid);
   
      % done with reading
   
   oo.par.package = package;
   oo.par.machine = machine;
   oo.par.dir = dir;
   oo.par.file = [file,'/',ext];
   
   header = sprintf('System: A[%dx%d], B[%dx%d], C[%dx%d], D[%dx%d]',...
                    size(A,1),size(A,2), size(B,1),size(B,2), ...
                    size(C,1),size(C,2), size(D,1),size(D,2));
   oo.par.comment = {header,['package: ',package],['machine: ',machine],...
                     ['file: ',file,'/',ext],['directory: ',dir]};
                 
   oo.par.system.A = A;
   oo.par.system.B = B;
   oo.par.system.C = C;
   oo.par.system.D = D;
   
   ev = eig(A);       % eigenvalues
   t = 1:length(ev);
   x = real(ev);
   y = imag(ev);
   [~,idx] = sort(abs(imag(ev)));
   
   oo.data.t = t;
   oo.data.x = x(idx)';
   oo.data.y = y(idx)';
end
