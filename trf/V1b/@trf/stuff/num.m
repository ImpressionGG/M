function p = num(obj)
%
% NUM      Numewrator of a TFF object (transfer function)
%
%             G = tff([2 4],2*[1 2]);
%             p = num(G);
%
%          See also: TFF, TRIM, DSP, NUM, DEN
%
   G = data(obj);
   p = tffnum(G);
   
   return
%   