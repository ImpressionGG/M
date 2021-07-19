function make(o,vers)
%
% MAKE   Make toolbox version based on source version
%
%           make(corazon,'V1i2')
%
%        Copyright(c): Bluenetics 2021
%
%        See also: CORAZON, CORAZITO, CORAZITA
%
   if (nargin ~= 2)
      error('2 input args expected');
   end
   
   [srcpath,dstpath] = Path(o,vers);
   
      % make sure that destination directory does not exist and create
      % destination directory
      
   rv = exist(dstpath);
   if (rv ~= 0)
      error(sprintf('*** destination folder must not exist (%s)',dstpath));
   end
   mkdir(dstpath);
   
   CopyFiles(o,srcpath,dstpath);
end

%==========================================================================
% Extract Comment from an m-file
%==========================================================================

function Comment(o,path)
end

%==========================================================================
% Copy Files
%==========================================================================

function o = CopyFiles(o,from,to)
   copyfile([from,'/*.m'],to);
end

%==========================================================================
% Get Path
%==========================================================================

function [srcpath,dstpath] = Path(o,vers)
   path = which('corazon');
   chunk = '/@corazon/corazon.m';
   idx = strfind(path,chunk);
   
   assert(~isempty(idx));
   path(idx(1):end) = [];
   
   idx = length(path);
   
   for (i=length(path):-1:1)
      c = path(i);
      if (c == '/' || c == '\')
         idx = i-1;
         break;
      end
   end
   
   root = path(1:idx);
   srcpath = path;
   dstpath = [root,'/',vers];
end