function obj = chain(dp,varargin)
%
% CHAIN   Chain modifyer for Discrete Process Object. Create a sequence of
%         discrete process objects
%      
%            chn = chain(dp,dp1,dp2,dp3,...,dpn)
%            chn = chain(dp,{dp1,dp2,dp3,...,dpn})
%
%         See also: DPROC, PROCESS

   if (~isa(dp,'dproc'))
      error('arg1: DPROC object expected!'); 
   end
   
   list = varargin;
   if length(list) == 1 && iscell(list{1})
      list = list{1};
   end

   for (i=1:length(list))
      if ~isa(list{i},'dproc')
         error(sprintf('arg%g: DPROC object expected!',i+1)); 
      end
   end

% Define default property values

   dat = data(dp);
   dat.type = 'chain';
   dat.kind = 'chain';

% set parameters

   dat.list = list;

% create class object

   obj.data = dat;
   obj.work = [];             % work properties
   obj = class(obj,'dproc');  % convert to class object
end
