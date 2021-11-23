function [package,typ,name,run,mach] = split(o,title)
%
% SPLIT   Split package name into parts
%
%            [package,typ,name,run,mach] = split(o,title)
%            [package,typ,name,run,mach] = split(o,o.par.title)
%            [package,typ,name,run,mach] = split(o)    % same as above
%
%            split(o,title)            % show splitted info
%            split(o)                  % show splitted info
%
%         See also: CORAZON
%
   if (nargin < 2)
      title = get(o,'title');
   end
   if (nargout == 0)
      Show(o,title);
      return
   end
   
   if ~ischar(title)
      error('package title must be char type!');
   end
   if length(title) == 0 || title(1) ~= '@'
      error('no valid package title!');
   end
   
      % split into parts

   assert(title(1)=='@');
   idx = find(title=='.');
   
   if length(idx) == 0
      error('bad package title (missing ''.'' characters)!');
   elseif length(idx) == 1
      mach = title(2:idx(1)-1);
      runtxt = title(idx(1)+1:end);
      run = sscanf(runtxt,'%f');
      typ = 'any';
      name = '';
   else
      mach = title(2:idx(1)-1);
      runtxt = title(idx(1)+1:idx(2)-1);
      run = sscanf(runtxt,'%f');
      typ = '';

      i = idx(2)+1;  c = upper(title(i));
      while (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')
         typ(1,end+1) = title(i);
         i = i+1;
         if i > length(title)
            break
         end
         c = upper(title(i));
      end
      typ = lower(typ);
      name = title(i+1:end);
   end
      
%  if isempty(mach) || (any((mach < '0') | (mach > '9')))
   if isempty(mach)
      error('bad package title (machine number)!');
   end
   if isempty(run) || ~isequal(runtxt,sprintf('%d',run))
      error('bad package title (run number)!');
   end      
   if length(typ) == 0 || upper(typ(1)) < 'A' || upper(typ(end)) > 'Z'
      error('bad package title (type)!');
   end      
   
   package = sprintf('@%s.%d',mach,run);
end

%==========================================================================
% Show Splitted Info
%==========================================================================

function Show(o,title)
   [package,typ,name,run,mach] = split(o,title);
   fprintf('   Package: %s\n',package);
   fprintf('   Name:    %s\n',name);   
   fprintf('   Type:    %s\n',typ);   
   fprintf('   Run:     %g\n',run);
   fprintf('   Machine: %s\n',mach);
end
