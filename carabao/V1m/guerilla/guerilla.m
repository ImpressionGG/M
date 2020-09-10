function out = guerilla(o,varargin)    % Guerilla Shell                
%
% GUERILLA   Launch a Guerilla Shell utilizing plugin's
%
%               guerilla   % launch guerilla shell
%
%            The following plugin's are utilized:
%
%               sample                 % PLAIN & SIMPLE type objects
%               basis                  % BASIS type objects
%               pbi                    % PBI type objects
%               bqr                    % BQR objects
%               tcb                    % TCB objects
%
   if (nargin == 0)
      o = cigarillo('guerilla');
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
   o = set(o,{'title'},'Guerilla Shell');
   o = set(o,{'comment'},'Log Data Analysis');
   o = opt(o,{'style.labels'},'statistics');
end
function o = Register(o)               % Register Plugins              
   message(o,'Registering Plugins ...');
   sample(o,'Register');               % plugin for SIMPLE type objects
   basis(o,'Register');                % plugin for basis tests
   pbi(o,'Register');                  % plugin for PBI type objects
   bqr(o,'Register');                  % plugin for BQR type objects
   tcb(o,'Register');                  % plugin for TCB type objects
end

