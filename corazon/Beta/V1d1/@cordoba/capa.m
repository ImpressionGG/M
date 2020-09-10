function [Cpk,Cp,sig,avg,mini,maxi] = capa(o,V,spec)
%
% CAPA   Capability number calculation
%
%    Calculate capability number Cpk, potential capability number Cp,
%    standard deviation sig (sigma), average avg, minimum mini and
%    maximum maxi of a data vector V according to spec limits.
%
%       [Cpk,Cp,sig,avg,mini,maxi] = capa(o,V,spec)
%
%    Remark: CAPA will ignore a number of repeats for non-empty option
%            opt(o,'ignore');
%
%    Examples:
%       [Cpk,Cp] = capa(o,1+randn(1,100),3);
%       [Cpk,Cp] = capa(o,1+randn(1,100),[-3 3]);
%       [Cpk,Cp] = capa(o,1+randn(1,100),[-1 4]);
%
%       [Cpk,Cp] = capa(o,1+randn(3,100),[3 3 30]);
%       [Cpk,Cp] = capa(o,1+randn(3,100),[-3 3; -3 3; -30 30]);
%
%    Algorithm:
%
%       spec = [lsl,usl]                       % lower & upper spec limit
%       Cp = (usl-lsl)/(6*sig);                % potential capability number
%       Cpk = min(usl-avg,avg-lsl)/(3*sig);    % capability number
%
%    Copyright(c): Bluenetics 2020 
%
%    See also: CORDOBA
%
   ignore = opt(o,{'ignore',0});       % how many repeats to ignore?
%
% handle ignorance - this is only allowed for length(V(:)) = m*n*r
%
   [m,n,r] = sizes(o);
   r = floor(r);
   
   if (ignore > 0 && o.is(V))
      [mV,nV] = size(V);
      if (length(V(:)) == m*n*r - ignore*m*n)
         'ok';                            % good, no action
      elseif (length(V(:)) == r - ignore) % e.g. for average
         'ok';                            % good, no action
      elseif (length(V(:)) == m*n*r)
         V = reshape(V,m*n,r);
         ignore = min(ignore,size(V,2));  % truncate @ columns of V
         V(:,1:ignore) = [];
         nV = length(V(:))/mV;            % new column size after ignoring
         if (nV == round(nV))             % need an integer column size
            V = reshape(V,mV,nV);         % reshape back to initial row size
         else                             % otherwise error handling!
            V = [];                       % that's how we recover to proceed
         end
      elseif (mV == 1 && length(V(:)) == r)
         V(1:ignore) = [];
      elseif (mV == 1 && length(V(:)) == m*n)
         'no action';
      else
         error('incompatible sizes for data vector (arg2)!');
      end
   end
%
% if V is empty (either passed already as empty matrix or after ignoring
% some repeats we will provide zeroes for output arguments and return
%
   if isempty(V)
      Cp = 0;  Cpk = 0;  sig = 0;  avg = 0;  mini = 0;  maxi = 0;
      return
   end
%
% As we may assume a nonempty V we can calculate statistical results
%
   mini = min(V')';                    % minimum
   maxi = max(V')';                    % maximum
   avg = mean(V')';                    % average
   sig = std(V')';                     % sigma
%
% spec can be empty. In this case Cm and Cmk will be returned with 0 and
% everything has been calculated.
%
   if isempty(spec)
      Cp = 0;  Cpk = 0;
      return                           % we are done!
   end
   
% check dimensional integrity of spec

   [M,N] = size(V);
   [m,n] = size(spec);

   if (n == 0 || n > 2)
      error('spec (arg3) must have 1 or 2 columns');
   end

   if ~(m == 1 || m == M)
      error('spec (arg3) must have 1 row or same number of rows as data vector (arg2)');
   end

% adopt spec according to data vector dimensions

   if size(spec,2) == 1
      spec = [-abs(spec), abs(spec)];
   end
   
   if (size(spec,1) == 1)
      spec = ones(size(V(:,1))) * spec;
   end
   
   [m,n] = size(spec);

% final check of dimensions

   if (m ~= M)
      error('bad dimensions for spec (arg2)!');
   end

   if any(spec(:,2) < spec(:,1))
      error('upper spec limits must be grater equal lower spec limits!');
   end
   
% Calculate mini, maxi, avg, sigma and center values

   lsl = spec(:,1);                       % lower spec limit
   usl = spec(:,2);                       % upper spec limit
   
   Cp = (usl-lsl)./(6*sig);               % potential capability number
   Cpk = min(usl-avg,avg-lsl)./(3*sig);   % capability number
   return
end
