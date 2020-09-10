function obj = can(obj,epsi)
%
% CAN      Cancel a TFF object (transfer function)
%
%             G = tff([2 4],2*[1 2]);
%             G = can(G);
%             G = can(G,epsi);
%
%          See also: TFF, TRIM, DSP
%
   G = data(obj);
   if (nargin < 2)
      G = tffcan(G);
   else
      G = tffcan(G,epsi);
   end
   obj = tff(G);
   
   return
%   