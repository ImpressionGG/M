function oo = system(o,cdx)
%
% SYSTEM  Create a CORASIM state space system from an SPM object according
%         to selected contact points.
%
%            oo = system(o,cdx)     % system due to contact indices
%            oo = system(o)         % system due to 'process.contact' opts
%
%         All calculations are live and without consultation of the cache!
%         (takes about 20...100ms for an order 200 system)
%
%         1) retrieve open loop SPM system matrices after variation, time
%         normalization, coordinate transformation and contact based se-
%         lection
%
%            oo = system(o,cdx)     % system due to contact indices
%            [A,B,C,D] = var(oo,'A,B,C,D');   % system matrices
%            T0 = var(oo,'T0');               % scaling constant
%
%         2) Retrieve basis matrices for L0(s and lambda(s) calculation,
%         and subsequent critical quantities (K0,f0,K180,f180) calculation
%
%            oo = system(o,cdx)     % system due to contact indices
%            [A,B_1,B_3,C_3] = var(oo,'A,B_1,B_3,C_3');
%
%            Phi(s) = inv(s*I-A)
%            G31(s) = C_3*Phi(s)*B_1
%            G33(s) = C_3*Phi(s)*B_3
%            L0(s)  = G33(s)\G31(s)
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, CONTACT, CONSTRAIN
%
   if ~type(o,{'spm'})
      oo = [];
      return
   end
   
   if (nargin < 2)                     % then retrieve contact indices
      cdx = opt(o,{'process.contact',inf});
   end
   
   oo = Variation(o);                  % apply system variation
   oo = Normalize(oo);                 % normalize system
   oo = Transform(oo);                 % coordinate transformation
   
   [A,B,C,D] = var(oo,'A,B,C,D');      % get transformed system matrices
   oo = contact(oo,cdx,A,B,C,D);       % calc free system regarding contact 
   
   oo = inherit(oo,o);                 % inherit options
end

%==========================================================================
% Helper
%==========================================================================

function oo = Variation(o)             % System Variation              
   oo = brew(o,'Variation');           % apply system variation
end
function oo = Normalize(o)             % Normalize System              
   oo = brew(o,'Normalize');           % apply system normalization
end
function oo = Transform(o)             % coordinate transformation     
   oo = brew(o,'Transform');           % apply system transformation                        
end
