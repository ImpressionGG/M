function obfuscate(tbox,version,class)
%
% OBFUSCATE   Obfuscate a directory, i.e, create *.p files in addition to
%             *.m files.
%
%                obfuscate corazon V1i2 @corazito
%
%             See also: pcode
%
   if (class(1) == '@')
      constructor = class(2:end);
   else
      error('no class directory (arg3)');
   end
   
   dir = [mhome,'/',tbox,'/',version,'/',class];
   path = [dir,'/',constructor,'.m'];
   
   if (exist(path) ~= 2)
      error(['constructor not found (',path,')']);
   end
   
   fprintf('obfuscating %s/%s/%s directory (%s)\n',tbox,version,class,dir);
   
      % actual obfuscating ...
      
   pcode(dir,'-inplace');
end

function Corazon
%
   list = {'cache','call','id','menu','shell','version','with'};
end