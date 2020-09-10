function oo = write(o,varargin)        % Write CONTROL Object To File
%
% WRITE   Write a CONTROL object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteControlLog',path)   % write .log file
%             oo = write(o,'WriteControlDat',path)   % write .dat file
%
%          See also: CONTROL, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteControlLog,@WriteControlDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteControlLog(o)        % Write Driver for Control .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Control Data
%==========================================================================

function oo = WriteControlDat(o)        % Write Driver for Control .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
