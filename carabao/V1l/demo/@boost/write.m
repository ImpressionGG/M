function oo = write(o,varargin)        % Write BOOST Object To File
%
% WRITE   Write a BOOST object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteBoostLog',path)   % write .log file
%             oo = write(o,'WriteBoostDat',path)   % write .dat file
%
%          See also: BOOST, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteBoostLog,@WriteBoostDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteBoostLog(o)        % Write Driver for Boost .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Boost Data
%==========================================================================

function oo = WriteBoostDat(o)        % Write Driver for Boost .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
