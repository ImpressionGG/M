function phi = angle(o,Gjw,mode)
%
% ANGLE   Calculate angle of a frequency response according to specific
%         mode. The rows of Gjw (arg2) represent the sequences of frequency
%         responses.
%
%            phi = angle(o,Gjw)                  % no 'jumps'
%            phi = angle(o,Gjw,k0)               % no 'jumps'
%            phi = angle(o,Gjw,'Continuous')     % no 'jumps'
%
%            phi = angle(o,Gjw,'Negative')       % map to [-2*pi,0]
%            phi = angle(o,Gjw,'Symmetric')      % map to [-pi,+pi]
%            phi = angle(o,Gjw,'Positive')       % map to [0,+2*pi]
%
%         Copyright(c): Bluenetics 2021
%
%         See also: SPM, LAMBDA, PSION
%
   if (nargin == 3 && isa(mode,'double'))
      phi = Continuous(o,Gjw);
      k0 = mode;
      phi = Offset(phi,k0);
      return
   end
   
   switch mode
      case 'Continuous'
         phi = Continuous(o,Gjw);
      case 'Negative'
         phi = mod(angle(Gjw),2*pi) - 2*pi;
      case 'Symmetric'
         phi = mod(angle(Gjw)+pi,2*pi) - pi;
      case 'Positive'
         phi = mod(angle(Gjw),2*pi);
      otherwise
         error('bad mode');
   end
end

%==========================================================================
% Helper
%==========================================================================

function phi = Continuous(o,Gjw)
   [m,n] = size(Gjw);
   phi = mod(angle(Gjw),2*pi) - 2*pi;
   
   for (i=1:m)
      dphi = diff(phi(i,:));
      idx = find(abs(dphi)>pi);
      
      for (j=1:length(idx))
         k = idx(j);                   % index with jump
         if (dphi(k) > 0)
            phi(i,k+1:end) = phi(i,k+1:end) - 2*pi;
         else
            phi(i,k+1:end) = phi(i,k+1:end) + 2*pi;
         end
      end
   end
end
function phi = Offset(phi,k0)
   if isempty(k0)
      return
   end
   
   phi0 = phi(:,k0);
   for (i=1:length(phi0))
      while (phi0(i) > 0)
         phi0(i) = phi0(i) - 2*pi;
         phi(i,:) = phi(i,:) - 2*pi;
      end
      while (phi0(i) < -2*pi)
         phi0(i) = phi0(i) + 2*pi;
         phi(i,:) = phi(i,:) + 2*pi;
      end
   end
end