function q = den(obj)
%
% DEN      Denominator of a TFF object (transfer function)
%
%             G = tff([2 4],2*[1 2]);
%             q = den(G);
%
%          See also: TFF, TRIM, DSP, NUM, DEN
%
   G = data(obj);
   q = tffden(G);
   
   return
%   