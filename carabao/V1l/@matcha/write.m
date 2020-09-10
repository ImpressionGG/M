function oo = write(o,varargin)        % Write MATCHA Object To File
%
% WRITE   Write a MATCHA object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteMatchaLog',path)   % write .log file
%             oo = write(o,'WriteMatchaDat',path)   % write .dat file
%
%          See also: MATCHA, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteMatchaLog,@WriteMatchaDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteMatchaLog(o)        % Write Driver for Matcha .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Matcha Data
%==========================================================================

function oo = WriteMatchaDat(o)        % Write Driver for Matcha .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
