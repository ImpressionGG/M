function y = rsp(o,u,t)
%
% RSP      Calculate response of a TRF object to a given input function
%
%             G = trf([2 4],2*[1 2]);
%             t = 0:20;
%             u = ones(size(t));
%             y = rsp(G,u,t);
%
%          See also: TRF, STEP
%
   G = data(o);
   if (nargin == 2)
      y = tffrsp(G,u);
   elseif (nargin == 3)
      y = tffrsp(G,u,t);
   else
      error('2 or 3 input args expected!');
   end
end
