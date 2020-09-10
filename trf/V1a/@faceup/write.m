function oo = write(o,varargin)        % Write FACEUP Object To File
%
% WRITE   Write a FACEUP object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteFaceupLog',path)   % write .log file
%             oo = write(o,'WriteFaceupDat',path)   % write .dat file
%
%          See also: FACEUP, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteFaceupLog,@WriteFaceupDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteFaceupLog(o)        % Write Driver for Faceup .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Faceup Data
%==========================================================================

function oo = WriteFaceupDat(o)        % Write Driver for Faceup .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
