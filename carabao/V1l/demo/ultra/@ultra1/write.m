function oo = write(o,varargin)        % Write ULTRA1 Object To File
%
% WRITE   Write a ULTRA1 object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteUltra1Log',path)   % write .log file
%             oo = write(o,'WriteUltra1Dat',path)   % write .dat file
%
%          See also: ULTRA1, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteUltra1Log,@WriteUltra1Dat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteUltra1Log(o)        % Write Driver for Ultra1 .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Ultra1 Data
%==========================================================================

function oo = WriteUltra1Dat(o)        % Write Driver for Ultra1 .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
