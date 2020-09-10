function obj = process(dp,varargin)
%
% PROCESS    Process modifyer for Discrete Process Object. Create a processe of
%            discrete process CHAIN objects
%      
%            prc = process(dp,ch1,ch2,ch3,...,chn)
%
%   See also   DISCO, DPROC

   if (~isa(dp,'dproc'))
      error('arg1: DPROC object expected!'); 
   end

   for (i=1:length(varargin))
      if ~isa(varargin{i},'dproc')
         error(sprintf('arg%g: DPROC object expected!',i+1)); 
      end
      if ~strcmp(kind(varargin{i}),'chain')
         error(sprintf('arg%g: DPROC chain object expected!',i+1)); 
      end
   end

% Define default property values

   dat = data(dp);
   dat.type = 'process';
   dat.kind = 'process';
   dat.baseline = [];
   dat.baseskip = 0.5;
   dat.period = [];
   dat.initial = {};
   dat.start = [];
   dat.stop = [];
   dat.threads = {};
   dat.critical = {};
   dat.fontsize = 8;

% set parameters

   dat.list = varargin;

% create assoc list for indices

   k = 1;
   for (i=1:length(dat.list))
      ch = dat.list{i};
      chain = getp(ch,'list');
      for (j=1:length(chain))
         nam = name(chain{j});
         names(k,1:length(nam)) = nam;
         index(k,1:2) = [i,j];
         k = k+1;
      end
   end
   dat.lookup = {names,index};
   dat.sizes = [max(index(:,1)),max(index(:,2))];
   
% create class object

   obj.data = dat;
   obj.work = [];             % work properties
   obj = class(obj,'dproc');  % convert to class object

% eof
