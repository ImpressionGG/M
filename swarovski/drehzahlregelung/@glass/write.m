function oo = write(o,varargin)        % Write GLASS Object To File
%
% WRITE   Write a GLASS object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%             oo = write(o,'WriteGlassLog',path)   % write .log file
%             oo = write(o,'WriteGlassDat',path)   % write .dat file
%
%          See also: GLASS, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@WriteGlassLog,@WriteGlassDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Log Data
%==========================================================================

function oo = WriteGlassLog(o)        % Write Driver for Glass .log  
   path = arg(o,1);
   oo = write(o,'WriteLogLog',path);
end

%==========================================================================
% Write Driver for Glass Data
%==========================================================================

function oo = WriteGlassDat(o)        % Write Driver for Glass .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
