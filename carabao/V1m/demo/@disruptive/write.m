function oo = write(o,varargin)        % Write DISRUPTIVE Object To File
%
% WRITE   Write a DISRUPTIVE object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteDisruptiveLog',path)   % write .log file
%             oo = write(o,'WriteDisruptiveDat',path)   % write .dat file
%
%          See also: DISRUPTIVE, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteDisruptiveLog,@WriteDisruptiveDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteDisruptiveLog(o)        % Write Driver for Disruptive .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Disruptive Data
%==========================================================================

function oo = WriteDisruptiveDat(o)        % Write Driver for Disruptive .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
