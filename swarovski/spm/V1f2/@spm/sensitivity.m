function [modes,dB] = sensitivity(o,omega)
%
% SENSITIVITY Calculate mode sensitivity: analyse all mode numbers with
%             respect to magnitude sensitivity in the critical frequency 
%             region and return modenumber and according dB values sorted
%             by greatest sensitivity.
%
%                [modes,dB] = sensitivity(o)
%             
%             Copyright(c) Bluenetics 2021
%
%             See also: SPM
%
   if (nargin < 2)
      olo = opt(o, {'omega.low',100});
      ohi = opt(o,{'omega.high',1e5});
      points = opt(o,{'omega.points',2000});

      omega = logspace(log10(olo),log10(ohi),points);
   end
   
   sys = system(o);
   [A,B_1,B_3,C_3,T0] = var(sys,'A,B_1,B_3,C_3,T0');
   Om = T0*omega;
   
      % one way to calculate the lambda frequency response would be 
      % via system matrice, which, however, we do not chose.
      
%  l0jw = lambda(o,A,B_1,B_3,C_3,T0*omega);

      % More over we calculate frequency responbse via psion representa-
      % tion, sincewe have to do this calculation hundreds of time

   PsiW31 = psion(o,A,B_1,C_3); % to calculate G31(jw)
   PsiW33 = psion(o,A,B_3,C_3); % to calculate G33(jw)
   l0jw = lambda(o,PsiW31,PsiW33,Om);

 
if (nargout == 0)
   cls(o);
   oo = Fqr(o,l0jw,Om);
   bode(oo,'ryyy');
   hold on;
 end
   
   
   for (i=1:100)
      l0jwi = lambda(o,PsiW31,PsiW33,Om);
      oo = Fqr(o,l0jwi,Om);
      bode(oo,'kw');
      fprintf('%g\n',i);
   end
   
   modes = l0jw;  dB = l0jwi;
end

%==========================================================================
% Helper
%==========================================================================

function oo = Fqr(o,Gjw,om)            % create fqr transfer function
   F = {};
   for (i=1:size(Gjw,1))
      F{1,1} = Gjw(i,:);
      oo = fqr(corasim,om,F);
   end
   
end
