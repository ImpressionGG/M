function obj = trim(obj)
%
% TRIM     Display a TFF object (transfer function)
%
%             G = tff(2,2*[1 2]);
%             G = trim(G);
%
%          See also: TFF
%
   G = data(obj);
   G = tfftrim(G);
   obj = set(tff(G),get(obj));
   
   return
%   