function oo = contact(o,idx)
%
% CONTACT  Return free system with specified contact indices as CORASIM
%          state space object.
%
%             oo = contact(o)          % according to process.contact opt
%             oo = contact(o,0)        % center contact
%             oo = contact(o,idx)      % specfied contact indices
%             oo = contact(o,inf)      % multi contact
%
%          Copyright(c): Bluenetics 2021
%
%          See also: SPM
%
   if (nargin < 2)
      idx = opt(o,{'process.contact',0});
   end
   
   [A,B,C,D] = cook(o,'A,B,C,D');      % cook SPM matrices
   
   oo = system(corasim,A,B,C,D,0,oscale(o));
   [n,no,ni] = size(oo);
   
   if (no ~= ni)
      error('number of inputs and outputs not matching');
   end
   N = no/3;
   if (N ~= round(N))
      error('input/output number not a multiple of 3');
   end
   
   if isinf(idx)
      cdx = [];                        % multi contact
   elseif isequal(idx,0)               % center contact
      cdx = (N+1)/2;
      if (cdx ~= round(cdx))
         error('no center contact for even article number');
      end
   else
      cdx = idx;
      if (any(cdx<1) || any(cdx>N))
         error('not all indices (arg2) in range');
      end
   end
   
      % contact index (cdx) is either empty or it indexs B-columns
      % and C-rows to pick
      
   if ~isempty(cdx)
      kdx = [];
      for (i=1:N)
         if any(i==cdx)
            kdx = [kdx,(3*(i-1)+1):(3*(i-1)+3)];
         end
      end
      
      assert(~isempty(kdx));
      B = B(:,kdx);
      C = C(kdx,:);
      D = D(kdx,kdx);
      
         % overwrite system with contact system
         
      oo = system(corasim,A,B,C,D,0,oscale(o));
   end
      
   oo = inherit(oo,o);
end
