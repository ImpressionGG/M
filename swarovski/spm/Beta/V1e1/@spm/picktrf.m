function Gij = picktrf(o,i,j)
%
% PICKTRF Calculate i-j-th transfer function of a MIMO system
%
%            Gij = picktrf(cuo,i,j);
%
%         Note: Gij is a class TRF object
%
%         See also: SPM
%
   if isempty(var(o,'G'))
      o = brew(o,'TrfMatrix');
   end
   
   G = var(o,'G');                     % access transfer matrix
   
   numden = G{i,j};
   Gij = trf(numden{1},numden{2});
   Gij = can(Gij);
end
