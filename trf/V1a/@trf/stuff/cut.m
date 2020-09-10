function omega = cut(G,omin,omax)
%
% CUT      Calculate cutoff frequency of a transfer function
%
%             omega = cut(Ps,omin,omax)
%             omega = cut(Ps)           % use defaults for omin,omax
%
%          See also: TFF, FQR
%
   if (nargin < 2)
      omin = 1e-10;
   end
   
   if (nargin < 3)
      omax = 1e+10;
   end
   
   logom = log(omin):0.01:log(omax);
   omega = exp(logom);
   
   mgn = fqr(G,omega);
   
      % determine cut off frequency
      
   idx = find(mgn < 1/sqrt(2));
   omh = min(omega(idx));
   oml = omh/1.1;

   mgn = fqr(G,[oml,omh]);
   
   if (mgn(1) < 1/sqrt(2) || mgn(2) > 1/sqrt(2))
      error('cannot proceed!');
   end
   
   for (i = 1:50)
      om = sqrt(oml*omh);
      mgn = fqr(G,om);
      if (mgn > 1/sqrt(2))
         oml = om;
      elseif(mgn < 1/sqrt(2))
         omh = om;
      else
         break;
      end
   end
         
   omega = om;
   return
   
   