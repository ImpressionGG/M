function oo = write(o,varargin)        % Write ULTRA Object To File
%
% WRITE   Write a ULTRA object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteUltraLog',path)   % write .log file
%             oo = write(o,'WriteUltraDat',path)   % write .dat file
%
%          See also: ULTRA, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteUltraLog,@WriteUltraDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteUltraLog(o)        % Write Driver for Ultra .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Ultra Data
%==========================================================================

function oo = WriteUltraDat(o)        % Write Driver for Ultra .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
