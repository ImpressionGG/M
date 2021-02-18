function oo = contact(o,idx,A,B,C,D)
%
% CONTACT  Return free system with specified contact indices as CORASIM
%          state space object.
%
%             oo = contact(o)          % according to process.contact opt
%             oo = contact(o,0)        % center contact
%             oo = contact(o,-3)       % triple contact
%             oo = contact(o,idx)      % specfied contact indices
%             oo = contact(o,inf)      % multi contact
%
%          Calling syntax to avoid recursion during brew
%
%             oo = contact(o,idx,A,B,C,D)
%
%          Copyright(c): Bluenetics 2021
%
%          See also: SPM
%
   if (nargin < 2)
      idx = opt(o,{'process.contact',0});
   end
   
   if (nargin < 3)
      [A,B,C,D] = cook(o,'A,B,C,D');   % cook SPM matrices
   end
   
   oo = system(corasim,A,B,C,D,0,oscale(o));
   [n,no,ni] = size(oo);
   
   if (no ~= ni)
      error('number of inputs and outputs not matching');
   end
   N = no/3;  M = N;
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
   elseif isequal(idx,-1)              % leading contact
      cdx = (N+1)/2;                   % center index
      if (cdx ~= round(cdx))
         error('no center contact for even article number');
      end
      cdx = 1:cdx;                     % leading indices
   elseif isequal(idx,-2)              % trailing contact
      cdx = (N+1)/2;                   % center index
      if (cdx ~= round(cdx))
         error('no center contact for even article number');
      end
      cdx = cdx:N;                     % first, center and last index
   elseif isequal(idx,-3)              % triple contact
      cdx = (N+1)/2;                   % center index
      if (cdx ~= round(cdx))
         error('no center contact for even article number');
      end
      cdx = [1 cdx N];                 % first, center and last index
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
      
      M = length(kdx)/3;               % overwrite
      
         % overwrite system with contact system
         
      oo = system(corasim,A,B,C,D,0,oscale(o));
   end
   
      % add matrices B_1,B_2,B_3 and C_1,C_2,C_3 to variables
      
         % get indices of 1-2-3 components

   idx1 = 1+3*(0:M-1);
   idx2 = 2+3*(0:M-1);
   idx3 = 3+3*(0:M-1);

   B_1 = B(:,idx1);  B_2 = B(:,idx2);  B_3 = B(:,idx3);
   C_1 = C(idx1,:);  C_2 = C(idx2,:);  C_3 = C(idx3,:);
   oo = var(oo,'B_1,B_2,B_3,C_1,C_2,C_3',B_1,B_2,B_3,C_1,C_2,C_3);
   oo = var(oo,'contact',idx);
   
      % finally inherit options from shell
      
   oo = inherit(oo,o);
end
