function om = orange(o,oml,omh,points)
%
% ORANGE  Set omega range / get omega vector
%
%            om = orange(o)            % omega range based in omega options
%            om = orange(o,oml,omh)    % omega range based on explicit args
%            om = orange(o,oml,omh,n)  % provide also number of pints
%
%      Options:
%         omega.low          low value of omega range (default 1e-5)
%         omega.high         high value of omega range (default 1e5)
%         omega.points       number of points of omega range (default 1000)
%         oscale             omega scaling factor (default 1)
%
%         See also CORASIM, FQR, BODE, NYQ
%
   if (nargin < 2)
      oml = opt(o,{'omega.low',1e-5});
   end
   if (nargin < 3)
      omh = opt(o,{'omega.high',1e5});
   end
   if (nargin < 4)
      points = opt(o,{'omega.points',1000});
   end
   
   om = logspace(log10(oml),log10(omh),points);
end
