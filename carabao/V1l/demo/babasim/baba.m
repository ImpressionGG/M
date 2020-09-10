function out = baba(o,varargin)        % Launch BaBaSimSim Shell                
%
% BABA   Launch a BaBaSimSim Shell utilizing plugin's
%
%               baba                   % launch BabaSimSim shell
%
%            The following plugin's are utilized:
%
%               sample                 % PLAIN/SIMPLE type objects
%               basis                  % VIBRATION/BMC type objects
%
   if (nargin == 0)
      o = babasim('baba');
   end

   [gamma,oo] = manage(o,varargin,@Shell,@Register,@File);
   if (nargout >= 1)
      out = gamma(o);
   else
      gamma(o);
   end
end

%==========================================================================
% Shell Setup
%==========================================================================

function o = Shell(o)                  % Setup Guerilla Shell          
   o = Init(o);
   
   o.profiler([]);                     % init profiler
   o = shell(o);
   
   Register(o);   
   rebuild(o);
end
function o = Init(o)                   % Init Guerilla Shell Object    
   o = set(o,{'title'},'BaBa SimSim Shell');
   o = set(o,{'comment'},'Log File Management');
   o = opt(o,{'style.labels'},'statistics');
end
function o = Register(o)               % Register Plugins              
   message(o,'Registering Plugins ...');
   sample(o,'Register');               % plugin for SAMPLE type objects
   basis(o,'Register');                % plugin for basis tests
   %pbi(o,'Register');                 % plugin for PBI type objects
   %dana(o,'Register');                % plugin for DANA type objects
   %tcb(o,'Register');                 % plugin for TCB type objects
end

