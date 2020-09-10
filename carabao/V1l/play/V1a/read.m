function [x,y,par] = read(path)        % read log data (v1a/read.m)
   fid = fopen(path,'r');
   if (fid < 0)
      error('cannot open log file!');
   end
   par.title = fscanf(fid,'$title=%[^\n]');
   log = fscanf(fid,'%f',[2 inf])';    % transpose after fscanf!
   x = log(:,1); y = log(:,2);
end
