function oo = write(o,varargin)        % Write PREDICT Object To File
%
% WRITE   Write a PREDICT object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WritePredictLog',path)   % write .log file
%             oo = write(o,'WritePredictDat',path)   % write .dat file
%
%          See also: PREDICT, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WritePredictLog,@WritePredictDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WritePredictLog(o)        % Write Driver for Predict .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Predict Data
%==========================================================================

function oo = WritePredictDat(o)        % Write Driver for Predict .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
