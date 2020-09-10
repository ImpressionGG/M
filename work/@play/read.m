function oo = read(o,varargin)         % Read PLAY Object From File
%
% READ   Read a PLAY object from file.
%
%             oo = read(o,'ReadLogLog',path) % .log data read driver
%
%          See also: PLAY, IMPORT
%
   [gamma,oo] = manage(o,varargin,@ReadLogLog);
   oo = gamma(oo);
end

%==========================================================================
% Read Driver for Log Data
%==========================================================================

function oo = ReadLogLog(o)            % Read Driver for .log Data
   path = arg(o,1);
   [x,y,par] = Read(path);

   oo = play('log');
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
