function [o1,o2] = variation(o,vtab)
%
% VARIATION   Set specific variations for eigenfrequency and damping of 
%             particular modes. These specific variations act in addition
%             to a global variation.
%
%             1) set variation accordiong to variation table (vtab)
%
%                vtab = [0 0, 1 0.5; 9 12, 1 0.8; 15 24, 1 0.8]
%                variation(o,vtab)     % store variations according to vtab
%
%             2) get effective variations or plot effective variations
%
%                [komega,kzeta] = variation(o)  % get effective variations
%                variation(o)                   % plot effective variations
%
%             the effective variation (for either omega or zeta) is
%             the product of the following 4 variations:
%                * shell variation
%                * package variation
%                * object variation
%                * global variation
%       
%             Remarks:
%             a) Each line in vtab describes a mode range (from ... to) 
%                and variation constants komega,kzeta for omega and zeta
%                variation in the designated range. Lines are processed top
%                down and it is possible that variations in upper lines
%                are redefinedf (overwritten) by definitions in lower
%                lines.
%
%             b) If object (arg1) can be identified by object id as either
%                the shell object or a shell's child object then variation
%                table is permanently stored as 'variation' parameter in
%                the particular shell object or shell's child object
%
%             c) In order that variation gets into effect the according
%                settings must be enabled. The 
%
%             Example 1: (3 column vtab)
%
%                vtab = ...
%                [
%                   0  0,  1  0.5   % omega*1, zeta*0.5 for all modes
%                   9 12,  1  0.8   % omega*1, zeta*0.8 for modes 9:12
%                  15 24,  1  0.8   % omega*1, zeta*0.8 for modes 15:24 
%                ];
%
%             Copyright(c): Bluenetics 2021
%
%             See also: SPM
%
   if (nargin == 1 && nargout > 0)
      [o1,o2] = Variation(o);
   elseif (nargin == 1 && nargout == 0)
      Variation(o);
   elseif (nargin == 2)                % store variation in object params
      Store(o,vtab);
   else
      error('bad args');   
   end
end

%==========================================================================
% Get/Plot Effective Variation
%==========================================================================

function [komega,kzeta] = Variation(o) % Effective Variation
   kzeta = opt(o,{'variation.zeta',1});
   komega = opt(o,{'variation.omega',1});
   
   if ~type(o,{'spm'})
      error('effective variation only for SPM typed objects!');
   end
   
   oo = o;                             % rename object
   o = pull(o);                        % fetch shell object
   
   if (container(oo))
      vsho = get(o,'vtable');
      vpkg = [];  
      vobj = [];
   elseif type(oo,{'pkg'})
      vsho = get(o,'vtable');
      vpkg = get(oo,'vtable');
      vobj = [];
   else   
      vsho = get(o,'vtable');
      vpkg = PackageVariation(o,oo);
      vobj = get(oo,'vtable');
   end
   
   N = length(data(oo,'A'))/2;
   komega = ones(N,1);
   kzeta = ones(N,1);
    
   function vpkg = PackageVariation(o,oo)
      package = get(oo,'package');
      if isempty(package)
         vpkg = [];
      else
         for (i=1:length(o.data))
            oi = o.data{i};
            if isequal(oi.type,'pkg') && isequal(package,get(oi,'package'))
               vpkg = get(oi,'vtable');
               return;
            end
         end
      end
      vpkg = [];
   end
end

%==========================================================================
% Store Variation
%==========================================================================

function Store(o,vtab)
   Check(o,vtab);                      % check consistenccy of vtab
   
   oo = o;                             % rename
   o = pull(o);                        % pull shell object
   
   if container(oo)
      o = set(o,'vtable',vtab);
   else
      ID = id(oo);
      [~,idx] = id(o,ID);              % get child index
      
      if isempty(idx)
         error('object could not be located in shell');
      end
      
      oo = o.data{idx};
      oo = set(oo,'vtable',vtab);
      o.data{idx} = oo;
   end
   
   push(o);                            % push shell object back
end

%==========================================================================
% Check Consistency of Variation Table
%==========================================================================

function Check(o,vtab)                 % Check Vtab Consistency        
   % done
end
