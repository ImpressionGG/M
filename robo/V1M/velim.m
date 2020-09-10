function V = velim(Vnan)
%
% VELIM     Eliminate all columns with NANs of a vector set.
%
%              V = velim(Vnan)
%
%           See also: ROBO, VCAT, VTEXT, VCHIP
%
   idx = find(isnan(sum(Vnan)));   % dirty trick: sum(.) preserves NANs
   V = Vnan;
   V(:,idx) = [];

% eof