function oo = write(o,varargin)        % Write GACO Object To File
%
% WRITE   Write a GACO object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteGacoLog',path)   % write .log file
%             oo = write(o,'WriteGacoDat',path)   % write .dat file
%
%          See also: GACO, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteGacoLog,@WriteGacoDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteGacoLog(o)        % Write Driver for Gaco .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Gaco Data
%==========================================================================

function oo = WriteGacoDat(o)        % Write Driver for Gaco .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
