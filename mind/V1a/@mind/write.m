function oo = write(o,varargin)        % Write MIND Object To File
%
% WRITE   Write driver to write a MIND object to file.
%
%             oo = write(o,'WriteStuffTxt',path)
%
%          See also: MIND, EXPORT
%
   [gamma,oo] = manage(o,varargin,@WriteLogLog);
   oo = gamma(oo);
end

%==========================================================================
% Data Write Driver for Mind Stuff
%==========================================================================

function o = WriteLogLog(o)            % Export Object to .log File
   path = arg(o,1);                    % get path argument
   log = [o.data.x(:),o.data.y(:)];
   title = get(o,'title');

   fid = fopen(path,'w');                    % open log file for write
   if (fid < 0)
      error('cannot open log file');
   end

   fprintf(fid,'$title=%s\n',title);
   fprintf(fid,'%10f %10f\n',log');          % write x/y data
   fclose(fid);                              % close log file
end
