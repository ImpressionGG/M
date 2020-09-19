function varargout = reduce(o,varargin)
%
% REDUCE  Reduce number of points of a graph to be plotted. Either returns
%         reduced data or index for subsequent reduction
%
%            idx = reduce(o,t)              % index for 1 out arg
%
%            [t,x,y] = reduce(o,t,x,y);     % reduction for > 1 out args
%
%         Options:
%
%            simu.plot       max data points to be plotted (default: inf)
%            simu.tmax       max simulation time
%            simu.dt         simulation time
%
%         The behavior of reduce is fully controlled by the three options
%         plot, tmax and dt. Option plot can have any positive value > 0
%         and alternatively the value inf.
%
%         If plot==inf then no reduction will happen, input/output data
%         vectors will be the same, and reduction index vector is
%         1:length(t).
%
%         For plot<inf the reduction algorithm is as follows
%
%            1) calculate an index-delta: delta = floor(tmax/dt)
%            2) for delta > dt the reduction index is calculated in one of
%               the following two ways:
%
%                  a) idx = [1:delta:length(tmax)]
%                  b) idx = [1:delta:length(tmax) length(tmax)]
%
%               where the subsequent reduction is t=t(idx), x=x(idx), ... 
%
%            3) for delta <= dt no reduction is applied
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORASIM, STEP, PLOT
%
   if ~((nargin==2 && nargout <= 1) || (nargin == 1+nargout))
      error('bad number of input/output args');
   end
   
   idx = [];                           % default: empty
   t = varargin{1};
   
   dt = opt(o,'simu.dt');
   plot = opt(o,'simu.plot');
      
   if ~isempty(dt) && ~isempty(plot) && (dt < max(t)/plot)
      n = length(t);
      delta = floor(n/plot);
      if (~isempty(delta) && delta >= 1)
         idx = 1:delta:n;
         if (length(idx) > 0 && idx(end) ~= n)
            idx(end+1) = n;
         end
      end
   end
   
      % set output args
      
   if (nargout <= 1)
      varargout{1} = idx;              % return idx
   elseif isempty(idx)
      for (i=1:length(varargin))
         varargout{i} = varargin{i};
      end
   else
      for (i=1:length(varargin))
         d = varargin{i};              % data stream
         varargout{i} = d(:,idx);      % replace by reduced subset
      end
   end
end
