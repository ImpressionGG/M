function oo = write(o,varargin)        % Write CARABAO Object To File  
%
% WRITE   Write driver to write a CARABAO object to file.
%
%             oo = write(o,'WriteLogLog',path)
%             oo = write(o,'WriteStuffTxt',path)
%
%          See also: CARAMEL, EXPORT
%
   [gamma,oo] = manage(o,varargin,@WriteLogLog,@WriteStuffTxt);
   oo = gamma(oo);
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function o = WriteLogLog(o)            % Write Driver for Log Data .log   
   path = arg(o,1);

   fid = fopen(path,'w');              % open data file for writing
   if (fid < 0)
      error('cannot open export file');
   end
   
   fprintf(fid,'$title=%s\n',get(o,{'title',''}));
   [x,y] = data(o,'x','y');
   bulk = [x(:),y(:)];
   fprintf(fid,'%10f %10f\n',bulk');   % write data
   fclose(fid);                        % close data file
end

%==========================================================================
% Data Write Driver for Carabao Stuff
%==========================================================================

function o = WriteStuffTxt(o)          % Export Object to .txt File
   path = arg(o,1);                    % get path argument
   fid = fopen(path,'w');              % open data file for writing
   if (fid < 0)
      error('cannot open export file');
   end
   
   c = get(o,{'color',[0 0 0]});
   fprintf(fid,'$title=%s\n',get(o,{'title',''}));
   fprintf(fid,'$type=%s\n',o.type);
   fprintf(fid,'$color=[%g %g %g]\n',c(1),c(2),c(3));
   switch o.type
      case 'weird'
         [t,w,x,y,z] = data(o,'t','w','x','y','z');
         bulk = [t,w,x,y,z];
         fprintf(fid,'%10f %10f %10f %10f %10f\n',bulk');    % write data
      case {'ball','cube'}
        [radius,offset] = data(o,'radius','offset');
         bulk = [radius,offset];
         fprintf(fid,'%10f %10f %10f %10f',bulk');    % write data
   end
   fclose(fid);                        % close data file
end
