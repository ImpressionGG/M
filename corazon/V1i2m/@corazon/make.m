function make(o,vers)
%
% MAKE   Make toolbox version based on source version
%
%           make(corazon,'V1i2')
%
%        Note: make an obfuscated toolbox based on current (active)
%        toolbox. This means that path settings must be on current CORAZON
%        toolbox
%
%        Copyright(c): Bluenetics 2021
%
%        See also: CORAZON, CORAZITO, CORAZITA
%
   if (nargin ~= 2)
      error('2 input args expected');
   end
   
   [psrc,pdst] = Path(o,vers);

   CopyFiles(o,psrc,pdst);
   
   dir = CopyFiles(o,psrc,pdst,'@corazon');
   obfuscate(dir);
end

%==========================================================================
% Extract Comment from an m-file
%==========================================================================

function Comment(o,path)
end

%==========================================================================
% Copy Files
%==========================================================================

function MkDir(o,path)
   rv = exist(path);
   if (rv ~= 0)
      error(sprintf('folder must not exist (%s)',path));
   end

   ok = mkdir(path);
   if (~ok)
      error(sprintf('cannot create directory',path));
   end
end
function dir = CopyFiles(o,from,to,class)
   if (nargin >= 4)
      from = [from,'/',class];
      to = [to,'/',class];
   end
   
   MkDir(o,to);
   copyfile([from,'/*.m'],to);
   dir = to;                           % return arg
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