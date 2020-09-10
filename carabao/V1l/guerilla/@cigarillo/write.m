function oo = write(o,varargin)        % Write CIGARILLO Object To File
%
% WRITE   Write a CIGARILLO object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%          See also: CIGARILLO, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@LogData,@TxtData);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Log Data Write
%==========================================================================

function oo = LogData(o)               % Write Driver for .log File
   path = arg(o,1);                    % get path argument
   oo = caramel(o);
   oo = write(oo,'LogData',path);      % delegate to caramel/write
end

function oo = TxtData(o)               % Write Driver for .txt File
   path = arg(o,1);                    % get path argument
   fid = fopen(path,'w');              % open log file for write
   if (fid < 0)
      error('cannot open export file');
   end

   fprintf(fid,'$title=%s\n',get(o,{'title',''}));
   % add more code for export          % put your own code here
   fclose(fid);                        % close export file
end
