function o = sho(o)
%
% SHO   Shell Object: Get (current) shell object: pulls shell object from
%       current shell
%
%          o = sho                     % same as o = pull(corazon)
%          oo = sho(oo)                % inherit shell options to oo
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
   if (nargin == 0)
      o = pull(corazon);
   else
      so = sho;                        % pull shell object
      
      if isempty(so)
         return                        % return without inheriting
      end
      
      o = inherit(o,so);               % inherit shell settings as options
      o = opt(o,'inherit',true);       % additionally set inherit option
   end
end
