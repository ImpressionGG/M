function [Gs,Ts] = tffstf(G)
%
% TFFSTF  S-transformation.
%
%            [Gs,Ts] = tffstf(Gq)
%            [Gs,Ts] = tffstf(Gz)
%
%         Gs = STF(Gq) converts a q type transfer function or a z type
%         transfer function into an s type transfer function. 
%         In addition [Gs,Ts] = tffstf(Gq) returns the sampling intervall. 
%
%	  See TFFNEW, TFFQTF, TFFZTF.
%

   [class,kind] = ddmagic(G);

   if ( kind == 2 )			      % z type
      Gz = tffcan(G);
   elseif ( kind == 3 )		              % q type
      Gz = tffcan(tffztf(G));
   else
      error('bad transfer function type');
   end

   Ts = Gz(2,1);

   m = max(size(Gz));
   n = m-2;

   num = Gz(1,2:m);
   den = Gz(2,2:m);
   den = den / den(1);

   Phi = [zeros(n-1,1),eye(n-1,n-1); -den(n+1:-1:2)];
   h = [zeros(n-1,1); 1];
   d = num(1);
   c = num(n+1:-1:2) - d*den(n+1:-1:2);

   [A,b] = d2c(Phi,h,Ts);

   Gs = tffnew(A,b,c,d);

% eof
