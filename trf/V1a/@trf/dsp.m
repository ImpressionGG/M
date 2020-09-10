function dsp(o,txt)
%
% DSP      Display a TFF object (transfer function)
%
%             G = tff(1,[1 2]);
%             dsp(G1);
%             dsp(G1,'txt');
%
%          See also: TFF, PLUS, MINUS, TIMES, RDIVIDE
%
   G = data(o);
   
   if ~isempty(G) && isa(G,'double')
      if (nargin < 2)
         txt = get(o,'title');
      end

      if (~isempty(txt))
         fprintf(['\n',txt,'\n']);
      end
      tffdisp(G);
   else
      disp(o);
   end
   return
%   