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
   
   oo = Path(o,vers);

   fprintf('Make CORAZON toolbox version %s (from version %s)\n',...
           vers,version(o));
   
   MakeM(oo);                          % make basic m-files
   MakeCorazon(oo);                    % make @corazon class   
   MakeCorazita(oo);                   % make @corazita class   
   MakeCorazito(oo);                   % make @corazito class   
   MakeCorleon(oo);                    % make @corleon class   
   MakeCorshito(oo);                   % make @corshito class   
   MakeCorasim(oo);                    % make @corasim class   
   
      % so far to not provide nichols method with corazon toolbox
      
   dst = var(oo,'dst');
   delete([dst,'/@corasim/nichols.m']);
   
   fprintf('done!\n');
end

%==========================================================================
% Make Classes
%==========================================================================

function MakeM(o)                      % Make Basic M-files            
   fprintf('   * making basic files ...\n');
   CopyFiles(o);
end
function MakeCorazon(o)                % Make Corazon Class            
   exception = {'cache','call','id','menu','shell','version','with'};
   class = '@corazon';
   MakeClass(o,class,exception);
end
function MakeCorazita(o)               % Make Corazita Class            
   exception = {'clean','launch','shit'};
   class = '@corazita';
   MakeClass(o,class,exception);
end
function MakeCorazito(o)               % Make Corazito Class            
   exception = {'master'};
   class = '@corazito';
   MakeClass(o,class,exception);
end
function MakeCorleon(o)                % Make Corleon Class            
   exception = {'master'};
   class = '@corleon';
   MakeClass(o,class,exception);
end
function MakeCorshito(o)               % Make Corshito Class            
   exception = {'*'};
   class = '@corshito';
   MakeClass(o,class,exception);
end
function MakeCorasim(o)                % Make Corasim Class            
   exception = {'*'};
   class = '@corasim';
   MakeClass(o,class,exception);
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
function dir = CopyFiles(o,class)
   [from,to] = var(o,'src,dst');

   if (nargin >= 2)
      from = [from,'/',class];
      to = [to,'/',class];
   end
   
   MkDir(o,to);
   copyfile([from,'/*.m'],to);
   dir = to;                           % return arg
end
function MakeClass(o,class,exception)
   fprintf('   * making %s class ...\n',class);
   dir = CopyFiles(o,class);
   obfuscate(dir,exception);
end

%==========================================================================
% Get Path
%==========================================================================

function oo = Path(o,vers)
%
% PATH  Determine source and destination path and store as object variables
%
%          oo = Path(o,'V1i1');
%          [src,dst] = var(oo,'src,dst');
%
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
   src = path;                         % source path
   dst = [root,'/',vers];              % destination path
   
   oo = var(o,'src,dst',src,dst);
end
