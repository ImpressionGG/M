function obj = sequence(dp,varargin)
%
% SEQUENCE   Sequence modifyer for Discrete Process Object. Create a sequence of
%            discrete process objects
%      
%            seq = sequence(dp,dp1,dp2,dp3,...,dpn)
%
%   See also   DISCO, DPROC

   if (~isa(dp,'dproc'))
      error('arg1: DPROC object expected!'); 
   end

   for (i=1:length(varargin))
      if ~isa(varargin{i},'dproc')
         error(sprintf('arg%g: DPROC object expected!',i+1)); 
      end
   end

% Define default property values

   dat = data(dp);
   dat.type = 'sequence';
   dat.kind = 'sequence';

% set parameters

   dat.list = varargin;

% create class object

   obj.data = dat;
   obj = class(obj,'dproc');  % convert to class object

% eof
