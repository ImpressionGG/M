function [i,j,k] = index(prc,name)
% 
% INDEX  Get indices of a named process element
%      
%             [i,j] = index(prc,name)
%             ij = index(prc,name)
%
%          See also   DISCO, DPROC

   base = key(prc);  % get base for calculating key
   knd = kind(prc);
   k = [];

% check arguments
 
   switch knd
      case 'process'
         lookup = getp(prc,'lookup');
         idx = seek(lookup,name);
         
            % deal with output args

         i = [];  j = [];
         if ~isempty(idx)
            if (nargout <= 1)
               i = idx;
            else
               i = idx(1);  j = idx(2);
               k = base*i+j;   % key
            end
         end

      otherwise
         error('argument must be of kind process, chain or sequence!');
   end

   return
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function idx = seek(lookup,name)
   names = lookup{1};
   index = lookup{2};

   idx = [];
   [m,n] = size(names);
   if ( n < length(name) )
      return              % not found
   end

   name = ones(m,1) * [name, zeros(1,n-length(name))];
   match = all(name'==names');
   fnd = find(match ~= 0);

   if (isempty(fnd)) return; end   % not found
   idx = index(fnd(1),:); 
   return

% eof

