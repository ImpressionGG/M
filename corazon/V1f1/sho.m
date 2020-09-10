function o = sho
%
% SHO   Shell Object: Get (current) shell object: pulls shell object from
%       current shell
%
%          o = sho     % same as o = pull(corazon)
%
%       Remark: use 'sho' only in the command console! In program code use
%       method 'pull' instead:
%
%          oo = pull(corazon)          % same as: oo = sho
%
%       Copyright(c): Bluenetics 2020
%
%       See also: CORAZON, PULL, CURRENT
%
   o = pull(corazon);
end
