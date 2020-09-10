function oo = write(o,varargin)        % Write BABASIM Object To File
%
% WRITE   Write a BABASIM object to file.
%
%             oo = write(o,driver,path) % return non-empty if successful
%
%          See also: BABASIM, IMPORT, EXPORT, READ, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@LogData,@WriteBabasimDat);
   oo = gamma(oo);
   oo = launch(oo,launch(o));          % inherit launch function
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Write Driver for Babasim Data
%==========================================================================

function oo = WriteBabasimDat(o)         % Write Driver for Babasim .dat  
   path = arg(o,1);
   oo = write(o,'WriteGenDat',path);
end
