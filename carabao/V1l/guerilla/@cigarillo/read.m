function oo = read(o,varargin)         % Read CIGARILLO Object From File
%
% READ   Read a CIGARILLO object from file.
%
%             oo = read(o,driver,path)
%
%          See also: CIGARILLO, IMPORT, EXPORT, WRITE
%
   [gamma,oo] = manage(o,varargin,@Error,@LogData);
   oo = gamma(oo);
end

function o = Error(o)                  % Default Error Method
   error('two input args expected!');
end

%==========================================================================
% Log Data Read
%==========================================================================

function oo = LogData(o)               % Read Driver for .log File
   path = arg(o,1);                    % fetch path argument
   o = cast(o,'caramel');              % cast to basis class
   oo = read(o,'LogData',path);        % delegate to basis method
end
