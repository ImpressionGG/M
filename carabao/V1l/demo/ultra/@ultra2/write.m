function oo = write(o,varargin)        % Write ULTRA2 Object To File
%
% WRITE   Write a ULTRA2 object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteUltra2Log',path)   % write .log file
%             oo = write(o,'WriteUltra2Dat',path)   % write .dat file
%
%          See also: ULTRA2, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteUltra2Log,@WriteUltra2Dat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteUltra2Log(o)        % Write Driver for Ultra2 .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Ultra2 Data
%==========================================================================

function oo = WriteUltra2Dat(o)        % Write Driver for Ultra2 .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
