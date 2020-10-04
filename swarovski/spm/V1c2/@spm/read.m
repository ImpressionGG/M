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

function oo = ReadSpmSpm(o)            % Read Driver for SPM Data      
   path = arg(o,1);                    % get path arg
   lines = snif(o,path,1);
   
      % SPM1 format is characterized by a header line
      % containing the string 'State-Space'
      
   if ~isempty(strfind(lines{1},'State-Space'))
      oo = ReadSpm1Spm(o);
      return
   end
   
      % SPM2 format is characterized by a header line
      % containing the string 'BEGIN ANSOFT HEADER'
      
   if ~isempty(strfind(lines{1},'BEGIN ANSOFT HEADER'))
      oo = ReadSpm2Spm(o);
      return
   end
   
      % otherwise no idea how to import file
      
   message(o,'No idea how to import file!',...
             {['Path: ',path]});
   oo = [];
end
function oo = ReadSpm1Spm(o)           % Read Driver 1 for .spm File   
   talk = (control(o,'verbose') >= 3);

   path = arg(o,1);                    % get path arg
   [dir,file,ext] = fileparts(path);
      
   oo = construct(o,class(o));         % create class object of type 'SPM'
   oo.type = 'spm';
   
      % read infos
   
   fid = fopen(path,'r');
   line = fgetl(fid);
   line = fgetl(fid);
   oo.par.notes = oo.trim(line);
   line = fgetl(fid);
   oo.par.date = [line(4:5),'-',line(1:2),'-',line(7:10)];
   oo.par.time = line(17:end);
   line = fgetl(fid);
   oo.par.title = oo.trim(line(8:end));
   
      % extract parameters from file name
      
   oo = context(oo,path);
   
      % skip to 'INPUT LABELS'
   
   lcnt = 0;
   while (true)
      line = fgetl(fid);
      if (talk)
         lcnt = lcnt + 1;
         fprintf('%04d %s\n',lcnt,line');
      end
      if isequal(line,' INPUT LABELS')
         break;
      end
   end
   
      % read input labels
      
   in = {};
   while (true)
      line = fgetl(fid);
      if (talk)
         lcnt = lcnt + 1;
         fprintf('%04d %s\n',lcnt,line');
      end
      if isequal(line,' OUTPUT LABELS')
         break;
      else
         in{end+1} = oo.trim(line);
      end
   end   
   
      % read output labels
      
   out = {};
   while (true)
      line = fgetl(fid);
      if isequal(line,'A MATRIX')
         break;
      else
         out{end+1} = oo.trim(line);
      end
   end   
   
      % read matrices
      % we are already at position 'A MATRIX' in the file so no need for
      % skipping lines with matrix A
      
   A = ReadMatrix(fid);
   B = ReadMatrix(fid,'B');
   C = ReadMatrix(fid,'C');
   D = zeros(size(C,1),size(B,2));
   
   fclose(fid);
   
   oo.par.dir = dir;
   oo.par.file = [file,ext];
   oo.par.labelIn = in;
   oo.par.labelOut = out;
   
   header = sprintf('System: A[%dx%d], B[%dx%d], C[%dx%d], D[%dx%d]',...
                    size(A),size(B),size(C),size(D));

   oo.par.title = file;
   oo.par.comment = {header,['file: ',file,ext],['directory: ',dir]};
                 
   oo.data.A = A;
   oo.data.B = B;
   oo.data.C = C;
   oo.data.D = D;
   
   ev = eig(A);       % eigenvalues
   t = 1:length(ev);
   x = real(ev);
   y = imag(ev);
   [~,idx] = sort(abs(imag(ev)));
   
   oo.data.t = t;
   oo.data.x = x(idx)';
   oo.data.y = y(idx)';
   return
   
   function [mat] = ReadMatrix(fid,name)
      % if 'name' is missing, start from current position
      
      mat = [];
      
      if nargin>1
         % skip lines until matrix starts
         while (true)
            l = fgetl(fid);
            if (isequal(l,[name,' MATRIX']))
               break;
            end
         end
      end
      
      % read dimensions
      l = fgetl(fid);
      [rows,~] = sscanf(l,'%f');

      % read matrix
      for i=1:rows
         l = fgetl(fid);
         entries = sscanf(l,'%f');
         mat = [mat;entries'];
      end
   end
end
function oo = ReadSpm2Spm(o)           % Read Driver 2 for .spm File   
   talk = (control(o,'verbose') >= 3);

   path = arg(o,1);                    % get path arg
   [dir,file,ext] = fileparts(path);
      
   oo = construct(o,class(o));         % create class object of type 'SPM'
   oo.type = 'spm';
   
      % read infos
   
   fid = fopen(path,'r');
   line = fgetl(fid);
   line = fgetl(fid);
   oo.par.notes = oo.trim(line);
   line = fgetl(fid);
   %oo.par.date = [line(4:5),'-',line(1:2),'-',line(7:10)];
   %oo.par.time = line(17:end);
   line = fgetl(fid);
   %oo.par.title = oo.trim(line(8:end));
   
      % extract parameters from file name
      
   oo = context(oo,path);

      % skip until line with string 'MatrixA'
   
   lcnt = 0;
   while (true)
      line = fgetl(fid);
      if (talk)
         lcnt = lcnt + 1;
         fprintf('%04d %s\n',lcnt,line');
      end
      if ~isempty(strfind(line,'MatrixA'))
         break;
      end
   end
   
   A = ReadMatrix(fid);
   B = ReadMatrix(fid,'B');
   C = ReadMatrix(fid,'C');
   D = zeros(size(C,1),size(B,2));
   
   fclose(fid);
   
   oo.par.dir = dir;
   oo.par.file = [file,ext];
   
   header = sprintf('System: A[%dx%d], B[%dx%d], C[%dx%d], D[%dx%d]',...
                    size(A),size(B),size(C),size(D));

   oo.par.title = file;
   oo.par.comment = {header,['file: ',file,ext],['directory: ',dir]};
                 
   oo.data.A = A;
   oo.data.B = B;
   oo.data.C = C;
   oo.data.D = D;
   
   ev = eig(A);       % eigenvalues
   t = 1:length(ev);
   x = real(ev);
   y = imag(ev);
   [~,idx] = sort(abs(imag(ev)));
   
   oo.data.t = t;
   oo.data.x = x(idx)';
   oo.data.y = y(idx)';
   return
   
   function [mat] = ReadMatrix(fid,name)
      % if 'name' is missing, start from current position
      
      mat = [];
         
      while (1)
         line = fgetl(fid);
         if ~isempty(strfind(line,'Matrix')) || ~isempty(strfind(line,')'))
            break;
         end

         entries = sscanf(line,'%f');
         mat = [mat;entries'];
      end
   end
end

