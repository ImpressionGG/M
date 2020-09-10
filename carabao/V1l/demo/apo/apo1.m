function oo = apo1(o,varargin)         % APO (Version #1)              
%
% APO1   Automatic Position Optimization (Version #1)
%
%           apo1;                      % launch APO1 shell
%
%        First steps:
%           - provide a package initializer & package manager
%           - provide a tiny shell
%           - provide a 'Study' menu
%
%        See also: TRACE
%
   if (nargin == 0)                    % need to init object?
      o = carma(mfilename);            % create a CARMA object
   end
   [gamma,oo] = manage(o,varargin,@Shell);
   oo = gamma(o);                      % dispatch to managed function
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Shell Setup                   
   o = menu(o,'Begin');                % begin menu setup
   oo = Study(o);                      % add Study menu
   o = menu(o,'End');                  % end menu setup
end

%==========================================================================
% Study Menu
%==========================================================================

function oo = Study(o)                 % Study Menu                    
   oo = mhead(o,'Study');              % create new menu
   ooo = mitem(oo,'Create Sample',{@CreateSample});
   ooo = mitem(oo,'Plot Sample',{@PlotSample});
end
function o = CreateSample(o)           % Create Sample Callback        
   message(o,'Create Sample');
end
function o = PlotSample(o)             % Plot Sample Callback          
   message(o,'Plot Sample');
end
