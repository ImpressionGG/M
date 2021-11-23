function [o,kid,fig] = objid(o,n)
%
% OBJID   Set/get object ID, which encorporates a figure part and a
%         children part (vhild number n).
%
%            id = objid(o);            % get object ID
%            [id,kid,fig] = objid(o);  % get also child ID and figure part
%            o = objid(o,n);           % set object ID for n-th child
%
%         Copyright(c): Bluenetics 2020
%
%         See also: CORAZON, CONTAINER, ADD
%
   if (nargin == 1)
      id = work(o,'id');
      if isempty(id)
         kid = [];  fig = figure(o);
      else
         kid = floor(id);
         fig = (id-kid)*1000;
      end
      o = id;                          % rename out arg
   elseif (nargin == 2)
      fig = figure(o);
      if isempty(fig)
         error('empty figure handle');
      end
      
      if ~isa(n,'double') || floor(n) ~= n || n < 0
         error('n (arg2) must be a non-negative integer');
      end
      
      id = n + double(fig)/1000;
      o.work.id = id;
   else
      error('max 2 input args expected');
   end
end
