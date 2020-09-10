function create(path)  % create random data log file (v1a/create.m) 
%
%  CREATE   Create random data & log to a log file: create(path)
%
   log = ones(1000,1)*randn(1,2) + randn(1000,2)*randn(2,2);
   x = log(:,1);  y = log(:,2);
   
   fid = fopen(path,'w');                    % open log file for write
   if (fid < 0)
      error('cannot open log file');
   end
   
   [~,name] = fileparts(path);
   fprintf(fid,'$title=%s\n',upper(name));
   fprintf(fid,'%10f %10f\n',log');          % write x/y data
   fclose(fid);                              % close log file
end
