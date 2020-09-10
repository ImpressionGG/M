function oo = write(o,varargin)        % Write HUCK Object To File
%
% WRITE   Write a HUCK object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteHuckLog',path)   % write .log file
%             oo = write(o,'WriteHuckDat',path)   % write .dat file
%
%          See also: HUCK, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteHuckLog,@WriteHuckDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteHuckLog(o)        % Write Driver for Huck .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Huck Data
%==========================================================================

function oo = WriteHuckDat(o)        % Write Driver for Huck .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
