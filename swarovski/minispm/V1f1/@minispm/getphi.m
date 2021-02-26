function [phi,txt,phi_p,phi_o] = getphi(o)
%
% GETPHI  Get actual phi for coordinate transformation
%
%            phi = getphi(o)           % row vector of individual angles
%
%         More detail data
%
%            [phi,txt,phi_p,phi_o]
%
%         phi:    row vector of individual angles
%         phi_o:  object specific phi rotation (scalar or vector)
%         phi_p:  process specific phi (global for all objects)
%         txt:    info text for heading
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM
%
   phi_p = opt(o,{'process.phi',0});   % process phi [°]
   phi_o = get(o,{'phi',0});        % object phi [°]
   Cphi = opt(o,{'process.Cphi',0});

   if type(o,{'pkg'})
      N = length(phi_o);
   elseif type(o,{'spm'})
      N = Pins(o);                     % number of pins
   else
      error('SPM or PKG object expected');
   end
         
      
   if (length(phi_o) == 1)
      phi_o = phi_o * ones(1,N);
   end

      % only center phi correction is considered if delta phi
      % correction is not enabled

   dphi_o = phi_o - mean(phi_o);
   phi_o = mean(phi_o)*ones(1,N) + Cphi*dphi_o; 

   phi = phi_o + phi_p;                  % total phi [°]
   
   txt = 'phi: ['; sep = '';
   for (i=1:length(phi))
      txt = [txt,sep,sprintf('%g',o.rd(phi(i),1))]; sep = ',';
   end
   txt = [txt,']'];
end

function npins = Pins(o)
   [B,C] = data(o,'B,C');
   npins = size(C,1)/3;                % number of pins
   
   if (npins ~= round(npins) || npins ~= size(B,2)/3)
      error('mismatch during extraction of pin number');
   end
end